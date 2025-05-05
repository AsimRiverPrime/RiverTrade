//
//  DepositViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit
//import WebKit
//import PaysafePaymentsSDK

class DepositViewController: BaseViewController {
    
    @IBOutlet weak var deposit_tableView: UITableView!
    
    var bank_item = ["Trust wallet", "HyperPay"]
    
    weak var delegateCompeleteProfile: DashboardVCDelegate?
    weak var delegate2: CompleteProfileButtonDelegate?
    
    var profileStep = 0
    var registrationType: Int?
    
    var isPhoneVerified = false
    var isEmailVerified = false
    var userEmail = ""
    
    var realAccount = false
//    var webView: WKWebView!
    
    let odooClientService = OdooClientNew()
    var ammountValue = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        odooClientService.getCheckout_ID(ammount: ammountValue, partner_id: <#T##Int#>)
        
        self.delegateCompeleteProfile = self
        self.delegate2 = self
        
        deposit_tableView.delegate = self
        deposit_tableView.dataSource = self
        deposit_tableView.allowsSelection = true
        deposit_tableView.isUserInteractionEnabled = true
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _profileStep = savedUserData["profileStep"] as? Int {
                profileStep = _profileStep
            }
            if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
                realAccount = defaultAccount.isReal == true
            }
        }
        
        if profileStep == 2 {
            deposit_tableView.registerCells([ListingTableViewCell.self])
        } else {
            deposit_tableView.registerCells([ProfileTopTableViewCell.self, ListingTableViewCell.self])
        }
        
        deposit_tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: AccountsViewController(), navController: self.navigationController, title: "Deposit", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
}

// MARK: - Table View Methods

extension DepositViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return profileStep == 2 ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 && profileStep != 2 ? 1 : bank_item.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if profileStep != 2 && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: ProfileTopTableViewCell.self, for: indexPath)
            cell.lbl_title.text = "Deposit"
            cell.imageIcon.isHidden = true
            cell.btn_edit.isHidden = true
            cell.btn_editProfile.isHidden = true
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(with: ListingTableViewCell.self, for: indexPath)
            let bankName = bank_item[indexPath.row]
            cell.lblTitle.text = bankName
            cell.icon_bank.image = UIImage(named: bankName == "Trust wallet" ? "trustWallet" : "hyperPay")
            cell.icon_bank.layer.cornerRadius = 0
            cell.icon_bank.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return profileStep != 2 && indexPath.section == 0 ? 200 : 170
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
            // Prevent selecting the header cell when profileStep != 2
            if profileStep != 2 && indexPath.section == 0 {
                return
            }

            let selectedBank = bank_item[indexPath.row]
            switch selectedBank {
            case "HyperPay":
                let vc = Utilities.shared.getViewController(identifier: .hyperPayVC, storyboardType: .dashboard) as! HyperPayVC
                self.navigate(to: vc)
            case "Trust wallet":
                let vc = Utilities.shared.getViewController(identifier: .cryptoVC, storyboardType: .dashboard) as! CryptoVC
                self.navigate(to: vc)
            default:
                break
            }
        

        
        if indexPath.section == 1 {
            let selectedBank = bank_item[indexPath.row]
            
            guard profileStep == 2 else {
                self.ToastMessage("First Complete your Profile & KYC")
                return
            }
            
            if selectedBank == "Trust wallet" {
                let vc = Utilities.shared.getViewController(identifier: .cryptoVC, storyboardType: .dashboard) as! CryptoVC
                self.navigate(to: vc)
            } else {
                // Add your Skrill navigation logic here
            }
        }
    }
}

// MARK: - DashboardVCDelegate

extension DepositViewController: DashboardVCDelegate {
    func navigateToCompeletProfile() {
        guard realAccount else {
            Alert.showAlert(withMessage: "Please First Create Real Account", andTitle: "Unable to Proceed!", on: self)
            return
        }
        
        switch profileStep {
        case 0:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
            vc.delegateKYC = self
            self.navigate(to: vc)
        case 1:
            let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
            vc.delegateKYC = self
            self.navigate(to: vc)
        case 2:
            self.ToastMessage("Already Done KYC")
        default:
            self.ToastMessage("Already Done KYC")
        }
    }
}

// MARK: - CompleteProfileButtonDelegate & PhoneVerifyDelegate

extension DepositViewController: CompleteProfileButtonDelegate, PhoneVerifyDelegate {
    
    func didTapCompleteProfileButtonInCell() {
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let profileStep1 = savedUserData["profileStep"] as? Int,
               let _email = savedUserData["email"] as? String,
               let _registrationType = savedUserData["registrationType"] as? Int,
               let _isPhoneVerified = savedUserData["phoneVerified"] as? Bool,
               let _isEmailVerified = savedUserData["emailVerified"] as? Bool {
                isEmailVerified = _isEmailVerified
                isPhoneVerified = _isPhoneVerified
                profileStep = profileStep1
                userEmail = _email
                registrationType = _registrationType
            }
        }
        
