//
//  TopNewsModel.swift
//  RiverPrime
//
//  Created by Ross Rostane on 12/12/2024.
//

import Foundation

// MARK: - Root Response
struct TopNewsModel: Codable {
    let id: String?
    let jsonrpc: String
    let result: ResultData
}

// MARK: - Result Data
struct ResultData: Codable {
    let payload: [PayloadItem]
    let success: Bool
}

// MARK: - Payload Item
struct PayloadItem: Codable {
    let category: String
    let country: String
    let date: String
    let description: String
    let id: Int
    let importance: Int
    let symbol: String
    let title: String
    let url: String
}
