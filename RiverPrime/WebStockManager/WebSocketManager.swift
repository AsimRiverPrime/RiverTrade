//
//  WebSocketManager.swift
//  RiverPrime
//
//  Created by Ross Rostane on 21/08/2024.
//

/*
import Foundation
import Starscream

class WebSocketManager: WebSocketDelegate {

    var webSocket: WebSocket?
    static let shared = WebSocketManager() // Shared instance

    private init() {}

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
    
    func connectWebSocket() {
        let url = URL(string: "wss://mbe.riverprime.com/mobile_web_socket")! // Same URL for both trade and history
        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
    }

    func sendWebSocketMessage(for event: String, symbol: String? = nil) {
        let (currentTimestamp, hourBeforeTimestamp) = getCurrentAndNextHourTimestamps()
        
        var message: [String: Any] = [:]

        // Prepare message based on event type (trade or history)
        if event == "subscribeTrade" {
            message = [
                "event_name": "subscribe",
                "data": [
                    "last": 0,
                    "channels": ["price_feed"]
                ]
            ]
        } else if event == "subscribeHistory" {
            
            let message: [String: Any] = [
                "event_name": "get_chart_history",
                "data": [
                    "symbol": symbol ?? "",
                    "from": hourBeforeTimestamp,
                    "to": currentTimestamp
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
            print("WebSocket is connected: \(headers)")

            // Subscribe to both trade and history once connected
            sendWebSocketMessage(for: "subscribeTrade")
//            sendWebSocketMessage(for: "subscribeHistory")

        case .text(let string):
            handleWebSocketMessage(string)

        case .disconnected(let reason, let code):
            print("WebSocket is disconnected: \(reason) with code: \(code)")

        case .error(let error):
            handleError(error)

        default:
            print("WebSocket received an unhandled event: \(event)")
        }
    }

    // Handle the WebSocket message
    func handleWebSocketMessage(_ string: String) {
        if let jsonData = string.data(using: .utf8) {
            do {
                // Determine the message type and decode based on that
                let genericResponse = try JSONDecoder().decode(WebSocketResponse<TradeDetails>.self, from: jsonData)
                
                if genericResponse.message.type == "tick" {
                    handleTradeData(genericResponse.message.payload)
                   
                } else if genericResponse.message.type == "ChartHistory" {
                    let historyResponse = try JSONDecoder().decode(WebSocketResponse<SymbolChartData>.self, from: jsonData)
                    handleHistoryData(historyResponse.message.payload)
                } else {
                    print("Unexpected message type: \(genericResponse.message.type)")
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
        WebSocketManager.shared.trades[response.symbol] = response
        print("Trade price tick details: \(WebSocketManager.shared.trades[response.symbol] ?? nil)")
//        for tradeDetail in response {
//            WebSocketManager.shared.trades[tradeDetail.symbol] = tradeDetail
//            print("Trade price tick details: \(trades[tradeDetail.symbol] ?? nil)")
//        }
        
    }

    // Handle history data
    func handleHistoryData(_ response: SymbolChartData) {
        // Handle history data here
        print("Received history data: \(response)")
      
        NotificationCenter.default.post(name: .symbolDataUpdated, object: response)
                
        for payload in response.chartData {
                    print("[DEBUG] Chart history payload: \(payload)")
                  
            }
            
    
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
}
*/


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
//            self.connectHistoryWebSocket()
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
                    "channels": ["Gold"]
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
                print("Trade price tick details: \(response)")
                guard response.message.type == "tick" else {
                    print("Unexpected message type: \(response.message.type)")
                    return
                }
                let tradeDetails = response.message.payload
                   WebSocketManager.shared.trades[tradeDetails.symbol] = tradeDetails
                   
                   // Print the updated trade details for the symbol
                   print("\n Updated trade details: \(WebSocketManager.shared.trades[tradeDetails.symbol] ?? nil)")
//                for tradeDetail in response.message.payload {
////                    self.getSymbolHistory(tradeDetail)
//                    WebSocketManager.shared.trades[tradeDetail.symbol] = tradeDetail
//                    print("Trade price tick details: \(trades[tradeDetail.symbol])")
//                }
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

