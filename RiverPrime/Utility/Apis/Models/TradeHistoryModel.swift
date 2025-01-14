//
//  TradeHistoryModel.swift
//  RiverPrime
//
//  Created by Ross Rostane on 04/11/2024.
//

import Foundation

struct ChartHistoryData: Codable {
    let close: Double
    let datetime: Int
    let high: Double
    let low: Double
    let open: Double
}

struct HistoryResponseData: Codable {
    let symbol: String
    let chartData: [ChartHistoryData]
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case chartData = "chart_data"
    }
}
