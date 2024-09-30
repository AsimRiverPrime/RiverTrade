//
//  OdooClientNew.swift
//  RiverPrime
//
//  Created by Ross Rostane on 13/09/2024.
//

import Foundation
import Alamofire


class OdooClientNew {
    
    var indicate = BaseViewController()
    
    var createRequestBool : Bool = false
    
    private let baseURL = "https://mbe.riverprime.com"
    private let authURL = "https://mbe.riverprime.com/jsonrpc"
    
    var dataBaseName: String = "mbe.riverprime.com" // localhost
    var dbUserName: String =  "ios"
    var dbPassword: String =  "7d2d38646cf6437034109f442596b86cbf6110c0" //"4e9b5768375b5a0acf0c94645eac5cdd9c07c059"
    var userEmail: String = ""
    
  
    weak var otpDelegate: SendOTPDelegate?
    weak var updateNumberDelegate: UpdatePhoneNumebrDelegate?
    weak var verifyDelegate: VerifyOTPDelegate?
    weak var createUserAcctDelegate: CreateUserAccountTypeDelegate?
    
    var uid = UserDefaults.standard.integer(forKey: "uid")
    
    func authenticate() {
        let methodName = "login"
        
        let parametersValue: [String: Any] = [
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
        
        print("the paras is: \(parametersValue)")
        
        AF.request(authURL,
                   method: .post,
                   parameters: parametersValue,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type": "application/json"])
        .validate()
        .responseData { response in
            switch response.result {
            case .success(let data):
                self.saveUserIdFromJSONData(data)  // Update this to handle JSON
                print("Response JSON: \(String(data: data, encoding: .utf8) ?? "")")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func sendOTP(type: String, email: String, phone: String) {
        
     
        
        let parametersValue: [String: Any] = [
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
        
        print("json params is: \(parametersValue)")
        
        // Convert the dictionary to JSON object and send the request using Alamofire
        AF.request(authURL,
                   method: .post,
                   parameters: parametersValue,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type": "application/json"])
            .validate()
            .responseJSON { response in
                switch response.result {
                  
                case .success(let value):
                    print("value is: \(value)")
                    if let json = value as? [String: Any], let result = json["result"] as? [String: Any], let status = result["success"] as? Bool {  // Expecting a boolean here
                        
                        if status {
                            print("\n this is the SUCCESS response of type: \(type) and response is \(json)\n")
                            self.otpDelegate?.otpSuccess(response: result)
                         //   self.indicate.ToastMessage("Please check Your email for OTP")
                           
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
        
        let parametersValue: [String: Any] = [
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
        
        print("json params is: \(parametersValue)")
        
        // Convert the dictionary to JSON object and send the request using Alamofire
        AF.request(authURL,
                   method: .post,
                   parameters: parametersValue,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type": "application/json"])
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
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
    //MARK: - Create request (Leads) Method for records
    // working
    func createRecords(firebase_uid: String, email: String, name: String) {
        self.createRequestBool = true
        
        let methodName = "execute_kw"
        
        let params: [Any] = [
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
        
        
    }
    
    //MARK: - create trade Account Method

    func createAccount(phone: String, group: String, email: String, currency: String, leverage: Int, first_name: String, last_name: String, password: String) {
  
        let params: [String: Any] = [
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
        
        print("\n the parameters is: \(params)")
        
        let url = "https://mbe.riverprime.com/jsonrpc"
        // Make the request
        AF.request(url,
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type": "application/json"])
        .validate()
        .responseJSON { (response: AFDataResponse<Any>) in
            switch response.result {
                           
            case .success(let value):
                print("value is: \(value)")
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
//                GlobalVariable.instance.uid = userId
                UserDefaults.standard.set(userId, forKey: "uid")
               
                // You can store the userId in a variable or process it further as needed
            } else {
                print("Unexpected JSON format")
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
}
