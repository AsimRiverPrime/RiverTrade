//
//  OdooClientNew.swift
//  RiverPrime
//
//  Created by Ross Rostane on 13/09/2024.
//

import Foundation
import Alamofire

class OdooClientNew {
    
    private let baseURL = "https://mbe.riverprime.com"
    private let authURL = "https://mbe.riverprime.com/jsonrpc"
    
    var dataBaseName: String = "mbe.riverprime.com" // localhost
    var dbUserName: String =  "ios"
    var dbPassword: String =  "4e9b5768375b5a0acf0c94645eac5cdd9c07c059"
    var userEmail: String = ""
    
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
        
        var uid = UserDefaults.standard.integer(forKey: "uid")
        
        let parametersValue: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "execute_kw",
            "params": [
                uid,
                dataBaseName,   // Your database name
                dbUserName,     // Your username
                dbPassword,
                "mt.middleware",
                "send_otp",
//                "service": "common"
                [
                    phone,
                    email,
                    type,
                    ""
                ]
            ]
        ]
        
        print("json params is: \(parametersValue)")
        
        // Convert the dictionary to JSON object and send the request using Alamofire
        AF.request(baseURL,
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
                   let status = result["status"] as? String {
                    if status == "success" {
                        print("\n this is the SUCCESS response of type: \(type) and response is \(json)\n")
                        //                        self.delegate?.otpSuccess(response: result)
                    } else {
                        let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Status is not success"])
                        //                        self.delegate?.otpFailure(error: error)
                        print("this is send otp (success) error response of type \(type) : \(error)")
                    }
                } else {
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Invalid JSON structure"])
                    //                    self.delegate?.otpFailure(error: error)
                    print("this is send otp Error response of type \(type) : \(error)")
                }
            case .failure(let error):
                //                self.delegate?.otpFailure(error: error)
                print("this is send otp error response: \(error)")
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
               
                // You can store the userId in a variable or process it further as needed
            } else {
                print("Unexpected JSON format")
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
}
