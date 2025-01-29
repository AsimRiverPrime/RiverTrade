//
//  KYCViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 06/09/2024.
//

import UIKit
import SVProgressHUD
import IDWiseSDK
import ShuftiPro.Swift

enum KYCType {
    case KycScreen
    case ProfileScreen
    case FirstScreen
    case SecondScreen
    case ThirdScreen
    case FourthScreen
    case FifthScreen
    case SixthScreen
    case SeventhScreen
    case ReturnDashboard
}  

protocol KYCVCDelegate: AnyObject {
    func navigateToCompeletProfile(kyc: KYCType)
}

class KYCViewController: BaseViewController{
    
    var dob: String?
    var userName: String?
    var gender: String?
    var userId: String?
    var userEmail : String?
    
    var odooClientService = OdooClientNew()
//    var appToken = "eyJhbGciOiJIUzI1NiJ9.aXRAc2FsYW1pbnYuY29tWmFpZCAgT2RlaCAgIGQ3NDU5ZjBlLTdmNWItNDhlNC04ZDAzLWE0YmJjNzMyNzE3Mg.QzQR-QHQM2kyYkdqUF9x0Te2L4m8aCQvU4E6bL_9KrY"
//    var userToken = ""
    
    let fireStoreInstance = FirestoreServices()
    
//    let clientKey = "QmFzaWMgVkMxaE1qWTBOVGt5Wmkxak9EZGhMVFExTnpndFlqSTRNUzFsTVRBNE1XRTJZemRoT0RZNlRHdGpibUYwTkRSWFMxRnlkRkJhV0RKTGIyZHdUMmhrYzNneFVrTk9hVlZFVTFsNk5rRktUUT09"
//    let flowId = "a264592f-c87a-4578-b281-e1081a6c7a86"
//    var journeyId = "" // used for idwise
    
