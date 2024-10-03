//
//  AccountOPCModel.swift
//  RiverPrime
//
//  Created by abrar ul haq on 03/10/2024.
//

import Foundation

//MARK: - Open
struct OpenModel: Codable {
    let position: Int
    let login: Int
    let symbol: String
    let action: Int
    let priceOpen: Double
    let priceCurrent: Double
    let takeProfit: Double
    let stopLoss: Double
    let volume: Int
    let profit: Double
    let dealer: Int
    let timeCreate: Double
    let timeUpdate: Double
    let comment: String
    
    // Coding keys to match JSON keys
    enum CodingKeys: String, CodingKey {
        case position, login, symbol, action
        case priceOpen = "price_open"
        case priceCurrent = "price_current"
        case takeProfit = "take_profit"
        case stopLoss = "stop_loss"
        case volume, profit, dealer
        case timeCreate = "time_create"
        case timeUpdate = "timme_update" // Note the typo in the original JSON key
        case comment
    }
}

//MARK: - Pending
struct PendingModel: Codable {
    
}

//MARK: - Close
struct CloseModel: Codable {
    let login: Int
    let order: Int
    let position: Int
    let dealer: Int
    let symbol: String
    let type: Int
    let typeFill: Int
    let price: Double
    let volume: Int
    let takeProfit: Double
    let stopLoss: Double
    let timeSetup: Double
    let timeDone: Double
    let comment: String

    enum CodingKeys: String, CodingKey {
        case login, order, position, dealer, symbol, type
        case typeFill = "type_fill"
        case price, volume
        case takeProfit = "take_profit"
        case stopLoss = "stop_loss"
        case timeSetup = "time_setup"
        case timeDone = "time_done"
        case comment
    }
}
