//
//  TradeSessionModel.swift
//  RiverPrime
//
//  Created by Ross Rostane on 18/12/2024.
//

import Foundation

// MARK: - Main Response
struct TradeSessionModel: Codable {
    let jsonrpc: String
       let id: Int
       let result: [TradeSession]
}

// MARK: - Trade Session
struct TradeSession: Codable {
    let id: Int
        let symbolID: [CreateUid]
        let sessionType, day, openHours, openMinutes: String
        let closeHours, closeMinutes, lastUpdate, displayName: String
        let createUid: [CreateUid]
        let createDate: String
        let writeUid: [CreateUid]
        let writeDate: String

        enum CodingKeys: String, CodingKey {
            case id
            case symbolID = "symbol_id"
            case sessionType = "session_type"
            case day
            case openHours = "open_hours"
            case openMinutes = "open_minutes"
            case closeHours = "close_hours"
            case closeMinutes = "close_minutes"
            case lastUpdate = "__last_update"
            case displayName = "display_name"
            case createUid = "create_uid"
            case createDate = "create_date"
            case writeUid = "write_uid"
            case writeDate = "write_date"
        }
    }

    enum CreateUid: Codable {
        case integer(Int)
        case string(String)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode(Int.self) {
                self = .integer(x)
                return
            }
            if let x = try? container.decode(String.self) {
                self = .string(x)
                return
            }
            throw DecodingError.typeMismatch(CreateUid.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for CreateUid"))
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .integer(let x):
                try container.encode(x)
            case .string(let x):
                try container.encode(x)
            }
        }
    }
