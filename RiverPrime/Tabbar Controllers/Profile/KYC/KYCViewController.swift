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
    var userId: String?
    var userEmail : String?
    var odooClientService = OdooClientNew()
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
        
        IDWise.initialize(clientKey: clientKey,theme: .dark) { err in
                       // Deal with error here
                   if let error = err {
                     // handle error, show some alert or any other logic
                   }
               }
        
        let applicantDetailssss: [String:String] = [
            ApplicantDetailsKeys.FULL_NAME: self.userName ?? "",
            ApplicantDetailsKeys.BIRTH_DATE: self.dob ?? "",
            ApplicantDetailsKeys.SEX: self.gender ?? "",
          
        ]
//        IDWise.startJourney(journeyDefinitionId: flowId, referenceNumber: "0o9bz50Y63XlI25auIbm0B2zJt42", locale: "en", journeyDelegate: self)
        IDWise.startJourney(flowId: flowId, referenceNumber: self.userId ?? "", applicantDetails: applicantDetailssss , journeyCallbacks: self)
     
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
                self.showTimeAlert(str:"KYC detail added successfully!")
                self.dismiss(animated: true) {
                    self.delegateKYC?.navigateToCompeletProfile(kyc: .ReturnDashboard)
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
        
        var fieldsToUpdate: [String: Any] = [
           
                "profileStep": profileStep,
                "KycStatus": "Progress Started"
                
             ]
        
        fireStoreInstance.updateUserFields(userID: userId!, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                print("\n User data save successfully in the fireBase")
                self.fireStoreInstance.fetchUserData(userId: userId!)
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
       
    }
    
    func onJourneyResumed(journeyResumedInfo: IDWiseSDK.JourneyResumedInfo) {
        print("journeyResumedInfo: \(journeyResumedInfo)")
    }
    
    func onJourneyCompleted(journeyCompletedInfo: IDWiseSDK.JourneyCompletedInfo) {
        print("Complete Info: \(journeyCompletedInfo)")
        UserDefaults.standard.set(journeyCompletedInfo.journeyId, forKey: "SID")
        
        let sid = UserDefaults.standard.string(forKey: "SID")
        print("sid: \(sid)")
        
        self.showTimeAlert(str:"Scanning completed successfully")
        
        UserDefaults.standard.set(3, forKey: "profileStepCompeleted")
        
        odooClientService.SearchRecord(email: self.userEmail ?? "") { data, error in
            print("id_waise decision is: \(data) : error is: \(error)")
            self.AddUserAccountDetail()
        }
        
//        delegateKYC?.navigateToCompeletProfile(kyc: .ReturnDashboard)
    }
    
    func onJourneyCancelled(journeyCancelledInfo: IDWiseSDK.JourneyCancelledInfo) {
        print("journeyCancelledInfo: \(journeyCancelledInfo)")
    }
}

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
//                GlobalVariable.instance.isReturnToProfile = true
//                profileVC.initTableView_CheckData()
                
                self.navigate(to: profileVC)
            }
//            if let dashboardVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "HomeTabbarViewController"){
//                GlobalVariable.instance.isReturnToProfile = true
//                self.navigate(to: dashboardVC)
//            }
            break
        case .KycScreen:
            let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
            vc.delegateKYC = self
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            
        }
    }
    
}
