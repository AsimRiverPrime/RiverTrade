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
    
//    func OPCApi1(index: Int, completion: @escaping ([OpenModel]?, [PendingModel]?, [CloseModel]?, Error?) -> Void) {
//        
//        let url = "https://mbe.riverprime.com/jsonrpc"
//        var jsonrpcBody: [String: Any] = [String: Any]()
//        
//        if index == 0 {
//            
//            jsonrpcBody = [
//                "jsonrpc": "2.0",
//                "params": [
//                    "service": "object",
//                    "method": "execute_kw",
//                    "args": [
//                        "mbe.riverprime.com",
//                        6,
//                        "7d2d38646cf6437034109f442596b86cbf6110c0",
//                        "mt.middleware",
//                        "get_positions",
//                        [
//                            [],
//                            "asimprime900@gmail.com",
//                            1012576
//                        ]
//                    ]
//                ]
//            ]
//            
//        } else if index == 1 {
//            
//            jsonrpcBody = [
//                "jsonrpc": "2.0",
//                "params": [
//                    "service": "object",
//                    "method": "execute_kw",
//                    "args": [
//                        "mbe.riverprime.com",
//                        6,
//                        "7d2d38646cf6437034109f442596b86cbf6110c0",
//                        "mt.middleware",
//                        "get_orders",
//                        [
//                            [],
//                            "asimprime900@gmail.com",
//                            1012576
//                        ]
//                    ]
//                ]
//            ]
//            
//            
//        } else if index == 2 {
//            
//            jsonrpcBody = [
//                "jsonrpc": "2.0",
//                "params": [
//                    "service": "object",
//                    "method": "execute_kw",
//                    "args": [
//                        "mbe.riverprime.com",
//                        6,
//                        "7d2d38646cf6437034109f442596b86cbf6110c0",
//                        "mt.middleware",
//                        "get_deals",
//                        [
//                            [],
//                            "asimprime900@gmail.com",
//                            1012614,
//                            1727740855, // to previous
//                            1728036267  // from current
//                        ]
//                    ]
//                ]
//            ]
//            
//        }
//        
//        AF.request(url,
//                   method: .post,
//                   parameters: jsonrpcBody,
//                   encoding: JSONEncoding.default,
//                   headers: ["Content-Type": "application/json"])
//        .validate()
//        .responseJSON { (response: AFDataResponse<Any>) in
//            switch response.result {
//                
//            case .success(let value):
//                print("value is: \(value)")
////                ActivityIndicator.shared.hide(from: self.view)
//                
//                do {
//                    // Decode the response
//                    if let json = value as? [String: Any],
//                       let result = json["result"] as? [[String: Any]] {
//                        
//                        if index == 0 {
//                            
//                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
//                            let positions = try JSONDecoder().decode([OpenModel].self, from: jsonData)
//                            
//    //                        // Use the parsed positions
//    //                        for position in positions {
//    //                            print("Position: \(position.position), Symbol: \(position.symbol), Profit: \(position.profit)")
//    //                        }
//                            
//                            completion(positions, nil, nil, nil) // Pass positions to completion
//                            
//                        } else if index == 1 {
//                            
//                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
//                            var orders = try JSONDecoder().decode([PendingModel].self, from: jsonData)
//                            
//                            if orders.count != 0 {
//                                
//                                var data = [PendingModel]()
//                                data = orders
//                                data.remove(at: 0)
//                                
//                                orders = data
//                                
//                            }
//                            
//                            completion(nil, orders, nil, nil) // Pass positions to completion
//                            
//                        } else if index == 2 {
//                            
//                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
//                            let orders = try JSONDecoder().decode([CloseModel].self, from: jsonData)
//                            
//                            completion(nil, nil, orders, nil) // Pass positions to completion
//                            
//                        }
//                        
//                    }
//                } catch {
//                    print("Error decoding response: \(error)")
//                    completion(nil, nil, nil, error) // Pass error to completion
//                }
//                
//            case .failure(let error):
//                // Handle the error
////                ActivityIndicator.shared.hide(from: self.view)
//                print("Request failed with error: \(error)")
//                completion(nil, nil, nil, error) // Pass error to completion
//            }
//            
//        }
//        
//    }
    
    let odooClientService = OdooClientNew()
    let uid = UserDefaults.standard.integer(forKey: "uid")
    let pass = UserDefaults.standard.string(forKey: "password")
    var email = ""
    var loginId = 0
    
    func positionClosed(symbol: String, type: Int, volume: Double, price: Int, position: Int) {
        // Retrieve the data from UserDefaults
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _email = savedUserData["email"] as? String, let _loginId = savedUserData["loginId"] as? Int {
                email = _email
                loginId = _loginId
            }
        }
        print("/n uid: \(uid) \t email: \(email) \t pass: \(pass ?? "")) \t loginID: \(loginId) ")
        //close_order([], email, loginId, password, symbol, type, volume, price, position)
        let params: [String: Any] = [
            "jsonrpc": "2.0",
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    odooClientService.dataBaseName,
                    uid,
                    odooClientService.dbPassword,
                    "mt.middleware",
                    "close_order",
                    [
                        [],
                        email,
                        loginId,
                        pass ?? "",
                        symbol,
                        type,
                        volume,
                        price,
                        position
                    ]
                ]
            ]
        ]
        
        print("params is: \(params)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: params, showLoader: true) { result in
            switch result {
                
            case .success(let value):
                print("close position value is: \(value)")
                do {
                    // Decode the response
                    if let json = value as? [String: Any],
                       let result = json["result"] as? [[String: Any]] {
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                        print("jsonData: \(jsonData)")
                    }
                }
                catch {
                    print("Error decoding response: \(error)")
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func positionUpdate(takeProfit: Double, stopLoss: Double, position: Int) {
        // Retrieve the data from UserDefaults
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _email = savedUserData["email"] as? String, let _loginId = savedUserData["loginId"] as? Int {
                email = _email
                loginId = _loginId
            }
        }
        print("/n uid: \(uid) \t email: \(email) \t pass: \(pass ?? "")) \t loginID: \(loginId) \t  position: \(position) \t takeProfit: \(takeProfit) \t stoploss: \(stopLoss)")
        //update_position(self, email, login, password, position_id, take_profit, stop_loss)
        let params: [String: Any] = [
            "jsonrpc": "2.0",
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    odooClientService.dataBaseName,
                    uid,
                    odooClientService.dbPassword,
                    "mt.middleware",
                    "update_position",
                    [
                        [],
                        email,
                        loginId,
                        pass ?? "",
                        position,
                        takeProfit,
                        stopLoss
                    ]
                ]
            ]
        ]
        
        print("params is: \(params)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: params, showLoader: true) { result in
            switch result {
                
            case .success(let value):
                print(" position update value is: \(value)")
                do {
                    // Decode the response
                    if let json = value as? [String: Any],
                       let result = json["result"] as? [[String: Any]] {
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                        print("jsonData: \(jsonData)")
                    }
                }
                catch {
                    print("Error decoding response: \(error)")
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func OPCApi(index: Int, completion: @escaping ([OpenModel]?, [PendingModel]?, [CloseModel]?, Error?) -> Void) {
        
        var jsonrpcBody: [String: Any] = [String: Any]()
        
        // Retrieve the data from UserDefaults
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {

            if let _email = savedUserData["email"] as? String, let _loginId = savedUserData["loginId"] as? Int {
                email = _email
                loginId = _loginId
            }
        }
        
        if index == 0 {
            
            jsonrpcBody = [
                "jsonrpc": "2.0",
                "params": [
                    "service": "object",
                    "method": "execute_kw",
                    "args": [
                        odooClientService.dataBaseName,
                        uid,
                        odooClientService.dbPassword,
                        "mt.middleware",
                        "get_positions",
                        [
                            [],
                            email,
                            loginId
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
                        odooClientService.dataBaseName, //"mbe.riverprime.com",
                        uid, //6,
                        odooClientService.dbPassword, //"7d2d38646cf6437034109f442596b86cbf6110c0",
                        "mt.middleware",
                        "get_orders",
                        [
                            [],
                            email, //"asimprime900@gmail.com",
                            loginId //1012576
                        ]
                    ]
                ]
            ]
            
        } else if index == 2 {
            
            let currentTimestampInSeconds = Int(Date().timeIntervalSince1970)
            print("Current timestamp in milliseconds: \(currentTimestampInSeconds)")
            
            
            jsonrpcBody = [
                "jsonrpc": "2.0",
                "params": [
                    "service": "object",
                    "method": "execute_kw",
                    "args": [
                        odooClientService.dataBaseName, //"mbe.riverprime.com",
                        uid, //6,
                        odooClientService.dbPassword, //"7d2d38646cf6437034109f442596b86cbf6110c0",
                        "mt.middleware",
                        "get_deals",
                        [
                            [],
                            email, //"asimprime900@gmail.com",
                            loginId, //1012614,
                            1727740855, // to previous
                            currentTimestampInSeconds  // from current
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
                       let result = json["result"] as? [[String: Any]] { // jab error ata hai tu as mai error = "Error getting orders"; value ate hai as pe thost lagana hai
                        
//                         let error = result["error"] as? String {
//                            
//                        }
//                        
//                        print("error comes")
                        
                        if index == 0 {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                            let positions = try JSONDecoder().decode([OpenModel].self, from: jsonData)
                            
                            // Use the parsed positions
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
                            
                            print("order count:\(orders.count)")
                            
                            var filteredOrders = [CloseModel]()
                            if orders.count != 0  {
//                                filteredOrders = orders.filter { $0.entry == 1 }
                                filteredOrders = orders.filter { $0.position != 0 }
                                print("\n filteredOrders array is:  \(filteredOrders)")
                                   // Step 2: Count repeated positions
                                   var positionCount: [Int: Int] = [:]
                                   
                                   for order in filteredOrders {
                                       positionCount[order.position, default: 0] += 1
                                   }
                                   
                                   // Step 3: Find and print repeated positions
                                   for (position, count) in positionCount where count > 1 {
                                       print("Position \(position) is repeated \(count) times")
                                      
                                   }
                              //  print("filteredOrders array is:  \(filteredOrders) is count of: \(filteredOrders.count)")
//                                var data = [CloseModel]()
//                                    
//                                data = filteredOrders
//                                    
//                                filteredOrders = data
                                orders = filteredOrders
                                print("order count after filter:\(orders.count)")
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

