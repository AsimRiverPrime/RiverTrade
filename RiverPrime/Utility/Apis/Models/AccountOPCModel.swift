//
//  AccountOPCModel.swift
//  RiverPrime
//
//  Created by Ross Rostane on 03/10/2024.
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

//MARK: - Close
struct CloseModel: Codable {
    let deal: Int
    let login: Int
    let order: Int
    let position: Int
    let dealer: Int
    let direction: Int
    let value: Double
    let symbol: String
    let action: Int
    let price: Double
    let volume: Int
    let takeProfit: Double
    let stopLoss: Double
    let time: Int
    let comment: String
    let fee: Double
    let profit: Double
    let marketBid: Double
    let marketAsk: Double
   
    
    enum CodingKeys: String, CodingKey {
        case deal, login, order, position, dealer, direction, value, symbol, action, price, volume
        case takeProfit = "take_profit"
        case stopLoss = "stop_loss"
        case time, comment, fee, profit
        case marketBid = "market_bid"
        case marketAsk = "market_ask"
    }
}

//MARK: - New closed position Model
struct NewCloseModel {
    var symbol = String()
    var LatestTime = Int()
    var totalPrice = Double()
    var totalProfit = Double()
    var action = Int()
    var order = Int()
    var position = Int()
    var repeatedFilteredArray = [CloseModel]()
}
