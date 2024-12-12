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
    let id: Int?
    let importance: Int
    let symbol: String
    let title: String
    let url: String

    
enum CodingKeys: String, CodingKey {
       case category, country, date, description, id, importance, symbol, title, url
   }

   init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
       
       category = try container.decode(String.self, forKey: .category)
       country = try container.decode(String.self, forKey: .country)
       date = try container.decode(String.self, forKey: .date)
       description = try container.decode(String.self, forKey: .description)
       
       // Custom decoding for `id`
       if let intId = try? container.decode(Int.self, forKey: .id) {
           id = intId
       } else if let stringId = try? container.decode(String.self, forKey: .id), let intId = Int(stringId) {
           id = intId
       } else {
           id = nil // Handle invalid or `<null>` cases
       }
       
       importance = try container.decode(Int.self, forKey: .importance)
       symbol = try container.decode(String.self, forKey: .symbol)
       title = try container.decode(String.self, forKey: .title)
       url = try container.decode(String.self, forKey: .url)
   }
}
