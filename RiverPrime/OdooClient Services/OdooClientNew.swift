//
//  OdooClientNew.swift
//  RiverPrime
//
//  Created by Ross Rostane on 13/09/2024.
//

import Foundation
import Alamofire


class OdooClientNew {
    
    var createRequestBool : Bool = false
    
    private let baseURL = "https://mbe.riverprime.com"
//    private let baseURL = "http://18.116.153.208:8069"
    private let authURL = "https://mbe.riverprime.com/jsonrpc" // "http://18.116.153.208:8069/jsonrpc"
    
    var dataBaseName: String = "mbe.riverprime.com" // localhost
//    var dbUserName: String = "IOS"
//    var dbPassword: String = "92d8e79bd3d6fc1b549f128fab3cb7b1f362ee73"
    var dbUserName: String = "ios"
    var dbPassword: String = "5021da17d4a522a82ee2ccbab90ee4e90d50f463"
    
    var userEmail: String = ""
    var loginId = Int()
    
    weak var otpDelegate: SendOTPDelegate?
    weak var updateNumberDelegate: UpdatePhoneNumebrDelegate?
    weak var verifyDelegate: VerifyOTPDelegate?
    weak var createUserAcctDelegate: CreateUserAccountTypeDelegate?
    weak var createLeadDelegate: CreateLeadOdooDelegate?
    weak var tradeSymbolDetailDelegate: TradeSymbolDetailDelegate?
    weak var tradeSessionDelegate: TradeSessionRequestDelegate?
    weak var updateUserNamePasswordDelegate: UpdateUserNamePassword?
    weak var topNewsDelegate: TopNewsProtocol?
    weak var economicCalendarDelegate: EconomicCalendarProtocol?
    weak var demoDepositProtocolDelegate : DemoDepositProtocol?
    weak var demoWithdrawProtocolDelegate : DemoWithdrawProtocol?
    
    
    var uid = UserDefaults.standard.integer(forKey: "uid")
    
    func authenticate() {
        
        let methodName = "login"
        
        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "execute_kw",  // Correct method name as per Postman
            "id": 9105,  // The request ID
            "params": [
                "method": methodName,  // Method inside "params" should be "login"
                "service": "common",  // Object
                "args": [
                    dataBaseName,   // Your database name
                    dbUserName,     // Your username
                    dbPassword      // Your password (hashed)
                ]
            ]
        ]
        
