//
//  JSONRPCParams.swift
//  RiverPrime
//
//  Created by Macbook on 16/09/2024.
//

import Foundation

struct JSONRPCModel: Encodable {
    let method: String
    let context: [String: String]
    let service: String
    let args: [String]
}
