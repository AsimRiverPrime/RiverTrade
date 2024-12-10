//
//  GetBalanceModel.swift
//  RiverPrime
//
//  Created by Ross Rostane on 10/12/2024.
//
import Foundation

// MARK: - ResponseModel
struct ResponseModel: Codable {
    let jsonrpc: String
    let id: Int?
    let result: Result1
}

// MARK: - Result
struct Result1: Codable {
    let success: Bool
    let user: UserBalance
}

// MARK: - User
struct UserBalance: Codable {
    let balance: Double
    let credit: Double
    let equity: Double
    let profit: Double
    let leverage: Int
    let margin: Double
    let marginFree: Double
    let marginLevel: Double

    enum CodingKeys: String, CodingKey {
        case balance, credit, equity, profit, leverage, margin
        case marginFree = "margin_free"
        case marginLevel = "margin_level"
    }
}
