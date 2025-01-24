
//
//  WebSocketManager.swift
//  RiverPrime
//
//  Created by Ross Rostane on 21/08/2024.
//

import Foundation
import Starscream

enum SocketMessageType {
    case tick
    case Unsubscribed
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

class WebSocketManager: WebSocketDelegate {

    var webSocket: WebSocket?
    static let shared = WebSocketManager() // Shared instance
    
    var connectionCheckTimer: Timer?

    private init() {}
    
    public weak var delegateSocketData: GetSocketData?
    public weak var delegateCandleSocketMessage: GetCandleData?
    public weak var delegateSocketPeerClosed: SocketPeerClosed?
    public weak var delegateSocketConnectionInit: SocketConnectionInitDelegate?
    public weak var delegateSocketNotSendData: SocketNotSendDataDelegate?
    
    var isTradeDismiss = Bool()

    var reconnectAttempts = 0
    
    private let webSocketQueue = DispatchQueue(label: "webSocketQueue", qos: .background)
  
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

    @objc private func checkConnection() {
        if isSocketConnected() {
            print("WebSocket is connected.")
        } else {
            print("WebSocket is disconnected.")
        }
        
        
        startConnectionCheckTimer()
        
        print("GlobalVariable.instance.socketTimerCount = \(GlobalVariable.instance.socketTimerCount)")
        print("GlobalVariable.instance.socketTimer = \(GlobalVariable.instance.socketTimer)")
        
        DisconnectWebSocket()
        connectWebSocket()
        
        print("GlobalVariable.instance.previouseSymbolList = \(GlobalVariable.instance.previouseSymbolList)")
        print("GlobalVariable.instance.tempPreviouseSymbolList = \(GlobalVariable.instance.tempPreviouseSymbolList)")
        
        //MARK: - Save symbol local to unsubcibe.
        sendWebSocketMessage(for: "unsubscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList, isTradeDismiss: true)
        //MARK: - START calling Socket message from here.
        sendWebSocketMessage(for: "subscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList)
        
//        delegateSocketNotSendData?.socketNotSendData(isCalled: T##Bool)
    }

    // Check if the socket is connected
    func isSocketConnected() -> Bool {
        return GlobalVariable.instance.isConnected
    }


    func connectWebSocket() {
        let url = URL(string: "wss://mbe.riverprime.com/mobile_web_socket")! // Same URL for both trade and history
//        let url = URL(string: "ws://192.168.3.169:8073")!
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
    
    func getSavedSymbols() -> [SymbolData]? {
        let savedSymbolsKey = "savedSymbolsKey"
        if let savedSymbols = UserDefaults.standard.data(forKey: savedSymbolsKey) {
            let decoder = JSONDecoder()
            return try? decoder.decode([SymbolData].self, from: savedSymbols)
        }
        return nil
    }
    
    // WebSocket delegate method
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("WebSocket is connected: \(headers)")
            GlobalVariable.instance.isConnected = true // Update connection state
            reconnectAttempts = 0

            //MARK: - This Check is handle for Offline data.
            if !GlobalVariable.instance.socketNotSendData {
                self.delegateSocketConnectionInit?.SocketConnectionInit()
            }
            
            NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "true"])
           
        case .text(let string):
            // Invalidate any existing timer
            connectionCheckTimer?.invalidate()
            connectionCheckTimer = nil
            startConnectionCheckTimer()
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
//            //MARK: - This Check is handle for Offline data.
//            if !GlobalVariable.instance.socketNotSendData {
////                GlobalVariable.instance.socketNotSendData = true
//                delegateSocketNotSendData?.socketNotSendData()
//            } else {
//                attemptReconnect()
//            }
////            delegateSocketNotSendData?.socketNotSendData()
            
//            attemptReconnect()
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


//  WebSocketManager.swift
//  RiverPrime
//
//  Created by Ross Rostane on 21/08/2024.
//
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
//class WebSocketManager: WebSocketDelegate {
//
//    var webSocket: WebSocket?
//    static let shared = WebSocketManager() // Shared instance
//    
//    var connectionCheckTimer: Timer?
//
//    private init() {}
//    
//    public weak var delegateSocketData: GetSocketData?
//    public weak var delegateCandleSocketMessage: GetCandleData?
//    public weak var delegateSocketPeerClosed: SocketPeerClosed?
//    public weak var delegateSocketConnectionInit: SocketConnectionInitDelegate?
//    public weak var delegateSocketNotSendData: SocketNotSendDataDelegate?
//    
//    var isTradeDismiss = Bool()
//
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
//    private func startConnectionCheckTimer() {
//        // Invalidate existing timer
//        connectionCheckTimer?.invalidate()
//        connectionCheckTimer = nil
//        
//        // Create a new timer with the current interval
//        connectionCheckTimer = Timer.scheduledTimer(timeInterval: GlobalVariable.instance.socketTimer, target: self, selector: #selector(checkConnection), userInfo: nil, repeats: true)
//    }
//
//    @objc private func checkConnection() {
//        if isSocketConnected() {
//            print("WebSocket is connected.")
//        } else {
//            print("WebSocket is disconnected.")
//        }
//        
//        
//        startConnectionCheckTimer()
//        
//        print("GlobalVariable.instance.socketTimerCount = \(GlobalVariable.instance.socketTimerCount)")
//        print("GlobalVariable.instance.socketTimer = \(GlobalVariable.instance.socketTimer)")
//        
//        connectWebSocket()
//        
//        print("GlobalVariable.instance.previouseSymbolList = \(GlobalVariable.instance.previouseSymbolList)")
//        print("GlobalVariable.instance.tempPreviouseSymbolList = \(GlobalVariable.instance.tempPreviouseSymbolList)")
//        
//        //MARK: - Save symbol local to unsubcibe.
//        sendWebSocketMessage(for: "unsubscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList, isTradeDismiss: true)
//        //MARK: - START calling Socket message from here.
//        sendWebSocketMessage(for: "subscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList)
//        
////        delegateSocketNotSendData?.socketNotSendData(isCalled: <#T##Bool#>)
//    }
//
//    // Check if the socket is connected
//    func isSocketConnected() -> Bool {
//        return GlobalVariable.instance.isConnected
//    }
//
//
//    func connectWebSocket() {
//        let url = URL(string: "wss://mbe.riverprime.com/mobile_web_socket")! // Same URL for both trade and history
////        let url = URL(string: "ws://192.168.3.169:8073")!
//        var request = URLRequest(url: url)
//        request.timeoutInterval = 5
//
//        webSocket = WebSocket(request: request)
//        webSocket?.delegate = self
//        webSocket?.connect()
//    }
//    
//    func disconnectWebSocket() {
//        if isSocketConnected() {
//            webSocket?.disconnect()
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
//    func getSavedSymbols() -> [SymbolData]? {
//        let savedSymbolsKey = "savedSymbolsKey"
//        if let savedSymbols = UserDefaults.standard.data(forKey: savedSymbolsKey) {
//            let decoder = JSONDecoder()
//            return try? decoder.decode([SymbolData].self, from: savedSymbols)
//        }
//        return nil
//    }
//    
//    // WebSocket delegate method
//    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
//        switch event {
//        case .connected(let headers):
//            print("WebSocket is connected: \(headers)")
//            GlobalVariable.instance.isConnected = true // Update connection state
//
//            //MARK: - This Check is handle for Offline data.
//            if !GlobalVariable.instance.socketNotSendData {
//                self.delegateSocketConnectionInit?.SocketConnectionInit()
//            }
//            
//            NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "true"])
//           
//        case .text(let string):
//            // Invalidate any existing timer
//            connectionCheckTimer?.invalidate()
//            connectionCheckTimer = nil
//            startConnectionCheckTimer()
//            handleWebSocketMessage(string)
//
//        case .disconnected(let reason, let code):
//            print("WebSocket is disconnected: \(reason) with code: \(code)")
//            GlobalVariable.instance.isConnected = false // Update connection state
//
//            NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "false"])
//            
//            delegateSocketPeerClosed?.peerClosed()
//            
//        case .error(let error):
//            handleError(error)
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
//
//        default:
//            print("WebSocket received an unhandled event: \(event)")
//            //MARK: - This Check is handle for Offline data.
//            if !GlobalVariable.instance.socketNotSendData {
////                GlobalVariable.instance.socketNotSendData = true
//                delegateSocketNotSendData?.socketNotSendData()
//            }
////            delegateSocketNotSendData?.socketNotSendData()
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
//    
//
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
//        
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
