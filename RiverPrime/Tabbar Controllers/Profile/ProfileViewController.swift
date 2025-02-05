//
//  ProfileViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/07/2024.
//

import UIKit

protocol DashboardVCDelegate: AnyObject {
    func navigateToCompeletProfile()
}
protocol PhoneVerifyDelegate: AnyObject {
    func didCompletePhoneVerification()
}

class ProfileViewController: BaseViewController{
    
    @IBOutlet weak var tblView: UITableView!
    
    weak var delegateCompeleteProfile: DashboardVCDelegate?
    var profileStep = Int()
    
    var realAccount: Bool?
    weak var delegateKYC : KYCVCDelegate?
    var registrationType : Int?
    
    var isPhoneVerified = Bool()
    var isEmailVerified = Bool()
    var userEmail = String()
    var odooClientService = OdooClientNew()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.isScrollEnabled = false
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: AccountsViewController(), navController: self.navigationController, title: "Profile", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
        
        initTableView_CheckData()
    }
    @objc func updateProfileData(_ notification: Notification) {
        // Retrieve the user info dictionary from the notification
        
        tblView.reloadData()
    }
    
    
    func initTableView_CheckData(){
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let profileStep1 = savedUserData["profileStep"] as? Int, let _email = savedUserData["email"] as? String, let _userId = savedUserData["id"] as? String, let _registrationType = savedUserData["registrationType"] as? Int, let _isPhoneVerified = savedUserData["phoneVerified"] as? Bool, let _isEmailVerified = savedUserData["emailVerified"] as? Bool  {
                profileStep = profileStep1
                userEmail = _email
                registrationType = _registrationType
                isPhoneVerified = _isPhoneVerified
                isEmailVerified = _isEmailVerified
                UserDefaults.standard.set(_userId, forKey: "userID")
            }
        }
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            //print("\n Default Account User: \(defaultAccount)")
            
            realAccount = defaultAccount.isReal == true ? true : false
        }
        
        //        odooClientService.SearchRecord(email: self.userEmail ?? "") { data, error in
        //            print("id_waise decision is: \(data) : error is: \(error)")
        //        }
        
        tblView.registerCells([
            ProfileTopTableViewCell.self, RefferalProgramTableViewCell.self,  SuppotTableViewCell.self, LogoutTableViewCell.self
        ])
        
        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
        
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return 1
        }else if section == 2 {
            return 1
            
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: ProfileTopTableViewCell.self, for: indexPath)
            
            cell.delegate = self
            cell.selectionStyle = .none
            cell.editDelegate = self
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(with: RefferalProgramTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            //                self.setNeedsLayout()
            return cell
        }else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(with: SuppotTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(with: LogoutTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 200
            
        }else if indexPath.section == 1 {
            return 110
            
        } else if indexPath.section == 2 {
            return 310
            
        }else{
            return 80
        }
    }
    
}

extension ProfileViewController: CompleteProfileButtonDelegate, PhoneVerifyDelegate {
    
    func didTapCompleteProfileButtonInCell() {
        //            delegateCompeleteProfile?.navigateToCompeletProfile()
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _isEmailVerified = savedUserData["emailVerified"] as? Bool, let _isPhoneVerified = savedUserData["phoneVerified"] as? Bool {
                isEmailVerified = _isEmailVerified
                isPhoneVerified = _isPhoneVerified
            }
        }
        
        if realAccount == true {
            if registrationType == 1 && !isEmailVerified {
                let vc = Utilities.shared.getViewController(identifier: .emailSendVC, storyboardType: .bottomSheetPopups) as! EmailSendVC
                vc.UserEmail = userEmail
                PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            }else if !isPhoneVerified {
                
                let vc = Utilities.shared.getViewController(identifier: .phoneVerifyVC, storyboardType: .main) as! PhoneVerifyVC
                vc.userEmail = userEmail
                vc.delegate = self
                PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            }else{
                didCompletePhoneVerification()
            }
            
        }else{
            Alert.showAlert(withMessage: "Please First Create Real Account", andTitle: "Unable to Proceed!", on: self)
        }
    }
    
    func didCompletePhoneVerification() {
        // After phone verification is complete, check profileStep
        initTableView_CheckData()
        switch profileStep {
        case 0:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
            vc.delegateKYC = self
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        case 1:
            let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
            vc.delegateKYC = self
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            //               case 2:
            //                   let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
            //                   vc.delegateKYC = self
            //                   PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        default:
            self.ToastMessage("Already Done KYC")
        }
    }
}

extension ProfileViewController: KYCVCDelegate {
    
    func navigateToCompeletProfile(kyc: KYCType) {
        switch kyc {
        case .ProfileScreen:
            
            if let profileVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "HomeTabbarViewController"){
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
            initTableView_CheckData()
            //            if let dashboardVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "HomeTabbarViewController"){
            //                GlobalVariable.instance.isReturnToProfile = true
            //                self.navigate(to: dashboardVC)
            //            }
            if let profileVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "ProfileViewController") as? ProfileViewController {
                //                GlobalVariable.instance.isReturnToProfile = true
                profileVC.delegateKYC = self
                self.navigate(to: profileVC)
            }
            
            break
        case .KycScreen:
            let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
            vc.delegateKYC = self
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        }
    }
    
}
extension ProfileViewController: ProfileEditButtonDelegate {
    func didTapEditButtonInCell() {
        let vc = Utilities.shared.getViewController(identifier: .editPhotoVC, storyboardType: .dashboard) as! EditPhotoVC
        self.navigate(to: vc)
    }
    
}

