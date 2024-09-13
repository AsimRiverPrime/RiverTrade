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
    
    var dataBaseName: String = "mbe.riverprime.com" // localhost
    var dbUserName: String =  "ios"
    var dbPassword: String =  "4e9b5768375b5a0acf0c94645eac5cdd9c07c059"
    var userEmail: String = ""
    
    func authenticate() {
        let methodName = "login"
//        let parametersValue: [Any] = [
//            dataBaseName,     // Database name
//            dbUserName,     // Username
//            dbPassword,    // Password
//            [:] // Context as an empty dictionary
//        ]
        
        let parametersValue : [String: Any] = [
          "jsonrpc":"2.0",
          "method":"call",
          "id":9105,
          "params":[
            "method":"login",
            "context":{},
            "service":"common",  // object
            "args":[
                dataBaseName,
                dbUserName,
                dbPassword
              ]
        ]
          ]
              
        // Create the JSON-RPC payload
            guard let jsonData = jsonRPCPayload(method: methodName, parameters: parametersValue) else {
                print("Error creating JSON payload")
                return
            }
        
            print("JSONData parameter: \(jsonData)")
        
            var urlRequest = URLRequest(url: URL(string: baseURL)!)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonData
            
            AF.request(urlRequest)
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
        
//        guard let xmlData = xmlRPCPayload(method: methodName, parameters: parametersValue) else {
//            print("Error creating XML payload")
//            return
//        }
//        var urlRequest = URLRequest(url: URL(string: commonURL)!)
//        urlRequest.httpMethod = "POST"
//        urlRequest.setValue("text/xml", forHTTPHeaderField: "Content-Type")
//        urlRequest.httpBody = xmlData
//
//        AF.request(urlRequest)
//            .validate()
//            .responseData { response in
//                switch response.result {
//                case .success(let data):
//                    self.saveUserIdFromXMLData(data)
//
//                    print("Response XML: \(String(data: data, encoding: .utf8) ?? "")")
//                case .failure(let error):
//                    print("Error: \(error)")
//                }
//            }
    }
    
    func jsonRPCPayload(method: String, parameters: [String: Any]) -> Data? {
        let payload: [String: Any] = [
            "jsonrpc": "2.0",
            "method": method,
            "params": parameters,
            "id": 1 // The request id, can be any unique number
        ]
        
        // Convert payload to JSON Data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            return jsonData
        } catch {
            print("Error creating JSON payload: \(error)")
            return nil
        }
    }
    
    func saveUserIdFromJSONData(_ data: Data) {
        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let result = jsonResponse["result"] as? [String: Any],
               let userId = result["userId"] as? Int {
                // Save or process the userId
                print("User ID: \(userId)")
            } else {
                print("Unexpected JSON format")
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
}