    weak var delegateKYC: KYCVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            //print("saved User Data: \(savedUserData)")
            if let _gender = savedUserData["gender"] as? String,let _email = savedUserData["email"] as? String, let _userId = savedUserData["id"]  as? String, let _name = savedUserData["fullName"] as? String, let _dob = savedUserData["dateOfBirth"] as? String {
                self.dob = _dob
                self.userName = _name
                self.gender = _gender
                self.userId = _userId
                self.userEmail = _email
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @IBAction func closeBtn_action(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    
    @IBAction func uploadDocBtn(_ sender: Any) {
        
        let shufti = Shufti()
       let authKeyss = [
            "auth_type" : "basic_auth",
            "client_id": "19cc49621d50e7918f50c03798478511700af56687763226b96b090435c45775",
            "secret_key": "pB14s1X3CkipprTDy3hwtmXhUUTQXOmR"
        ]

        let uniqueReference =  shufti.getUniqueReference()
        
        
        let configsss = [
            "open_webview" : false,
            "async" : false,
            "video_kyc" : false
        ]
        
//        let configsss = [
//            "base_url":  "api.shuftipro.com",
//            "consent_age":  16,
//            "open_webview" : false,
//            "async" : false,
//            "video_kyc" : false
//        ] as [String : Any]
        
        var dataDictionary: [String: Any] = [
            "reference": uniqueReference,
            "country": "",
            "language": "EN",
            "email": userEmail ?? "",
            "callback_url": "",
            "show_results": "1",
            "redirect_url": "https://www.mydummy.shuftipro.com/",
            "show_privacy_policy": "1",
            "show_consent": "1",
            "verification_mode": "image_only",
            "allow_offline": "1",
            "allow_online": "1",
            "face": ["proof": ""],
            "document": [
                "proof": "",
                "additional_proof": "",
                "supported_types": ["passport", "id_card"],
                "name": ["first_name": "", "last_name": ""],
                "backside_proof_required": "0",
                "dob": "",
                "document_number": "",
                "expiry_date": "",
                "issue_date": ""
            ],
            "background_checks": [
                "alias_search": "0",
                "rca_search": "0",
                "match_score": "100",
                "countries": ["ae"],
              
                "filters": [
                    "sanction",
                    "warning",
                    "fitness-probity",
                    "pep",
                    "pep-class-1",
                    "pep-class-2",
                    "pep-class-3",
                    "pep-class-4"
                ]
            ]
        ]

        print("Final Request: \(dataDictionary)")

        
        shufti.shuftiProVerification(requestObject: dataDictionary, authKeys: authKeyss, parentVC: self, configs: configsss) {(result) in
            print("Got response from sdk: \(result)")
            let response = result as! NSDictionary
                       
            let reponse = result as? NSDictionary
            if reponse?.value(forKey: "event") as? String == "verification.accepted" {
              // Verification Accepted Callback
                print("Verified: Do something")
                if let responseDict = result as? [String: Any],
                   let verificationData = responseDict["verification_data"] as? [String: Any] {
                    
                    do {
                        // Convert dictionary to Data
                        let jsonData = try JSONSerialization.data(withJSONObject: verificationData, options: .prettyPrinted)
                        
                        // Save to UserDefaults
                        UserDefaults.standard.set(jsonData, forKey: "verificationData")
                        UserDefaults.standard.synchronize()
                        
                        print("Verification data saved successfully!")
                    } catch {
                        print("Failed to convert verification data to JSON: \(error.localizedDescription)")
                    }
                } else {
                    print("Failed to extract verification_data")
                }
                
                UserDefaults.standard.set(2, forKey: "profileStepCompeleted")
                self.AddUserAccountDetail()
            }
            else if reponse?.value(forKey: "event") as? String == "verification.declined"{
              // Verification Declined Callback
            }
            else if reponse?.value(forKey: "event") as? String == "request.received"{
              // This event states that the verification request has been received and is under processing.
            }
            else if reponse?.value(forKey: "event") as? String == "request.pending"{
              // This event is returned for all on-site verifications until the verification is completed or timeout.
            }else if reponse?.value(forKey: "event") as? String == "request.unauthorized"{
                // This event occurs when the auth header is not correct and, client id/secret key may be invlaid.
              }else{
                print("Declined: Do something")
            }
            
        }
    
//        generateAccessToken { accessToken in
//            guard let accessToken = accessToken else {
//                print("Failed to generate access token")
//                return
//            }
//            
//            
//            // Define authKeys with the access token
//            let authKeys = [
//                "auth_type": "access_token",
//                "access_token": accessToken,
//                "client_id": "19cc49621d50e7918f50c03798478511700af56687763226b96b090435c45775",
//                "secret_key": "jOVT1Qg5ysTsvhQ2n8bVPcfhGrtrKNu1"
//            ]
//            
//            
//            let requestObject: [String: Any] = [
//                "reference": self.userId ?? "",
//                "country": "Dubai",
//                "language": "",
//                "email": self.userEmail ?? "",
//                "callback_url": "http://www.example.com",
//                "show_results": "",
//                "verification_mode": "image_only",
//                "face": ["proof": ""],
//                "document": [
//                    "proof": "",
//                    "additional_proof": "",
//                    "supported_types": [
//                        "passport",
//                        "id_card"
//                    ],
//                    "name": [
//                        "first_name": "",
//                        "last_name": ""
//                    ],
//                    "backside_proof_required": "0",
//                    "dob": "",
//                    "document_number": "",
//                    "expiry_date": "",
//                    "issue_date": ""
//                ],
//                "address": [
//                    "proof": "",
//                    "full_address": "",
//                    "name": [
//                        "first_name": "",
//                        "last_name": ""
//                    ],
//                    "supported_types": [
//                        "id_card",
//                        "utility_bill",
//                        "bank_statement"
//                    ]
//                ],
//                "consent": [
//                    "proof": "",
//                    "text": "my consent note",
//                    "supported_types": [
//                        "printed",
//                        "handwritten"
//                    ]
//                ]
//            ]
//            
//            let configs = [
//                "base_url": "api.shuftipro.com",
//                "consent_age": 16,
//            ] as [String: Any]
//            
//            let instance = Shufti()
//            
//            instance.register(clientID: "19cc49621d50e7918f50c03798478511700af56687763226b96b090435c45775", customerID: self.userId ?? "", configs: configs) { result in
//                print(result)
//            }
//            
//            instance.shuftiProVerification(requestObject: requestObject, authKeys: authKeys, parentVC: self, configs: configs) { result in
//                print("result for request is: \(result)") // Callback response for verification verified/declined
//                let response = result as! NSDictionary
//                if response.value(forKey: "event") as? String == "verification.accepted" {
//                    // Verified: Do something
//                    print("Verified: Do something")
//                } else {
//                    // Declined: Do something
//                    print("Declined: Do something")
//                }
//            }
//        }
    }
    
    
    
    func AddUserAccountDetail() {
        let userId =  UserDefaults.standard.string(forKey: "userID")
        let profileStep = UserDefaults.standard.integer(forKey: "profileStepCompeleted")
        let overAllStatus = UserDefaults.standard.string(forKey: "OverAllStatus")
        let sid = UserDefaults.standard.string(forKey: "SID")
        
//        print("profileStepCompeleted is : \(profileStep) OverAll status is : \(overAllStatus) sid: \(sid)")
        
        let userData: [String: Any] = [
               "uid": userId ?? "",
               "sId": sid ?? "",
               "step": profileStep,
               "profileStep": profileStep,
               "overAllStatus": overAllStatus ?? ""
           ]
        
        print("\n userKYCData detail: \(userData)")
        fireStoreInstance.addUserAccountData(uid: userId ?? "", data: userData) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                print("\n KYC detail ADD to firebase successfully!")
                self.updateUser()
                self.ToastMessage("KYC detail added successfully!")
                
            case .failure(let error):
                print("Error adding/updating document: \(error)")
                self.showTimeAlert(str:"\(error)")
            }
        }
    }
   
    
    func updateUser() {
        let userId =  UserDefaults.standard.string(forKey: "userID")
        let profileStep = UserDefaults.standard.integer(forKey: "profileStepCompeleted")
        
        var fieldsToUpdate: [String: Any] = [
           
                "profileStep": profileStep,
                "KycStatus": "verification.accepted"
             ]
        
        fireStoreInstance.updateUserFields(userID: userId!, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                print("\n User data save successfully in the fireBase after KYC process")
                self.fireStoreInstance.fetchUserData(userId: userId!)
                
                let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                    self.dismiss(animated: true) {
                        NotificationCenter.default.post(name: Notification.Name("UpdateProfileDataStatus"), object: nil, userInfo: ["type": "", "status": "Approved"])
                    }
                }
            }
        }
        if let savedData = UserDefaults.standard.data(forKey: "verificationData") {
            do {
                let verificationData = try JSONSerialization.jsonObject(with: savedData, options: []) as? [String: Any]
                print("Retrieved Verification Data: \(String(describing: verificationData))")
            } catch {
                print("Failed to decode verification data: \(error.localizedDescription)")
            }
        }
        
    }
}

