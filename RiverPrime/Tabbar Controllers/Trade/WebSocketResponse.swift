//
//  WebSocketResponse.swift
//  RiverPrime
//
//  Created by Ross Rostane on 13/08/2024.
//

import Foundation

struct WebSocketResponse<T: Codable>: Codable {
    let id: Int
    let message: Message<T>
    
    struct Message<T: Codable>: Codable {
        let type: String
        let payload: T
    }
}

// TradeDetails for trade data
struct TradeDetails: Codable {
    let datetime: Int
    let symbol: String
    let ask: Double
    let bid: Double
    let url: String?
    let close: Int?
}

// SymbolChartData for history/chart data
struct SymbolChartData: Codable {
    let symbol: String
    let chartData: [ChartData]
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case chartData = "chart_data"
    }
}

// Chart data details
struct ChartData: Codable {
    let close: Double
    let datetime: Int
    let high: Double
    let low: Double
    let open: Double
}
