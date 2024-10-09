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
    
    func orderClosed(symbol: String, type: Int, volume: Double, price: Int, position: Int) {
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
    
    func OPCApi2(index: Int, completion: @escaping ([OpenModel]?, [PendingModel]?, [CloseModel]?, Error?) -> Void) {
        
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
                            
//                            new postion array without zero + time + symbol + profit/loss + repeated values against symbols
//                            Model
                            
//                            var newCloseModel = [NewCloseModel]()
                            
                            var filteredOrders = [CloseModel]()
                            if orders.count != 0  {
////                                filteredOrders = orders.filter { $0.entry == 1 }
//                                filteredOrders = orders.filter { $0.position != 0 }
//                                print("\n filteredOrders array is:  \(filteredOrders)")
//                                
//                                
//                                
//                                   // Step 2: Count repeated positions
//                                   var positionCount: [Int: Int] = [:]
//                                   
//                                   for order in filteredOrders {
//                                       positionCount[order.position, default: 0] += 1
//                                   }
//                                   
//                                   // Step 3: Find and print repeated positions
//                                   for (position, count) in positionCount where count > 1 {
//                                       print("Position \(position) is repeated \(count) times")
//                                      
//                                   }
//                              //  print("filteredOrders array is:  \(filteredOrders) is count of: \(filteredOrders.count)")
////                                var data = [CloseModel]()
////
////                                data = filteredOrders
////
////                                filteredOrders = data
//                                orders = filteredOrders
//                                print("order count after filter:\(orders.count)")
                                
//                                // Call the function
//                                if let summaryClose = self.getSummaryCloseModel(from: orders) {
//                                    print("Latest Time: \(summaryClose.latestTime)")
//                                    print("Repeated Symbols as CloseModel: \(summaryClose.repeatedSymbols)")
//                                    print("Symbol Profit List: \(summaryClose.symbolProfitList)")
//                                    print("Symbol Strings: \(summaryClose.symbolStrings)")
//                                    print("Profit Values: \(summaryClose.profitValues)")
//                                    print("Non-Zero Position Values: \(summaryClose.nonZeroPositionValues)")
//                                }
                                
                                let getNewCloseList = self.getSymbolProfitList(from: orders)
                                
//                                let newCloseModel = [NewCloseModel]()
                                
//                                newCloseModel.append(NewCloseModel(symbol: <#T##String#>, filteredArray: <#T##[CloseModel]#>, time: <#T##Int#>, profitLoss: <#T##[Double]#>, totalProfit: <#T##Double#>))
                                
//                                // Call the function
//                                let symbolProfitList = getSymbolProfitList(from: orders)
//                                for symbolProfit in symbolProfitList {
//                                    print("Time: \(symbolProfit.time), Symbol: \(symbolProfit.symbol), Profit: \(symbolProfit.profit)")
//                                }
//                                
////                                // Call the function
////                                if let summaryClose = self.getSummaryCloseModel(from: orders) {
////                                    print("Latest Time: \(summaryClose.latestTime)")
////                                    print("Repeated Symbols as CloseModel: \(summaryClose.repeatedSymbols)")
////                                    print("Symbol Strings: \(summaryClose.symbolStrings)")
////                                    print("Profit Values: \(summaryClose.profitValues)")
////                                    print("Non-Zero Position Values: \(summaryClose.nonZeroPositionValues)")
////                                }
                                
                            }
                            
                            /*
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
                            */

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
    
    func OPCApi(index: Int, completion: @escaping ([OpenModel]?, [PendingModel]?, [(String,[CloseModel],Int,[Double],Double,[CloseModel],Int,Int,Int,Int,Double,Double)]?, Error?) -> Void) {
        
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
                            
//                            new postion array without zero + time + symbol + profit/loss + repeated values against symbols
//                            Model
                            
//                            var newCloseModel = [NewCloseModel]()
                            
//                            var filteredOrders = [CloseModel]()
                            
                            var newCloseList = [(String,[CloseModel],Int,[Double],Double,[CloseModel],Int,Int,Int,Int,Double,Double)]()
                            
                            if orders.count != 0  {
                                
                                let getNewCloseList = self.getSymbolProfitList(from: orders)
                                newCloseList = getNewCloseList
                                
                            }
                            
                            completion(nil, nil, newCloseList, nil) // Pass positions to completion

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
//    var order = Int()//6
//    var entry = Int()//7
//    var action = Int()//8
//    var volume = Int()//9
//    var price = Double()//10
//    var profit = Double()//11
//    [(String,[CloseModel],Int,[Double],Double,[CloseModel],Int,Int,Int,Int,Double,Double)]
    
    func getSymbolProfitList(from closes: [CloseModel]) -> [(String,[CloseModel],Int,[Double],Double,[CloseModel],Int,Int,Int,Int,Double,Double)] {
        var filteredOrders = closes.filter { $0.position != 0 }
        
        let groupedCloseModels = separateDuplicateSymbols(from: filteredOrders)
        
        var groupedModels: [(String,[CloseModel],Int,[Double],Double,[CloseModel],Int,Int,Int,Int,Double,Double)] = [("",[],0,[],0.0,[],0,0,0,0,0.0,0.0)]
        groupedModels.removeAll()
        
//        var profits: [Double] = []
        
        // Now you can access groupedCloseModels
        for (symbol, models) in groupedCloseModels {
//            print("Symbol: \(symbol), Models: \(models)")
            // Get the latest time
            let latestTime = models.map { $0.time }.max() ?? 0
            
            /*
            // Filter to get repeated values based on the latest time
            let repeatedValues = models.filter { $0.time == latestTime }
            
            // Get unique symbols from the repeated values
            let uniqueProfit = Set(repeatedValues.map { $0.profit })
            */
            
            let profitValues = models.map { $0.profit }
            
            let totalProfit = models.map { $0.profit }.reduce(0, +)
            
            
            
            guard let latestMaxTimeModel = models.max(by: { $0.time < $1.time }) else {
                return [("",[],0,[],0.0,[],0,0,0,0,0.0,0.0)] // Return nil if there are no models
            }
            
            // Filter to get repeated values based on the latest time
            let repeatedValues = models.filter { $0.time == latestTime }
            
            // Get unique symbols from the repeated values
            let order = latestMaxTimeModel.order
            let entry = latestMaxTimeModel.entry
            let action = latestMaxTimeModel.action
            let volume = latestMaxTimeModel.volume
            let price = latestMaxTimeModel.price
            let profit = latestMaxTimeModel.profit
            
            
            
            groupedModels.append((symbol,models,latestTime,profitValues,totalProfit,filteredOrders,order,entry,action,volume,price,profit))
        }
        
//        print("groupedModels = \(groupedModels)")
        
        
        
//        //let repeatedValues = closes.filter { $0.symbol == latestTime }
        
        return groupedModels
    }
    
//    // Function to append new data
//    func appendToGroupedModels(key: String, model: CloseModel) {
//        var groupedModels: [(String, [CloseModel])] = [("", [])]
//        
//        // Check if the key already exists
//        if let index = groupedModels.firstIndex(where: { $0.0 == key }) {
//            // If it exists, append the new model to the existing array
//            groupedModels[index].1.append(model)
//        } else {
//            // If it doesn't exist, create a new entry
//            groupedModels.append((key, [model]))
//        }
//    }
    
    func separateDuplicateSymbols(from closeModels: [CloseModel]) -> [String: [CloseModel]] {
        var uniqueSymbols: Set<String> = []
        var groupedModels: [String: [CloseModel]] = [:]

        for model in closeModels {
            if !uniqueSymbols.contains(model.symbol) {
                uniqueSymbols.insert(model.symbol)
                groupedModels[model.symbol] = []
            }
            groupedModels[model.symbol]?.append(model)
        }
        
        return groupedModels
    }
    
//    func getSummaryCloseModel(from closes: [CloseModel]) -> SummaryCloseModel? {
//        guard !closes.isEmpty else { return nil }
//        
//        // Get the latest time
//        let latestTime = closes.map { $0.time }.max() ?? 0
//        
//        // Filter to get repeated values based on the latest time
//        let repeatedValues = closes.filter { $0.time == latestTime }
//        
//        // Get unique symbols from the repeated values
//        let uniqueSymbols = Set(repeatedValues.map { $0.symbol })
//        
//        // Filter to create a list of CloseModel with unique symbols
//        let repeatedSymbols = repeatedValues.filter { uniqueSymbols.contains($0.symbol) }
//        
//        // Extract symbol strings and profit values
//        let symbolStrings = repeatedSymbols.map { $0.symbol }
//        let profitValues = repeatedSymbols.map { $0.profit }
//        
//        // Filter all CloseModels where position is not zero
//        let nonZeroPositionValues = closes.filter { $0.position != 0 }
//        
//        // Create the symbol profit list directly in the summary model
//        let symbolProfitList = closes.map { (time: $0.time, symbol: $0.symbol, profit: $0.profit) }
//        
//        return SummaryCloseModel(
//            latestTime: latestTime,
//            repeatedSymbols: repeatedSymbols,
//            symbolProfitList: symbolProfitList,
//            symbolStrings: Array(uniqueSymbols),
//            profitValues: profitValues,
//            nonZeroPositionValues: nonZeroPositionValues
//        )
//    }
    
//    func getSymbolProfitList(from closes: [CloseModel]) -> [SymbolProfitModel] {
//        var symbolProfitList: [SymbolProfitModel] = []
//        
//        for close in closes {
//            let symbolProfit = SymbolProfitModel(time: close.time, symbol: close.symbol, profit: close.profit)
//            symbolProfitList.append(symbolProfit)
//        }
//        
//        return symbolProfitList
//    }
//    
//    func getSummaryCloseModel(from closes: [CloseModel]) -> SummaryCloseModel? {
//        guard !closes.isEmpty else { return nil }
//        
//        // Get the latest time
//        let latestTime = closes.map { $0.time }.max() ?? 0
//        
//        // Filter to get repeated values based on the latest time
//        let repeatedValues = closes.filter { $0.time == latestTime }
//        
//        // Get unique symbols from the repeated values
//        let uniqueSymbols = Set(repeatedValues.map { $0.symbol })
//        
//        // Filter to create a list of CloseModel with unique symbols
//        let repeatedSymbols = repeatedValues.filter { uniqueSymbols.contains($0.symbol) }
//        
//        // Extract symbol strings and profit values
//        let symbolStrings = repeatedSymbols.map { $0.symbol }
//        let profitValues = repeatedSymbols.map { $0.profit }
//        
//        // Filter all CloseModels where position is not zero
//        let nonZeroPositionValues = closes.filter { $0.position != 0 }
//        
//        return SummaryCloseModel(
//            latestTime: latestTime,
//            repeatedSymbols: repeatedSymbols,
//            symbolStrings: Array(uniqueSymbols),
//            profitValues: profitValues,
//            nonZeroPositionValues: nonZeroPositionValues
//        )
//    }
    
////    // Function to get the latest time and repeated values
////    func getLatestCloseModel(from closes: [CloseModel]) -> NewCloseModel? {
////        guard !closes.isEmpty else { return nil }
////        
////        // Get the latest time
////        let latestTime = closes.map { $0.time }.max() ?? 0
////        
////        // Filter to get repeated values based on the latest time
////        let repeatedValues = closes.filter { $0.time == latestTime }
////        
//////        return LatestCloseModel(latestTime: latestTime, repeatedValues: repeatedValues)
////        return NewCloseModel(filteredArray: <#T##arg#>, time: latestTime, symbol: <#T##arg#>, profitLoss: <#T##arg#>, repeatedSymbolList: <#T##arg#>)
////    }
//    
//    func getLatestCloseModel(from closes: [CloseModel]) -> NewCloseModel? {
//        guard !closes.isEmpty else { return nil }
//        
//        // Get the latest time
//        let latestTime = closes.map { $0.time }.max() ?? 0
//        
//        // Filter to get repeated values based on the latest time
//        let repeatedValues = closes.filter { $0.time == latestTime }
//        
////        // Get the repeated symbols from the filtered values
////        let repeatedSymbols = Set(repeatedValues.map { $0.symbol })
//        
//        
//        // Get unique symbols from the repeated values
//        let uniqueSymbols = Set(repeatedValues.map { $0.symbol })
//        
//        // Filter to create a list of CloseModel with unique symbols
//        let repeatedSymbols = repeatedValues.filter { uniqueSymbols.contains($0.symbol) }
//        
//        
////        return LatestCloseModel(latestTime: latestTime, repeatedSymbols: Array(repeatedSymbols), repeatedValues: repeatedValues)
//        return NewCloseModel(filteredArray: <#T##arg#>, time: latestTime, symbol: <#T##arg#>, profitLoss: <#T##arg#>, repeatedSymbolList: repeatedSymbols)
//    }
    
}

//extension Array where Element:Equatable {
//    func removeDuplicates() -> [Element] {
//        var result = [Element]()
//
//        for value in self {
//            if result.contains(value) == false {
//                result.append(value)
//            }
//        }
//
//        return result
//    }
//}
