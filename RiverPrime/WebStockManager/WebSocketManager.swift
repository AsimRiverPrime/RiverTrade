
import Foundation
import Starscream
import Network
import SystemConfiguration

enum SocketMessageType {
    case tick
    case Unsubscribed
}

// MARK: - Network Status Enum
enum NetworkStatus {
    case available
    case unavailable
    case unknown
}

protocol GetSocketData: AnyObject {
    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?)
}

protocol GetSocketMessages: AnyObject {
    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?)
}

protocol GetCandleData: AnyObject {
    func tradeHistoryUpdates(socketMessageType: SocketMessageType, historyMessage: SymbolChartData?)
}

protocol SocketPeerClosed: AnyObject {
    func peerClosed()
}

protocol SocketConnectionInitDelegate: AnyObject {
    func SocketConnectionInit()
}

protocol SocketNotSendDataDelegate: AnyObject {
    func socketNotSendData()
}

protocol StartOffLineDataDelegate: AnyObject {
    func startOfflineData()
}

class WebSocketManager: WebSocketDelegate {

    var webSocket: WebSocket?
    static let shared = WebSocketManager() // Shared instance
    
    var connectionCheckTimer: Timer?
    
    var isConnectionStable: Timer?
    var connectionCount = 0

    public weak var delegateSocketData: GetSocketData?
    public weak var delegateCandleSocketMessage: GetCandleData?
    public weak var delegateSocketPeerClosed: SocketPeerClosed?
    public weak var delegateSocketConnectionInit: SocketConnectionInitDelegate?
    public weak var delegateSocketNotSendData: SocketNotSendDataDelegate?
    public weak var delegateStartOffLineData: StartOffLineDataDelegate?
    
    var isTradeDismiss = Bool()

    var reconnectAttempts = 0
    
    private var retryCount = 0
    private let maxRetryCount = 3
    
    private let webSocketQueue = DispatchQueue(label: "webSocketQueue", qos: .background)
    
    // MARK: - Network Monitoring Properties
    private var networkMonitor: NWPathMonitor?
    private var networkStatus: NetworkStatus = .unknown {
        didSet {
            handleNetworkStatusChange()
        }
    }
  
    private init() {
        setupNetworkMonitoring()
//        setupApplicationStateObservers()
    }
    
    deinit {
        cleanup()
    }
    
    var trades: [String: TradeDetails] = [:] {
        didSet {
            NotificationCenter.default.post(name: .tradesUpdated, object: nil)
        }
    }
    var symbolData: [String: SymbolChartData] = [:] {
        didSet {
            NotificationCenter.default.post(name: .symbolDataUpdated, object: nil)
        }
    }
    
    private func startConnectionCheckTimer() {
        // Invalidate existing timer
        connectionCheckTimer?.invalidate()
        connectionCheckTimer = nil
        
        // Create a new timer with the current interval
        connectionCheckTimer = Timer.scheduledTimer(timeInterval: GlobalVariable.instance.socketTimer, target: self, selector: #selector(checkConnection), userInfo: nil, repeats: true)
    }
    
    private func isConnectionStableTimer() {
        // Invalidate existing timer
        isConnectionStable?.invalidate()
        isConnectionStable = nil
        
        // Create a new timer with the current interval
        isConnectionStable = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(isConnectionStbl), userInfo: nil, repeats: true)
    }
    
    @objc private func isConnectionStbl() {
        
        connectionCount += 1
        
        if connectionCount > 3 {
            connectionCount = 0
            delegateStartOffLineData?.startOfflineData()
        }
    }
    
    // MARK: - Cleanup
    private func cleanup() {
//        stopAllTimers()
        networkMonitor?.cancel()
        webSocket?.disconnect()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Network Monitoring Setup
    private func setupNetworkMonitoring() {
        networkMonitor = NWPathMonitor()
        
        networkMonitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let newStatus: NetworkStatus = path.status == .satisfied ? .available : .unavailable
                if self?.networkStatus != newStatus {
                    self?.networkStatus = newStatus
                }
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor?.start(queue: queue)
        
        // Initial network status check
        checkInitialNetworkStatus()
    }
    
    private func checkInitialNetworkStatus() {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            networkStatus = (isReachable && !needsConnection) ? .available : .unavailable
        }
    }
    
    private func handleNetworkStatusChange() {
        print("🌐 Network status changed to: \(networkStatus)")
        
        switch networkStatus {
        case .available:
            print("✅ Network is available")
            if !isSocketConnected() /*&& !isManualDisconnection*/ {
                print("🔄 Network recovered, attempting to reconnect...")
                // Reset reconnect attempts when network comes back
                reconnectAttempts = 0
                connectWebSocket()
            }
        case .unavailable:
            print("❌ Network is unavailable")
            if isSocketConnected() {
                print("📱 Disconnecting due to network unavailability")
                // Don't call DisconnectWebSocket as it will trigger reconnection
                GlobalVariable.instance.isConnected = false
                DisconnectWebSocket()
                delegateSocketPeerClosed?.peerClosed()
                
                NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "false"])
            }
        case .unknown:
            break
        }
    }

    @objc private func checkConnection() {
        if isSocketConnected() {
            print("WebSocket is connected.")
        } else {
            print("WebSocket is disconnected.")
        }
        
        GlobalVariable.instance.socketTimerCount += 1
        
        if GlobalVariable.instance.socketTimerCount > 3 {
            return
        }
        
        print("GlobalVariable.instance.socketTimerCount = \(GlobalVariable.instance.socketTimerCount)")
        print("GlobalVariable.instance.socketTimer = \(GlobalVariable.instance.socketTimer)")
        
        DisconnectWebSocket()
        connectWebSocket()
        
        //MARK: - Save symbol local to unsubcibe.
        sendWebSocketMessage(for: "unsubscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList, isTradeDismiss: true)
        //MARK: - START calling Socket message from here.
        sendWebSocketMessage(for: "subscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList)
    }

    // Check if the socket is connected
    func isSocketConnected() -> Bool {
        return GlobalVariable.instance.isConnected
    }

    func connectWebSocket() {
//        let url = URL(string: "wss://mbe.riverprime.com/mobile_web_socket")!

        let url = URL(string: "ws://18.116.153.208:8074")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
    }
    
    func ConnectWebSocket() {
        if !isSocketConnected() {
            webSocket?.connect()
        }
    }

    func DisconnectWebSocket() {
        if isSocketConnected() {
            webSocket?.disconnect()
            webSocket = nil
        }
    }
    
    private func attemptReconnect() {
        if isSocketConnected() {
            reconnectAttempts += 1
            let retryDelay = min(Double(reconnectAttempts) * 2, 30) // Exponential backoff capped at 30 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) { [weak self] in
                guard let self = self else { return }
                print("Attempting to reconnect... Attempt \(self.reconnectAttempts)")
                self.webSocket?.disconnect()
//                self.webSocket?.connect()
                connectWebSocket()
            }
        }
    }

    func sendWebSocketMessage(for event: String, symbol: String? = nil, symbolList: [String]? = nil, isTradeDismiss: Bool? = nil) {
        let (currentTimestamp, hourBeforeTimestamp) = getCurrentAndNextHourTimestamps()
        
        let timestamps = currentAndBeforeBusinessDayTimestamps()

        var message: [String: Any] = [:]
        
        // Prepare message based on event type (trade or history)
        if event == "subscribeTrade" {
            
            if symbolList != nil {
                message = [
                    "event_name": "subscribe",
                    "data": [
                        "last": 0,
    //                    "channels": ["price_feed"]
                        "channels": symbolList ?? [""] //["Gold","Silver"]
                    ]
                ]
            } else {
                message = [
                    "event_name": "subscribe",
                    "data": [
                        "last": 0,
    //                    "channels": ["price_feed"]
                        "channels": [symbol ?? ""] //["Gold","Silver"]
                    ]
                ]
            }
        } else if event == "subscribeHistory" {
       
        } else if event == "unsubscribeTrade" {
            
            self.isTradeDismiss = isTradeDismiss ?? false
            
            message = [
                "event_name": "unsubscribe",
                "data": [
                    "last": 0,
                    "channels": symbolList ?? [""]
                ]
            ]
        }

        // Send the prepared message to the WebSocket
        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            webSocketQueue.async {
                if let webSocket = self.webSocket {
                    webSocket.write(string: jsonString)
                    print("Message sent to WebSocket: \(event)")
                } else {
                    print("WebSocket is not connected.")
                }
            }
        }
    }

    
    // WebSocket delegate method
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
//            print("WebSocket is connected: \(headers)")
            GlobalVariable.instance.isConnected = true // Update connection state
            reconnectAttempts = 0

            //MARK: - This Check is handle for Offline data.
            if !GlobalVariable.instance.socketNotSendData {
                self.delegateSocketConnectionInit?.SocketConnectionInit()
            }
            
            NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "true"])
            
