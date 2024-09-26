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
    case history
    case Unsubscribed
}

protocol GetSocketMessages: AnyObject {
//    func tradeUpdates(tickMessage: TradeDetails? = nil, historyMessage: SymbolChartData? = nil)
    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?, historyMessage: SymbolChartData?)
}

protocol GetCandleData: AnyObject {
    func tradeHistoryUpdates(socketMessageType: SocketMessageType, historyMessage: SymbolChartData?)
}

class WebSocketManager: WebSocketDelegate {

    var webSocket: WebSocket?
    static let shared = WebSocketManager() // Shared instance

    private init() {}
    
    public weak var delegateSocketMessage: GetSocketMessages?
    public weak var delegateCandleSocketMessage: GetCandleData?

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
    
    // Check if the socket is connected
    func isSocketConnected() -> Bool {
        return GlobalVariable.instance.isConnected
    }

    func connectWebSocket() {
        let url = URL(string: "wss://mbe.riverprime.com/mobile_web_socket")! // Same URL for both trade and history
        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
    }
    
    func disconnectWebSocket() {
        if isSocketConnected() {
            webSocket?.disconnect()
        }
    }

    func sendWebSocketMessage(for event: String, symbol: String? = nil, symbolList: [String]? = nil) {
        let (currentTimestamp, hourBeforeTimestamp) = getCurrentAndNextHourTimestamps()
        
        let timestamps = currentAndBeforeBusinessDayTimestamps()
        print("Current Timestamp: \(timestamps.currentTimestamp)")
        print("Previous Business Day Timestamp: \(timestamps.previousTimestamp)")

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
            
//            message = [
//                "event_name": "subscribe",
//                "data": [
//                    "last": 0,
////                    "channels": ["price_feed"]
//                    "channels": [symbol ?? ""] //["Gold","Silver"]
//                ]
//            ]
        } else if event == "subscribeHistory" {
            
            //MARK: - get_chart_history body values.
            /*
            Printing description of message:
            ▿ 2 elements
              ▿ 0 : 2 elements
                - key : "event_name"
                - value : "get_chart_history"
              ▿ 1 : 2 elements
                - key : "data"
                ▿ value : 3 elements
                  ▿ 0 : 2 elements
                    - key : "symbol"
                    - value : "NDX100"
                  ▿ 1 : 2 elements
                    - key : "from"
                    - value : 1726068497
                  ▿ 2 : 2 elements
                    - key : "to"
                    - value : 1726072097
            */
            
            message = [
                "event_name": "get_chart_history",
                "data": [
                    "symbol": symbol ?? "",
                    "from": timestamps.previousTimestamp,
                    "to":  timestamps.currentTimestamp
//                    "from": hourBeforeTimestamp,
//                    "to": currentTimestamp
                ]
            ]
            
        } else if event == "unsubscribeTrade" {
//            print("symbolList = \(symbolList)")
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

            NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "true"])

//            let symbol = getSavedSymbols().map { $0 }
//            print("symbol?[0].name = \(symbol?[0].name)")
//            sendWebSocketMessage(for: "subscribeTrade", symbol: symbol?[0].name)
            
            
            /*
            let symbol = getSavedSymbols().map { $0 }
            let sector = GlobalVariable.instance.sectors.map { $0.sector }
            GlobalVariable.instance.getSelectedSectorSymbols.1.removeAll()
            guard let mySymbol = symbol else { return }
            if sector.count == 0 {
                return
            }
            for item in mySymbol {
                if sector[0] == item.sector {
                    GlobalVariable.instance.getSelectedSectorSymbols.1.append(item.name)
                }
            }
            sendWebSocketMessage(for: "subscribeTrade", symbolList: GlobalVariable.instance.getSelectedSectorSymbols.1)
            */
            
            //This method is call from tradeVC according to the selection of collectionview.
            setTradeModel(collectionViewIndex: 0)
             
            
            
            
