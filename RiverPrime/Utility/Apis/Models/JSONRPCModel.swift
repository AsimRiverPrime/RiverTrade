//
//  JSONRPCParams.swift
//  RiverPrime
//
//  Created by Ross on 16/09/2024.
//

import Foundation

struct JSONRPCModel: Encodable {
    let method: String
    let service: String
    let args: [String]
}