//            delegateStartOffLineData?.startOfflineData()
           
        case .text(let string):
            // Invalidate any existing timer
            connectionCheckTimer?.invalidate()
            connectionCheckTimer = nil
//            startConnectionCheckTimer()
            handleWebSocketMessage(string)

        case .disconnected(let reason, let code):
            print("WebSocket is disconnected: \(reason) with code: \(code)")
            GlobalVariable.instance.isConnected = false // Update connection state
            attemptReconnect()

            NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "false"])
            
            delegateSocketPeerClosed?.peerClosed()
            
        case .error(let error):
            handleError(error)
            attemptReconnect()
            
            NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "false"])
            
            delegateSocketPeerClosed?.peerClosed()
            
        case .peerClosed:
            
            print("peerClosed...")
            
            delegateSocketPeerClosed?.peerClosed()
            
            break
            
        case .cancelled:
            print("WebSocket cancelled... reconnect again")
//            connectWebSocket()
//            connectHistoryWebSocket()
            attemptReconnect()

        default:
            print("WebSocket received an unhandled event: \(event)")
            
            connectionCount = 0
            isConnectionStableTimer()
          
        }
    }
    
    
    func filterSymbolsBySector(symbols: [SymbolData], sector: String) -> [String] {
        return symbols.filter { $0.sector == sector }.map { $0.displayName }
    }
    
    private func setTradeModel(collectionViewIndex: Int) {
        let symbols = GlobalVariable.instance.symbolDataArray
        let sectors = GlobalVariable.instance.sectors
        
        GlobalVariable.instance.filteredSymbols.removeAll()
        GlobalVariable.instance.filteredSymbolsUrl.removeAll()
        
        // Populate filteredSymbols and filteredSymbolsUrl for each sector
        for sector in sectors {
            let filteredSymbols = filterSymbolsBySector(symbols: symbols, sector: sector.sector)
            
            GlobalVariable.instance.filteredSymbols.append(filteredSymbols)
        }
        
        // Append trades for the selected collectionViewIndex
        let selectedSymbols = GlobalVariable.instance.filteredSymbols[safe: collectionViewIndex] ?? []
        let selectedUrls = GlobalVariable.instance.filteredSymbolsUrl[safe: collectionViewIndex] ?? []
        
       // print("GlobalVariable.instance.filteredSymbolsUrl = \(GlobalVariable.instance.filteredSymbolsUrl)")
        
        //MARK: - Save symbol local to unsubcibe.
        GlobalVariable.instance.previouseSymbolList = selectedSymbols
        
        sendWebSocketMessage(for: "subscribeTrade", symbolList: selectedSymbols)
    }
    // Handle the WebSocket message
    func handleWebSocketMessage(_ string: String) {
        if let jsonData = string.data(using: .utf8) {
            do {
              
                var myType = ""
                
                // Deserialize JSON data
                do {
                    // Deserialize data to a dictionary
                    if let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        
                        // Access elements in the dictionary
                        if let message = jsonDictionary["message"] as? [String: Any],
                           let type = message["type"] as? String {
                            
                            myType = type
                            
                        } else {
                            print("Error: Unexpected JSON format")
                        }
              
                    }
                } catch {
                    print("Error deserializing JSON: \(error.localizedDescription)")
                }
                
                if myType == "tick" {
                    let genericResponse = try JSONDecoder().decode(WebSocketResponse<TradeDetails>.self, from: jsonData)
                    handleTradeData(genericResponse.message.payload)
                   
                } else if myType == "get_chart_history" {
//                    let historyResponse = try JSONDecoder().decode(WebSocketResponse<SymbolChartData>.self, from: jsonData)
//                    handleHistoryData(historyResponse.message.payload)
                } else if myType == "Unsubscribed" {
                    handleUnsubscribedData()
                } else {
                    print("Unexpected message type: \(myType)")
                }
          
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        } else {
            print("Error converting string to Data")
        }
    }

    
    // Handle trade data
    func handleTradeData(_ response: TradeDetails) {
        
        delegateSocketData?.tradeUpdates(socketMessageType: .tick, tickMessage: response)
        NotificationCenter.default.post(name: .tradesUpdated, object: response)
        
    }

    func handleUnsubscribedData() {
        //Unsubscribed
        
        if self.isTradeDismiss {
            return
        }
        
        delegateSocketData?.tradeUpdates(socketMessageType: .Unsubscribed, tickMessage: nil)
    }

    // Handle errors
    func handleError(_ error: Error?) {
        if let error = error {
            print("WebSocket encountered an error: \(error.localizedDescription)")
        }
    }
    
    func closeWebSockets() {
        webSocketQueue.async {
            self.webSocket?.disconnect()
        }
    }
    func getCurrentAndNextHourTimestamps() -> (current: Int, beforeHour: Int) {
        let now = Date()
        //        let calendar = Calendar.current
        
        // Get current timestamp in milliseconds
        let currentTimestamp = Int(now.timeIntervalSince1970) + (3 * 60 * 60)
        let beforeHourTimestamp = currentTimestamp -  (24 * 60 * 60)
        
        return (current: currentTimestamp, beforeHour: beforeHourTimestamp)
    }
    
    
    func currentAndBeforeBusinessDayTimestamps() -> (currentTimestamp: Int, previousTimestamp: Int) {
        let timeZone = TimeZone(identifier: "UTC")!
        let currentDate = Date()
        
        // Get current date components
        let components = Calendar.current.dateComponents(in: timeZone, from: currentDate)
        
        // Create the current timestamp
        let currentTimestamp = Int(currentDate.timeIntervalSince1970)
        
        // Calculate previous business day
        var previousBusinessDay = currentDate
        
        // Check if the current day is a business day (for this example, we'll consider weekdays only)
        let weekday = components.weekday ?? 1 // Default to Sunday (1)
        
        // If today is Sunday (1), go back to Friday (5)
        if weekday == 1 {
            previousBusinessDay = Calendar.current.date(byAdding: .day, value: -2, to: currentDate)!
        }
        // If today is Monday (2), go back to Friday (5)
        else if weekday == 2 {
            previousBusinessDay = Calendar.current.date(byAdding: .day, value: -3, to: currentDate)!
        }
        // Otherwise, just go back one day
        else {
            previousBusinessDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        // Get previous timestamp
        let previousTimestamp = Int(previousBusinessDay.timeIntervalSince1970)
        
        return (currentTimestamp: currentTimestamp, previousTimestamp: previousTimestamp)
    }

}



