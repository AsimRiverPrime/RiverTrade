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
    weak var updateUserNamePasswordDelegate: UpdateUserNamePassword?
    weak var topNewsDelegate: TopNewsProtocol?
    
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
            print("saved User Data: \(savedUserData)")
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
                    userEmail,
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
    
    let calendarSampleData = """
                [
            {
                "CalendarId": "352775",
                "Date": "2024-06-13T00:40:00",
                "Country": "Angola",
                "Category": "Inflation Rate",
                "Event": "Inflation Rate YoY",
                "Reference": "May",
                "ReferenceDate": "2024-05-31T00:00:00",
                "Source": "Instituto Nacional de Estatística, Angola",
                "SourceURL": "https://www.ine.gov.ao/",
                "Actual": "30.16%",
                "Previous": "28.2%",
                "Forecast": "",
                "TEForecast": "30.0%",
                "URL": "/angola/inflation-cpi",
                "DateSpan": "0",
                "Importance": 1,
                "LastUpdate": "2024-06-13T00:37:17.17",
                "Revised": "",
                "Currency": "",
                "Unit": "%",
                "Ticker": "ANGOLAIR",
                "Symbol": "AngolaIR"
            },
            {
                "CalendarId": "352774",
                "Date": "2024-06-13T00:40:00",
                "Country": "Angola",
                "Category": "Inflation Rate Mom",
                "Event": "Inflation Rate MoM",
                "Reference": "May",
                "ReferenceDate": "2024-05-31T00:00:00",
                "Source": "Instituto Nacional de Estatística, Angola",
                "SourceURL": "https://www.ine.gov.ao/",
                "Actual": "2.49%",
                "Previous": "2.61%",
                "Forecast": "",
                "TEForecast": "2.5%",
                "URL": "/angola/inflation-rate-mom",
                "DateSpan": "0",
                "Importance": 1,
                "LastUpdate": "2024-06-13T00:37:54.987",
                "Revised": "",
                "Currency": "",
                "Unit": "%",
                "Ticker": "ANGOLAINFRATMOM",
                "Symbol": "ANGOLAINFRATMOM"
            },
            {
                "CalendarId": "365832",
                "Date": "2024-06-13T00:00:00",
                "Country": "G7",
                "Category": "Calendar",
                "Event": "G7 Summit",
                "Reference": "",
                "ReferenceDate": null,
                "Source": "",
                "SourceURL": "",
                "Actual": "",
                "Previous": "",
                "Forecast": "",
                "TEForecast": "",
                "URL": "/g7/calendar",
                "DateSpan": "1",
                "Importance": 1,
                "LastUpdate": "2024-06-06T22:41:09.787",
                "Revised": "",
                "Currency": "",
                "Unit": "",
                "Ticker": "G7CALENDAR",
                "Symbol": "G7CALENDAR"
            }
        ]
    """.data(using: .utf8)!


