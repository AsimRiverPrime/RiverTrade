//
//  TradeTypeCellVM.swift
//  RiverPrime
//
//  Created by abrar ul haq on 03/10/2024.
//

import Foundation
import Alamofire

class TradeTypeCellVM {
    
    var onTradesUpdated: (() -> Void)?
    
    //self.onTradesUpdated?()
    
    func OPCApi1(index: Int, completion: @escaping ([OpenModel]?, [PendingModel]?, [CloseModel]?, Error?) -> Void) {
        
        let url = "https://mbe.riverprime.com/jsonrpc"
        var jsonrpcBody: [String: Any] = [String: Any]()
        
        if index == 0 {
            
            jsonrpcBody = [
                "jsonrpc": "2.0",
                "params": [
                    "service": "object",
                    "method": "execute_kw",
                    "args": [
                        "mbe.riverprime.com",
                        6,
                        "7d2d38646cf6437034109f442596b86cbf6110c0",
                        "mt.middleware",
                        "get_positions",
                        [
                            [],
                            "asimprime900@gmail.com",
                            1012576
                        ]
                    ]
                ]
            ]
            
        } else if index == 1 {
            
            jsonrpcBody = [
                "jsonrpc": "2.0",
                "params": [
                    "service": "object",
                    "method": "execute_kw",
                    "args": [
                        "mbe.riverprime.com",
                        6,
                        "7d2d38646cf6437034109f442596b86cbf6110c0",
                        "mt.middleware",
                        "get_orders",
                        [
                            [],
                            "asimprime900@gmail.com",
                            1012576
                        ]
                    ]
                ]
            ]
            
            
        } else if index == 2 {
            
            jsonrpcBody = [
                "jsonrpc": "2.0",
                "params": [
                    "service": "object",
                    "method": "execute_kw",
                    "args": [
                        "mbe.riverprime.com",
                        6,
                        "7d2d38646cf6437034109f442596b86cbf6110c0",
                        "mt.middleware",
                        "get_deals",
                        [
                            [],
                            "asimprime900@gmail.com",
                            1012614,
                            1727740855, // to previous
                            1728036267  // from current
                        ]
                    ]
                ]
            ]
            
        }
        
        AF.request(url,
                   method: .post,
                   parameters: jsonrpcBody,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type": "application/json"])
        .validate()
        .responseJSON { (response: AFDataResponse<Any>) in
            switch response.result {
                
            case .success(let value):
                print("value is: \(value)")
//                ActivityIndicator.shared.hide(from: self.view)
                
                do {
                    // Decode the response
                    if let json = value as? [String: Any],
                       let result = json["result"] as? [[String: Any]] {
                        
                        if index == 0 {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                            let positions = try JSONDecoder().decode([OpenModel].self, from: jsonData)
                            
    //                        // Use the parsed positions
    //                        for position in positions {
    //                            print("Position: \(position.position), Symbol: \(position.symbol), Profit: \(position.profit)")
    //                        }
                            
                            completion(positions, nil, nil, nil) // Pass positions to completion
                            
                        } else if index == 1 {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                            var orders = try JSONDecoder().decode([PendingModel].self, from: jsonData)
                            
                            if orders.count != 0 {
                                
                                var data = [PendingModel]()
                                data = orders
                                data.remove(at: 0)
                                
                                orders = data
                                
                            }
                            
                            completion(nil, orders, nil, nil) // Pass positions to completion
                            
                        } else if index == 2 {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                            let orders = try JSONDecoder().decode([CloseModel].self, from: jsonData)
                            
                            completion(nil, nil, orders, nil) // Pass positions to completion
                            
                        }
                        
                    }
                } catch {
                    print("Error decoding response: \(error)")
                    completion(nil, nil, nil, error) // Pass error to completion
                }
                
            case .failure(let error):
                // Handle the error
//                ActivityIndicator.shared.hide(from: self.view)
                print("Request failed with error: \(error)")
                completion(nil, nil, nil, error) // Pass error to completion
            }
            
        }
        
    }
    
    
    func OPCApi(index: Int, completion: @escaping ([OpenModel]?, [PendingModel]?, [CloseModel]?, Error?) -> Void) {
        
        var jsonrpcBody: [String: Any] = [String: Any]()
        
        if index == 0 {
            
            jsonrpcBody = [
                "jsonrpc": "2.0",
                "params": [
                    "service": "object",
                    "method": "execute_kw",
                    "args": [
                        "mbe.riverprime.com",
                        6,
                        "7d2d38646cf6437034109f442596b86cbf6110c0",
                        "mt.middleware",
                        "get_positions",
                        [
                            [],
                            "asimprime900@gmail.com",
                            1012576
                        ]
                    ]
                ]
            ]
            
        } else if index == 1 {
            jsonrpcBody = [
                "jsonrpc": "2.0",
                "params": [
                    "service": "object",
                    "method": "execute_kw",
                    "args": [
                        "mbe.riverprime.com",
                        6,
                        "7d2d38646cf6437034109f442596b86cbf6110c0",
                        "mt.middleware",
                        "get_orders",
                        [
                            [],
                            "asimprime900@gmail.com",
                            1012576
                        ]
                    ]
                ]
            ]
            
        } else if index == 2 {
            
            jsonrpcBody = [
                "jsonrpc": "2.0",
                "params": [
                    "service": "object",
                    "method": "execute_kw",
                    "args": [
                        "mbe.riverprime.com",
                        6,
                        "7d2d38646cf6437034109f442596b86cbf6110c0",
                        "mt.middleware",
                        "get_deals",
                        [
                            [],
                            "asimprime900@gmail.com",
                            1012614,
                            1727740855, // to previous
                            1728036267  // from current
                        ]
                    ]
                ]
            ]
            
        }
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            switch result {
                
            case .success(let value):
                print("value is: \(value)")
                
                do {
                    // Decode the response
                    if let json = value as? [String: Any],
                       let result = json["result"] as? [[String: Any]] {
                        
                        if index == 0 {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                            let positions = try JSONDecoder().decode([OpenModel].self, from: jsonData)
                            
    //                        // Use the parsed positions
    //                        for position in positions {
    //                            print("Position: \(position.position), Symbol: \(position.symbol), Profit: \(position.profit)")
    //                        }
                            
                            completion(positions, nil, nil, nil) // Pass positions to completion
                            
                        } else if index == 1 {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                            let orders = try JSONDecoder().decode([PendingModel].self, from: jsonData)
                            
                        
                            
                            completion(nil, orders, nil, nil) // Pass positions to completion
                            
                        } else if index == 2 {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                            var orders = try JSONDecoder().decode([CloseModel].self, from: jsonData)
                            
                            if orders.count != 0 {
                                
                                var data = [CloseModel]()
                                data = orders
                                data.remove(at: 0)
                                
                                orders = data
                                
                            }
                            
                            completion(nil, nil, orders, nil) // Pass positions to completion
                            
                        }
                        
                    }
                } catch {
                    print("Error decoding response: \(error)")
                    completion(nil, nil, nil, error) // Pass error to completion
                }
                
            case .failure(let error):
                // Handle the error
//                ActivityIndicator.shared.hide(from: self.view)
                print("Request failed with error: \(error)")
                completion(nil, nil, nil, error) // Pass error to completion
            }
        }
        
    }
    
}
