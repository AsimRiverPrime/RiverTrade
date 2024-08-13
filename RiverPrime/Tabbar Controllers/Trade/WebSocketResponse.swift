//
//  WebSocketResponse.swift
//  RiverPrime
//
//  Created by Ross Rostane on 13/08/2024.
//

import Foundation

struct WebSocketResponse: Codable {
    let stream: String
    let data: TradeDetails

    private enum CodingKeys: String, CodingKey {
        case stream
        case data
    }
}

struct TradeDetails: Codable {
    let symbol: String
    let price: String
    let quantity: String
    
    private enum CodingKeys: String, CodingKey {
        case symbol = "s"
        case price = "p"
        case quantity = "q"
    }
}