        print("the params for authenticate is: \(jsonrpcBody)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: false) { result in
            
            guard let data = result.data else { return }
            
            self.saveUserIdFromJSONData(data)
            
        }
        
    }
    
    func sendSymbolDetailRequest() {
        
        let domainFilter: [[Any]] = [[
            "mobile_available", "=" , "True"
        ]]
        
        let fieldRetrieve: [String] =  ["id","name","description","icon_url","volume_min","volume_max","volume_step","contract_size","display_name","sector","digits","mobile_available","spread_size","swap_short","swap_long","stops_level","yesterday_close","is_mobile_favorite","trading_sessions_ids"]
       

        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            "method":"call",
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    dataBaseName,    // Your database name
                    uid,             // Your user ID
                    dbPassword,      // Your password
                    "mt.symbol",     // The model you're calling
                    "search_read",   // The method to be executed
                    [domainFilter,    // Domain (search criteria)
                     fieldRetrieve // Field list to retrieve
                    ]
                ]
            ]
        ]
        
        print("json params for sendSymbolDetailRequest(search_read) is: \(jsonrpcBody)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
//            print("result is : \(result)")
            
            switch result {
            case .success(let value):
                if let jsonData = value as? [String: Any], let result = jsonData["result"] as? [[String: Any]] {
                    self.tradeSymbolDetailDelegate?.tradeSymbolDetailSuccess(response: ["result": result])
                }else {
                    print("Unexpected response format or missing 'result' key")
                }
                
            case .failure(let error):
                self.tradeSymbolDetailDelegate?.tradeSymbolDetailFailure(error: error)
                break
                
            }
        }
    }
    
    func requestSymbolTrade_session(sessionIds: [Int]) {
       
        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "params": [
                "service": "object",
                "method": "execute_kw",
                "context": [
                    "uid": 0 // Context if required
                ],
                "args": [
                    dataBaseName,        // Your database name
                    uid,                 // Your user ID
                    dbPassword,          // Your password
                    "mt.symbol.trading_session", // The model you're calling
                    "search_read",       // The method to be executed
                    [
                        [
                            [
                                "id",
                                "in",   // Search criteria
                                sessionIds // Field list to retrieve
                            ]
                        ],
                        [] // Empty list for additional options
                    ]
                ]
            ],
            "id": 5263 // ID for the JSON-RPC request
        ]
        
        print("json params for requestSymbolTrade_session is: \(jsonrpcBody)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            print("requestSymbolTrade_session result is : \(result)")
            
            switch result {
            case .success(let value):
                if let jsonData = value as? [String: Any], let result = jsonData["result"] as? [[String: Any]] {
                do {
                    let decoder = JSONDecoder()
//                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let jsonData1 = try JSONSerialization.data(withJSONObject: jsonData, options: [])
                    let response = try decoder.decode(TradeSessionModel.self, from: jsonData1)
                    self.tradeSessionDelegate?.tradeSessionRequestSuccess(response: response )
//                    print(response.result)
                } catch {
                    print("Failed to decode JSON: \(error)")
                    self.tradeSessionDelegate?.tradeSessionRequestFailure(error: error)
                }
                
                }else {
                    print("Unexpected response format or missing 'result' key")
                }
                
            case .failure(let error):
                self.tradeSessionDelegate?.tradeSessionRequestFailure(error: error)
                break
                
            }
        }
    }
    
    
    //MARK: - search request from records to fetch KYC status
    func SearchRecord(email: String, completion: @escaping (String?, Error?) -> Void) {
        
        uid = UserDefaults.standard.integer(forKey: "uid")
        
        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            "method":"call",
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    dataBaseName,      // Database name
                    uid,               // uid
                    dbPassword,        // password
                    "crm.lead",       // Model name
                    "search_read",         // Method name
                    [[[                // vals_list
                        "email_from",
                        "=",
                        email
                        
                     ]],
                    []
                ]
            ]
        ]
    ]
        
        print("\n params for search_read records value is : \(jsonrpcBody)")
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            print("result of search read and save user id is : \(result)")
            switch result {
            case .success(let value):
                if let json = value as? [String: Any],
                          let resultArray = json["result"] as? [[String: Any]],
                   let firstItem = resultArray.first { // Assuming we need the first object,  save ID
                        //  let idwiseDecision = firstItem["idwise_decision"] as? String {
                    UserDefaults.standard.set(firstItem["id"], forKey: "recordId")
                   
                    if let partnerArray = firstItem["partner_id"] as? [Any],
                       let partnerId = partnerArray.first as? Int {
                        UserDefaults.standard.set(partnerId, forKey: "partner_id")
                        
                        print("crm user_id is: \(firstItem["id"]) and partner_id is \(partnerId)")
                        
                    }
                   
                  //  completion(idwiseDecision, nil)
                    
                }else {
                    print("Unexpected response format or missing 'result' key")
                    completion("", nil)
                }
                
            case .failure(let error):
                completion(nil, error)
                print("error is :\(error)")
                break
                
            }
            
        }
        
    }
    
    //MARK: - Create request (Leads) Method for records
    func createRecords(firebase_uid: String, email: String, name: String) {
        
        uid = UserDefaults.standard.integer(forKey: "uid")
        
        var nameCheck = String()
        
        if name == "" {
            nameCheck = "anyName"
        }else{
            nameCheck = name
        }
        
        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            "method":"call",
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    dataBaseName,      // Database name
                    uid,               // uid
                    dbPassword,        // password
                    "crm.lead",       // Model name
                    "create",         // Method name
                    [[                // vals_list
                        "contact_name": name,
//                        "name": name,
//                        "last_name": "",
                        "firebase_uid": firebase_uid,
                        "type": "opportunity",
                        "email_from": email
                       
                     ]]
                ]
            ]
        ]
        