        guard realAccount else {
            Alert.showAlert(withMessage: "Please First Create Real Account", andTitle: "Unable to Proceed!", on: self)
            return
        }
        
        if registrationType == 1 && !isEmailVerified {
            let vc = Utilities.shared.getViewController(identifier: .emailSendVC, storyboardType: .bottomSheetPopups) as! EmailSendVC
            vc.UserEmail = userEmail
            self.navigate(to: vc)
        } else if !isPhoneVerified {
            let vc = Utilities.shared.getViewController(identifier: .phoneVerifyVC, storyboardType: .main) as! PhoneVerifyVC
            vc.userEmail = userEmail
            vc.delegate = self
            self.navigate(to: vc)
        } else {
            didCompletePhoneVerification()
        }
    }
    
    func didCompletePhoneVerification() {
        switch profileStep {
        case 0:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
            vc.delegateKYC = self
            self.navigate(to: vc)
        case 1:
            let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
            vc.delegateKYC = self
            self.navigate(to: vc)
        default:
            self.ToastMessage("Already Done KYC")
        }
    }
}

// MARK: - KYCVCDelegate

extension DepositViewController: KYCVCDelegate {
    
    func navigateToCompeletProfile(kyc: KYCType) {
        let vc: UIViewController
        
        switch kyc {
        case .ProfileScreen:
            vc = Utilities.shared.getViewController(identifier: .depositViewController, storyboardType: .dashboard) as! DepositViewController
        case .FirstScreen:
            vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
        case .SecondScreen:
            vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen2, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen2
        case .ThirdScreen:
            vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen3, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen3
        case .KycScreen:
            vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .bottomSheetPopups) as! KYCViewController
        case .FourthScreen:
            vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen4, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen4
        case .FifthScreen:
            vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen5, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen5
        case .SixthScreen:
            vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen6, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen6
        case .SeventhScreen:
            vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen7, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen7
        case .ReturnDashboard:
            vc = Utilities.shared.getViewController(identifier: .profileViewController, storyboardType: .bottomSheetPopups) as! ProfileViewController
        }
        
        if let kycVC = vc as? CompleteVerificationProfileScreen1 {
            kycVC.delegateKYC = self
        } else if let kycVC = vc as? CompleteVerificationProfileScreen2 {
            kycVC.delegateKYC = self
        } else if let kycVC = vc as? CompleteVerificationProfileScreen3 {
            kycVC.delegateKYC = self
        }
        
        self.navigate(to: vc)
    }
}
























