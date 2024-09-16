//
//  OodoClient.swift
//  RiverPrime
//
//  Created by Ross Rostane on 05/08/2024.
//

import Alamofire
import Foundation
import AEXML

protocol SendOTPDelegate: AnyObject {
    func otpSuccess(response: Any)
    func otpFailure(error: Error)
}
protocol VerifyOTPDelegate: AnyObject {
    func otpVerifySuccess(response: Any)
    func otpVerifyFailure(error: Error)
}
protocol CreateLeadOdooDelegate: AnyObject {
    func leadCreatSuccess(response: Any)
    func leadCreatFailure(error: Error)
}

protocol UpdatePhoneNumebrDelegate: AnyObject {
    func updateNumberSuccess(response: Any)
    func updateNumberFailure(error: Error)
}

protocol CreateUserAccountTypeDelegate: AnyObject {
    func createAccountSuccess(response: Any)
    func createAccountFailure(error: Error)
}

protocol TradeSymbolDetailDelegate: AnyObject {
    func tradeSymbolDetailSuccess(response: String)
    func tradeSymbolDetailFailure(error: Error)
}
class OdooClient {
    
//    private let baseURL = "http://192.168.3.107:8069/xmlrpc/2/"
//    private let baseURLOTP = "http://192.168.3.107:8069"
    private let baseURLOTP = "https://mbe.riverprime.com"
    private let baseURL = "https://mbe.riverprime.com/xmlrpc/2/"
    
    private lazy var commonURL: String = {
        return baseURL + "common"
    }()
    
    private lazy var objectURL: String = {
        return baseURL + "object"
    }()
    
    private lazy var otpSendURL: String = {
        return baseURLOTP + "/web/session/send_otp"
    }()
    
    private lazy var otpVerifyURL: String = {
        return baseURLOTP + "/web/session/verify_otp"
    }()
    
    private lazy var createAccountURL: String = {
        return baseURLOTP + "/web/mt/account/create"
    }()
    
    var uid: Int = UserDefaults.standard.integer(forKey: "uid")
    var recordedId: Int = UserDefaults.standard.integer(forKey: "recordId")
    
    var createRequestBool : Bool = false
    
    var dataBaseName: String = "mbe.riverprime.com"
    var dbUserName: String =  "ios"
    var dbPassword: String =  "4e9b5768375b5a0acf0c94645eac5cdd9c07c059"
    var userEmail: String = ""
    
    weak var delegate: SendOTPDelegate?
    weak var createLeadDelegate: CreateLeadOdooDelegate?
    weak var verifyDelegate: VerifyOTPDelegate?
    weak var updateNumberDelegate: UpdatePhoneNumebrDelegate?
    weak var createUserAcctDelegate: CreateUserAccountTypeDelegate?
    weak var tradeSymbolDetailDelegate: TradeSymbolDetailDelegate?
    
    //MARK: - Authentication Method
    // working
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
    
    //MARK: - Verify OTP Method
    