//        OdooValues odooValues = new OdooValues();odooValues.put("phone", userModel.getPhone());odooValues.put("first_name", userModel.getFullName());odooValues.put("last_name", userModel.getFullName());odooValues.put("email_from", userModel.getEmail());odooValues.put("firebase_uid", userModel.getId());odooValues.put("type", "opportunity");
        
        print("\n params for create records value in odoo server: \(jsonrpcBody)")
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            print("create records result is : \(result)")
            switch result {
            case .success(let value):
                if let jsonData = value as? [String: Any],  let result = jsonData["result"] as? Int {
                    
                    UserDefaults.standard.set(result, forKey: "recordId") // crm UserID
                    self.createLeadDelegate?.leadCreatSuccess(response: result)
                    print("result is: \(result)")
                    
                }else {
                    print("Unexpected response format or missing 'result' key")
                    
                }
                
            case .failure(let error):
                self.createLeadDelegate?.leadCreatFailure(error: error)
                print("error is :\(error)")
                break
                
            }
        }
    }
    
    func getCheckout_ID(ammount: String, partner_id: Int) {
        
//        let decimalAmount = Decimal(string: String(format: "%.2f", Double(ammount) ?? 0.0)) ?? 0.00
        let decimalAmount = NSDecimalNumber(string: String(format: "%.2f", Double(ammount) ?? 0.0))
        
//        let doubleValue = Double(ammount) ?? 0.0
//        let decimalAmount = NSDecimalNumber(value: doubleValue)
        
        uid = UserDefaults.standard.integer(forKey: "uid")
        var accountNumber = Int()
       
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _email = savedUserData["email"] as? String{
                self.userEmail = _email
            }
        }
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            if defaultAccount.isReal && defaultAccount.isDefault {
                accountNumber = defaultAccount.accountNumber
            }
        }
        
        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            "method":"call",
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    dataBaseName,      // Database name
                    uid,               // uid
                    dbPassword,        // password
                    "payment.transaction",  // Model name
                    "prepare_checkout",   // Method name
                    [],
                    [                // vals_list
                        "partner_id": partner_id,
                        "email": userEmail,
                        "amount": decimalAmount,
                        "mt_loggin_number": accountNumber,
                        "currency_name": "USD",
                        "payment_type": "DB",
                        "source": "ios_app"
                     ]
                ]
            ]
        ]
        
       
        print("\n params for get checkOut ID from odoo server: \(jsonrpcBody)")
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            print("For checkOut_ID result is : \(result)")
            switch result {
            case .success(let value):
                if let jsonData = value as? [String: Any],  let result = jsonData["result"] as? Int {
                    
//                    UserDefaults.standard.set(result, forKey: "recordId") // crm UserID
//                    self.createLeadDelegate?.leadCreatSuccess(response: result)
                    print("result is: \(result)")
                    
                }else {
                    print("Unexpected response format or missing 'result' key")
                    
                }
                
            case .failure(let error):
//                self.createLeadDelegate?.leadCreatFailure(error: error)
                print("error is :\(error)")
                break
                
            }
            
        }
        
    }
    
    func writeName_toCRM(name: String){
      
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let recordedId = UserDefaults.standard.integer(forKey: "recordId")
        
        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            "method":"call",
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    dataBaseName,      // Database name
                    uid,               //   GlobalVariable.instance.uid,
                    dbPassword,            // password
                    "crm.lead",       // Model name
                    "write",         // Method name
                    [[recordedId],[                // vals_list // need record id save in userdefault
                        "contact_name" : name
                    ]]
                ]
            ]
        ]
        
        
        print("\n params value for write name records on CRM : \(jsonrpcBody)")
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            print("\n send userName record to CRM result is : \(result)")
            switch result {
            case .success(let value):
                if let jsonData = value as? [String: Any],  let result = jsonData["result"] as? Int {
                    print("success userName updated result is: \(result)")
//                    self.updateNumberDelegate?.updateNumberSuccess(response: result)
                }else {
                    print("Unexpected response format or missing 'result' key")
                }
            case .failure(let error):
//                self.updateNumberDelegate?.updateNumberFailure(error: error)
                print("error is :\(error)")
                break
            }
        }
    }
    
    func writeFirebaseToken(firebaseToken: String){
      
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let recordedId = UserDefaults.standard.integer(forKey: "recordId")
        
        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            "method":"call",
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    dataBaseName,      // Database name
                    uid,               //   GlobalVariable.instance.uid,
                    dbPassword,            // password
                    "crm.lead",       // Model name
                    "write",         // Method name
                    [[recordedId],[                // vals_list // need record id save in userdefault
                        "firebase_ios_notification_token" : firebaseToken
                    ]]
                ]
            ]
        ]
        
        
        print("\n params value for write records on CRM like Firebase_Notification_Token: \(jsonrpcBody)")
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            print("/n send firebaseToken record to CRM result is : \(result)")
            switch result {
            case .success(let value):
                if let jsonData = value as? [String: Any],  let result = jsonData["result"] as? Int {
                    print("success firebase token result is: \(result)")
//                    self.updateNumberDelegate?.updateNumberSuccess(response: result)
                    
                }else {
                    print("Unexpected response format or missing 'result' key")
                }
                
            case .failure(let error):
//                self.updateNumberDelegate?.updateNumberFailure(error: error)
                print("error is :\(error)")
                break
            }
        }
    }
    //MARK: - Write records (Leads) Method for change/update phone number CRM (OdooServer) records
    func writeRecords(number: String) {
        let uid = UserDefaults.standard.integer(forKey: "uid")
        let recordedId = UserDefaults.standard.integer(forKey: "recordId")
        
        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            "method":"call",
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    dataBaseName,      // Database name
                    uid,               //   GlobalVariable.instance.uid,
                    dbPassword,            // password
                    "crm.lead",       // Model name
                    "write",         // Method name
                    [[recordedId],[                // vals_list // need record id save in userdefault
                        "mobile": number
                    ]]
                ]
            ]
        ]
        
        print("\n params value for write records on CRM like phone Number : \(jsonrpcBody)")
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            print("send phone# record to CRM result is : \(result)")
            switch result {
            case .success(let value):
                if let jsonData = value as? [String: Any],  let result = jsonData["result"] as? Int {
                    print("result is: \(result)")
                    self.updateNumberDelegate?.updateNumberSuccess(response: result)
                    
                }else {
                    print("Unexpected response format or missing 'result' key")
                }
                
            case .failure(let error):
                self.updateNumberDelegate?.updateNumberFailure(error: error)
                print("error is :\(error)")
                break
                
            }
            
        }
        
    }
    
    
    func sendOTP(type: String, email: String, phone: String) {
        
        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    dataBaseName,    // Your database name
                    uid,             // Your user ID
                    dbPassword,      // Your password
                    "mt.middleware", // The model you're calling
                    "send_otp",      // The method to be executed
                    [
                        [],           // Empty list as per Postman
                        email,        // Email address
                        type,         // Type (e.g., "email")
                        phone         // Phone number or empty string
                    ]
                ]
            ]
        ]
        
        print("json params is: \(jsonrpcBody)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            switch result {
                
            case .success(let value):
                print("sendOTP value is: \(value)")
                if let json = value as? [String: Any], let result = json["result"] as? [String: Any], let status = result["success"] as? Bool {  // Expecting a boolean here
                    
                    if status {
                        print("\n this is the SUCCESS response of type: \(type) and response is \(json)\n")
                        self.otpDelegate?.otpSuccess(response: result)
                        
                    } else {
                        let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Status is not success"])
                        self.otpDelegate?.otpFailure(error: error)
                        print("this is send otp (success) error response of type \(type) : \(error)")
                    }
                } else {
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Invalid JSON structure"])
                    self.otpDelegate?.otpFailure(error: error)
                    print("this is send otp Error response of type \(type) : \(error)")
                }
            case .failure(let error):
                self.otpDelegate?.otpFailure(error: error)    // Handle the network or other failure, e.g.,
                print("this is send otp error response: \(error)")
            }
        }
        
    }
    
    func verifyOTP(type: String, email: String, phone: String, otp: String) {
        
        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    dataBaseName,    // Your database name
                    uid,             // Your user ID
                    dbPassword,      // Your password
                    "mt.middleware", // The model you're calling
                    "verify_otp",      // The method to be executed
                    [
                        [],           // Empty list as per Postman
                        email,        // Email address
                        type,         // Type (e.g., "email")
                        phone,         // Phone number or empty string
                        otp
                    ]
                ]
            ]
        ]
        
        print("json params for verifyOTP is: \(jsonrpcBody)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            switch result {
                
            case .success(let value):
                print("verifyOTP value is: \(value)")
                if let json = value as? [String: Any],
                   let result = json["result"] as? [String: Any],
                   let status = result["success"] as? Bool {  // Expecting a boolean here
                    if status {
                        print("\n this is the SUCCESS response of verify OTP: \(type) and response is \(json)\n")
                        self.verifyDelegate?.otpVerifySuccess(response: result)
                        
                    } else {
                        let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Status is not success"])
                        
                        self.verifyDelegate?.otpVerifyFailure(error: error)
                        print("this is send otp (success) error response of type \(type) : \(error)")
                    }
                } else {
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Invalid JSON structure"])
                    
                    self.verifyDelegate?.otpVerifyFailure(error: error)
                    print("this is send otp Error response of type \(type) : \(error)")
                }
            case .failure(let error):
                self.verifyDelegate?.otpVerifyFailure(error: error)
                print("this is send otp error response: \(error)")
            }
        }
        
    }
    
    func updateMTUserNamePassword(email: String, loginID: Int, oldPassword: String,newPassword: String,userName: String){
        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    dataBaseName,
                    uid,
                    dbPassword,
                    "mt.middleware",
                    "update_user",
                    [
                        [],
                        email,
                        loginID,
                        oldPassword,
                        userName,
                        newPassword
                    ]
                ]
            ]
        ]
        
        print("\n the parameters is: \(jsonrpcBody)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            switch result {
                
            case .success(let value):
                print("update username/password value is: \(value)")
                self.updateUserNamePasswordDelegate?.updateSuccess(response: value)
            case .failure(let error):
                print("error update password is:\(error)")
                self.updateUserNamePasswordDelegate?.updateFailure(error: error)
            }
        }
    }
    
    func getNewsRecords(){
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            //print("saved User Data: \(savedUserData)")
            if let email = savedUserData["email"] as? String{
                self.userEmail = email
            }
        }
        
        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            "id":"685",
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    dataBaseName,
                    uid,
                    dbPassword,
                    "te.middleware",
                    "get_news",
                    [
                        [],
                        
                        1,
                        10
                    ]]
            ]
        ]
        
        print("\n the parameters is: \(jsonrpcBody)")
        
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            switch result {
            case .success(let value):
                print("get news value is: \(value)")
                
                if var responseDict = value as? [String: Any] {
                    if var resultDict = responseDict["result"] as? [String: Any],
                       var payloadArray = resultDict["payload"] as? [[String: Any]] {
                        payloadArray = payloadArray.map { item in
                            var modifiedItem = item
                            if let id = modifiedItem["id"] as? String, id == "<null>" || Int(id) == nil {
                                modifiedItem["id"] = nil // Replace with `nil` or default `0`
                            }
                            return modifiedItem
                        }
                        resultDict["payload"] = payloadArray
                        responseDict["result"] = resultDict
                    }
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                        let decodedResponse = try JSONDecoder().decode(TopNewsModel.self, from: jsonData)
                        print("Decoded Response: \(decodedResponse)")
                        self.topNewsDelegate?.topNewsSuccess(response: decodedResponse)
                    } catch {
                        print("Failed to decode JSON: \(error)")
                        self.topNewsDelegate?.topNewsFailure(error: error)
                    }
                }
            case .failure(let error):
                print("news value Request failed: \(error)")
                self.topNewsDelegate?.topNewsFailure(error: error)
            }
        }
        
    }
    
        func getCalendarDataRecords(fromDate: String , toDate: String) {
            if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
                //print("saved User Data: \(savedUserData)")
                if let email = savedUserData["email"] as? String{
                    self.userEmail = email
                }
            }
    
            let jsonrpcBody: [String: Any] = [
                "jsonrpc": "2.0",
                "id":685,
                "params": [
                    "service": "object",
                    "method": "execute_kw",
                    "args": [
                        dataBaseName,
                        uid,
                        dbPassword,
                        "te.middleware",
                        "get_calendar_data",
                        [
                        [],
                        
                        fromDate,
                        toDate
                        ]]
                    ]
                ]
    
            print("\n the economic calander parameters is: \(jsonrpcBody)")
    
            JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
    
                switch result {
                case .success(let value):
                    print("get economic calendar value is: \(String(describing: value))")
                    do {
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: value!, options: [])
                        let decodedResponse = try JSONDecoder().decode(EconomicCalendarModel.self, from: jsonData)
                        print("Decoded Economic Calendar Response: \(decodedResponse)")
                        self.economicCalendarDelegate?.economicCalendarSuccess(response: decodedResponse)
                    } catch {
                        print("Failed to decode JSON: \(error)")
                        self.economicCalendarDelegate?.economicCalendarFailure(error: error)
                    }
    
                case .failure(let error):
                    print("economic calendar Request failed: \(error)")
                }
            }
    
        }
    
    func createAccount(phone: String, group: String, email: String, currency: String, leverage: Int, first_name: String, last_name: String, password: String, is_demo: Bool) {
        
//        let jsonrpcBody: [String: Any] = [
//            "jsonrpc": "2.0",
//            "params": [
//                "service": "object",
//                "method": "execute_kw",
//                "args": [
//                    dataBaseName,
//                    uid,
//                    dbPassword,
//                    "mt.middleware",
//                    "create_account",
//                    [
//                        [],
//                        email,
//                        phone,
//                        group,
//                        leverage,
//                        first_name,
//                        last_name,
//                        password,
//                        is_demo
//                    ]
//                ]
//            ]
//        ]
        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 2472,
            "params": [
                "service": "object",
                "method": "execute_kw",
                "context": [
                    "uid": 0
                ],
                "args": [
                    dataBaseName,
                    uid,
                    dbPassword,
                    "mt.middleware",
                    "create_account",
                    [
                        [],
                        email,
                        phone,
                        group,
                        leverage,
                        first_name,
                        last_name,
                        password,
                        is_demo
                    ]
                ]
            ]
        ]
        print("\n create MT Account parameters is: \(jsonrpcBody)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            switch result {
                
            case .success(let value):
                print("createAccount value is: \(value)")
                if let json = value as? [String: Any], let result = json["result"] as? [String: Any], let status = result["success"] as? Bool, let loginID = result["login"] as? Int {  // Expecting a boolean here
                    if status {
                        
                        print("The login Id is: \(loginID)")
                        GlobalVariable.instance.loginID = loginID
                        self.createUserAcctDelegate?.createAccountSuccess(response: result)
                    } else {
                        let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Status is not success"])
                        self.createUserAcctDelegate?.createAccountFailure(error: error)
                        print("Error response: \(error)")
                    }
                } else {
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])
                    self.createUserAcctDelegate?.createAccountFailure(error: error)
                    print("Error response: \(error)")
                }
            case .failure(let error):
                self.createUserAcctDelegate?.createAccountFailure(error: error)
                print("Request failed: \(error)")
            }
        }
        
    }
    
    func demoDeposit(amount: Double) {
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            //print("saved User Data: \(savedUserData)")
            if let email = savedUserData["email"] as? String{
                self.userEmail = email
            }
        }
        
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            //print("\n Default Account User: \(defaultAccount)")
            loginId = defaultAccount.accountNumber