//            // Subscribe to both trade and history once connected
//            sendWebSocketMessage(for: "subscribeTrade")
////            sendWebSocketMessage(for: "subscribeHistory")

        case .text(let string):
            handleWebSocketMessage(string)

        case .disconnected(let reason, let code):
            print("WebSocket is disconnected: \(reason) with code: \(code)")
            GlobalVariable.instance.isConnected = false // Update connection state

            NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "false"])

        case .error(let error):
            handleError(error)
            
            NotificationCenter.default.post(name: .checkSocketConnectivity, object: nil, userInfo: ["isConnect": "false"])

        default:
            print("WebSocket received an unhandled event: \(event)")
        }
    }
    
    
    func filterSymbolsBySector(symbols: [SymbolData], sector: String) -> [String] {
        return symbols.filter { $0.sector == sector }.map { $0.displayName }
    }
    
    private func setTradeModel(collectionViewIndex: Int) {
        let symbols = GlobalVariable.instance.symbolDataArray
        let sectors = GlobalVariable.instance.sectors
        
//        // Clear previous data
//        vm.trades.removeAll()
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
        
//        for (symbol, url) in zip(selectedSymbols, selectedUrls) {
//            vm.trades.append(TradeDetails(datetime: 0, symbol: symbol, ask: 0.0, bid: 0.0, url: url))
//        }
        
        print("GlobalVariable.instance.filteredSymbolsUrl = \(GlobalVariable.instance.filteredSymbolsUrl)")
        
        //MARK: - Save symbol local to unsubcibe.
        GlobalVariable.instance.previouseSymbolList = selectedSymbols
        
        sendWebSocketMessage(for: "subscribeTrade", symbolList: selectedSymbols)
    }
    

    // Handle the WebSocket message
    func handleWebSocketMessage(_ string: String) {
        if let jsonData = string.data(using: .utf8) {
            do {
                // Determine the message type and decode based on that
                
//                print("string = \(string)")
//                print("jsonData = \(jsonData)")
                
                var myType = ""
                
                // Deserialize JSON data
                do {
                    // Deserialize data to a dictionary
                    if let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        
                        // Access elements in the dictionary
                        if let message = jsonDictionary["message"] as? [String: Any],
                           let type = message["type"] as? String {
                            
                            // Print out values to verify
                            print("Message Type: \(type)")
                            
                            myType = type
                            
                        } else {
                            print("Error: Unexpected JSON format")
                        }
                        
//                        // Access elements in the dictionary
//                        if let id = jsonDictionary["id"] as? Int,
//                           let message = jsonDictionary["message"] as? [String: Any],
//                           let type = message["type"] as? String,
//                           let payload = message["payload"] as? [String: Any],
//                           let symbol = payload["symbol"] as? String,
//                           let ask = payload["ask"] as? Double,
//                           let bid = payload["bid"] as? Double,
//                           let datetime = payload["datetime"] as? Int {
//
//                            // Print out values to verify
//                            print("ID: \(id)")
//                            print("Message Type: \(type)")
//                            print("Symbol: \(symbol)")
//                            print("Ask: \(ask)")
//                            print("Bid: \(bid)")
//                            print("Datetime: \(datetime)")
//
//                            myType = type
//
//                        } else {
//                            print("Error: Unexpected JSON format")
//                        }
                    }
                } catch {
                    print("Error deserializing JSON: \(error.localizedDescription)")
                }
                
                if myType == "tick" {
                    let genericResponse = try JSONDecoder().decode(WebSocketResponse<TradeDetails>.self, from: jsonData)
                    handleTradeData(genericResponse.message.payload)
                   
                } else if myType == "ChartHistory" {
                    let historyResponse = try JSONDecoder().decode(WebSocketResponse<SymbolChartData>.self, from: jsonData)
                    handleHistoryData(historyResponse.message.payload)
                } else if myType == "Unsubscribed" {
                    handleUnsubscribedData()
                } else {
                    print("Unexpected message type: \(myType)")
                }
                
//                if "genericResponse.message.type" == "tick" {
//                    let genericResponse = try JSONDecoder().decode(WebSocketResponse<TradeDetails>.self, from: jsonData)
//                    handleTradeData(genericResponse.message.payload)
//
//                } else if "genericResponse.message.type" == "ChartHistory" {
//                    let historyResponse = try JSONDecoder().decode(WebSocketResponse<SymbolChartData>.self, from: jsonData)
//                    handleHistoryData(historyResponse.message.payload)
//                } else {
//                    print("Unexpected message type: \("genericResponse.message.type")")
//                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        } else {
            print("Error converting string to Data")
        }
    }


