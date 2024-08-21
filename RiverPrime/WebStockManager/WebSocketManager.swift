//
//  WebSocketManager.swift
//  RiverPrime
//
//  Created by Ross Rostane on 21/08/2024.
//

import Foundation
import Starscream

class WebSocketManager: WebSocketDelegate {
    
    var webSocket : WebSocket!
    
    static let shared = WebSocketManager()
    private init() {}
    
    var trades: [String: TradeDetails] = [:] 
    {
        didSet {
            NotificationCenter.default.post(name: .tradesUpdated, object: nil)
        }
    }
    
    func connect() {
//        let url =  URL(string:"ws://192.168.3.107:8069/websocket")!
        let url =  URL(string:"wss://mbe.riverprime.com/websocket")!
        var request = URLRequest(url: url)
             request.timeoutInterval = 5
     
        webSocket = WebSocket(request: request)
        webSocket.delegate = self
        webSocket.connect()
    }
    
    func sendSubscriptionMessage() {
        // Define the message dictionary
        let message: [String: Any] = [
            "event_name": "subscribe",
            "data": [
                "last": 0,
                "channels": ["price_tick"]
//                "channels": ["price_chart"]
            ]
        ]

        // Convert the dictionary to JSON string
        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("the message is \(jsonString)")
            webSocket.write(string: jsonString)
        }
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
                case .connected(let headers):
                    print("WebSocket is connected: \(headers)")
                    sendSubscriptionMessage() // Send the message once connected
                case .disconnected(let reason, let code):
                    print("WebSocket is disconnected: \(reason) with code: \(code)")
                case .text(let string):
                    handleWebSocketMessage(string)
                case .binary(let data):
                    print("Received data: \(data.count)")
                case .error(let error):
                    handleError(error)
                default:
                    break
                }
    }

    func handleWebSocketMessage(_ string: String) {
//        print("Received JSON string: \(string) \n")
        
        if let jsonData = string.data(using: .utf8) {
            do {
                // Decode the JSON into a WebSocketResponse
                let response = try JSONDecoder().decode(WebSocketResponse.self, from: jsonData)
                
                // Ensure the message type is what you're expecting (e.g., "tick")
                guard response.message.type == "tick" else {
                    print("Unexpected message type: \(response.message.type)")
                    return
                }
                
                // Process each trade detail
                for tradeDetail in response.message.payload {
                    // Store the trade details or update your data model
                    WebSocketManager.shared.trades[tradeDetail.symbol] = tradeDetail
                    
                    print("Trade details: \(trades[tradeDetail.symbol]!)")
                }
                NotificationCenter.default.post(name: .tradesUpdated, object: nil)
                
            } catch let error as DecodingError {
                switch error {
                case .typeMismatch(let type, let context):
                    print("Type mismatch error for type \(type): \(context.debugDescription), codingPath: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("Value not found error for type \(type): \(context.debugDescription), codingPath: \(context.codingPath)")
                case .keyNotFound(let key, let context):
                    print("Key not found error for key \(key): \(context.debugDescription), codingPath: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("Data corrupted error: \(context.debugDescription), codingPath: \(context.codingPath)")
                default:
                    print("Decoding error: \(error.localizedDescription)")
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                print("Error parsing JSON: \(error)\n")
            }
        } else {
            print("Error converting string to Data")
        }
    }

    func handleError(_ error: Error?) {
        if let error = error {
            print("WebSocket encountered an error: \(error)")
        }
    }
    
    func closeWebSocket() {
            webSocket.disconnect()
        }
    
    
}
