//
//  APIResponse.swift
//  RiverPrime
//
//  Created by Macbook on 16/09/2024.
//

import Foundation

struct JSONRPCRequest<T: Encodable>: Encodable {
    let jsonrpc: String
    let method: String
    let id: Int
    let params: T//JSONRPCParams
}
