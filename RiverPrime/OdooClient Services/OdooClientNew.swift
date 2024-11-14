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
    private let authURL = "https://mbe.riverprime.com/jsonrpc"
    
    var dataBaseName: String = "mbe.riverprime.com" // localhost
    var dbUserName: String =  "ios"
    var dbPassword: String =  "3c0ec26b14366c720cc6cc14b8dd78bd250c803e"
    
    var userEmail: String = ""
    
    weak var otpDelegate: SendOTPDelegate?
    weak var updateNumberDelegate: UpdatePhoneNumebrDelegate?
    weak var verifyDelegate: VerifyOTPDelegate?
    weak var createUserAcctDelegate: CreateUserAccountTypeDelegate?
    weak var createLeadDelegate: CreateLeadOdooDelegate?
    weak var tradeSymbolDetailDelegate: TradeSymbolDetailDelegate?
    
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
        
        print("the params is: \(jsonrpcBody)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: false) { result in
            
            guard let data = result.data else { return }
            
            self.saveUserIdFromJSONData(data)
            
        }
        
    }
    
    func sendSymbolDetailRequest() {
        
        let domainFilter: [[Any]] = [[
            "mobile_available", "=" , "True"
        ]]
        
        let fieldRetrieve: [String] =  ["id","name","description","icon_url","volume_min","volume_max","volume_step","contract_size","display_name","sector","digits","mobile_available","spread_size","swap_short","swap_long","stops_level","yesterday_close"]
        
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
        
        print("json params is: \(jsonrpcBody)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            print("result is : \(result)")
            
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
    //MARK: - Create request (Leads) Method for records
    func createRecords(firebase_uid: String, email: String, name: String) {
        
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
                    "create",         // Method name
                    [[                // vals_list
                        "name": name,
                        "firebase_uid": firebase_uid,
                        "type": "opportunity",
                        "email_from": email
                        
                     ]]
                ]
            ]
        ]
        
        print("\n params value is: \(jsonrpcBody)")
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            print("result is : \(result)")
            switch result {
            case .success(let value):
                if let jsonData = value as? [String: Any],  let result = jsonData["result"] as? Int {
                    
                    UserDefaults.standard.set(result, forKey: "recordId")
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
    
    //MARK: - Write records (Leads) Method for change/update phone number CRM (OdooServer) records
    func writeRecords(number: String) {
       var uid = UserDefaults.standard.integer(forKey: "uid")
       var recordedId = UserDefaults.standard.integer(forKey: "recordId")
        
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
                        "number_ids": [
                            [0, 0, [
                                "number": number,
                                "type": "work"
                            ]]
                        ]
                    ]]
                ]
            ]
        ]
        
        
        print("\n params value is: \(jsonrpcBody)")
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            print("write phone # record result is : \(result)")
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
    
    
    func createAccount(phone: String, group: String, email: String, currency: String, leverage: Int, first_name: String, last_name: String, password: String) {
  
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
                    "create_account",
                    [
                    [],
                    email,
                    phone,
                    group,
                    leverage,
                    first_name,
                    last_name,
                    password
                    ]
                    ]
                ]
            ]
        
        print("\n the parameters is: \(jsonrpcBody)")
        
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