//    func getNewsRecords() {
//        // Use the sample JSON response
//        let sampleResponse = """
//        [
//            {"id":"389217","title":"North Macedonia Inflation Lowest since End of 2021","date":"2024-12-13T12:23:44.617","description":"The annual inflation rate in Macedonia eased further to 6.6% in September 2023 from 8.3% in the previous month, marking the lowest level since December 2021. Slower increases were primarily seen in food & non-alcoholic beverages (7.8% vs 10.8% in August), housing & utilities (6.1% vs 8.5%), clothing & footwear (5.1% vs 5.6%), and furnishings & household equipment (10.7% vs 14.1%). On the other hand, the cost grew faster for transport (1.8% vs 0.4%), while remaining unchanged for restaurants & hotels (5.5% vs 5.5%), On a monthly basis, consumer prices edged down by 0.1% in September.","country":"Macedonia","category":"Inflation Rate","symbol":"MacedoniaIR","url":"/macedonia/inflation-cpi","importance":3},
//            {"id":"389215","title":"Malta Industrial Production Accelerates in August","date":"2024-12-09T10:09:31.267","description":"Industrial production in Malta rose by 2.9% year-on-year in August 2023, following a downwardly revised 2% increase in the previous month, as production accelerated for intermediate goods (8.7% vs 5.0% in August), manufacturing (4.1% vs 3.2%) and rebounded for capital goods (7.4% vs -1.7%). Also, production of durable consumer goods surged (33% vs 26%), while output of non-durable consumer goods declined (-0.9% vs 3.8%). Meanwhile, energy production fell at a softer pace (-1.1% vs -3.2%). On a seasonally adjusted basis, industrial production rose 0.6%, following a downwardly revised 3.1% increase in July.","country":"Malta","category":"Industrial Production","symbol":"MalaltaIndction","url":"/malta/industrial-production","importance":3},
//            {"id":"389214","title":"Croatia Trade Deficit Narrows in August","date":"2024-12-12T14:57:00","description":"Croatia’s trade deficit narrowed to EUR 1.3 billion in August 2023 from EUR 2 billion in the corresponding month of the previous year, preliminary estimates showed. Year-on-year, exports fell at a softer 10.5% to EUR 1.7 billion, while imports shrank by 25.6% to EUR 2.9 billion. Considering the January-August period, the trade deficit decreased to EUR 11.3 billion from EUR 12.1 billion in the same period of 2022.","country":"Croatia","category":"Balance of Trade","symbol":"CroatiaBalrade","url":"/croatia/balance-of-trade","importance":0},
//            {"id":"389213","title":"Italian Shares Flat on Monday","date":"2024-12-11T09:38:05.063","description":"The FTSE MIB was trading around the flatline slightly above the 27,800 threshold on Monday, mirroring the performance of its European peers, as demand for safety increased after the conflict between Israel and Hamas escalated. Significant declines were seen in Amplifon (-1.5%), Telecom Italia (-2%) and Moncler (-1.8%). However, petrochemical firms, including Tenaris, Eni and Saipem, were all up by almost 2%, benefitting from a significant surge in oil prices. Additionally, global defense stocks, namely Leonardo (+6.3%), have experienced a rally amidst the prevailing geopolitical tensions.","country":"Italy","category":"Stock Market","symbol":"FTSEMIB","url":"/italy/stock-market","importance":1},
//            {"id":"389212","title":"Copper Rebounds from 4-Month Low","date":"2024-12-13T09:30:12.583","description":"Copper futures rose to above $3.6 per pound, rebounding from the four-month low of $3.56 on October 5th as markets reassessed the impact of soaring bond yields on the demand for industrial inputs. Optimistic PMI data from the US underscored the robustness of manufacturers to tighter monetary policy, keeping the demand outlook in check despite the surge in long-dated bond yields. Improved PMI data from China also underpinned robust industrial activity, aligning with recent bets from JPMorgan that forecasted high infrastructure construction in the world’s top consumer. Looming shortage concerns in the longer run also supported prices. Reports from S&P Global and the EIA project copper demand to double from the current levels by 2035, missing the International Copper Association’s forecasts of a 26% increase in supply, and raising concerns of wide shortfalls. In the shorter term, output from Codelco sank by 14% in the first half of the year, stretching the 7% decline from 2022.","country":"Commodity","category":"Commodity","symbol":"HG1","url":"/commodity/copper","importance":1},
//            {"id":"389213","title":"Copper Rebounds from 4-Month Low","date":"2024-12-12T09:30:12.583","description":"Copper futures rose to above $3.6 per pound, rebounding from the four-month low of $3.56 on October 5th as markets reassessed the impact of soaring bond yields on the demand for industrial inputs. Optimistic PMI data from the US underscored the robustness of manufacturers to tighter monetary policy, keeping the demand outlook in check despite the surge in long-dated bond yields. Improved PMI data from China also underpinned robust industrial activity, aligning with recent bets from JPMorgan that forecasted high infrastructure construction in the world’s top consumer. Looming shortage concerns in the longer run also supported prices. Reports from S&P Global and the EIA project copper demand to double from the current levels by 2035, missing the International Copper Association’s forecasts of a 26% increase in supply, and raising concerns of wide shortfalls. In the shorter term, output from Codelco sank by 14% in the first half of the year, stretching the 7% decline from 2022.","country":"Commodity","category":"Commodity","symbol":"HG1","url":"/commodity/copper","importance":3},
//            {"id":"389214","title":"Copper Rebounds from 4-Month Low","date":"2024-12-13T13:30:12.583","description":"Copper futures rose to above $3.6 per pound, rebounding from the four-month low of $3.56 on October 5th as markets reassessed the impact of soaring bond yields on the demand for industrial inputs. Optimistic PMI data from the US underscored the robustness of manufacturers to tighter monetary policy, keeping the demand outlook in check despite the surge in long-dated bond yields. Improved PMI data from China also underpinned robust industrial activity, aligning with recent bets from JPMorgan that forecasted high infrastructure construction in the world’s top consumer. Looming shortage concerns in the longer run also supported prices. Reports from S&P Global and the EIA project copper demand to double from the current levels by 2035, missing the International Copper Association’s forecasts of a 26% increase in supply, and raising concerns of wide shortfalls. In the shorter term, output from Codelco sank by 14% in the first half of the year, stretching the 7% decline from 2022.","country":"Commodity","category":"Commodity","symbol":"HG1","url":"/commodity/copper","importance":3}
//        ]
//        """.data(using: .utf8)!
//
//        do {
//            // Decode the JSON response
//            let decodedResponse = try JSONDecoder().decode([PayloadItem].self, from: sampleResponse)
//            print("Decoded Response: \(decodedResponse)")
//            self.topNewsDelegate?.topNewsSuccess(response: decodedResponse)
//        } catch {
//            print("Failed to decode JSON: \(error)")
//            self.topNewsDelegate?.topNewsFailure(error: error)
//        }
//    }
   

    
    
    func getCalendarDataRecords(fromDate: String , toDate: String) {
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            if let email = savedUserData["email"] as? String{
                self.userEmail = email
            }
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
                    "te.middleware",
                    "get_calendar_data",
                    [
                    [],
                    userEmail,
                    fromDate,
                    toDate
                    ]]
                ]
            ]
        
        print("\n the parameters is: \(jsonrpcBody)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: jsonrpcBody, showLoader: true) { result in
            
            switch result {
            case .success(let value):
                print("get economic calendar value is: \(value)")
            case .failure(let error):
                print("economic calendar Request failed: \(error)")
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
