//
//  GetBalanceModel.swift
//  RiverPrime
//
//  Created by Ross Rostane on 10/12/2024.
//
import Foundation

//// MARK: - ResponseModel
//struct ResponseModel: Codable {
//    let jsonrpc: String
//    let id: Int?
//    let result: Result1
//}
//
//// MARK: - Result
//struct Result1: Codable {
//    let success: Bool
//    let user: UserBalance
//}
//
//// MARK: - User
//struct UserBalance: Codable {
//    let balance: Double
//    let credit: Double
//    let equity: Double
//    let profit: Double
//    let leverage: Double
//    let margin: Double
//    let marginFree: Double
//    let marginLevel: Double
//    let totalWithdraw: Double
//    let totalDeposit: Double
//    let BalancePrevMonth: Double
//
//    enum CodingKeys: String, CodingKey {
//        case balance, credit, equity, profit, leverage, margin, totalWithdraw,totalDeposit,BalancePrevMonth
//        case marginFree = "margin_free"
//        case marginLevel = "margin_level"
//    }
//}

struct ResponseModel: Codable {
    let jsonrpc: String
    let id: String? // Matches `null` in JSON
    let result: Result1
}
    struct Result1: Codable {
        let success: Bool
        let user: UserBalance
    }

    struct UserBalance: Codable {
        let balance: Double
        let totalDeposit: Double
        let totalWithdraw: Double
        let balancePrevMonth: Double
        let credit: Double
        let equity: Double
        let profit: Double
        let leverage: Int
        let margin: Double
        let marginFree: Double
        let marginLevel: Double

        // Coding keys to match the server's naming conventions
        enum CodingKeys: String, CodingKey {
            case balance
            case totalDeposit = "total_deposit"
            case totalWithdraw = "total_withdraw"
            case balancePrevMonth = "BalancePrevMonth"
            case credit
            case equity
            case profit
            case leverage
            case margin
            case marginFree = "margin_free"
            case marginLevel = "margin_level"
        }
    }

