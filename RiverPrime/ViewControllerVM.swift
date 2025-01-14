//
//  ViewControllerVM.swift
//  RiverPrime
//
//  Created by Ross Rostane on 16/09/2024.
//

import Foundation

class ViewControllerVM {
    
    func Authentication(completion: @escaping (String?) -> Void) {
       
        let request = JSONRPCRequest(
            jsonrpc: "2.0",
            method: "execute_kw",
            id: 9105,
            params: JSONRPCModel(
                method: "login",
              
                service: "common",
                args: [
                    GlobalVariable.instance.dataBaseName,
                    GlobalVariable.instance.dbUserName,
                    GlobalVariable.instance.dbPassword
                ]
            )
        )
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, request: request) { result in
            switch result {
            case .success(let data):
                if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
        
                            do {
                                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                                   let userId = jsonResponse["result"] as? Int {
                                    print("Result: \(userId)")
                                   
                                    GlobalVariable.instance.uid = userId
                                }
                            }catch {
                        print("exception from JsonResponse from auth")
                    }
//                    do {
//                        let decoder = JSONDecoder()
//                        let response = try decoder.decode([SymbolData].self, from: data)
//                        print("response = \(response)")
//                    } catch {
//                        return "exception"
//                    }
//                    if let userId = jsonString["result"] as? Int {
//                        // Save or process the userId
//                        print("User ID: \(userId)")
//                        UserDefaults.standard.set(userId, forKey: "uid")
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