//import Foundation
//import Starscream
//import Network
//import SystemConfiguration
//
//enum SocketMessageType {
//    case tick
//    case Unsubscribed
//    case connectionLost
//    case networkUnavailable
//}
//
//protocol GetSocketData: AnyObject {
//    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?)
//}
//
//protocol GetSocketMessages: AnyObject {
//    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?)
//}
//
//protocol GetCandleData: AnyObject {
//    func tradeHistoryUpdates(socketMessageType: SocketMessageType, historyMessage: SymbolChartData?)
//}
//
//protocol SocketPeerClosed: AnyObject {
//    func peerClosed()
//}
//
//protocol SocketConnectionInitDelegate: AnyObject {
//    func SocketConnectionInit()
//}
//
//protocol SocketNotSendDataDelegate: AnyObject {
//    func socketNotSendData()
//}
//
//protocol StartOffLineDataDelegate: AnyObject {
//    func startOfflineData()
//}
//
//// MARK: - Network Status Enum
//enum NetworkStatus {
//    case available
//    case unavailable
//    case unknown
//}
//
//class WebSocketManager: WebSocketDelegate {
//
//    var webSocket: WebSocket?
//    static let shared = WebSocketManager() // Shared instance
//
//    var connectionCheckTimer: Timer?
//
//    var isConnectionStable: Timer?
//    var connectionCount = 0
//
//    private init() {
//        setupNetworkMonitoring()
//        setupApplicationStateObservers()
//    }
//
//    deinit {
//        cleanup()
//    }
//
//    public weak var delegateSocketData: GetSocketData?
//    public weak var delegateCandleSocketMessage: GetCandleData?
//    public weak var delegateSocketPeerClosed: SocketPeerClosed?
//    public weak var delegateSocketConnectionInit: SocketConnectionInitDelegate?
//    public weak var delegateSocketNotSendData: SocketNotSendDataDelegate?
//    public weak var delegateStartOffLineData: StartOffLineDataDelegate?
//
//    var isTradeDismiss = Bool()
//
//    var reconnectAttempts = 0
//    private let maxReconnectAttempts = 10
//    private var reconnectTimer: Timer?
//
//    private let webSocketQueue = DispatchQueue(label: "webSocketQueue", qos: .background)
//
//    // MARK: - Network Monitoring Properties
//    private var networkMonitor: NWPathMonitor?
//    private var networkStatus: NetworkStatus = .unknown {
//        didSet {
//            handleNetworkStatusChange()
//        }
//    }
//
//    // MARK: - Enhanced Connection Monitoring
//    private var lastDataReceiveTime: Date?
//    private var noDataTimer: Timer?
//    private let noDataTimeoutInterval: TimeInterval = 30.0 // 30 seconds without data
//    private var expectedDataReceived = false
//    private var isManualDisconnection = false
//    private var heartbeatTimer: Timer?
//    private let heartbeatInterval: TimeInterval = 30.0
//
//    // MARK: - Application State
//    private var isInBackground = false
//
//    var trades: [String: TradeDetails] = [:] {
//        didSet {
//            NotificationCenter.default.post(name: .tradesUpdated, object: nil)
//        }
//    }
//    var symbolData: [String: SymbolChartData] = [:] {
//        didSet {
//            NotificationCenter.default.post(name: .symbolDataUpdated, object: nil)
//        }
//    }
//
//    // MARK: - Network Monitoring Setup
//    private func setupNetworkMonitoring() {
//        networkMonitor = NWPathMonitor()
//
//        networkMonitor?.pathUpdateHandler = { [weak self] path in
//            DispatchQueue.main.async {
//                let newStatus: NetworkStatus = path.status == .satisfied ? .available : .unavailable
//                if self?.networkStatus != newStatus {
//                    self?.networkStatus = newStatus
//                }
//            }
//        }
//
//        let queue = DispatchQueue(label: "NetworkMonitor")
//        networkMonitor?.start(queue: queue)
//
//        // Initial network status check
//        checkInitialNetworkStatus()
//    }
//
//    private func checkInitialNetworkStatus() {
//        var zeroAddress = sockaddr_in()
//        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
//        zeroAddress.sin_family = sa_family_t(AF_INET)
//
//        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
//            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
//                SCNetworkReachabilityCreateWithAddress(nil, $0)
//            }
//        }
//
//        var flags = SCNetworkReachabilityFlags()
//        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
//            let isReachable = flags.contains(.reachable)
//            let needsConnection = flags.contains(.connectionRequired)
//            networkStatus = (isReachable && !needsConnection) ? .available : .unavailable
//        }
//    }
//
//    private func handleNetworkStatusChange() {
//        print("🌐 Network status changed to: \(networkStatus)")
//
//        switch networkStatus {
//        case .available:
//            print("✅ Network is available")
//            if !isSocketConnected() && !isManualDisconnection {
//                print("🔄 Network recovered, attempting to reconnect...")
//                // Reset reconnect attempts when network comes back
//                reconnectAttempts = 0
//                connectWebSocket()
//            }
//        case .unavailable:
//            print("❌ Network is unavailable")
//            if isSocketConnected() {
//                print("📱 Disconnecting due to network unavailability")
//                // Don't call DisconnectWebSocket as it will trigger reconnection
//                GlobalVariable.instance.isConnected = false
//                webSocket?.disconnect()
//                webSocket = nil
//                stopAllTimers()
//
//                // Notify delegates about network issue
//                delegateSocketData?.tradeUpdates(socketMessageType: .networkUnavailable, tickMessage: nil)
//                delegateSocketPeerClosed?.peerClosed()
//
//                NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "false"])
//            }
//        case .unknown:
//            break
//        }
//    }
//
//    // MARK: - Application State Observers
//    private func setupApplicationStateObservers() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(applicationDidEnterBackground),
//            name: UIApplication.didEnterBackgroundNotification,
//            object: nil
//        )
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(applicationWillEnterForeground),
//            name: UIApplication.willEnterForegroundNotification,
//            object: nil
//        )
//    }
//
//    @objc private func applicationDidEnterBackground() {
//        isInBackground = true
//        print("📱 App entered background")
//        // Reduce heartbeat frequency in background
//        stopHeartbeatTimer()
//    }
//
//    @objc private func applicationWillEnterForeground() {
//        isInBackground = false
//        print("📱 App entering foreground")
//
//        // Resume heartbeat and check connection
//        if isSocketConnected() {
//            startHeartbeatTimer()
//        } else if !isManualDisconnection && networkStatus == .available {
//            print("🔄 Reconnecting after returning from background")
//            connectWebSocket()
//        }
//    }
//
//    private func isConnectionStableTimer() {
//        // Invalidate existing timer
//        isConnectionStable?.invalidate()
//        isConnectionStable = nil
//
//        // Create a new timer with the current interval
//        isConnectionStable = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(isConnectionStbl), userInfo: nil, repeats: true)
//    }
//
//    @objc private func isConnectionStbl() {
//        connectionCount += 1
//
//        if connectionCount > 3 {
//            connectionCount = 0
//
//            // Enhanced offline data detection
//            print("🔄 No stable connection detected, switching to offline mode")
//            delegateStartOffLineData?.startOfflineData()
//
//            // Try to reconnect if network is available
//            if networkStatus == .available && !isManualDisconnection {
//                print("🔄 Attempting reconnection due to unstable connection")
//                DisconnectWebSocket()
//                connectWebSocket()
//            }
//        }
//    }
//
//    // Check if the socket is connected (keeping your original logic)
//    func isSocketConnected() -> Bool {
//        return GlobalVariable.instance.isConnected
//    }
//
//    func connectWebSocket() {
//        // Check network availability before connecting
//        guard networkStatus == .available else {
//            print("❌ Cannot connect: Network unavailable")
//            return
//        }
//
//        print("🔄 Attempting to connect to WebSocket...")
//
//        let url = URL(string: "ws://18.116.153.208:8074")!
//        var request = URLRequest(url: url)
//        request.timeoutInterval = 10.0 // Increased timeout
//
//        webSocket = WebSocket(request: request)
//        webSocket?.delegate = self
//        webSocket?.connect()
//
//        // Start connection monitoring
//        isConnectionStableTimer()
//    }
//
//    func ConnectWebSocket() {
//        guard networkStatus == .available else {
//            print("❌ Cannot connect: Network unavailable")
//            return
//        }
//
//        if !isSocketConnected() {
//            isManualDisconnection = false
//            webSocket?.connect()
//        }
//    }
//
//    func DisconnectWebSocket() {
//        isManualDisconnection = true
//        stopAllTimers()
//
//        if isSocketConnected() {
//            webSocket?.disconnect()
//            webSocket = nil
//            GlobalVariable.instance.isConnected = false
//        }
//    }
//
//    private func attemptReconnect() {
//        guard !isManualDisconnection else {
//            print("⚠️ Manual disconnection - not attempting reconnect")
//            return
//        }
//
//        guard networkStatus == .available else {
//            print("⚠️ Network unavailable - scheduling reconnect for later")
//            scheduleNetworkRetry()
//            return
//        }
//
//        guard reconnectAttempts < maxReconnectAttempts else {
//            print("❌ Max reconnection attempts reached")
//            delegateSocketPeerClosed?.peerClosed()
//            return
//        }
//
//        reconnectAttempts += 1
//        let retryDelay = min(Double(reconnectAttempts) * 2, 30) // Exponential backoff capped at 30 seconds
//
//        print("🔄 Scheduling reconnection attempt \(reconnectAttempts) in \(retryDelay) seconds")
//
//        reconnectTimer?.invalidate()
//        reconnectTimer = Timer.scheduledTimer(withTimeInterval: retryDelay, repeats: false) { [weak self] _ in
//            guard let self = self else { return }
//            print("🔄 Attempting to reconnect... Attempt \(self.reconnectAttempts)")
//            self.webSocket?.disconnect()
//            self.connectWebSocket()
//        }
//    }
//
//    private func scheduleNetworkRetry() {
//        reconnectTimer?.invalidate()
//        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
//            if self?.networkStatus == .available {
//                self?.attemptReconnect()
//            } else {
//                self?.scheduleNetworkRetry()
//            }
//        }
//    }
//
//    // MARK: - Enhanced Timer Management
//    private func startHeartbeatTimer() {
//        stopHeartbeatTimer()
//        guard !isInBackground else { return } // Don't send heartbeat in background
//
//        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: heartbeatInterval, repeats: true) { [weak self] _ in
//            self?.sendHeartbeat()
//        }
//    }
//
//    private func stopHeartbeatTimer() {
//        heartbeatTimer?.invalidate()
//        heartbeatTimer = nil
//    }
//
//    private func sendHeartbeat() {
//        guard isSocketConnected() else { return }
//
//        let heartbeatMessage = [
//            "event_name": "ping",
//            "data": [:]
//        ] as [String : Any]
//
//        if let jsonData = try? JSONSerialization.data(withJSONObject: heartbeatMessage, options: []),
//           let jsonString = String(data: jsonData, encoding: .utf8) {
//            webSocketQueue.async { [weak self] in
//                self?.webSocket?.write(string: jsonString)
//            }
//        }
//    }
//
//    private func startNoDataTimer() {
//        noDataTimer?.invalidate()
//        noDataTimer = Timer.scheduledTimer(withTimeInterval: noDataTimeoutInterval, repeats: false) { [weak self] _ in
//            self?.handleNoDataTimeout()
//        }
//    }
//
//    private func handleNoDataTimeout() {
//        print("⚠️ No data received for \(noDataTimeoutInterval) seconds - switching to offline mode")
//        delegateStartOffLineData?.startOfflineData()
//
//        // Reset expected data flag and restart monitoring
//        expectedDataReceived = false
//        if isSocketConnected() {
//            startNoDataTimer()
//        }
//    }
//
//    private func stopAllTimers() {
//        connectionCheckTimer?.invalidate()
//        isConnectionStable?.invalidate()
//        reconnectTimer?.invalidate()
//        noDataTimer?.invalidate()
//        stopHeartbeatTimer()
//
//        connectionCheckTimer = nil
//        isConnectionStable = nil
//        reconnectTimer = nil
//        noDataTimer = nil
//    }
//
//    func sendWebSocketMessage(for event: String, symbol: String? = nil, symbolList: [String]? = nil, isTradeDismiss: Bool? = nil) {
//        guard isSocketConnected() else {
//            print("❌ Cannot send message: WebSocket not connected")
//            return
//        }
//
//        let (currentTimestamp, hourBeforeTimestamp) = getCurrentAndNextHourTimestamps()
//        let timestamps = currentAndBeforeBusinessDayTimestamps()
//
//        var message: [String: Any] = [:]
//
//        // Prepare message based on event type (trade or history)
//        if event == "subscribeTrade" {
//
//            if symbolList != nil {
//                message = [
//                    "event_name": "subscribe",
//                    "data": [
//                        "last": 0,
//                        "channels": symbolList ?? [""]
//                    ]
//                ]
//            } else {
//                message = [
//                    "event_name": "subscribe",
//                    "data": [
//                        "last": 0,
//                        "channels": [symbol ?? ""]
//                    ]
//                ]
//            }
//
//            // Start monitoring for data when subscribing
//            expectedDataReceived = true
//            startNoDataTimer()
//
//        } else if event == "subscribeHistory" {
//            // Your history subscription logic here
//
//        } else if event == "unsubscribeTrade" {
//
//            self.isTradeDismiss = isTradeDismiss ?? false
//
//            message = [
//                "event_name": "unsubscribe",
//                "data": [
//                    "last": 0,
//                    "channels": symbolList ?? [""]
//                ]
//            ]
//
//            // Stop monitoring for data when unsubscribing
//            expectedDataReceived = false
//            noDataTimer?.invalidate()
//        }
//
//        // Send the prepared message to the WebSocket
//        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
//           let jsonString = String(data: jsonData, encoding: .utf8) {
//            webSocketQueue.async {
//                if let webSocket = self.webSocket {
//                    webSocket.write(string: jsonString)
//                    print("✅ Message sent to WebSocket: \(event)")
//                } else {
//                    print("❌ WebSocket is not connected.")
//                }
//            }
//        }
//    }
//
//    // WebSocket delegate method (Enhanced)
//    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
//        switch event {
//        case .connected(let headers):
//            print("✅ WebSocket is connected: \(headers)")
//            GlobalVariable.instance.isConnected = true
//            reconnectAttempts = 0
//            connectionCount = 0
//
//            // Start enhanced monitoring
//            startHeartbeatTimer()
//            lastDataReceiveTime = Date()
//
//            //MARK: - This Check is handle for Offline data.
//            if !GlobalVariable.instance.socketNotSendData {
//                self.delegateSocketConnectionInit?.SocketConnectionInit()
//            }
//
//            NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "true"])
//
//        case .text(let string):
//            // Reset connection stability monitoring
//            connectionCount = 0
//
//            // Update last data receive time
//            lastDataReceiveTime = Date()
//
//            // Reset no data timer
//            if expectedDataReceived {
//                startNoDataTimer()
//            }
//
//            // Invalidate existing connection check timer
//            connectionCheckTimer?.invalidate()
//            connectionCheckTimer = nil
//
//            handleWebSocketMessage(string)
//
//        case .disconnected(let reason, let code):
//            print("❌ WebSocket is disconnected: \(reason) with code: \(code)")
//            GlobalVariable.instance.isConnected = false
//            stopAllTimers()
//
//            attemptReconnect()
//
//            NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "false"])
//
//            delegateSocketPeerClosed?.peerClosed()
//
//        case .error(let error):
//            print("❌ WebSocket error: \(error?.localizedDescription ?? "Unknown error")")
//            GlobalVariable.instance.isConnected = false
//            stopAllTimers()
//
//            handleError(error)
//            attemptReconnect()
//
//            NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "false"])
//
//            delegateSocketPeerClosed?.peerClosed()
//
//        case .peerClosed:
//            print("👋 WebSocket peer closed...")
//            GlobalVariable.instance.isConnected = false
//            stopAllTimers()
//
//            delegateSocketPeerClosed?.peerClosed()
//
//            if !isManualDisconnection {
//                attemptReconnect()
//            }
//
//        case .cancelled:
//            print("🚫 WebSocket cancelled... attempting reconnect")
//            GlobalVariable.instance.isConnected = false
//            stopAllTimers()
//
//            attemptReconnect()
//
//        default:
//            print("⚠️ WebSocket received an unhandled event: \(event)")
//
//            connectionCount = 0
//            isConnectionStableTimer()
//        }
//    }
//
//    func filterSymbolsBySector(symbols: [SymbolData], sector: String) -> [String] {
//        return symbols.filter { $0.sector == sector }.map { $0.displayName }
//    }
//
//    private func setTradeModel(collectionViewIndex: Int) {
//        let symbols = GlobalVariable.instance.symbolDataArray
//        let sectors = GlobalVariable.instance.sectors
//
//        GlobalVariable.instance.filteredSymbols.removeAll()
//        GlobalVariable.instance.filteredSymbolsUrl.removeAll()
//
//        // Populate filteredSymbols and filteredSymbolsUrl for each sector
//        for sector in sectors {
//            let filteredSymbols = filterSymbolsBySector(symbols: symbols, sector: sector.sector)
//
//            GlobalVariable.instance.filteredSymbols.append(filteredSymbols)
//        }
//
//        // Append trades for the selected collectionViewIndex
//        let selectedSymbols = GlobalVariable.instance.filteredSymbols[safe: collectionViewIndex] ?? []
//        let selectedUrls = GlobalVariable.instance.filteredSymbolsUrl[safe: collectionViewIndex] ?? []
//
//        //MARK: - Save symbol local to unsubcibe.
//        GlobalVariable.instance.previouseSymbolList = selectedSymbols
//
//        sendWebSocketMessage(for: "subscribeTrade", symbolList: selectedSymbols)
//    }
//
//    // Handle the WebSocket message (Enhanced)
//    func handleWebSocketMessage(_ string: String) {
//        if let jsonData = string.data(using: .utf8) {
//            do {
//                var myType = ""
//
//                // Deserialize JSON data
//                do {
//                    // Deserialize data to a dictionary
//                    if let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
//
//                        // Access elements in the dictionary
//                        if let message = jsonDictionary["message"] as? [String: Any],
//                           let type = message["type"] as? String {
//
//                            myType = type
//
//                        } else {
//                            print("Error: Unexpected JSON format")
//                        }
//
//                    }
//                } catch {
//                    print("Error deserializing JSON: \(error.localizedDescription)")
//                }
//
//                if myType == "tick" {
//                    let genericResponse = try JSONDecoder().decode(WebSocketResponse<TradeDetails>.self, from: jsonData)
//                    handleTradeData(genericResponse.message.payload)
//
//                } else if myType == "get_chart_history" {
//                    // Handle history data if needed
//
//                } else if myType == "Unsubscribed" {
//                    handleUnsubscribedData()
//                } else if myType == "pong" {
//                    // Handle heartbeat response
//                    print("💓 Heartbeat response received")
//                } else {
//                    print("⚠️ Unexpected message type: \(myType)")
//                }
//
//            } catch {
//                print("❌ Error parsing JSON: \(error.localizedDescription)")
//            }
//        } else {
//            print("❌ Error converting string to Data")
//        }
//    }
//
//    // Handle trade data (keeping your original logic)
//    func handleTradeData(_ response: TradeDetails) {
//        delegateSocketData?.tradeUpdates(socketMessageType: .tick, tickMessage: response)
//        NotificationCenter.default.post(name: .tradesUpdated, object: response)
//    }
//
//    func handleUnsubscribedData() {
//        //Unsubscribed
//        if self.isTradeDismiss {
//            return
//        }
//
//        delegateSocketData?.tradeUpdates(socketMessageType: .Unsubscribed, tickMessage: nil)
//    }
//
//    // Handle errors (Enhanced)
//    func handleError(_ error: Error?) {
//        if let error = error {
//            print("❌ WebSocket encountered an error: \(error.localizedDescription)")
//        }
//    }
//
//    func closeWebSockets() {
//        isManualDisconnection = true
//        stopAllTimers()
//
//        webSocketQueue.async {
//            self.webSocket?.disconnect()
//        }
//    }
//
//    func getCurrentAndNextHourTimestamps() -> (current: Int, beforeHour: Int) {
//        let now = Date()
//
//        // Get current timestamp in milliseconds
//        let currentTimestamp = Int(now.timeIntervalSince1970) + (3 * 60 * 60)
//        let beforeHourTimestamp = currentTimestamp -  (24 * 60 * 60)
//
//        return (current: currentTimestamp, beforeHour: beforeHourTimestamp)
//    }
//
//    func currentAndBeforeBusinessDayTimestamps() -> (currentTimestamp: Int, previousTimestamp: Int) {
//        let timeZone = TimeZone(identifier: "UTC")!
//        let currentDate = Date()
//
//        // Get current date components
//        let components = Calendar.current.dateComponents(in: timeZone, from: currentDate)
//
//        // Create the current timestamp
//        let currentTimestamp = Int(currentDate.timeIntervalSince1970)
//
//        // Calculate previous business day
//        var previousBusinessDay = currentDate
//
//        // Check if the current day is a business day (for this example, we'll consider weekdays only)
//        let weekday = components.weekday ?? 1 // Default to Sunday (1)
//
//        // If today is Sunday (1), go back to Friday (5)
//        if weekday == 1 {
//            previousBusinessDay = Calendar.current.date(byAdding: .day, value: -2, to: currentDate)!
//        }
//        // If today is Monday (2), go back to Friday (5)
//        else if weekday == 2 {
//            previousBusinessDay = Calendar.current.date(byAdding: .day, value: -3, to: currentDate)!
//        }
//        // Otherwise, just go back one day
//        else {
//            previousBusinessDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
//        }
//
//        // Get previous timestamp
//        let previousTimestamp = Int(previousBusinessDay.timeIntervalSince1970)
//
//        return (currentTimestamp: currentTimestamp, previousTimestamp: previousTimestamp)
//    }
//
//    // MARK: - Cleanup
//    private func cleanup() {
//        stopAllTimers()
//        networkMonitor?.cancel()
//        webSocket?.disconnect()
//        NotificationCenter.default.removeObserver(self)
//    }
//}
//
//// MARK: - Extensions (keeping your original structure)
//extension Notification.Name {
////    static let tradesUpdated = Notification.Name("tradesUpdated")
////    static let symbolDataUpdated = Notification.Name("symbolDataUpdated")
////    static let checkSocketConnectivity = Notification.Name("checkSocketConnectivity")
//}
//
//extension Array {
//    subscript(safe index: Index) -> Element? {
//        return indices.contains(index) ? self[index] : nil
//    }
//}
//
////// MARK: - Data Models (Add these if not already present)
////struct WebSocketResponse<T: Codable>: Codable {
////    let message: Message<T>
////}
////
////struct Message<T: Codable>: Codable {
////    let type: String
////    let payload: T
////}
////
////// Add your actual models if not already present
////struct TradeDetails: Codable {
////    // Your trade details properties
////}
////
////struct SymbolChartData: Codable {
////    // Your symbol chart data properties
////}
////
////struct SymbolData: Codable {
////    let displayName: String
////    let sector: String
////    // Add other properties as needed
////}


