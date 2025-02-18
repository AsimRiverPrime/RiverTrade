//
//  TradeTypeCellVM.swift
//  RiverPrime
//
//  Created by Ross Rostane on 03/10/2024.
//

import Foundation
import Alamofire

class TradeTypeCellVM {
    
    var onTradesUpdated: (() -> Void)?
    
//    var forToast = BaseViewController()
    
    let odooClientService = OdooClientNew()
    let uid = UserDefaults.standard.integer(forKey: "uid")
    let pass = UserDefaults.standard.string(forKey: "password")
    var email = ""
    var loginId = 0
    
    func positionClosed(symbol: String, type: Int, volume: Double, price: Int, position: Int, completion: @escaping (String) -> Void) {
        // Retrieve the data from UserDefaults
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _email = savedUserData["email"] as? String{
                email = _email
               
            }
        }
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
//            //print("\n Default Account User: \(defaultAccount)")
            loginId = defaultAccount.accountNumber
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
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: params, showLoader: false) { result in
            switch result {
                
            case .success(let value):
                print(" position closed value is: \(value)")
//                self.forToast.showTimeAlert(str: "Position closed successfully")
                do {
                    // Decode the response
                    if let json = value as? [String: Any],
                       let result = json["result"] as? [String: Any], let success = result["success"] as? Bool {
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                        print("jsonData for position closed : \(jsonData)")
                        
                        print("success = \(success)")
                        
                        let error = result["error"] as? String
                        
                        if success {
                            completion("Position closed successfully")
                        } else {
                            completion(error ?? "Something went wrong.")
                        }
                        return
                    }
                    completion("Something went wrong.")
                }
                catch {
                    print("Error decoding response: \(error)")
//                    self.forToast.showTimeAlert(str: "\(error)")
                    completion("\(error)")
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
//                self.forToast.showTimeAlert(str: "\(error)")
                completion("\(error)")
            }
        }
    }
    
    func positionUpdate(takeProfit: Double, stopLoss: Double, position: Int, completion: @escaping (String) -> Void) {
        // Retrieve the data from UserDefaults
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _email = savedUserData["email"] as? String{
                email = _email
               
            }
        }
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            //print("\n Default Account User: \(defaultAccount)")
            loginId = defaultAccount.accountNumber
        }
        print("/n uid: \(uid) \t email: \(email) \t pass: \(pass ?? "")) \t loginID: \(loginId) \t  position: \(position) \t takeProfit: \(takeProfit) \t stoploss: \(stopLoss)")
        
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
        
        print("params for positionUpdate is: \(params)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: params, showLoader: false) { result in
            switch result {
                
            case .success(let value):
                print(" position update value is: \(value)")
//                self.forToast.showTimeAlert(str: "Position update successfully")
                do {
                    // Decode the response
                    if let json = value as? [String: Any],
                       let result = json["result"] as? [String: Any],
                       let success = result["success"] as? Bool {
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                        print("jsonData for positionUpdate: \(jsonData)")
                        if success {
//                            self.forToast.showTimeAlert(str: "Position update successfully")
                            completion("Position update successfully")
                        }else{
//                            self.forToast.showTimeAlert(str: "Position Not Found")
                            completion("Position Not Found")
                        }
                        return
                    }
                    completion("Something went wrong.")
                }
                catch {
                    print("Error decoding response: \(error)")
//                    self.forToast.showTimeAlert(str: "\(error)")
                    completion("\(error)")
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
//                self.forToast.showTimeAlert(str: "\(error)")
                completion("\(error)")
            }
        }
    }
    
    func deletePendingOrder(order_Id: Int, completion: @escaping (String) -> Void) {
        // Retrieve the data from UserDefaults
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _email = savedUserData["email"] as? String{
                email = _email
             
            }
        }
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            //print("\n Default Account User: \(defaultAccount)")
            loginId = defaultAccount.accountNumber
        }
        print("/n uid: \(uid) \t email: \(email) \t pass: \(pass ?? "")) \t loginID: \(loginId) \t order_Id: \(order_Id) ")
        
        
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
                    "delete_order",
                    [
                        [],
                        email,
                        loginId,
                        pass ?? "",
                        order_Id
                    ]
                ]
            ]
        ]
        
        print("params for deletePendingOrder is: \(params)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: params, showLoader: false) { result in
            switch result {
                
            case .success(let value):
                print("Delete order value is: \(value)")
//                self.forToast.showTimeAlert(str: "Order Deleted successfully")
                do {
                    // Decode the response
                    if let json = value as? [String: Any],
                       let result = json["result"] as? [String: Any],
                       let success = result["success"] as? Int {
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                        print("jsonData for deletePendingOrder: \(jsonData)")
                        if success == 1 {
                            completion("Delete order successfully")
                        }else{
                            completion("Order Not Found")
                        }
                        return
                    }
                    completion("Something went wrong.")
                }
                catch {
                    print("Error decoding response: \(error)")
                    completion("\(error)")
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
                completion("\(error)")
            }
        }
    }
    
    func UpdatePendingOrder(order_Id: Int, takeProfit: Double, stopLoss: Double, price: Double, completion: @escaping (String) -> Void) {
        // Retrieve the data from UserDefaults
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _email = savedUserData["email"] as? String {
                email = _email
               
            }
        }
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            //print("\n Default Account User: \(defaultAccount)")
            loginId = defaultAccount.accountNumber
        }
        print("/n uid: \(uid) \t email: \(email) \t pass: \(pass ?? "")) \t loginID: \(loginId) \t order_Id: \(order_Id) \t  price: \(price) \t takeProfit: \(takeProfit) \t stoploss: \(stopLoss)")
        
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
                    "update_order",
                    [
                        [],
                        email,
                        loginId,
                        pass ?? "",
                        order_Id
                    ]
                ]
            ]
        ]
        
        print("params is: \(params)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: params, showLoader: false) { result in
            switch result {
                
            case .success(let value):
                print("pending order update value is: \(value)")
//                completion("Order update successfully")
                do {
                    // Decode the response
                    if let json = value as? [String: Any],
                       let result = json["result"] as? [[String: Any]],
                       let success = json["success"] as? Int {
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                        print("jsonData for pending order : \(jsonData)")
                        if success == 1 {
                           
                            completion("Pending Order update successfully")
                        }else{
                            completion("Order Not Found")
                        }
                        
                    }
                }
                catch {
                    print("Error decoding response: \(error)")
//                    self.forToast.showTimeAlert(str: "\(error)")
                    completion("\(error)")
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
//                self.forToast.showTimeAlert(str: "\(error)")
                completion("\(error)")
            }
        }
    }
    
    func loginForPassword (loginID: Int, pass: String, completion: @escaping (String) -> Void) {
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _email = savedUserData["email"] as? String{
                email = _email
               
            }
        }