    func verifyOTP(type: String, email: String, phone: String, otp: String) {
        
        let parametersValue: [String: Any] = [
            "type": type,
            "email": email,
            "otp": otp,
            "phone": phone
        ]
        // Convert the dictionary to JSON object and send the request using Alamofire
        AF.request(otpVerifyURL,
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
                        print("\n this is the verify response of type: \(type) and response is \(json)\n")
                        self.verifyDelegate?.otpVerifySuccess(response: result)
                    } else {
                        let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Status is not success"])
                        self.verifyDelegate?.otpVerifyFailure(error: error)
                    }
                } else {
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Invalid JSON structure"])
                    self.verifyDelegate?.otpVerifyFailure(error: error)
                }
            case .failure(let error):
                self.verifyDelegate?.otpVerifyFailure(error: error)
            }
        }
    }
    
    //MARK: - send OTP Method
    
    func sendOTP(type: String, email: String, phone: String) {
        
        let parametersValue: [String: Any] = [
            "type": type,
            "email": email,
            "phone": phone
        ]
        
        
            let parametersValue1: [String: Any] = [
                "method": "execute_kw",
                "params": [
                    "mbe.riverprime.com",
                    7,
                    "4e9b5768375b5a0acf0c94645eac5cdd9c07c059",
                    "mt.middleware",
                    "send_otp",
                    [
                        phone,
                        email,
                        type,
                        ""
                    ]
                ]
            ]
        
        // Convert the dictionary to JSON object and send the request using Alamofire
        AF.request(otpSendURL,
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
                        print("\n this is the SUCESS response of type: \(type) and response is \(json)\n")
                        self.delegate?.otpSuccess(response: result)
                    } else {
                        let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Status is not success"])
                        self.delegate?.otpFailure(error: error)
                        print("this is send otp (success) error response of type \(type) : \(error)")
                    }
                } else {
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Invalid JSON structure"])
                    self.delegate?.otpFailure(error: error)
                    print("this is send otp Error response of type \(type) : \(error)")
                }
            case .failure(let error):
                self.delegate?.otpFailure(error: error)
                print("this is send otp error response: \(error)")
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
    
    //MARK: - create trade Account Method
//
//    /web/mt/account/create
//
//    {
//            "jsonrpc": "2.0",
//            "method": "call",
//            "params": {
//                    "email": "h.yaseen@riverprime.com",
//                    "phone": "+971566486002",
//                    "group": "demo\\RP\\PRO",
//                    "leverage": 4000,
//                    "first_name": "Hasabalrasool",
//                    "last_name": "Yaseen",
//                    "password": "CFCqse780@*"
//            },
//            "id": 82101
//    }
//
//
    func createAccount(phone: String, group: String, email: String, currency: String, leverage: Int, first_name: String, last_name: String, password: String) {
       
        let parameters: [String: Any] = [
            "phone": phone,
            "group": group,
            "currency": currency,
            "email": email,
            "first_name": first_name,
            "last_name" : last_name,
            "password": password
        ]
        
        // Make the request
        AF.request(createAccountURL,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type": "application/json"])
        .validate()
        .responseJSON { (response: AFDataResponse<Any>) in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let result = json["result"] as? [String: Any],
                   let status = result["status"] as? String {
                    if status == "success" {
                        print("This is the response: \(json)")
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
    //MARK: - information for trade Symbol detail
    // working
    func sendSymbolDetailRequest() {
        let methodName = "execute_kw"
       
      
        // Define the domain filter and parameters
        let domainFilter: [[Any]] = [[
            "mobile_available", "=" , "True"
        ]]
        
        let fieldRetrieve: [String: [String]] = ["fields": ["id","name","description","icon_url","volume_min","volume_max","volume_step","contract_size","display_name","sector","digits","mobile_available"]]
        
        let params: [Any] = [
            dataBaseName,      // Database name
            uid,               // UID
            dbPassword,        // Password
            "mt.symbol",       // Model name
            "search_read",    // Method name
            [domainFilter],   // Domain (search criteria)
            fieldRetrieve             // Fields to retrieve
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
                       
                        self.tradeSymbolDetailDelegate?.tradeSymbolDetailSuccess(response: responseString)
                    }
                case .failure(let error):
                    print("Trade symbol detail response Error: \(error)")
                    self.tradeSymbolDetailDelegate?.tradeSymbolDetailFailure(error: error)
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
            .responseData { [self] response in
                switch response.result {
                case .success(let data):
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("createR Lead ecords Response XML: \(responseString)")
                        createLeadDelegate?.leadCreatSuccess(response: responseString)
                        // sendOTP(email: userEmail, phone: "")
                    }
                    self.saveUserIdFromXMLData(data)
                case .failure(let error):
                    print("Error: \(error)")
                    createLeadDelegate?.leadCreatFailure(error: error)
                }
            }
    }
    //MARK: - Method write/update data to OdooServer
    // working
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
                        self.updateNumberDelegate?.updateNumberSuccess(response: responseString)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    self.updateNumberDelegate?.updateNumberFailure(error: error)
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
