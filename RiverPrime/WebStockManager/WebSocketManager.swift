
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

enum SocketURLType {
    case demo
    case live

    var url: String {
        switch self {
        case .demo:
            return "ws://2.59.169.158:8074"
        case .live:
            return "ws://2.59.169.158:8075"
        }
    }
}

class WebSocketManager: WebSocketDelegate {

    var webSocket: Starscream.WebSocket?
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
                connectWebSocket(socketURLType: GlobalVariable.instance.socketURLType)
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
        connectWebSocket(socketURLType: GlobalVariable.instance.socketURLType)
        
        //MARK: - Save symbol local to unsubcibe.
        sendWebSocketMessage(for: "unsubscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList, isTradeDismiss: true)
        //MARK: - START calling Socket message from here.
        sendWebSocketMessage(for: "subscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList)
    }

    // Check if the socket is connected
    func isSocketConnected() -> Bool {
        return GlobalVariable.instance.isConnected
    }

    func connectWebSocket(socketURLType: SocketURLType) {
//        let url = URL(string: "wss://mbe.riverprime.com/mobile_web_socket")!

        GlobalVariable.instance.socketURLType = socketURLType
        guard let url = URL(string: socketURLType.url) else {
            print("Invalid URL for socket type: \(socketURLType)")
            return
        }
        print("socket URL get: \(url)")
        
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
                connectWebSocket(socketURLType: GlobalVariable.instance.socketURLType)
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
//                    print("tick  message type: \(myType)")
                } else if myType == "get_chart_history" {
//                    let historyResponse = try JSONDecoder().decode(WebSocketResponse<SymbolChartData>.self, from: jsonData)
//                    handleHistoryData(historyResponse.message.payload)
                    print("get_chart_history message type: \(myType)")
                } else if myType == "Unsubscribed" {
                    print("Unsubscribed message type: \(myType)")
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