//            passwd = defaultAccount.password
        }
        
        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    dataBaseName,
                    uid,
                    dbPassword,
                    "mt.middleware",
                    "deposit",
                    [
                        [],
                        userEmail,
                        loginId,
                        UserDefaults.standard.string(forKey: "password") ?? "",
                        amount
                    ]
                ]
            ]
        ]
        
        print("\n the deposit parameters is: \(jsonrpcBody)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            switch result {
                
            case .success(let value):
                print("demo deposit response value is: \(value)")
                if let json = value as? [String: Any], let result = json["result"] as? [String: Any], let status = result["success"] as? Bool{  // Expecting a boolean here
                    if status {
                        
            
                        self.demoDepositProtocolDelegate?.demoDepositSuccess(response: result)
                    } else {
                        let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Status is not success"])
                        self.demoDepositProtocolDelegate?.demoDepositFailure(error: error)
                        print("Error response: \(error)")
                    }
                } else {
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])
                    self.demoDepositProtocolDelegate?.demoDepositFailure(error: error)
                    print("Error response: \(error)")
                }
            case .failure(let error):
                self.demoDepositProtocolDelegate?.demoDepositFailure(error: error)
                print("Request failed: \(error)")
            }
        }
    }
    
    func demoWithdrawal(amount: Double) {
        let password = UserDefaults.standard.string(forKey: "password")
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data in withdrawl: \(savedUserData)")
            if let email = savedUserData["email"] as? String{
                self.userEmail = email
            }
        }
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            //print("\n Default Account User: \(defaultAccount)")
            loginId = defaultAccount.accountNumber
        }
        
        let jsonrpcBody: [String: Any] = [
            "jsonrpc": "2.0",
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    dataBaseName,
                    uid,
                    dbPassword,
                    "mt.middleware",
                    "withdraw",
                    [
                        [],
                        userEmail,
                        loginId,
                        password ?? "",
                        amount
                    ]
                ]
            ]
        ]
        
        print("\n the withdraw parameters is: \(jsonrpcBody)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            switch result {
                
            case .success(let value):
                print("demo withdraw response value is: \(value)")
                if let json = value as? [String: Any], let result = json["result"] as? [String: Any], let status = result["success"] as? Int{
                    if status == 1 {
                        
            
                        self.demoWithdrawProtocolDelegate?.demoWithdrawSuccess(response: result)
                    } else {
                        let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Status is not success"])
                        self.demoWithdrawProtocolDelegate?.demoWithdrawFailure(error: error)
                        print("Error response: \(error)")
                    }
                } else {
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])
                    self.demoWithdrawProtocolDelegate?.demoWithdrawFailure(error: error)
                    print("Error response: \(error)")
                }
            case .failure(let error):
                self.demoWithdrawProtocolDelegate?.demoWithdrawFailure(error: error)
                print("Request failed: \(error)")
            }
        }
    }
    
    
    func saveUserIdFromJSONData(_ data: Data) {
        
        do {
            
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let userId = jsonResponse["result"] as? Int {
                // Save or process the userId
                print("User ID: \(userId)")
                
                UserDefaults.standard.set(userId, forKey: "uid")
                uid = UserDefaults.standard.integer(forKey: "uid")
                // You can store the userId in a variable or process it further as needed
            } else {
                print("Unexpected JSON format")
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
}