/*
import Foundation
import Starscream
import Network
import SystemConfiguration

// MARK: - Enums
enum SocketMessageType {
    case tick
    case Unsubscribed
    case error
    case connectionLost
}

enum WebSocketState {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case error
}

enum NetworkStatus {
    case available
    case unavailable
    case unknown
}

protocol GetSocketData: AnyObject {
    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?)
}

protocol GetSocketMessages: AnyObject {
    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?)
}

protocol GetCandleData: AnyObject {
    func tradeHistoryUpdates(socketMessageType: SocketMessageType, historyMessage: SymbolChartData?)
}

protocol SocketPeerClosed: AnyObject {
    func peerClosed()
}

protocol SocketConnectionInitDelegate: AnyObject {
    func SocketConnectionInit()
}

protocol SocketNotSendDataDelegate: AnyObject {
    func socketNotSendData()
}

protocol StartOffLineDataDelegate: AnyObject {
    func startOfflineData()
}

//// MARK: - Protocols
//protocol GetSocketData: AnyObject {
//    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?)
//}
//
//protocol GetCandleData: AnyObject {
//    func tradeHistoryUpdates(socketMessageType: SocketMessageType, historyMessage: SymbolChartData?)
//}
//
//protocol SocketPeerClosed: AnyObject {
//    func peerClosed()
//}
//
//protocol SocketConnectionInitDelegate: AnyObject {
//    func socketConnectionInit()
//}
//
//protocol SocketNotSendDataDelegate: AnyObject {
//    func socketNotSendData()
//}
//
//protocol StartOffLineDataDelegate: AnyObject {
//    func startOfflineData()
//}

protocol NetworkStatusDelegate: AnyObject {
    func networkStatusChanged(_ status: NetworkStatus)
}

// MARK: - WebSocket Manager
class WebSocketManager: NSObject {
    
    // MARK: - Singleton
    static let shared = WebSocketManager()
    
    // MARK: - Properties
    private var webSocket: WebSocket?
    private let webSocketQueue = DispatchQueue(label: "webSocketQueue", qos: .background)
    
    // State Management
    private var currentState: WebSocketState = .disconnected {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .socketStateChanged, object: self.currentState)
            }
        }
    }
    
    // Internal connection flag for precise state tracking
    private var isWebSocketConnected = false
    
    // Network Monitoring
    private var networkMonitor: NWPathMonitor?
    private var networkStatus: NetworkStatus = .unknown {
        didSet {
            handleNetworkStatusChange()
        }
    }
    
    // Reconnection Logic
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 10
    private var reconnectTimer: Timer?
    private let baseReconnectDelay: TimeInterval = 2.0
    private let maxReconnectDelay: TimeInterval = 60.0
    
    // Connection Monitoring
    private var connectionCheckTimer: Timer?
    private var heartbeatTimer: Timer?
    private var dataReceiveTimer: Timer?
    private var lastDataReceiveTime: Date?
    
    // Data Monitoring for Offline Detection
    private var noDataTimer: Timer?
    private let noDataTimeoutInterval: TimeInterval = 30.0 // 30 seconds without data
    private var expectedDataReceived = false
    
    // Configuration
    private let connectionTimeout: TimeInterval = 10.0
    private let heartbeatInterval: TimeInterval = 30.0
    private let connectionCheckInterval: TimeInterval = 5.0
    
    // WebSocket URL
    private let webSocketURL = "ws://18.116.153.208:8074"
    
    // Data Storage
    var trades: [String: TradeDetails] = [:] {
        didSet {
            NotificationCenter.default.post(name: .tradesUpdated, object: nil)
        }
    }
    
    var symbolData: [String: SymbolChartData] = [:] {
        didSet {
            NotificationCenter.default.post(name: .symbolDataUpdated, object: nil)
        }
    }
    
    // Delegates
    weak var delegateSocketData: GetSocketData?
    weak var delegateCandleSocketMessage: GetCandleData?
    weak var delegateSocketPeerClosed: SocketPeerClosed?
    weak var delegateSocketConnectionInit: SocketConnectionInitDelegate?
    weak var delegateSocketNotSendData: SocketNotSendDataDelegate?
    weak var delegateStartOffLineData: StartOffLineDataDelegate?
    weak var networkStatusDelegate: NetworkStatusDelegate?
    
    // Flags
    private var isTradeDismiss = false
    private var isManualDisconnection = false
    private var isInBackground = false
    
    // MARK: - Initialization
    private override init() {
        super.init()
        setupNetworkMonitoring()
        setupApplicationStateObservers()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Public Methods
    
    /// Start WebSocket connection
    func connect() {
        guard networkStatus == .available else {
            print("❌ Cannot connect: Network unavailable")
            currentState = .error
            return
        }
        
        isManualDisconnection = false
        connectWebSocket()
    }
    
    /// Disconnect WebSocket
    func disconnect() {
        isManualDisconnection = true
        disconnectWebSocket()
        stopAllTimers()
        currentState = .disconnected
    }
    
    /// Check if socket is connected
    func isConnected() -> Bool {
        return currentState == .connected
    }
    
    /// Send message to WebSocket
    func sendMessage(for event: String, symbol: String? = nil, symbolList: [String]? = nil, isTradeDismiss: Bool = false) {
        guard isConnected() else {
            print("❌ Cannot send message: WebSocket not connected")
            return
        }
        
        self.isTradeDismiss = isTradeDismiss
        let message = prepareMessage(for: event, symbol: symbol, symbolList: symbolList)
        sendWebSocketMessage(message, event: event)
    }
    
    // MARK: - Private Methods - Connection Management
    
    private func connectWebSocket() {
        guard let url = URL(string: webSocketURL) else {
            print("❌ Invalid WebSocket URL")
            currentState = .error
            return
        }
        
        currentState = .connecting
        print("🔄 Connecting to WebSocket...")
        
        var request = URLRequest(url: url)
        request.timeoutInterval = connectionTimeout
        
        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
        
        // Start connection timeout timer
        startConnectionTimeoutTimer()
    }
    
    private func disconnectWebSocket() {
        stopAllTimers()
        isWebSocketConnected = false
        webSocket?.disconnect()
        webSocket = nil
        currentState = .disconnected
    }
    
    private func reconnectWebSocket() {
        guard !isManualDisconnection else { return }
        guard networkStatus == .available else {
            print("⚠️ Cannot reconnect: Network unavailable")
            scheduleReconnect()
            return
        }
        
        guard reconnectAttempts < maxReconnectAttempts else {
            print("❌ Max reconnection attempts reached")
            currentState = .error
            delegateSocketPeerClosed?.peerClosed()
            return
        }
        
        currentState = .reconnecting
        reconnectAttempts += 1
        
        let delay = min(baseReconnectDelay * pow(2.0, Double(reconnectAttempts)), maxReconnectDelay)
        print("🔄 Scheduling reconnection attempt \(reconnectAttempts) in \(delay) seconds")
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.connectWebSocket()
        }
    }
    
    private func scheduleReconnect() {
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.reconnectWebSocket()
        }
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        networkMonitor = NWPathMonitor()
        
        networkMonitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let newStatus: NetworkStatus = path.status == .satisfied ? .available : .unavailable
                if self?.networkStatus != newStatus {
                    self?.networkStatus = newStatus
                }
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor?.start(queue: queue)
        
        // Initial network status check
        checkInitialNetworkStatus()
    }
    
    private func checkInitialNetworkStatus() {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            networkStatus = (isReachable && !needsConnection) ? .available : .unavailable
        }
    }
    
    private func handleNetworkStatusChange() {
        print("🌐 Network status changed to: \(networkStatus)")
        networkStatusDelegate?.networkStatusChanged(networkStatus)
        
        switch networkStatus {
        case .available:
            if currentState != .connected && !isManualDisconnection {
                reconnectWebSocket()
            }
        case .unavailable:
            if isConnected() {
                print("⚠️ Network lost, disconnecting WebSocket")
                disconnectWebSocket()
                delegateSocketPeerClosed?.peerClosed()
            }
        case .unknown:
            break
        }
    }
    
    // MARK: - Timer Management
    
    private func startConnectionTimeoutTimer() {
        connectionCheckTimer = Timer.scheduledTimer(withTimeInterval: connectionTimeout, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if self.currentState == .connecting {
                print("⏰ Connection timeout")
                self.disconnectWebSocket()
                self.reconnectWebSocket()
            }
        }
    }
    
    private func startHeartbeatTimer() {
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: heartbeatInterval, repeats: true) { [weak self] _ in
            self?.sendHeartbeat()
        }
    }
    
    private func startDataMonitoringTimer() {
        lastDataReceiveTime = Date()
        dataReceiveTimer = Timer.scheduledTimer(withTimeInterval: noDataTimeoutInterval, repeats: true) { [weak self] _ in
            self?.checkDataReceiveTimeout()
        }
    }
    
    private func startNoDataTimer() {
        noDataTimer?.invalidate()
        noDataTimer = Timer.scheduledTimer(withTimeInterval: noDataTimeoutInterval, repeats: false) { [weak self] _ in
            self?.handleNoDataTimeout()
        }
    }
    
    private func stopAllTimers() {
        connectionCheckTimer?.invalidate()
        heartbeatTimer?.invalidate()
        dataReceiveTimer?.invalidate()
        noDataTimer?.invalidate()
        reconnectTimer?.invalidate()
        
        connectionCheckTimer = nil
        heartbeatTimer = nil
        dataReceiveTimer = nil
        noDataTimer = nil
        reconnectTimer = nil
    }
    
    private func sendHeartbeat() {
        guard isConnected() else { return }
        
        let heartbeatMessage = [
            "event_name": "ping",
            "data": [:]
        ] as [String : Any]
        
        sendWebSocketMessage(heartbeatMessage, event: "heartbeat")
    }
    
    private func checkDataReceiveTimeout() {
        guard let lastReceiveTime = lastDataReceiveTime else { return }
        
        let timeSinceLastData = Date().timeIntervalSince(lastReceiveTime)
        if timeSinceLastData > noDataTimeoutInterval && expectedDataReceived {
            print("⚠️ No data received for \(timeSinceLastData) seconds")
            handleNoDataTimeout()
        }
    }
    
    private func handleNoDataTimeout() {
        print("🔄 No data timeout - switching to offline mode")
        DispatchQueue.main.async {
            self.delegateStartOffLineData?.startOfflineData()
        }
        
        // Reset expected data flag and restart monitoring
        expectedDataReceived = false
        startNoDataTimer()
    }
    
    // MARK: - Message Handling
    
    private func prepareMessage(for event: String, symbol: String?, symbolList: [String]?) -> [String: Any] {
        var message: [String: Any] = [:]
        
        switch event {
        case "subscribeTrade":
            let channels = symbolList ?? (symbol != nil ? [symbol!] : [])
            message = [
                "event_name": "subscribe",
                "data": [
                    "last": 0,
                    "channels": channels
                ]
            ]
            expectedDataReceived = true
            startNoDataTimer()
            
        case "unsubscribeTrade":
            let channels = symbolList ?? (symbol != nil ? [symbol!] : [])
            message = [
                "event_name": "unsubscribe",
                "data": [
                    "last": 0,
                    "channels": channels
                ]
            ]
            
        case "subscribeHistory":
            // Add your history subscription logic here
            message = [
                "event_name": "subscribe_history",
                "data": [:]
            ]
            
        default:
            message = [
                "event_name": event,
                "data": [:]
            ]
        }
        
        return message
    }
    
    private func sendWebSocketMessage(_ message: [String: Any], event: String) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ Failed to serialize message for event: \(event)")
            return
        }
        
        webSocketQueue.async { [weak self] in
            guard let self = self, let webSocket = self.webSocket else {
                print("❌ WebSocket not available")
                return
            }
            
            webSocket.write(string: jsonString)
            print("✅ Message sent for event: \(event)")
        }
    }
    
    private func handleWebSocketMessage(_ string: String) {
        // Reset no data timer since we received data
        noDataTimer?.invalidate()
        lastDataReceiveTime = Date()
        
        guard let jsonData = string.data(using: .utf8) else {
            print("❌ Failed to convert message to data")
            return
        }
        
        do {
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                  let message = jsonDictionary["message"] as? [String: Any],
                  let type = message["type"] as? String else {
                print("❌ Invalid message format")
                return
            }
            
            switch type.lowercased() {
            case "tick":
                let response = try JSONDecoder().decode(WebSocketResponse<TradeDetails>.self, from: jsonData)
                handleTradeData(response.message.payload)
                
            case "get_chart_history":
                // Handle history data if needed
                break
                
            case "unsubscribed":
                handleUnsubscribedData()
                
            case "pong":
                // Handle heartbeat response
                print("💓 Heartbeat response received")
                
            default:
                print("⚠️ Unhandled message type: \(type)")
            }
            
            // Restart no data timer for next expected data
            if expectedDataReceived {
                startNoDataTimer()
            }
            
        } catch {
            print("❌ Error parsing message: \(error.localizedDescription)")
        }
    }
    
    private func handleTradeData(_ response: TradeDetails) {
        DispatchQueue.main.async {
            self.delegateSocketData?.tradeUpdates(socketMessageType: .tick, tickMessage: response)
            NotificationCenter.default.post(name: .tradesUpdated, object: response)
        }
    }
    
    private func handleUnsubscribedData() {
        guard !isTradeDismiss else { return }
        
        DispatchQueue.main.async {
            self.delegateSocketData?.tradeUpdates(socketMessageType: .Unsubscribed, tickMessage: nil)
        }
    }
    
    // MARK: - Application State Observers
    
    private func setupApplicationStateObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func applicationDidEnterBackground() {
        isInBackground = true
        print("📱 App entered background")
    }
    
    @objc private func applicationWillEnterForeground() {
        isInBackground = false
        print("📱 App entering foreground")
        
        // Check connection status when returning from background
        if !isConnected() && !isManualDisconnection {
            reconnectWebSocket()
        }
    }
    
    // MARK: - Cleanup
    
    private func cleanup() {
        stopAllTimers()
        networkMonitor?.cancel()
        webSocket?.disconnect()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - WebSocketDelegate
extension WebSocketManager: WebSocketDelegate {
    
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("✅ WebSocket connected with headers: \(headers)")
            currentState = .connected
            isWebSocketConnected = true
            reconnectAttempts = 0
            
            // Start monitoring timers
            startHeartbeatTimer()
            startDataMonitoringTimer()
            
            DispatchQueue.main.async {
                if !GlobalVariable.instance.socketNotSendData {
//                    self.delegateSocketConnectionInit?.socketConnectionInit()
                    self.delegateSocketConnectionInit?.SocketConnectionInit()
                }
                NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": true])
            }
            
        case .text(let string):
            handleWebSocketMessage(string)
            
        case .binary(let data):
            print("📦 Received binary data: \(data.count) bytes")
            
        case .disconnected(let reason, let code):
            print("❌ WebSocket disconnected: \(reason) (code: \(code))")
            currentState = .disconnected
            isWebSocketConnected = false
            stopAllTimers()
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": false])
                self.delegateSocketPeerClosed?.peerClosed()
            }
            
            if !isManualDisconnection {
                reconnectWebSocket()
            }
            
        case .error(let error):
            print("❌ WebSocket error: \(error?.localizedDescription ?? "Unknown error")")
            currentState = .error
            isWebSocketConnected = false
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": false])
                self.delegateSocketPeerClosed?.peerClosed()
            }
            
            if !isManualDisconnection {
                reconnectWebSocket()
            }
            
        case .cancelled:
            print("🚫 WebSocket cancelled")
            currentState = .disconnected
            isWebSocketConnected = false
            
            if !isManualDisconnection {
                reconnectWebSocket()
            }
            
        case .peerClosed:
            print("👋 WebSocket peer closed")
            currentState = .disconnected
            isWebSocketConnected = false
            
            DispatchQueue.main.async {
                self.delegateSocketPeerClosed?.peerClosed()
            }
            
            if !isManualDisconnection {
                reconnectWebSocket()
            }
            
        default:
            print("⚠️ WebSocket unhandled event: \(event)")
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
//    static let tradesUpdated = Notification.Name("tradesUpdated")
//    static let symbolDataUpdated = Notification.Name("symbolDataUpdated")
//    static let checkSocketConnectivity = Notification.Name("checkSocketConnectivity")
    static let socketStateChanged = Notification.Name("socketStateChanged")
}

// MARK: - Helper Extensions
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

*/


