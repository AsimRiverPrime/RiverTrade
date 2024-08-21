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


struct WebSocketChartResponse: Codable {
    let id: Int
    let message: Message
}
struct Message: Codable {
    let type: String
    let payload: [Payload]
}
struct Payload: Codable {
    let symbol: String
    let askHigh: Double
    let askLow: Double
    let bidHigh: Double
    let bidLow: Double
    let lastHigh: Double
    let lastLow: Double
    let priceOpen: Double
    let priceClose: Double
    let datetime: Int

    private enum CodingKeys: String, CodingKey {
        case symbol
        case askHigh = "ask_high"
        case askLow = "ask_low"
        case bidHigh = "bid_high"
        case bidLow = "bid_low"
        case lastHigh = "last_high"
        case lastLow = "last_low"
        case priceOpen = "price_open"
        case priceClose = "price_close"
        case datetime
    }
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
    let chartData: [ChartData]

    // Custom coding keys to match the JSON keys
    enum CodingKeys: String, CodingKey {
        case symbol
        case chartData = "chart_data"
    }
}