//        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
//            //print("\n Default Account User: \(defaultAccount)")
//            if 
//            loginId = defaultAccount.accountNumber
//        }
        
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
                    "login",
                    [
                        [],
                        email,
                        loginID,
                        pass
                       
                    ]
                ]
            ]
        ]
        
        print("params is: \(params)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: params, showLoader: false) { result in
            switch result {
                
            case .success(let value):
                print("Login value is: \(value)")
//                completion("Order update successfully")
                do {
                    // Decode the response
                    if let json = value as? [String: Any],
                       let result = json["result"] as? [String: Any],
                       let success = result["success"] as? Int {
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
//                        print("jsonData: \(jsonData)")
                        if success == 1 {
                            UserDefaults.standard.set((pass), forKey: "password")
                            completion("Login Successfully")
                        }else{
                            completion("Login Failed")
                        }
                        
                    }
                }
                catch {
                    print("Error decoding response: \(error)")
//                    completion("\(error)")
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
//                completion("\(error)")
            }
        }
    }
    
    func getUserBalance(completion: @escaping (Result<ResponseModel, Error>) -> Void) {
        var pass = UserDefaults.standard.string(forKey: "password")
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _email = savedUserData["email"] as? String, let _pass = savedUserData["password"] as? String {
                email = _email
               
            }
        }
        
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            print("\n Default Account User in get user balance: \(defaultAccount)")
            loginId = defaultAccount.accountNumber
            pass = defaultAccount.password
            
        }
        
        if (pass == nil || pass == "" ) && GlobalVariable.instance.isAccountCreated {
//            showPopup()
            return
        }else{
            print("the password is: \(pass ?? "")")
        }
        
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
                    "get_user",
                    [
                        [],
                        email,
                        loginId,
                        pass ?? ""
                    ]
                ]
            ]
        ]
        
        print("get balance Params: \(params)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: params, showLoader: false) { result in
            switch result {
            case .success(let value):
                print("/\n get user balance Value: \(value)")
                do {
                    // Convert the response to Data
                    let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                    
                    // Decode the JSON into your ResponseModel
                    let decodedResponse = try JSONDecoder().decode(ResponseModel.self, from: jsonData)
                    
                    // Pass the decoded model to the completion handler
                    completion(.success(decodedResponse))
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("API call error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func getBalance(completion: @escaping (String) -> Void) {
        var pass = UserDefaults.standard.string(forKey: "password")
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _email = savedUserData["email"] as? String {
                email = _email
            }
        }
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            //print("\n Default Account User: \(defaultAccount)")
            loginId = defaultAccount.accountNumber
            pass = defaultAccount.password
        }
        
        if (pass == nil || pass == "" ) && GlobalVariable.instance.isAccountCreated {
//            showPopup()
            return
        }else{
            print("the MT login password is: \(pass ?? "")")
        }
        
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
                    "get_user",
                    [
                        [],
                        email,
                        loginId,
                        pass ?? ""
                       
                    ]
                ]
            ]
        ]
        print("\n get balance params is: \(params)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: params, showLoader: false) { result in
            switch result {
                
            case .success(let value):
                print("------->>>>get user MT balance value is: \(value)")
                do {
                    // Decode the response
                    if let json = value as? [String: Any],
                       let result = json["result"] as? [String: Any], // Result is a dictionary, not an array
                       let success = result["success"] as? Int, // Success and balance are inside "result" ,

                       let user_detail = result["user"] as? [String: Any],
                       let balance_get = user_detail["balance"] as? Double {
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                        print("jsonData for user MT balance: \(String(data: jsonData, encoding: .utf8) ?? "")")
                        
                        if success == 1 {
                            // Return the balance value in the completion handler
                            completion("\(balance_get)")
                            print("\n !!!balance update sucess!!!!\n")
                        } else {
                            // Handle the case where success is not 1
                            completion("No balance Found")
                        }
                        
                    } else {
                        print("Error: Invalid JSON structure")
                        completion("Invalid Response")
                    
                    }
                } catch {
                    print("Error decoding response: \(error)")
                    completion("Error: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
                completion("\(error)")
            }
        }
    }
    
    func OPCApi(index: Int, fromDate: Int? = nil, toDate: Int? = nil, completion: @escaping ([OpenModel]?, [PendingModel]?, [NewCloseModel]?, Error?) -> Void) {
        
        var jsonrpcBody: [String: Any] = [String: Any]()
        
        // Retrieve the data from UserDefaults
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            
            if let _email = savedUserData["email"] as? String{
                email = _email
            }
        }
        
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            //print("\n Default Account User: \(defaultAccount)")
            loginId = defaultAccount.accountNumber
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
            let secondsToAdd = 3 * 60 * 60
            let newTimestampInSeconds = currentTimestampInSeconds + secondsToAdd
            print("New Timestamp (after adding 3 hours): \(newTimestampInSeconds)")
            
            
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
                            fromDate ?? 0, // to previous
                            toDate ?? newTimestampInSeconds  // from current
                          
                        ]
                    ]
                ]
            ]
            
        }
        
        print("\n parameter is : \(jsonrpcBody)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: false) { result in
            switch result {
                
            case .success(let value):
                print(" Open/Close/Pending LIST value is: \(value)")
                
                do {
                    // Decode the response
                    if let json = value as? [String: Any],
                       let result = json["result"] as? [[String: Any]] { // jab error ata hai tu as mai error = "Error getting orders"; value ate hai.. as pe toast lagana hai
                        
//                        let error = result["error"] as? String {
//                        }
//                        print("error comes")
                        
                        if index == 0 {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                            let positions = try JSONDecoder().decode([OpenModel].self, from: jsonData)
                            
                            
                            completion(positions, nil, nil, nil) // Pass positions to completion
                            
                        } else if index == 1 {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                            let orders = try JSONDecoder().decode([PendingModel].self, from: jsonData)
                            
                            completion(nil, orders, nil, nil) // Pass positions to completion
                            
                        } else if index == 2 {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                            var orders = try JSONDecoder().decode([CloseModel].self, from: jsonData)
                            
                            print("order count:\(orders.count)")
                            
                            var newCloseModel = [NewCloseModel]()
                            
                            if orders.count != 0  {
                                
                                let getNewCloseList = self.getSymbolProfitList(from: orders)
                                newCloseModel = getNewCloseList
                                
                            }
                            
                            //TODO: Without sort.
                            //completion(nil, nil, newCloseModel, nil) // Pass positions to completion
                            
                            //TODO: With sort.
                            // Sort orders before passing them to the completion handler
                            var sortedOrders = newCloseModel.sorted { $0.position < $1.position }
                            sortedOrders = newCloseModel.sorted { $0.LatestTime > $1.LatestTime }
                            print("\n closed order values:\(sortedOrders)")
//                            print("\n closed order values in newCloseModel:\(newCloseModel)")
                            completion(nil, nil, sortedOrders, nil) // Pass positions to completion
                            
                            //                            completion(nil, nil, newCloseModel, nil) // Pass positions to completion
                            
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
    
    //only get duplicate positions list data -> time + symbol + price + profit + Close Model Complete
    
    func getSymbolProfitList(from closes: [CloseModel]) -> [NewCloseModel] {
        var filteredOrders = closes.filter { $0.position != 0 }
        
        let groupedCloseModels = separateDuplicatePositionsOnly(from: filteredOrders)
//        let groupedCloseModels = separateDuplicatePositionsOnly(from: closes)
        var newCloseModel = [NewCloseModel]()
        
        if groupedCloseModels.count == 0 {
            return []
        }
        
        // Now you can access groupedCloseModels
        for (position, models) in groupedCloseModels {
            //            print("Symbol: \(symbol), Models: \(models)")
            // Get the latest time
            let latestTime = models.map { $0.time }.max() ?? 0
            
            let profitValues = models.map { $0.profit }
            
            let totalPrice = models.map { $0.price }.reduce(0, +)
            
            let totalProfit = models.map { $0.profit }.reduce(0, +)
            
            guard let latestMaxTimeModel = models.max(by: { $0.time < $1.time }) else {
                return []
            }
            
            // Filter to get repeated values based on the latest time
            let repeatedValues = models.filter { $0.time == latestTime }
            
            // Get unique symbols from the repeated values
            let order = latestMaxTimeModel.order
            let entry = latestMaxTimeModel.direction
            //            let action = latestMaxTimeModel.action
            let position = latestMaxTimeModel.position
            let volume = latestMaxTimeModel.volume
            let price = latestMaxTimeModel.price
            let profit = latestMaxTimeModel.profit
            let symbol = latestMaxTimeModel.symbol
            
            let earliestCloseModel = models.min(by: { $0.time < $1.time })
            
            let action = earliestCloseModel?.action
            
            newCloseModel.append(NewCloseModel(symbol: symbol, LatestTime: latestTime, totalPrice: totalPrice, totalProfit: totalProfit, action: action ?? -1, order: order, position: position, repeatedFilteredArray: groupedCloseModels[position]!, historyCloseData: closes))
        }
        
        
        return newCloseModel
    }
    
    
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
    
    func separateDuplicatePositions(from closeModels: [CloseModel]) -> [Int: [CloseModel]] {
        var groupedModels: [Int: [CloseModel]] = [:]
        
        for model in closeModels {
            if groupedModels[model.position] == nil {
                groupedModels[model.position] = []
            }
            groupedModels[model.position]?.append(model)
        }
        
        return groupedModels
    }
    
    func separateDuplicatePositionsOnly(from closeModels: [CloseModel]) -> [Int: [CloseModel]] {
        var positionCount: [Int: Int] = [:]
        var groupedModels: [Int: [CloseModel]] = [:]
        
        // First pass: Count occurrences of each position
        for model in closeModels {
            positionCount[model.position, default: 0] += 1
        }
        
        // Second pass: Group models by position, but only if they have duplicates
        for model in closeModels {
            if positionCount[model.position] ?? 0 > 1 {
                if groupedModels[model.position] == nil {
                    groupedModels[model.position] = []
                }
                groupedModels[model.position]?.append(model)
            }
        }
        
        return groupedModels
    }
    
    
}

extension TradeTypeCellVM {
    func showPopup() {
        let storyboard = UIStoryboard(name: "BottomSheetPopups", bundle: nil)
        
        // Replace "PopupViewController" with the actual identifier of your popup view controller
        if let popupVC = storyboard.instantiateViewController(withIdentifier: "LoginPopupVC") as? LoginPopupVC {
            // Set modal presentation style
            popupVC.modalPresentationStyle = .overFullScreen// .overCurrentContext    // You can use .overFullScreen for full-screen dimming
           
                 
            popupVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            popupVC.view.alpha = 0
            // Optional: Set modal transition style (this is for animation)
            popupVC.modalTransitionStyle = .crossDissolve
            popupVC.loginId = loginId
            // Present the popup
//            self.present(popupVC, animated: true, completion: nil)
            SCENE_DELEGATE.window?.rootViewController?.present(popupVC, animated: true)
        }
    }
}