//
//import Foundation
//import Starscream
//
//enum SocketMessageType {
//    case tick
//    case Unsubscribed
//}
//
//protocol GetSocketData: AnyObject {
//    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?)
//}
//
//protocol GetSocketMessages: AnyObject {
//    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?)
//}
//
//protocol GetCandleData: AnyObject {
//    func tradeHistoryUpdates(socketMessageType: SocketMessageType, historyMessage: SymbolChartData?)
//}
//
//protocol SocketPeerClosed: AnyObject {
//    func peerClosed()
//}
//
//protocol SocketConnectionInitDelegate: AnyObject {
//    func SocketConnectionInit()
//}
//
//protocol SocketNotSendDataDelegate: AnyObject {
//    func socketNotSendData()
//}
//
//protocol StartOffLineDataDelegate: AnyObject {
//    func startOfflineData()
//}
//
//class WebSocketManager: WebSocketDelegate {
//
//    var webSocket: WebSocket?
//    static let shared = WebSocketManager() // Shared instance
//
//    var connectionCheckTimer: Timer?
//
//    var isConnectionStable: Timer?
//    var connectionCount = 0
//
//    private init() {}
//
//    public weak var delegateSocketData: GetSocketData?
//    public weak var delegateCandleSocketMessage: GetCandleData?
//    public weak var delegateSocketPeerClosed: SocketPeerClosed?
//    public weak var delegateSocketConnectionInit: SocketConnectionInitDelegate?
//    public weak var delegateSocketNotSendData: SocketNotSendDataDelegate?
//    public weak var delegateStartOffLineData: StartOffLineDataDelegate?
//
//    var isTradeDismiss = Bool()
//
//    var reconnectAttempts = 0
//
//    private let webSocketQueue = DispatchQueue(label: "webSocketQueue", qos: .background)
//
//    var trades: [String: TradeDetails] = [:] {
//        didSet {
//            NotificationCenter.default.post(name: .tradesUpdated, object: nil)
//        }
//    }
//    var symbolData: [String: SymbolChartData] = [:] {
//        didSet {
//            NotificationCenter.default.post(name: .symbolDataUpdated, object: nil)
//        }
//    }
//
////    private func startConnectionCheckTimer() {
////        // Invalidate existing timer
////        connectionCheckTimer?.invalidate()
////        connectionCheckTimer = nil
////
////        // Create a new timer with the current interval
////        connectionCheckTimer = Timer.scheduledTimer(timeInterval: GlobalVariable.instance.socketTimer, target: self, selector: #selector(checkConnection), userInfo: nil, repeats: true)
////    }
//
//    private func isConnectionStableTimer() {
//        // Invalidate existing timer
//        isConnectionStable?.invalidate()
//        isConnectionStable = nil
//
//        // Create a new timer with the current interval
//        isConnectionStable = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(isConnectionStbl), userInfo: nil, repeats: true)
//    }
//
//    @objc private func isConnectionStbl() {
//
//        connectionCount += 1
//
//        if connectionCount > 3 {
//
//            connectionCount = 0
//
//            delegateStartOffLineData?.startOfflineData()
//
//        }
//
//    }
//
////    @objc private func checkConnection() {
////        if isSocketConnected() {
////            print("WebSocket is connected.")
////        } else {
////            print("WebSocket is disconnected.")
////        }
//////        startConnectionCheckTimer()
////
////        GlobalVariable.instance.socketTimerCount += 1
////
////                if GlobalVariable.instance.socketTimerCount > 3 {
////                    return
////                }
////
////        print("GlobalVariable.instance.socketTimerCount = \(GlobalVariable.instance.socketTimerCount)")
////        print("GlobalVariable.instance.socketTimer = \(GlobalVariable.instance.socketTimer)")
////
////        DisconnectWebSocket()
////        connectWebSocket()
////
//////        print("GlobalVariable.instance.previouseSymbolList = \(GlobalVariable.instance.previouseSymbolList)")
//////        print("GlobalVariable.instance.tempPreviouseSymbolList = \(GlobalVariable.instance.tempPreviouseSymbolList)")
////
////        //MARK: - Save symbol local to unsubcibe.
////        sendWebSocketMessage(for: "unsubscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList, isTradeDismiss: true)
////        //MARK: - START calling Socket message from here.
////        sendWebSocketMessage(for: "subscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList)
////
//////        delegateSocketNotSendData?.socketNotSendData(isCalled: T##Bool)
////    }
//
//    // Check if the socket is connected
//    func isSocketConnected() -> Bool {
//        return GlobalVariable.instance.isConnected
//    }
//
//    func connectWebSocket() {
////        let url = URL(string: "wss://mbe.riverprime.com/mobile_web_socket")!
//
//        let url = URL(string: "ws://18.116.153.208:8074")!
//        var request = URLRequest(url: url)
//        request.timeoutInterval = 5
//
//        webSocket = WebSocket(request: request)
//        webSocket?.delegate = self
//        webSocket?.connect()
//    }
//
//    func ConnectWebSocket() {
//        if !isSocketConnected() {
//            webSocket?.connect()
//        }
//    }
//
//    func DisconnectWebSocket() {
//        if isSocketConnected() {
//            webSocket?.disconnect()
//            webSocket = nil
//        }
//    }
//
//    private func attemptReconnect() {
//        if isSocketConnected() {
//            reconnectAttempts += 1
//            let retryDelay = min(Double(reconnectAttempts) * 2, 30) // Exponential backoff capped at 30 seconds
//            DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) { [weak self] in
//                guard let self = self else { return }
//                print("Attempting to reconnect... Attempt \(self.reconnectAttempts)")
//                self.webSocket?.disconnect()
////                self.webSocket?.connect()
//                connectWebSocket()
//            }
//        }
//    }
//
//    func sendWebSocketMessage(for event: String, symbol: String? = nil, symbolList: [String]? = nil, isTradeDismiss: Bool? = nil) {
//        let (currentTimestamp, hourBeforeTimestamp) = getCurrentAndNextHourTimestamps()
//
//        let timestamps = currentAndBeforeBusinessDayTimestamps()
//
//        var message: [String: Any] = [:]
//
//        // Prepare message based on event type (trade or history)
//        if event == "subscribeTrade" {
//
//            if symbolList != nil {
//                message = [
//                    "event_name": "subscribe",
//                    "data": [
//                        "last": 0,
//    //                    "channels": ["price_feed"]
//                        "channels": symbolList ?? [""] //["Gold","Silver"]
//                    ]
//                ]
//            } else {
//                message = [
//                    "event_name": "subscribe",
//                    "data": [
//                        "last": 0,
//    //                    "channels": ["price_feed"]
//                        "channels": [symbol ?? ""] //["Gold","Silver"]
//                    ]
//                ]
//            }
//        } else if event == "subscribeHistory" {
//
//        } else if event == "unsubscribeTrade" {
//
//            self.isTradeDismiss = isTradeDismiss ?? false
//
//            message = [
//                "event_name": "unsubscribe",
//                "data": [
//                    "last": 0,
//                    "channels": symbolList ?? [""]
//                ]
//            ]
//        }
//
//        // Send the prepared message to the WebSocket
//        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
//           let jsonString = String(data: jsonData, encoding: .utf8) {
//            webSocketQueue.async {
//                if let webSocket = self.webSocket {
//                    webSocket.write(string: jsonString)
//                    print("Message sent to WebSocket: \(event)")
//                } else {
//                    print("WebSocket is not connected.")
//                }
//            }
//        }
//    }
//
//
//    // WebSocket delegate method
//    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
//        switch event {
//        case .connected(let headers):
////            print("WebSocket is connected: \(headers)")
//            GlobalVariable.instance.isConnected = true // Update connection state
//            reconnectAttempts = 0
//
//            //MARK: - This Check is handle for Offline data.
//            if !GlobalVariable.instance.socketNotSendData {
//                self.delegateSocketConnectionInit?.SocketConnectionInit()
//            }
//
//            NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "true"])
//
////            delegateStartOffLineData?.startOfflineData()
//
//        case .text(let string):
//            // Invalidate any existing timer
//            connectionCheckTimer?.invalidate()
//            connectionCheckTimer = nil
////            startConnectionCheckTimer()
//            handleWebSocketMessage(string)
//
//        case .disconnected(let reason, let code):
//            print("WebSocket is disconnected: \(reason) with code: \(code)")
//            GlobalVariable.instance.isConnected = false // Update connection state
//            attemptReconnect()
//
//            NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "false"])
//
//            delegateSocketPeerClosed?.peerClosed()
//
//        case .error(let error):
//            handleError(error)
//            attemptReconnect()
//
//            NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "false"])
//
//            delegateSocketPeerClosed?.peerClosed()
//
//        case .peerClosed:
//
//            print("peerClosed...")
//
//            delegateSocketPeerClosed?.peerClosed()
//
//            break
//
//        case .cancelled:
//            print("WebSocket cancelled... reconnect again")
////            connectWebSocket()
////            connectHistoryWebSocket()
//            attemptReconnect()
//
//        default:
//            print("WebSocket received an unhandled event: \(event)")
//
//            connectionCount = 0
//            isConnectionStableTimer()
////
//////            //MARK: - This Check is handle for Offline data.
//////            if !GlobalVariable.instance.socketNotSendData {
////////                GlobalVariable.instance.socketNotSendData = true
//////                delegateSocketNotSendData?.socketNotSendData()
//////            } else {
//////                attemptReconnect()
//////            }
////////            delegateSocketNotSendData?.socketNotSendData()
////
//////            attemptReconnect()
//        }
//    }
//
//
//    func filterSymbolsBySector(symbols: [SymbolData], sector: String) -> [String] {
//        return symbols.filter { $0.sector == sector }.map { $0.displayName }
//    }
//
//    private func setTradeModel(collectionViewIndex: Int) {
//        let symbols = GlobalVariable.instance.symbolDataArray
//        let sectors = GlobalVariable.instance.sectors
//
//        GlobalVariable.instance.filteredSymbols.removeAll()
//        GlobalVariable.instance.filteredSymbolsUrl.removeAll()
//
//        // Populate filteredSymbols and filteredSymbolsUrl for each sector
//        for sector in sectors {
//            let filteredSymbols = filterSymbolsBySector(symbols: symbols, sector: sector.sector)
//
//            GlobalVariable.instance.filteredSymbols.append(filteredSymbols)
//        }
//
//        // Append trades for the selected collectionViewIndex
//        let selectedSymbols = GlobalVariable.instance.filteredSymbols[safe: collectionViewIndex] ?? []
//        let selectedUrls = GlobalVariable.instance.filteredSymbolsUrl[safe: collectionViewIndex] ?? []
//
//       // print("GlobalVariable.instance.filteredSymbolsUrl = \(GlobalVariable.instance.filteredSymbolsUrl)")
//
//        //MARK: - Save symbol local to unsubcibe.
//        GlobalVariable.instance.previouseSymbolList = selectedSymbols
//
//        sendWebSocketMessage(for: "subscribeTrade", symbolList: selectedSymbols)
//    }
//    // Handle the WebSocket message
//    func handleWebSocketMessage(_ string: String) {
//        if let jsonData = string.data(using: .utf8) {
//            do {
//
//                var myType = ""
//
//                // Deserialize JSON data
//                do {
//                    // Deserialize data to a dictionary
//                    if let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
//
//                        // Access elements in the dictionary
//                        if let message = jsonDictionary["message"] as? [String: Any],
//                           let type = message["type"] as? String {
//
//                            myType = type
//
//                        } else {
//                            print("Error: Unexpected JSON format")
//                        }
//
//                    }
//                } catch {
//                    print("Error deserializing JSON: \(error.localizedDescription)")
//                }
//
//                if myType == "tick" {
//                    let genericResponse = try JSONDecoder().decode(WebSocketResponse<TradeDetails>.self, from: jsonData)
//                    handleTradeData(genericResponse.message.payload)
//
//                } else if myType == "get_chart_history" {
////                    let historyResponse = try JSONDecoder().decode(WebSocketResponse<SymbolChartData>.self, from: jsonData)
////                    handleHistoryData(historyResponse.message.payload)
//                } else if myType == "Unsubscribed" {
//                    handleUnsubscribedData()
//                } else {
//                    print("Unexpected message type: \(myType)")
//                }
//
//            } catch {
//                print("Error parsing JSON: \(error.localizedDescription)")
//            }
//        } else {
//            print("Error converting string to Data")
//        }
//    }
//
//
//    // Handle trade data
//    func handleTradeData(_ response: TradeDetails) {
//
//        delegateSocketData?.tradeUpdates(socketMessageType: .tick, tickMessage: response)
//        NotificationCenter.default.post(name: .tradesUpdated, object: response)
//
//    }
//
//    func handleUnsubscribedData() {
//        //Unsubscribed
//
//        if self.isTradeDismiss {
//            return
//        }
//
//        delegateSocketData?.tradeUpdates(socketMessageType: .Unsubscribed, tickMessage: nil)
//    }
//
//    // Handle errors
//    func handleError(_ error: Error?) {
//        if let error = error {
//            print("WebSocket encountered an error: \(error.localizedDescription)")
//        }
//    }
//
//    func closeWebSockets() {
//        webSocketQueue.async {
//            self.webSocket?.disconnect()
//        }
//    }
//    func getCurrentAndNextHourTimestamps() -> (current: Int, beforeHour: Int) {
//        let now = Date()
//        //        let calendar = Calendar.current
//
//        // Get current timestamp in milliseconds
//        let currentTimestamp = Int(now.timeIntervalSince1970) + (3 * 60 * 60)
//        let beforeHourTimestamp = currentTimestamp -  (24 * 60 * 60)
//
//        return (current: currentTimestamp, beforeHour: beforeHourTimestamp)
//    }
//
//
//    func currentAndBeforeBusinessDayTimestamps() -> (currentTimestamp: Int, previousTimestamp: Int) {
//        let timeZone = TimeZone(identifier: "UTC")!
//        let currentDate = Date()
//
//        // Get current date components
//        let components = Calendar.current.dateComponents(in: timeZone, from: currentDate)
//
//        // Create the current timestamp
//        let currentTimestamp = Int(currentDate.timeIntervalSince1970)
//
//        // Calculate previous business day
//        var previousBusinessDay = currentDate
//
//        // Check if the current day is a business day (for this example, we'll consider weekdays only)
//        let weekday = components.weekday ?? 1 // Default to Sunday (1)
//
//        // If today is Sunday (1), go back to Friday (5)
//        if weekday == 1 {
//            previousBusinessDay = Calendar.current.date(byAdding: .day, value: -2, to: currentDate)!
//        }
//        // If today is Monday (2), go back to Friday (5)
//        else if weekday == 2 {
//            previousBusinessDay = Calendar.current.date(byAdding: .day, value: -3, to: currentDate)!
//        }
//        // Otherwise, just go back one day
//        else {
//            previousBusinessDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
//        }
//
//        // Get previous timestamp
//        let previousTimestamp = Int(previousBusinessDay.timeIntervalSince1970)
//
//        return (currentTimestamp: currentTimestamp, previousTimestamp: previousTimestamp)
//    }
//
//}