//extension KYCViewController: IDWiseJourneyCallbacks {
//    func onError(error: IDWiseSDK.IDWiseError) {
//        print("error: \(error)")
//    }
//    
//    func onJourneyStarted(journeyStartedInfo: IDWiseSDK.JourneyStartedInfo) {
//        self.journeyId = journeyStartedInfo.journeyId
//        print("journeyId: \(self.journeyId)")
//       
//    }
//    
//    func onJourneyResumed(journeyResumedInfo: IDWiseSDK.JourneyResumedInfo) {
//        print("journeyResumedInfo: \(journeyResumedInfo)")
//    }
//    
//    func onJourneyCompleted(journeyCompletedInfo: IDWiseSDK.JourneyCompletedInfo) {
//        print("Complete Info: \(journeyCompletedInfo)")
//        UserDefaults.standard.set(journeyCompletedInfo.journeyId, forKey: "SID")
//        
//        let sid = UserDefaults.standard.string(forKey: "SID")
//        print("sid: \(sid)")
//        
//        self.showTimeAlert(str:"Scanning completed successfully")
//        
//        UserDefaults.standard.set(2, forKey: "profileStepCompeleted")
//       
//        odooClientService.SearchRecord(email: self.userEmail ?? "") { data, error in
//            print("id_waise decision is: \(data) : error is: \(error)")
//            NotificationCenter.default.post(name: Notification.Name("UpdateProfileDataStatus"), object: nil, userInfo: ["type": "", "status": "inProgress"])
//            self.AddUserAccountDetail()
//        }
//        
////        delegateKYC?.navigateToCompeletProfile(kyc: .ReturnDashboard)
//    }
//    
//    func onJourneyCancelled(journeyCancelledInfo: IDWiseSDK.JourneyCancelledInfo) {
//        print("journeyCancelledInfo: \(journeyCancelledInfo)")
//    }
//}

