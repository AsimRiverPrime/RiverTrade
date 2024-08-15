//
//  WebSocketResponse.swift
//  RiverPrime
//
//  Created by Ross Rostane on 13/08/2024.
//

import Foundation

//struct TradeData: Codable {
//    let eventType: String
//    let eventTime: Int
//    let symbol: String
//    let tradeId: Int
//    let price: String
//    let quantity: String
//    let tradeTime: Int
//    let isMarketMaker: Bool
//    let ignore: Bool
//
//    private enum CodingKeys: String, CodingKey {
//        case eventType = "e"
//        case eventTime = "E"
//        case symbol = "s"
//        case tradeId = "t"
//        case price = "p"
//        case quantity = "q"
//        case tradeTime = "T"
//        case isMarketMaker = "m"
//        case ignore = "M"
//    }
//}


//struct WebSocketResponse: Codable {
//    let stream: String
//    let data: TradeDetails
//
//    private enum CodingKeys: String, CodingKey {
//        case stream
//        case data
//    }
//}
//
//struct TradeDetails: Codable {
//    let symbol: String
//    let price: String
//    let quantity: String
//    
//    private enum CodingKeys: String, CodingKey {
//        case symbol = "s"
//        case price = "p"
//        case quantity = "q"
//    }
//}
struct WebSocketResponse: Codable {
    let id: Int
    let message: Message
}

struct Message: Codable {
    let type: String
    let payload: [String]
}

struct TradeDetails: Codable {
    let symbol: String
    let ask: Double
    let bid: Double
}
