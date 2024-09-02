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


struct ChartData: Codable {
    let close: Double
    let datetime: Int
    let high: Double
    let low: Double
    let open: Double
}

// Model for the main structure
struct SymbolChartData: Codable {
    let symbol: String
    var chartData: [ChartData]

    // Custom coding keys to match the JSON keys
    enum CodingKeys: String, CodingKey {
        case symbol
        case chartData = "chart_data"
    }
}