//class KYCViewController: BaseViewController{
//    
//    var dob: String?
//    var userName: String?
//    var gender: String?
//    var userId: String?
//    var userEmail : String?
//    var odooClientService = OdooClientNew()
////    var appToken = "eyJhbGciOiJIUzI1NiJ9.aXRAc2FsYW1pbnYuY29tWmFpZCAgT2RlaCAgIGQ3NDU5ZjBlLTdmNWItNDhlNC04ZDAzLWE0YmJjNzMyNzE3Mg.QzQR-QHQM2kyYkdqUF9x0Te2L4m8aCQvU4E6bL_9KrY"
////    var userToken = ""
//    
//    let fireStoreInstance = FirestoreServices()
//    
//    let clientKey = "QmFzaWMgVkMxaE1qWTBOVGt5Wmkxak9EZGhMVFExTnpndFlqSTRNUzFsTVRBNE1XRTJZemRoT0RZNlRHdGpibUYwTkRSWFMxRnlkRkJhV0RKTGIyZHdUMmhrYzNneFVrTk9hVlZFVTFsNk5rRktUUT09"
//    let flowId = "a264592f-c87a-4578-b281-e1081a6c7a86"
//    var journeyId = ""
//    
//    weak var delegateKYC: KYCVCDelegate?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.navigationController?.navigationBar.isHidden = true
//        
//        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
//            //print("saved User Data: \(savedUserData)")
//            if let _gender = savedUserData["gender"] as? String,let _email = savedUserData["email"] as? String, let _userId = savedUserData["id"]  as? String, let _name = savedUserData["fullName"] as? String, let _dob = savedUserData["dateOfBirth"] as? String {
//                self.dob = _dob
//                self.userName = _name
//                self.gender = _gender
//                self.userId = _userId
//                self.userEmail = _email
//            }
//        }
//
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
//    }
//
//    @IBAction func closeBtn_action(_ sender: Any) {
////        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true)
//    }
//    
//    @IBAction func uploadDocBtn(_ sender: Any) {
//        
//        IDWise.initialize(clientKey: clientKey,theme: .dark) { err in
//                       // Deal with error here
//                   if let error = err {
//                     // handle error, show some alert or any other logic
//                   }
//               }
//        
//        let applicantDetailssss: [String:String] = [
//            ApplicantDetailsKeys.FULL_NAME: self.userName ?? "",
//            ApplicantDetailsKeys.BIRTH_DATE: self.dob ?? "",
//            ApplicantDetailsKeys.SEX: self.gender ?? "",
//          
//        ]
////        IDWise.startJourney(journeyDefinitionId: flowId, referenceNumber: "0o9bz50Y63XlI25auIbm0B2zJt42", locale: "en", journeyDelegate: self)
//        IDWise.startJourney(flowId: flowId, referenceNumber: self.userId ?? "", applicantDetails: applicantDetailssss , journeyCallbacks: self)
//     
//    }
//    
//    func AddUserAccountDetail() {
//        let userId =  UserDefaults.standard.string(forKey: "userID")
//        let profileStep = UserDefaults.standard.integer(forKey: "profileStepCompeleted")
//        let overAllStatus = UserDefaults.standard.string(forKey: "OverAllStatus")
//        let sid = UserDefaults.standard.string(forKey: "SID")
//        
////        print("profileStepCompeleted is : \(profileStep) OverAll status is : \(overAllStatus) sid: \(sid)")
//        
//        let userData: [String: Any] = [
//               "uid": userId ?? "",
//               "sId": sid ?? "",
//               "step": profileStep,
//               "profileStep": profileStep,
//               "overAllStatus": overAllStatus ?? ""
//           ]
//        
//        print("\n userKYCData detail: \(userData)")
//        fireStoreInstance.addUserAccountData(uid: userId ?? "", data: userData) { [weak self] result in
//            guard let self = self else { return }
//            
//            switch result {
//            case .success:
//                print("\n KYC detail ADD to firebase successfully!")
//                self.updateUser()
//                self.showTimeAlert(str:"KYC detail added successfully!")
//                self.dismiss(animated: true) {
////                    self.delegateKYC?.navigateToCompeletProfile(kyc: .ReturnDashboard)
//                NotificationCenter.default.post(name: Notification.Name("UpdateProfileDataStatus"), object: nil, userInfo: ["type": "", "status": "inProgress"])
//                }
//            case .failure(let error):
//                print("Error adding/updating document: \(error)")
//                self.showTimeAlert(str:"\(error)")
//            }
//        }
//    }
//   
//    
//    func updateUser() {
//        let userId =  UserDefaults.standard.string(forKey: "userID")
//        let profileStep = UserDefaults.standard.integer(forKey: "profileStepCompeleted")
//        
//        var fieldsToUpdate: [String: Any] = [
//           
//                "profileStep": profileStep,
//                "KycStatus": "Progress Started"
//                
//             ]
//        
//        fireStoreInstance.updateUserFields(userID: userId!, fields: fieldsToUpdate) { error in
//            if let error = error {
//                print("Error updating user fields: \(error.localizedDescription)")
//                return
//            } else {
//                print("\n User data save successfully in the fireBase after KYC process")
//                self.fireStoreInstance.fetchUserData(userId: userId!)
//            }
//        }
//    }
//}
//
//extension KYCViewController: IDWiseJourneyCallbacks {
//    func onError(error: IDWiseSDK.IDWiseError) {
//        print("error: \(error)")
//    }
//    
//    func onJourneyStarted(journeyStartedInfo: IDWiseSDK.JourneyStartedInfo) {
//        self.journeyId = journeyStartedInfo.journeyId
//        print("journeyId: \(self.journeyId)")
//       
//    }
//    
//    func onJourneyResumed(journeyResumedInfo: IDWiseSDK.JourneyResumedInfo) {
//        print("journeyResumedInfo: \(journeyResumedInfo)")
//    }
//    
//    func onJourneyCompleted(journeyCompletedInfo: IDWiseSDK.JourneyCompletedInfo) {
//        print("Complete Info: \(journeyCompletedInfo)")
//        UserDefaults.standard.set(journeyCompletedInfo.journeyId, forKey: "SID")
//        
//        let sid = UserDefaults.standard.string(forKey: "SID")
//        print("sid: \(sid)")
//        
//        self.showTimeAlert(str:"Scanning completed successfully")
//        
//        UserDefaults.standard.set(2, forKey: "profileStepCompeleted")
//       
//        odooClientService.SearchRecord(email: self.userEmail ?? "") { data, error in
//            print("id_waise decision is: \(data) : error is: \(error)")
//            NotificationCenter.default.post(name: Notification.Name("UpdateProfileDataStatus"), object: nil, userInfo: ["type": "", "status": "inProgress"])
//            self.AddUserAccountDetail()
//        }
//        
////        delegateKYC?.navigateToCompeletProfile(kyc: .ReturnDashboard)
//    }
//    
//    func onJourneyCancelled(journeyCancelledInfo: IDWiseSDK.JourneyCancelledInfo) {
//        print("journeyCancelledInfo: \(journeyCancelledInfo)")
//    }
//}

