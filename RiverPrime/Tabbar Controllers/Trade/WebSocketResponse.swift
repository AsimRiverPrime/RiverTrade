//
//  WebSocketResponse.swift
//  RiverPrime
//
//  Created by Ross Rostane on 13/08/2024.
//

import Foundation

struct WebSocketResponse: Codable {
    let id: Int
    let message: Message
    
    struct Message: Codable {
        let type: String
        let payload: [TradeDetails]
    }
}

struct TradeDetails: Codable {
    let datetime: Int
    let symbol: String
    let ask: Double
    let bid: Double
}


//MARKS: - history chart data
//struct ChartHistoryProgress: Codable {
//    let close: Double?
//    let datetime: Int?
//}

//struct ChartData: Codable {
//    let close: Double
//    let datetime: Int
//    let high: Double
//    let low: Double
//    let open: Double
//}
//
//// Model for the main structure
//struct SymbolChartData: Codable {
//    let symbol: String
//    var chartData: [ChartData]
//
//    // Custom coding keys to match the JSON keys
//    enum CodingKeys: String, CodingKey {
//        case symbol
//        case chartData = "chart_data"
//    }
//}
struct SymbolChartData: Codable {
    let id: Int
    let message: Message
}

// MARK: - Message
struct Message: Codable {
    let type: String
    let payload: Payload
}

// MARK: - Payload
struct Payload: Codable {
    let symbol: String
    let chartData: [ChartData]

    enum CodingKeys: String, CodingKey {
        case symbol
        case chartData = "chart_data"
    }
}

// MARK: - ChartData
struct ChartData: Codable {
    let close: Double
    let datetime: Int
    let high: Double
    let low: Double
    let open: Double
}
