//
//  DepositViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit

class DepositViewController: BaseViewController {
    
    @IBOutlet weak var deposit_tableView: UITableView!
    
    var bank_item = ["Bank Card", "Skrill" , "Venmo", "PayPal","BitCoin"]
    
    weak var delegateCompeleteProfile: DashboardVCDelegate?
    weak var delegate2 : CompleteProfileButtonDelegate?
    
    var profileStep = Int()
    var realAccount = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegateCompeleteProfile = self
        self.delegate2 = self
        
        deposit_tableView.registerCells([
            ProfileTopTableViewCell.self, ListingTableViewCell.self
        ])
        
        deposit_tableView.reloadData()

        self.deposit_tableView.delegate = self
        self.deposit_tableView.dataSource = self

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
            return 1
        }
    }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(with: ProfileTopTableViewCell.self, for: indexPath)
                cell.lbl_title.text = "Deposit"
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
                cell.lblTitle.text = "Deposit using Trust wallet" //self.bank_item[indexPath.row]
                cell.icon_bank.image = UIImage(named: "trustWallet")
                cell.icon_bank.layer.cornerRadius = 0
                cell.icon_bank.backgroundColor = .clear
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
                PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            case 1:
                let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .bottomSheetPopups) as! KYCViewController
                vc.delegateKYC = self
                PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//            case 2:
//                let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
//                vc.delegateKYC = self
//                PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            default:
                self.ToastMessage("Already Done KYC")
            }
        
        }else{
            Alert.showAlert(withMessage: "Please First Create Real Account", andTitle: "Unable to Proceed!", on: self)
        }
    }
}

extension DepositViewController: CompleteProfileButtonDelegate {
    
    func didTapCompleteProfileButtonInCell() {
        print("profile header complete btn click")
        delegateCompeleteProfile?.navigateToCompeletProfile()
    }
    
}

extension DepositViewController: KYCVCDelegate {
    
    func navigateToCompeletProfile(kyc: KYCType) {
        switch kyc {
        case .ProfileScreen:
//            if let profileVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DashboardVC"){
////                profileVC.delegateKYC = self
//                GlobalVariable.instance.isReturnToProfile = true
//                self.navigate(to: profileVC)
//            }
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
            if let profileVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "ProfileViewController") {
//                GlobalVariable.instance.isReturnToProfile = true
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
