//
//  KYCViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 06/09/2024.
//

import UIKit
import SVProgressHUD
//import IDWiseSDK
import ShuftiPro.Swift

//enum KYCType {
//    case KycScreen
//    case ProfileScreen
//    case FirstScreen
//    case SecondScreen
//    case ThirdScreen
//    case FourthScreen
//    case FifthScreen
//    case SixthScreen
//    case SeventhScreen
//    case ReturnDashboard
//}
//
//protocol KYCVCDelegate: AnyObject {
//    func navigateToCompeletProfile(kyc: KYCType)
//}

class KYCViewController: BaseViewController {
    
    var dob: String?
    var userName: String?
    var gender: String?
    var userId: String?
    var userEmail : String?
    
    var odooClientService = OdooClientNew()
 
    let fireStoreInstance = FirestoreServices()
    
//    weak var delegateKYC: KYCVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.isHidden = true
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            //print("saved User Data: \(savedUserData)")
            if let _gender = savedUserData["gender"] as? String,let _email = savedUserData["email"] as? String, let _userId = savedUserData["uid"]  as? String, let _name = savedUserData["fullName"] as? String, let _dob = savedUserData["dateOfBirth"] as? String {
                self.dob = _dob
                self.userName = _name
                self.gender = _gender
                self.userId = _userId
                self.userEmail = _email
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: ProfileViewController(), navController: self.navigationController, title: "Document Verification", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    @IBAction func closeBtn_action(_ sender: Any) {
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let window = windowScene.windows.first {
//            let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
//            let tabBarController = storyboard.instantiateViewController(withIdentifier: "HomeTabbarViewController") as! UITabBarController
//            window.rootViewController = tabBarController
//            window.makeKeyAndVisible()
//        }
        self.navigationController?.popToRootViewController(animated: true)
         // Change to tab index 0
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
             self.tabBarController?.selectedIndex = 0
         }
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
        
        var dataDictionary: [String: Any] = [
            "reference": uniqueReference,
            "country": "",
            "language": "EN",
            "email": userEmail ?? "",
            "callback_url": "https://mbe.riverprime.com/shufti/callback",
            "show_results": "0",
            
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
        print("\n---Final Request for Shufti---:\n \(dataDictionary)\n")
        
        shufti.shuftiProVerification(requestObject: dataDictionary, authKeys: authKeyss, parentVC: self, configs: configsss) {(result) in
            print("Got response from Shufti sdk:\n \(result)")
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
                        
                        print("Verification data saved successfully! data is:\n \t \t <<<<<<----*******************---------->>>Started \t \n \(String(describing: UserDefaults.standard.dictionary(forKey: "verificationData"))) \n \t \t <<<<<<----*******************---------->>>Finished \t \n ")
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
                self.ToastMessage("KYC verification declined!")
            }
            else if reponse?.value(forKey: "event") as? String == "request.received"{
                // This event states that the verification request has been received and is under processing.
            }
            else if reponse?.value(forKey: "event") as? String == "request.pending"{
                // This event is returned for all on-site verifications until the verification is completed or timeout.
                self.ToastMessage("KYC verification request.pending!")
            }else if reponse?.value(forKey: "event") as? String == "request.unauthorized"{
                // This event occurs when the auth header is not correct and, client id/secret key may be invlaid.
                self.ToastMessage("KYC verification request.unAuthorized!")
            }else{
                print("Declined: Do something")
                self.ToastMessage("KYC verification declined!")
            }
        }
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
                let _ = Timer.scheduledTimer(withTimeInterval: 0.85, repeats: false) { [weak self] _ in
//                    NotificationCenter.default.post(name: Notification.Name("UpdateProfileDataStatus"), object: nil, userInfo: ["type": "", "status": "Approved"])
                    //move to account VC
                    self?.navigationController?.popToRootViewController(animated: true)
                     // Change to tab index 0
                     DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                         self?.tabBarController?.selectedIndex = 0
                     }

                }
            case .failure(let error):
                print("Error adding/updating document: \(error)")
                self.showTimeAlert(str:"\(error)")
            }
        }
    }
    
    
    func updateUser() {
        let userId =  UserDefaults.standard.string(forKey: "userID")
        let profileStep = UserDefaults.standard.integer(forKey: "profileStepCompeleted")
        
        let fieldsToUpdate: [String: Any] = [
            
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
