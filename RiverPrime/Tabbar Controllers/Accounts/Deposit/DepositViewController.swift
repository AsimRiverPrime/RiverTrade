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
    var realAccount = Bool()
    var webView: WKWebView!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: AccountsViewController(), navController: self.navigationController, title: "Deposit", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
        
    }
    
    func paysafeMethod(){
        //       let theme = PSTheme(
        //           backgroundColor: UIColor(red: 44/255, green: 30/255, blue: 70/255, alpha: 1.0),
        //           borderColor: UIColor(red: 201/255, green: 201/255, blue: 201/255, alpha: 1.0),
        //           focusedBorderColor: UIColor(red: 133/255, green: 81/255, blue: 161/255, alpha: 1.0),
        //           textInputColor: UIColor(red: 214/255, green: 195/255, blue: 229/255, alpha: 1.0),
        //           placeholderColor: UIColor(red: 111/255, green: 77/255, blue: 155/255, alpha: 1.0),
        //           hintColor: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        //       )
        //      let credentials = "\("pmle-441874"):\("B-p1-0-6679395c-0-302d02150085f00a398fb3afdfe5752df077cb")"
        //       guard let credentialData = credentials.data(using: .utf8) else {
        //           print("Unable to encode credentials")
        //           return
        //       }
        //       let base64Credentials = credentialData.base64EncodedString()
        //       print("\n base64Credentials: \(base64Credentials)\n")
        //
        //
        //       PaysafeSDK.shared.setup(
        //           apiKey: base64Credentials,
        //           environment: .test,
        //           theme: theme)
        //       { result in
        //           switch result {
        //           case .success:
        //               print("[Paysafe SDK] initialized successfully")
        //           case let .failure(error):
        //               print("[Paysafe SDK] initialize failure \(error.displayMessage)")
        //           }
        //       }
        //
        webView = WKWebView(frame: self.view.bounds)
        self.view.addSubview(webView)
        
        let htmlForm = """
       <html>
         <body onload="document.forms[0].submit()">
           <form action="https://pay.skrill.com" method="POST">
             <input type="hidden" name="pay_to_email" value="omar@riverprime.com">
             <input type="hidden" name="amount" value="5.00">
             <input type="hidden" name="currency" value="USD">
             <input type="hidden" name="language" value="EN">
             <input type="hidden" name="merchant_id" value="261674847">
             <input type="hidden" name="transaction_id" value="ios_test_\(Int(Date().timeIntervalSince1970))">
             <input type="hidden" name="return_url" value="https://example.com/success">
             <input type="hidden" name="cancel_url" value="https://example.com/cancel">
             <input type="hidden" name="status_url" value="https://portal.riverprime.com/console/payment/custom/neteller.cfc?method=callback">
             <input type="hidden" name="detail1_description" value="iOS Test">
             <input type="hidden" name="detail1_text" value="Skrill test from app">
           </form>
         </body>
       </html>
       """
        
        webView.loadHTMLString(htmlForm, baseURL: nil)
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
            
            if selectedBank == "Trust wallet" {
                let vc = Utilities.shared.getViewController(identifier: .cryptoVC, storyboardType: .dashboard) as! CryptoVC
//                PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
                navigate(to: vc)
            }else{
                paysafeMethod()
            }
            
            if profileStep == 2 {
                //
            }
        }else{
            
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
