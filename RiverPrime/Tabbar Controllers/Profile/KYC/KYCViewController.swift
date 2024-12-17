//
//  KYCViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 06/09/2024.
//

import UIKit
import SVProgressHUD
import IDWiseSDK

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
//    var appToken = "eyJhbGciOiJIUzI1NiJ9.aXRAc2FsYW1pbnYuY29tWmFpZCAgT2RlaCAgIGQ3NDU5ZjBlLTdmNWItNDhlNC04ZDAzLWE0YmJjNzMyNzE3Mg.QzQR-QHQM2kyYkdqUF9x0Te2L4m8aCQvU4E6bL_9KrY"
//    var userToken = ""
    
    let fireStoreInstance = FirestoreServices()
    
    let clientKey = "QmFzaWMgVkMxaE1qWTBOVGt5Wmkxak9EZGhMVFExTnpndFlqSTRNUzFsTVRBNE1XRTJZemRoT0RZNlRHdGpibUYwTkRSWFMxRnlkRkJhV0RKTGIyZHdUMmhrYzNneFVrTk9hVlZFVTFsNk5rRktUUT09"
    let flowId = "a264592f-c87a-4578-b281-e1081a6c7a86"
    var journeyId = ""
    weak var delegateKYC: KYCVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            if let _gender = savedUserData["gender"] as? String,let _name = savedUserData["name"] as? String, let _dob = savedUserData["dob"] as? String {
                self.dob = _dob
                self.userName = _name
                self.gender = _gender
            }
        }
        
//        ActivityIndicator.shared.show(in: self.view)
        
//        DataBaseDownloading.initialization(completion:{progres, status, error in
//            print(progres, status, error)
//            ActivityIndicator.shared.hide(from: self.view)
//
//            SVProgressHUD.show(withStatus: progres)
//            if status == "Start Now" {
//                SVProgressHUD.dismiss()
//                
//            }
//            if progres == "" {
//                SVProgressHUD.dismiss()
//            }
//        })
//        
//        iPassSDKManger.delegate = self
//       
//        login()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
//    func login() {
//        // User onboarding process to get user token
//        iPassSDKManger.UserOnboardingProcess(email: "it@salaminv.com", password: "Salam@2022") { [weak self] status, tokenString in
//            guard let self = self else { return }
//            if status == true, let token = tokenString {
//                self.userToken = token
//                print("\n userToken is: \(self.userToken)")
//              
//            } else {
//                print("Error: Failed to get user token")
//            }
//        }
//    }
    
    @IBAction func closeBtn_action(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
    
//    func handleDocumentUpload() async {
//        if !userToken.isEmpty && !appToken.isEmpty {
//            
//                // Ensure the async SDK method is called on the main thread
//              await  iPassSDKManger.startScanningProcess(
//                    userEmail: "it@salaminv.com",
//                    flowId: 10032,
//                    socialMediaEmail: "Asimprime900@gmail.com",
//                    phoneNumber: "+971561606314",
//                    controller: self,
//                    userToken: self.userToken,
//                    appToken: self.appToken
//                )
//            
//        } else {
//            print("Error: Tokens are not set.")
//        }
//    }
    
    @IBAction func uploadDocBtn(_ sender: Any) {
        
        IDWise.initialize(clientKey: clientKey,theme: .dark) { err in
                       // Deal with error here
                   if let error = err {
                     // handle error, show some alert or any other logic
                   }
               }
        
        
        let applicantDetailssss: [String:String] = [
            ApplicantDetailsKeys.FULL_NAME: self.userName ?? "",
            ApplicantDetailsKeys.BIRTH_DATE: self.dob ?? "",
            ApplicantDetailsKeys.SEX: self.gender ?? ""
        ]
//        IDWise.startJourney(journeyDefinitionId: flowId, referenceNumber: "0o9bz50Y63XlI25auIbm0B2zJt42", locale: "en", journeyDelegate: self)
        IDWise.startJourney(flowId: flowId, applicantDetails: applicantDetailssss, journeyCallbacks: self)
        
//        DispatchQueue.main.async {
//            Task {
//                await self.handleDocumentUpload()
//                }
//        }
//
//        Task { @MainActor in
//                   iPassSDKManger.delegate = self
//          await iPassSDKManger.startScanningProcess(
//                  userEmail: "it@salaminv.com",
//                  flowId: 10015,
//                  socialMediaEmail: "Asimprime900@gmail.com",
//                  phoneNumber: "+971561606314",
//                  controller: self,
//                  userToken: self.userToken,
//                  appToken: self.appToken
//              )
//               }
//               
    }
    
//    
//    func getFlows() async {
//        let getList = iPassSDKManger.getWorkFlows()
//        // Ensure any UI updates happen on the main thread
//        DispatchQueue.main.async {
//            print("the get list is: \(getList)")
//        }
//    }
    
    func AddUserAccountDetail() {
        let userId =  UserDefaults.standard.string(forKey: "userID")
        let profileStep = UserDefaults.standard.integer(forKey: "profileStepCompeleted")
        let overAllStatus = UserDefaults.standard.string(forKey: "OverAllStatus")
        let sid = UserDefaults.standard.string(forKey: "SID")
        
//        print("profileStepCompeleted is : \(profileStep) OverAll status is : \(overAllStatus) sid: \(sid)")
       
        let questionAnswer: [String: [String]] = [:]
        
        let userData: [String: Any] = [
               "uid": userId ?? "",
               "sId": sid ?? "",
               "step": profileStep,
               "profileStep": profileStep,
               "overAllStatus": overAllStatus ?? "",
               "questionAnswer": questionAnswer
           ]
        
        fireStoreInstance.addUserAccountData(uid: userId ?? "", data: userData) { result in
            switch result {
            case .success:
                print("\n KYC detail ADD to firebase successfully!")
                self.updateUser()
               // self.ToastMessage("KYC detail add successfully!")
                self.navigateToQuestionScreen()
            case .failure(let error):
                print("Error adding/updating document: \(error)")
                self.ToastMessage("\(error)")
            }
        }
    }
    
    func navigateToQuestionScreen() {
        let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
        vc.delegateKYC = self
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
    }
    
    func updateUser() {
        let userId =  UserDefaults.standard.string(forKey: "userID")
        let profileStep = UserDefaults.standard.integer(forKey: "profileStepCompeleted")
        
        var fieldsToUpdate: [String: Any] = [
           
                "profileStep": profileStep,
                
             ]
        
        fireStoreInstance.updateUserFields(userID: userId!, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                print("\n User data save successfully in the fireBase")
            }
        }
        
    }
    
}