extension KYCViewController: KYCVCDelegate {
    
    func navigateToCompeletProfile(kyc: KYCType) {
        switch kyc {
        case .ProfileScreen:
//            if let profileVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DashboardVC"){
////                profileVC.delegateKYC = self
//                GlobalVariable.instance.isReturnToProfile = true
//                self.navigate(to: profileVC)
//            }
            if let profileVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "ProfileViewController"){
//                profileVC.delegateKYC = self
//                GlobalVariable.instance.isReturnToProfile = true
                self.navigate(to: profileVC)
            }
            break
        case .FirstScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
            vc.delegateKYC = self
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .SecondScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen2, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen2
            vc.delegateKYC = self
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .ThirdScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen3, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen3
            vc.delegateKYC = self
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .FourthScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen4, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen4
            vc.delegateKYC = self
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .FifthScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen5, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen5
            vc.delegateKYC = self
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .SixthScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen6, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen6
            vc.delegateKYC = self
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .SeventhScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen7, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen7
            vc.delegateKYC = self
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .ReturnDashboard:
            if let profileVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "ProfileViewController") as? ProfileViewController {
                self.navigate(to: profileVC)
            }

            break
        case .KycScreen:
            let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
            vc.delegateKYC = self
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            
        }
    }
    
}
