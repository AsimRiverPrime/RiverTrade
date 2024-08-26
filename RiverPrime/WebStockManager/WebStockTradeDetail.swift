//
//  WebStockTradeDetail.swift
//  RiverPrime
//
//  Created by Ross Rostane on 26/08/2024.
//

import Foundation
import Starscream

class WebStockTradeDetail:  WebSocketDelegate {
    
    var webSocket : WebSocket!
    var tradeDetails: TradeDetails?

    
    func connectHistoryWebSocket() {
        //        let url =  URL(string:"ws://192.168.3.107:8069/websocket")!
        let url =  URL(string:"wss://mbe.riverprime.com/websocket")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        webSocket = WebSocket(request: request)
        webSocket.delegate = self
        webSocket.connect()
    }
    
    func sendSubscriptionHistoryMessage() {
        // Define the message dictionary
        let (currentTimestamp, hourBeforeTimestamp) = getCurrentAndNextHourTimestamps()
        
        let message: [String: Any] = [
            "event_name": "get_chart_history",
            "data": [
                "symbol":  tradeDetails?.symbol ?? "",
                "from": hourBeforeTimestamp,
                "to":  currentTimestamp
            ]
        ]
        
        // Convert the dictionary to JSON string
        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            //            socket write(string: jsonString)
            print("the message is \(jsonString)")
            webSocket.write(string: jsonString)
        }
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("\n WebSocket chart is connected: \(headers)")
            sendSubscriptionHistoryMessage() // Send the message once connected
        case .disconnected(let reason, let code):
            print("WebSocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            handleHistoryWebSocketMessage(string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .error(let error):
            handleHistoryError(error)
        default:
            break
        }
    }
    
    func handleHistoryWebSocketMessage(_ string: String) {
        print("\n this is history json: \(string)\n")
        if let jsonData = string.data(using: .utf8) {
            do {
                let response = try JSONDecoder().decode(SymbolChartData.self, from: jsonData)
                
                for payload in response.chartData {
                    
//                    let times = Time.utc(timestamp: Double(payload.datetime))
                    // Debugging output to check timestamps
                    
//                    print("\n Candlestick each array object data: \(payload)")
                    
                    let open = payload.open
                    let close = payload.close
                    let high = payload.high
                    let low = payload.low
                    
//                    let dataPoint = CandlestickData(
//                        time: times,
//                        open: open,
//                        high: high,
//                        low: low,
//                        close: close
//                    )
                    
                    // Use update to add this candlestick incrementally
//                    series?.update(bar: dataPoint)
//                    candlestickData.append(dataPoint)
                }
//                series.setData(data: candlestickData)
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
    }
    func handleHistoryError(_ error: Error?) {
        if let error = error {
            print("History chart WebSocket encountered an error: \(error)")
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