/*
//
//  DepositViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit
//import PaysafeCardPayments
import WebKit
import PaysafePaymentsSDK

class DepositViewController: BaseViewController {
    
    @IBOutlet weak var deposit_tableView: UITableView!
    
    var bank_item = ["Trust wallet", "Skrill"]
    
    weak var delegateCompeleteProfile: DashboardVCDelegate?
    weak var delegate2 : CompleteProfileButtonDelegate?
    
    var profileStep = Int()
    var registrationType : Int?
    
    var isPhoneVerified = Bool()
    var isEmailVerified = Bool()
    var userEmail = String()
    
    var realAccount = Bool()
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegateCompeleteProfile = self
        self.delegate2 = self
        
        self.deposit_tableView.delegate = self
        self.deposit_tableView.dataSource = self
        deposit_tableView.allowsSelection = true
        deposit_tableView.isUserInteractionEnabled = true
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            //print("saved User Data: \(savedUserData)")
            if let _profileStep = savedUserData["profileStep"] as? Int{
                profileStep = _profileStep
                //                realAccount = _realAccount
            }
            if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
                print("\n Default Account user in Deposit screen: \(defaultAccount)")
                
                realAccount = defaultAccount.isReal == true ? true : false
            }
            
        }
        
        if profileStep == 2 {
            deposit_tableView.registerCells([
               ListingTableViewCell.self
            ])
        }else{
            deposit_tableView.registerCells([
                ProfileTopTableViewCell.self, ListingTableViewCell.self
            ])
            
        }
        deposit_tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: AccountsViewController(), navController: self.navigationController, title: "Deposit", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
        
    }
    
}

extension DepositViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return bank_item.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: ProfileTopTableViewCell.self, for: indexPath)
            cell.lbl_title.text =   "Deposit"
            
            cell.imageIcon.isHidden = true
            cell.btn_edit.isHidden = true
            cell.btn_editProfile.isHidden = true
            cell.delegate = self
            //                cell.view_profileComplete.isHidden = true
            //               let hieght = cell.bounds.height
            //                cell.heightAnchor.constraint(equalToConstant: hieght - 100)
            return cell
        } else  {
            let cell = tableView.dequeueReusableCell(with: ListingTableViewCell.self, for: indexPath)
            cell.lblTitle.text = self.bank_item[indexPath.row]
            
            let iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40)) // Adjust size as needed
            iconImageView.contentMode = .scaleAspectFit
            if bank_item[indexPath.row] == "Trust wallet" {
                cell.icon_bank.image  = UIImage(named: "trustWallet") // Ensure "trustWallet" exists in Assets
            } else if bank_item[indexPath.row] == "Skrill" {
                cell.icon_bank.image  = UIImage(named: "skrill") // Ensure "skrill" exists in Assets
            }
            
            cell.icon_bank.layer.cornerRadius = 0
            cell.icon_bank.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 200
        }else{
            return 170
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped on section: \(indexPath.section), row: \(indexPath.row)")
        if indexPath.section == 0 {
            print("section 0")
        }else if indexPath.section == 1 {
            let selectedBank = bank_item[indexPath.row]
            
            if profileStep == 2 {
                if selectedBank == "Trust wallet" {
                    let vc = Utilities.shared.getViewController(identifier: .cryptoVC, storyboardType: .dashboard) as! CryptoVC
                    //                PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
                    navigate(to: vc)
                }else{
                    //                paysafeMethod()
                }
                
            }else{
                self.ToastMessage("First Complete your Profile & KYC")
            }
        }
    }
}

extension DepositViewController: DashboardVCDelegate {
    func navigateToCompeletProfile() {
        print("move to completeprofile screen")
        if realAccount == true {
            switch profileStep {
            case 0:
                let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
                vc.delegateKYC = self
                self.navigate(to: vc) //PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            case 1:
                let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
                vc.delegateKYC = self
                self.navigate(to: vc) // PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
                //            case 2:
                //                let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
                //                vc.delegateKYC = self
                //                PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            case 2:
                self.ToastMessage("Already Done KYC")
            default:
                self.ToastMessage("Already Done KYC")
            }
            
        }else{
            Alert.showAlert(withMessage: "Please First Create Real Account", andTitle: "Unable to Proceed!", on: self)
        }
    }
}


extension DepositViewController: CompleteProfileButtonDelegate, PhoneVerifyDelegate {
    
    func didTapCompleteProfileButtonInCell() {
        //            delegateCompeleteProfile?.navigateToCompeletProfile()
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let profileStep1 = savedUserData["profileStep"] as? Int, let _email = savedUserData["email"] as? String, let _registrationType = savedUserData["registrationType"] as? Int, let _isPhoneVerified = savedUserData["phoneVerified"] as? Bool, let _isEmailVerified = savedUserData["emailVerified"] as? Bool  {
                isEmailVerified = _isEmailVerified
                isPhoneVerified = _isPhoneVerified
                profileStep = profileStep1
                userEmail = _email
                registrationType = _registrationType
            }
        }
        
        if realAccount == true {
            if registrationType == 1 && !isEmailVerified {
                
                let vc = Utilities.shared.getViewController(identifier: .emailSendVC, storyboardType: .bottomSheetPopups) as! EmailSendVC
                vc.UserEmail = userEmail
                self.navigate(to: vc)
//                PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            }else if !isPhoneVerified {
                
                let vc = Utilities.shared.getViewController(identifier: .phoneVerifyVC, storyboardType: .main) as! PhoneVerifyVC
                vc.userEmail = userEmail
                vc.delegate = self
                self.navigate(to: vc)
            }else{
                didCompletePhoneVerification()
            }
            
        }else{
            Alert.showAlert(withMessage: "Please First Create Real Account", andTitle: "Unable to Proceed!", on: self)
        }
    }
    
    func didCompletePhoneVerification() {
        // After phone verification is complete, check profileStep
       
        switch profileStep {
        case 0:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
            vc.delegateKYC = self
            self.navigate(to: vc)
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        case 1:
            let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
            vc.delegateKYC = self
            self.navigate(to: vc)
//
        default:
            self.ToastMessage("Already Done KYC")
        }
    }
}
extension DepositViewController: KYCVCDelegate {
    
    func navigateToCompeletProfile(kyc: KYCType) {
        switch kyc {
        case .ProfileScreen:
           
            let vc = Utilities.shared.getViewController(identifier: .depositViewController, storyboardType: .dashboard) as! DepositViewController
               
                self.navigate(to: vc)
            
            break
        case .FirstScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
            vc.delegateKYC = self
            self.navigate(to: vc) // PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .SecondScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen2, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen2
            vc.delegateKYC = self
            self.navigate(to: vc) //  PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .ThirdScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen3, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen3
            vc.delegateKYC = self
            self.navigate(to: vc) // PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .FourthScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen4, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen4
            vc.delegateKYC = self
            self.navigate(to: vc) // PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .FifthScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen5, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen5
            vc.delegateKYC = self
            self.navigate(to: vc) // PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .SixthScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen6, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen6
            vc.delegateKYC = self
            self.navigate(to: vc) //  PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .SeventhScreen:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen7, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen7
            vc.delegateKYC = self
            self.navigate(to: vc) // PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .ReturnDashboard:
            if let profileVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "ProfileViewController") {
                //                GlobalVariable.instance.isReturnToProfile = true
                self.navigate(to: profileVC)
            }
            break
        case .KycScreen:
            let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
            vc.delegateKYC = self
            self.navigate(to: vc) // PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        }
    }
    
}
*/
