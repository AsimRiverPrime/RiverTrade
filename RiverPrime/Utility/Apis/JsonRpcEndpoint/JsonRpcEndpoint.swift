//
//  JsonRpcEndpoint.swift
//  RiverPrime
//
//  Created by Ross Rostane on 16/09/2024.
//

import Foundation

enum Endpoint {
  
    case jsonrpc
    case symbolData//(String)
  
}

extension Endpoint {
    func getEndpoint() -> String {
        switch self {
            
        case .jsonrpc:
            return "/jsonrpc"
        case .symbolData://(let SiteName):
            return "/symboldata"
            
        }
    }
}