//    // Handle trade data
//    func handleTradeData(_ response: [TradeDetails]) {
//        for tradeDetail in response {
//            WebSocketManager.shared.trades[tradeDetail.symbol] = tradeDetail
//            print("Trade price tick details: \(trades[tradeDetail.symbol] ?? nil)")
//        }
//
//    }
    
    // Handle trade data
    func handleTradeData(_ response: TradeDetails) {
        
        delegateSocketMessage?.tradeUpdates(socketMessageType: .tick, tickMessage: response, historyMessage: nil)
        NotificationCenter.default.post(name: .tradesUpdated, object: response)
        
//        GlobalVariable.instance.changeSymbol = false
//        GlobalVariable.instance.changeSector = false
//        WebSocketManager.shared.trades[response.symbol] = response
        
//        GlobalVariable.instance.changeSymbol = false
//        GlobalVariable.instance.changeSector = false
//        WebSocketManager.shared.trades[response.symbol] = response
//
////        setTradeModel(collectionViewIndex: GlobalVariable.instance.tradeCollectionViewIndex.0)
//
//        print("Trade price tick details: \(WebSocketManager.shared.trades[response.symbol] ?? nil)")
////        for tradeDetail in response {
////            WebSocketManager.shared.trades[tradeDetail.symbol] = tradeDetail
////            print("Trade price tick details: \(trades[tradeDetail.symbol] ?? nil)")
////        }
        
    }

    // Handle history data
    func handleHistoryData(_ response: SymbolChartData) {
        // Handle history data here
        print("Received history data: \(response)")
        
        delegateSocketMessage?.tradeUpdates(socketMessageType: .history, tickMessage: nil, historyMessage: response)
        
        delegateCandleSocketMessage?.tradeHistoryUpdates(socketMessageType: .history, historyMessage: response)
      
//        GlobalVariable.instance.isProcessingSymbol = false
//        GlobalVariable.instance.isStopTick = true
//        NotificationCenter.default.post(name: .symbolDataUpdated, object: response)
//
//        for payload in response.chartData {
//                    print("[DEBUG] Chart history payload: \(payload)")
//
//            }
            
    
    }
    
    func handleUnsubscribedData() {
        //Unsubscribed
        delegateSocketMessage?.tradeUpdates(socketMessageType: .Unsubscribed, tickMessage: nil, historyMessage: nil)
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
        let beforeHourTimestamp = currentTimestamp -  (1 * 60 * 60)
        
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
/*

import Foundation
import Starscream


class WebSocketManager: WebSocketDelegate {

    var historyWebSocket: WebSocket?
    var tradeWebSocket: WebSocket?
    //    var viewModel = TradesViewModel()
    static let shared = WebSocketManager()
    
    private var processedSymbols: Set<String> = []
       
       // Queue to manage the sequential processing of symbols
       private var symbolQueue: [String] = []
       
       // A flag to indicate if the history API is currently being called
       private var isProcessing: Bool = false
       
    
    private init() {}

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
    
    // DispatchQueues for concurrent execution
    private let historyQueue = DispatchQueue(label: "historyQueue", qos: .background)
    private let tradeQueue = DispatchQueue(label: "tradeQueue", qos: .background)

    func connectAllWebSockets() {
//        DispatchQueue.main
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.connecttradeWebSocket()
            
        }
//        DispatchQueue.main.async
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.connectHistoryWebSocket()
        }

    }

    private func connectHistoryWebSocket() {
//        let url = URL(string: "wss://mbe.riverprime.com/websocket")!
        let url = URL(string: "wss://mbe.riverprime.com/mobile_web_socket")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        historyWebSocket = WebSocket(request: request)
        historyWebSocket?.delegate = self
        historyWebSocket?.connect()
    }

    private func connecttradeWebSocket() {
        let url = URL(string: "wss://mbe.riverprime.com/mobile_web_socket")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        tradeWebSocket = WebSocket(request: request)
        tradeWebSocket?.delegate = self
        tradeWebSocket?.connect()
    }

    func sendSubscriptionHistoryMessage(for symbol: String) {
  
        let (currentTimestamp, hourBeforeTimestamp) = getCurrentAndNextHourTimestamps()
        let message: [String: Any] = [
            "event_name": "get_chart_history",
            "data": [
                "symbol": symbol,
                "from": hourBeforeTimestamp,
                "to": currentTimestamp
            ]
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("\n json String sent to history WebSocket. \(jsonString) ")

                if let historyWebSocket = self.historyWebSocket {
                    historyWebSocket.write(string: jsonString)
                    print("Message sent to history WebSocket.")
                } else {
                    print("History WebSocket is not connected.")
                }

        }
    }
   
    
    func sendtradeWebSocketMessage() {
        
        let message: [String: Any] = [
                "event_name": "subscribe",
                "data": [
                    "last": 0,
                    "channels": ["price_feed"]
                ]
            ]
           

        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
//            tradeQueue.async {
                if let tradeWebSocket = self.tradeWebSocket {
                    tradeWebSocket.write(string: jsonString)
                    print("Message sent to trade WebSocket.")
                } else {
                    print("Trade WebSocket is not connected.")
                }
            }
        
    }

    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        if client === historyWebSocket {
             handleHistoryWebSocketEvent(event)
        } else if client === tradeWebSocket {
            handletradeWebSocketEvent(event)
        }
    }

    func handleHistoryWebSocketEvent(_ event: WebSocketEvent) {
        switch event {
        case .connected(let headers):
            print("[DEBUG] History WebSocket connected successfully at \(Date()) with headers: \(headers)")
          
        case .text(let string):
            print("[DEBUG] Received text message from History WebSocket at \(Date()): \(string.prefix(120))...")
            handleHistoryWebSocketMessage(string)
           
        case .disconnected(let reason, let code):
            print("[DEBUG] History WebSocket disconnected at \(Date()) with reason: \(reason) and code: \(code)")
        case .error(let error):
            print("[ERROR] History WebSocket encountered an error at \(Date()): \(error?.localizedDescription ?? "Unknown error")")
            handleHistoryError(error)
        case .viabilityChanged(let isViable):
            print("[DEBUG] History WebSocket viability changed at \(Date()): \(isViable ? "Connection is viable" : "Connection is not viable")")
        case .reconnectSuggested(let shouldReconnect):
            print("[DEBUG] History WebSocket reconnect suggested at \(Date()): \(shouldReconnect ? "Reconnection suggested" : "Reconnection not suggested")")
        default:
            print("[DEBUG] History WebSocket received an unhandled event at \(Date()): \(event)")
        }
    }

    func handleHistoryWebSocketMessage(_ string: String) {
        print("[DEBUG] Received chart history JSON string: \(string)")
        GlobalVariable.instance.isProcessingSymbol = false
        if let jsonData = string.data(using: .utf8) {
            do {
                let response = try JSONDecoder().decode(SymbolChartData.self, from: jsonData)
           //     print("\n [DEBUG] Parsed response: \(response)")
                NotificationCenter.default.post(name: .symbolDataUpdated, object: response)
                
                for payload in response.message.payload.chartData {
                    print("[DEBUG] Chart history payload: \(payload)")
                  
                }
            } catch {
                print("[ERROR] Error parsing JSON: \(error)")
            }
        } else {
            print("[ERROR] Error converting string to Data")
        }
    }

    func handleHistoryError(_ error: Error?) {
        if let error = error {
            print("History WebSocket encountered an error: \(error)")
        }
    }

    func handletradeWebSocketEvent(_ event: WebSocketEvent) {
        switch event {
        case .connected(let headers):
            print("Trade WebSocket is connected: \(headers)")
            tradeQueue.async {
                self.sendtradeWebSocketMessage()
            }
        case .text(let string):
            handleWebSocketMessage(string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .disconnected(let reason, let code):
            print("Trade WebSocket is disconnected: \(reason) with code: \(code)")
        case .error(let error):
            handleError(error)
        default:
            print("Trade WebSocket received an unhandled event: \(event)")
        }
    }

    func handleWebSocketMessage(_ string: String) {
        if let jsonData = string.data(using: .utf8) {
            do {
                let response = try JSONDecoder().decode(WebSocketResponse.self, from: jsonData)
                guard response.message.type == "tick" else {
                    print("Unexpected message type: \(response.message.type)")
                    return
                }
                
                for tradeDetail in response.message.payload {
//                    self.getSymbolHistory(tradeDetail)
                    WebSocketManager.shared.trades[tradeDetail.symbol] = tradeDetail
                    print("Trade price tick details: \(trades[tradeDetail.symbol])")
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        } else {
            print("Error converting string to Data")
        }
    }

    func getSymbolHistory(_ trade: TradeDetails){
        self.sendSubscriptionHistoryMessage(for: trade.symbol)
    }
    
    func handleError(_ error: Error?) {
        if let error = error {
            print("WebSocket encountered an error: \(error)")
        }
    }

    func closeAllWebSockets() {
        historyQueue.async {
            self.historyWebSocket?.disconnect()
        }
        tradeQueue.async {
            self.tradeWebSocket?.disconnect()
        }
    }
    
    func getCurrentAndNextHourTimestamps() -> (current: Int, beforeHour: Int) {
        let now = Date()
        //        let calendar = Calendar.current
        
        // Get current timestamp in milliseconds
        let currentTimestamp = Int(now.timeIntervalSince1970) + (3 * 60 * 60)
        let beforeHourTimestamp = currentTimestamp -  (1 * 60 * 60)
        
        return (current: currentTimestamp, beforeHour: beforeHourTimestamp)
        
    }
}


 */