extension KYCViewController: IDWiseJourneyCallbacks {
    func onError(error: IDWiseSDK.IDWiseError) {
        print("error: \(error)")
    }
    
    func onJourneyStarted(journeyStartedInfo: IDWiseSDK.JourneyStartedInfo) {
        self.journeyId = journeyStartedInfo.journeyId
        print("journeyId: \(self.journeyId)")
        UserDefaults.standard.set(self.journeyId, forKey: "SID")
    }
    
    func onJourneyResumed(journeyResumedInfo: IDWiseSDK.JourneyResumedInfo) {
        print("journeyResumedInfo: \(journeyResumedInfo)")
    }
    
    func onJourneyCompleted(journeyCompletedInfo: IDWiseSDK.JourneyCompletedInfo) {
        print("Complete Info: \(journeyCompletedInfo)")
        self.ToastMessage("Scanning completed successfully")
        UserDefaults.standard.set(2, forKey: "profileStepCompeleted")
        self.navigateToQuestionScreen()
    }
    
    func onJourneyCancelled(journeyCancelledInfo: IDWiseSDK.JourneyCancelledInfo) {
        print("journeyCancelledInfo: \(journeyCancelledInfo)")
    }
}

// Delegate methods to handle scan completion
//extension KYCViewController: iPassSDKManagerDelegate {
//        
//    func getScanCompletionResult(result: String, transactionId: String, error: String) {
//        // Handle the result of the scanning process
//        DispatchQueue.main.async {
//            if error.isEmpty {
//                print("Scan successful. Result: \(result), Transaction ID: \(transactionId)")
//                self.ToastMessage("Data Scanned Successfully.")
//                // Convert the result string into a Data object
//                if transactionId != "" {
//                    if let jsonData = result.data(using: .utf8) {
//                        do {
//                            // Parse the JSON data
//                            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
//                                     let data = jsonObject["data"] as? [String: Any] {
//                                      
//                                      // Extracting "OverAllStatus"
//                                      if let status = data["OverAllStatus"] as? String {
//                                          print("\n Overall Status: \(status)")
//                                          UserDefaults.standard.set(status, forKey: "OverAllStatus")
//                                          print("\n SID: \(transactionId) \t overall status : \(status)")
//                                        
//                                      }
//                                
//                                UserDefaults.standard.set(transactionId, forKey: "SID")
//                                UserDefaults.standard.set(1, forKey: "profileStepCompeleted")
//                                self.AddUserAccountDetail()
//                                
//                            } else {
//                                print("data not found in the result.")
//                            }
//                        } catch {
//                            print("Failed to parse JSON: \(error.localizedDescription)")
//                        }
//                    } else {
//                        print("Failed to convert result string to data.")
//                    }
//                }
//                
//            } else {
//                print("Scan failed. Error: \(error)")
//                // Handle the error, maybe show an alert to the user
//                self.ToastMessage("\(error)...scan again")
//            }
//        }
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
                GlobalVariable.instance.isReturnToProfile = true
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
//            if let dashboardVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DashboardVC"){
//                GlobalVariable.instance.isReturnToProfile = true
//                self.navigate(to: dashboardVC)
//            }
            if let dashboardVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "HomeTabbarViewController"){
                GlobalVariable.instance.isReturnToProfile = true
                self.navigate(to: dashboardVC)
            }
            break
        case .KycScreen:
            let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! CompleteVerificationProfileScreen1
            vc.delegateKYC = self
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            
        }
    }
    
}
