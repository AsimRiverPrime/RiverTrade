//
//  OodoClient.swift
//  RiverPrime
//
//  Created by Ross Rostane on 05/08/2024.
//

import Foundation
import Alamofire
import Foundation
import AEXML

class OdooClient {
    
    private let baseURL = "http://192.168.3.100:8069/xmlrpc/2/"
    
    private lazy var commonURL: String = {
        return baseURL + "common"
    }()
    
    private lazy var objectURL: String = {
        return baseURL + "object"
    }()
    
    var uid: Int = UserDefaults.standard.integer(forKey: "uid")
    var recordedId: Int = UserDefaults.standard.integer(forKey: "recordId")
    
    var createRequestBool : Bool = false
    
    var dataBaseName: String = "localhost"
    var dbUserName: String =  "ios"
    var dbPassword: String =  "ios"
    
    
    //MARK: - Authentication Method
    
    func authenticate() {
        let methodName = "authenticate"
        let parametersValue: [Any] = [
            dataBaseName,     // Database name
            dbUserName,     // Username
            dbPassword,    // Password
            [:] // Context as an empty dictionary
        ]
        
        guard let xmlData = xmlRPCPayload(method: methodName, parameters: parametersValue) else {
            print("Error creating XML payload")
            return
        }
        var urlRequest = URLRequest(url: URL(string: commonURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = xmlData
        
        AF.request(urlRequest)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    self.saveUserIdFromXMLData(data)
                    
                    print("Response XML: \(String(data: data, encoding: .utf8) ?? "")")
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }
    
    //MARK: - Send request Method for fetch data
    func sendRequest(searchEmail: String) {
        let methodName = "execute_kw"
        
        // Define the domain filter and parameters
        let domainFilter: [[Any]] = [[
            "email_from", "=", searchEmail
        ]]
        let params: [Any] = [
            dataBaseName,      // Database name
            uid,               // UID
            dbPassword,        // Password
            "crm.lead",       // Model name
            "search_read",    // Method name
            [domainFilter],   // Domain (search criteria)
            []                // Fields to retrieve
        ]
        
        guard let payload = xmlRPCPayload(method: methodName, parameters: params) else {
            print("Error creating XML payload")
            return
        }
        
        print(String(data: payload, encoding: .utf8)!)
        
        var urlRequest = URLRequest(url: URL(string: objectURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = payload
        
        AF.request(urlRequest)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response XML: \(responseString)")
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }
    
    //MARK: - Create request Method for records
    func createRecords(firebase_uid: String, email: String, number: String, name: String) {
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
                "email_from": email,
                "number_ids": [
                    [0, 0, [
                        "number": number,
                        "type": "work"
                    ]]
                ]
             ]]
        ]
        
        guard let payload = xmlRPCPayload(method: methodName, parameters: params) else {
            print("Error creating XML payload")
            return
        }
        
        print(String(data: payload, encoding: .utf8)!)
        
        var urlRequest = URLRequest(url: URL(string: objectURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = payload
        
        AF.request(urlRequest)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response XML: \(responseString)")
                    }
                    self.saveUserIdFromXMLData(data)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }
    //MARK: - Method write/update data to OdooServer
    func writeRecords(number: String) {
        let methodName = "execute_kw"
        let params: [Any] = [
            dataBaseName,      // Database name
            uid,               // uid
            dbPassword,            // password
            "crm.lead",       // Model name
            "write",         // Method name
            [[recordedId],[                // vals_list // need record id
                "number_ids": [
                    [0, 0, [
                        "number": number,
                        "type": "work"
                    ]]
                ]
                  ]]
        ]
        
        guard let payload = xmlRPCPayload(method: methodName, parameters: params) else {
            print("Error creating XML payload")
            return
        }
        
        print(String(data: payload, encoding: .utf8)!)
        
        var urlRequest = URLRequest(url: URL(string: objectURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = payload
        
        AF.request(urlRequest)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response XML: \(responseString)")
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }
    
    //MARK: -  Method to get the version of the Odoo server
    func version() {
        let method = "version"
        let parameters: [Any] = []
        
        guard let xmlData2 = xmlRPCPayload(method: method, parameters: parameters) else {
            print("Error creating XML payload")
            return
        }
                
        AF.request(commonURL, method: .post, headers: [.contentType("text/xml")]) { urlRequest in
            urlRequest.httpBody = xmlData2
        }
        .validate()
        .responseData { response in
            switch response.result {
            case .success(let data):
                // Parse the XML response here
                if let xmlString = String(data: data, encoding: .utf8) {
                    print("Response XML: \(xmlString)")
                    // You can use an XML parser to extract specific information
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    //MARK: - set/parse parameter as XML formate
    
    func xmlRPCPayload(method: String, parameters: [Any]) -> Data? {
        var xmlString = "<?xml version=\"1.0\"?>\n<methodCall>\n"
        xmlString += "<methodName>\(method)</methodName>\n"
        xmlString += "<params>\n"
        
        func appendValue(_ value: Any) {
            xmlString += "<value>"
            
            if let stringValue = value as? String {
                xmlString += "<string>\(stringValue)</string>"
            } else if let intValue = value as? Int {
                xmlString += "<int>\(intValue)</int>"
            } else if let arrayValue = value as? [Any] {
                xmlString += "<array><data>"
                for element in arrayValue {
                    xmlString += "<value>"
                    appendValue(element)
                    xmlString += "</value>"
                }
                xmlString += "</data></array>"
            } else if let dictValue = value as? [String: Any] {
                xmlString += "<struct>"
                for (key, val) in dictValue {
                    xmlString += "<member><name>\(key)</name><value>"
                    appendValue(val)
                    xmlString += "</value></member>"
                }
                xmlString += "</struct>"
            }
            
            xmlString += "</value>"
        }
        
        for param in parameters {
            xmlString += "<param>"
            appendValue(param)
            xmlString += "</param>\n"
        }
        
        xmlString += "</params>\n"
        xmlString += "</methodCall>"
        
        return xmlString.data(using: .utf8)
    }
    
    func saveUserIdFromXMLData(_ data: Data) {
        do {
            
            if let rawXMLString = String(data: data, encoding: .utf8) {
                print("Raw XML: \(rawXMLString)")
                
            }
            
            let xmlDoc1 = try AEXMLDocument(xml: data)
            print(xmlDoc1.xml)
            
            if createRequestBool == false {
                // Adjust this based on the actual XML structure
                if let intValueString = xmlDoc1.root["params"]["param"]["value"]["int"].value,
                   let intValue = Int(intValueString) {
                    // Save the uid int value to UserDefaults
                    UserDefaults.standard.set(intValue, forKey: "uid")
                    print("Int value saved: \(intValue)")
                } else {
                    print("Int value not found in the XML.")
                }
            }
           else {
                if let intValueString = xmlDoc1.root["params"]["param"]["value"]["int"].value,
                           let intValue = Int(intValueString) {
                            // Save the recorded id value to UserDefaults
                            UserDefaults.standard.set(intValue, forKey: "recordId")
                            print(" recorded Id Int value saved: \(intValue)")
                        } else {
                            print("recorded Id Int value not found in the XML.")
                        }
               createRequestBool = false
            }
        } catch {
            print("XML Parsing Error: \(error)")
        }
        
    }
}
