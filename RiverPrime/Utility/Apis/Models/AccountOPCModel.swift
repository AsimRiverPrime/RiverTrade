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
    let entry: Int
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
        case deal, login, order, position, dealer, entry, value, symbol, action, price, volume
        case takeProfit = "take_profit"
        case stopLoss = "stop_loss"
        case time, comment, fee, profit
        case marketBid = "market_bid"
        case marketAsk = "market_ask"
    }
}

//only get duplicate positions list data -> time + symbol + price + profit + Close Model Complete
//MARK: - New close Model
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

//new postion array without zero + time + symbol + profit/loss + repeated values against symbols
//Model
//var groupedModels: [(String,[CloseModel],Int,[Double],Double)] = [("",[],0,[],0.0)]

////MARK: - New close Model
//struct NewCloseModel {
//    var filteredArray = [CloseModel]()
//    var time = Int()
//    var symbol = String()
//    var profitLoss = Double()
//    var repeatedSymbolList = [CloseModel]()
//}

////MARK: - New close Model
//struct NewCloseModel {
//    var symbol = String()
//    var filteredArray = [CloseModel]()
//    var time = Int()
//    var profitLoss = [Double]()
//    var totalProfit = Double()
//    var order = Int()//5
//    var entry = Int()//6
//    var action = Int()//7
//    var volume = Int()//8
//    var price = Double()//9
//    var profit = Double()//10
////    var repeatedSymbolList = [CloseModel]()
//}

////// MARK: - SummaryCloseModel
////struct SummaryCloseModel {
////    let latestTime: Int
////    let repeatedSymbols: [CloseModel]
////    let symbolStrings: [String]
////    let profitValues: [Double]
////    let nonZeroPositionValues: [CloseModel]
////}
//
//// MARK: - SummaryCloseModel
//struct SummaryCloseModel {
//    let latestTime: Int
//    let repeatedSymbols: [CloseModel]
//    let symbolProfitList: [(time: Int, symbol: String, profit: Double)]
//    let symbolStrings: [String]
//    let profitValues: [Double]
//    let nonZeroPositionValues: [CloseModel]
//}
//
//
////get all these values from the CloseModel and make a new model.
////repeatedSymbols only as a CloseModel + Latest time from compared time + get symbol as a string from the repeated symbols + and profit value and last get all fillter array in which position is not 0.
////
////get time, symbol and profit against every symbol in the list.
////
////use only one model like: SummaryCloseModel don't use SymbolProfitModel seperatly
