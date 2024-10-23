//
//  SymbolDetailsModel.swift
//  RiverPrime
//
//  Created by Ross Rostane on 23/10/2024.
//

import Foundation

struct APIResponse: Codable {
    let jsonrpc: String
    let id: Int
    let result: [SymbolResult]
}

// The model for each individual symbol in the "symbol detail result" array
struct SymbolResult: Codable {
    let id: Int
    let icon_url: String
    let name: String
    let description: String
    let volume_min: Int
    let volume_max: Int
    let volume_step: Int
    let contract_size: Int
    let display_name: String
    let sector: String
    let stops_level: Double
    let swap_long: Double
    let swap_short: Double
    let spread_size: Double
    let digits: Int
}

struct SymbolData1 {
    let id: Int
    let name: String
    let description: String
    let icon_url: String
    let volumeMin: Int
    let volumeMax: Int
    let volumeStep: Int
    let contractSize: Int
    let displayName: String
    let sector: String
    let stopsLevel: Double
    let swapLong: Double
    let swapShort: Double
    let spreadSize: Double
    let digits: Int
    let mobile_available: Bool // Assuming you have this value in your app logic
}
