//
//  ViewControllerVM.swift
//  RiverPrime
//
//  Created by Macbook on 16/09/2024.
//

import Foundation

class ViewControllerVM {
    
    func fetchJsonRPCData(completion: @escaping (String?) -> Void) {
        let request = JSONRPCRequest(
            jsonrpc: "2.0",
            method: "call",
            id: 9105,
            params: JSONRPCParams(
                method: "login",
                context: [:],
                service: "common",
                args: [
                    "mbe.riverprime.com",
                    "admin",
                    "fa2cc3eb83e8b8c1fa323828ec67f0cfac7ca662"
                ]
            )
        )
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, request: request) { result in
            switch result {
            case .success(let data):
                if let data = data, let jsonString = String(data: data, encoding: .utf8) {
//                    print("Response JSON: \(jsonString)")
                    
//                    do {
//                        let decoder = JSONDecoder()
//                        let response = try decoder.decode([SymbolData].self, from: data)
//                        print("response = \(response)")
//                    } catch {
//                        return "exception"
//                    }
                    
                    completion(jsonString)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
}
