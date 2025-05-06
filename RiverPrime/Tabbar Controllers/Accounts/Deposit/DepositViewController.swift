//
//  DepositViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit
import OPPWAMobile
import ipworks3ds_sdk

// MARK: - DepositViewController
class DepositViewController: BaseViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var deposit_tableView: UITableView!
    
    // MARK: - Properties
    weak var delegateCompeleteProfile: DashboardVCDelegate?
    weak var delegate2: CompleteProfileButtonDelegate?
    
    private let bank_item = ["Pay with HyperPay"]
    private let odooClientService = OdooClientNew()
    
    // User Profile Properties
    var profileStep = 0
    var registrationType: Int?
    var isPhoneVerified = false
    var isEmailVerified = false
    var userEmail = ""
    var realAccount = false
    
    // Payment Properties
    var ammountValue = String()
    var checkoutID = "332EF113E0932367D74629B11AA73363.uat01-vm-tx01"
    var checkoutProvider: OPPCheckoutProvider?
    var paymentProvider: OPPPaymentProvider?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        setupTableView()
        loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(animated: animated)
    }
    
    // MARK: - Private Methods
    private func setupDelegates() {
        self.delegateCompeleteProfile = self
        self.delegate2 = self
    }
    
    private func setupTableView() {
        deposit_tableView.delegate = self
        deposit_tableView.dataSource = self
        deposit_tableView.allowsSelection = true
        deposit_tableView.isUserInteractionEnabled = true
        
        if profileStep == 2 {
            deposit_tableView.registerCells([ListingTableViewCell.self])
        } else {
            deposit_tableView.registerCells([ProfileTopTableViewCell.self, ListingTableViewCell.self])
        }
    }
    
    private func loadUserData() {
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _profileStep = savedUserData["profileStep"] as? Int {
                profileStep = _profileStep
            }
            if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
                realAccount = defaultAccount.isReal == true
            }
        }
    }
    
    private func setupNavigationBar(animated: Bool) {
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated,
                                     view: self.view,
                                     vc: self,
                                     VC: AccountsViewController(),
                                     navController: self.navigationController,
                                     title: "Deposit",
                                     leftTitle: "",
                                     rightTitle: "",
                                     textColor: .white,
                                     barColor: .black)
    }
}

// MARK: - UITableView DataSource & Delegate
extension DepositViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return profileStep == 2 ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 && profileStep != 2 ? 1 : bank_item.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if profileStep != 2 && indexPath.section == 0 {
            return configureProfileTopCell(tableView, at: indexPath)
        } else {
            return configureBankListingCell(tableView, at: indexPath)
        }
    }
    
    private func configureProfileTopCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: ProfileTopTableViewCell.self, for: indexPath)
        cell.lbl_title.text = "Deposit"
        cell.imageIcon.isHidden = true
        cell.btn_edit.isHidden = true
        cell.btn_editProfile.isHidden = true
        cell.delegate = self
        return cell
    }
    
    private func configureBankListingCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: ListingTableViewCell.self, for: indexPath)
        let bankName = bank_item[indexPath.row]
        
        cell.lblTitle.text = bankName
        cell.icon_bank.image = UIImage(named: bankName == "Trust wallet" ? "trustWallet" : "hyperPay")
        cell.icon_bank.layer.cornerRadius = 0
        cell.icon_bank.backgroundColor = .clear
        cell.selectionStyle = .none
        
        configureLockButton(for: cell, bankName: bankName)
        return cell
    }
    
    private func configureLockButton(for cell: ListingTableViewCell, bankName: String) {
        if profileStep == 2 {
            cell.lockBtn.titleLabel?.text = "Avaliable"
            cell.lockBtn.setImage(UIImage(systemName: "lock.open"), for: .normal)
            cell.lockBtn.isUserInteractionEnabled = true
        } else {
            cell.lockBtn.titleLabel?.text = "Unavaliable"
            cell.lockBtn.setImage(UIImage(systemName: "lock"), for: .normal)
            cell.lockBtn.isUserInteractionEnabled = false
        }
        
        cell.lockButtonAction = { [weak self] in
            if bankName == "Trust wallet" {
                let vc = Utilities.shared.getViewController(identifier: .cryptoVC, storyboardType: .dashboard) as! CryptoVC
                self?.navigate(to: vc)
            } else {
                let vc = Utilities.shared.getViewController(identifier: .hyperPayVC, storyboardType: .dashboard) as! HyperPayVC
                self?.navigate(to: vc)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return profileStep != 2 && indexPath.section == 0 ? 200 : 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if profileStep != 2 && indexPath.section == 0 { return }
        
        guard profileStep == 2 else {
            self.ToastMessage("First Complete your Profile & KYC")
            return
        }
        
        let selectedBank = bank_item[indexPath.row]
        if selectedBank == "Trust wallet" {
            let vc = Utilities.shared.getViewController(identifier: .cryptoVC, storyboardType: .dashboard) as! CryptoVC
            self.navigate(to: vc)
        } else {
            startCheckout()
        }
    }
}

// MARK: - Payment Handling
extension DepositViewController {
    func startCheckout() {
        paymentProvider = OPPPaymentProvider(mode: .test)
        
        let checkoutSettings = OPPCheckoutSettings()
        checkoutSettings.paymentBrands = ["VISA", "MASTER", "MADA"]
        checkoutSettings.shopperResultURL = "com.riverprime.payments://result"
        
        checkoutProvider = OPPCheckoutProvider(paymentProvider: paymentProvider!,
                                             checkoutID: checkoutID,
                                             settings: checkoutSettings)
        
        checkoutProvider?.presentCheckout { [weak self] transaction, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Payment failed: \(error.localizedDescription)")
                self.dismiss(animated: true)
                return
            }
            
            guard let transaction = transaction else {
                print("❌ No transaction returned")
                self.dismiss(animated: true)
                return
            }
            
            print("✅ Payment possibly succeeded")
            print("Payment Brand: \(transaction.paymentParams.paymentBrand)")
            print("Transaction Type: \(transaction.type.rawValue)")
            print("Transaction description: \(transaction.description)")
            
            self.dismiss(animated: true)
        }
    }
}

// MARK: - DashboardVCDelegate
extension DepositViewController: DashboardVCDelegate {
    func navigateToCompeletProfile() {
        guard realAccount else {
            Alert.showAlert(withMessage: "Please First Create Real Account",
                          andTitle: "Unable to Proceed!",
                          on: self)
            return
        }
        
        switch profileStep {
        case 0:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1,
                                                      storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
            vc.delegateKYC = self
            self.navigate(to: vc)
        case 1:
            let vc = Utilities.shared.getViewController(identifier: .kycViewController,
                                                      storyboardType: .dashboard) as! KYCViewController
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
        loadUserVerificationData()
        
        guard realAccount else {
            Alert.showAlert(withMessage: "Please First Create Real Account",
                          andTitle: "Unable to Proceed!",
                          on: self)
            return
        }
        
        handleUserVerification()
    }
    
    private func loadUserVerificationData() {
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
    }
    
    private func handleUserVerification() {
        if registrationType == 1 && !isEmailVerified {
            let vc = Utilities.shared.getViewController(identifier: .emailSendVC,
                                                      storyboardType: .bottomSheetPopups) as! EmailSendVC
            vc.UserEmail = userEmail
            self.navigate(to: vc)
        } else if !isPhoneVerified {
            let vc = Utilities.shared.getViewController(identifier: .phoneVerifyVC,
                                                      storyboardType: .main) as! PhoneVerifyVC
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
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1,
                                                      storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
            vc.delegateKYC = self
            self.navigate(to: vc)
        case 1:
            let vc = Utilities.shared.getViewController(identifier: .kycViewController,
                                                      storyboardType: .dashboard) as! KYCViewController
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
            vc = Utilities.shared.getViewController(identifier: .depositViewController,
                                                  storyboardType: .dashboard) as! DepositViewController
        case .FirstScreen:
            vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1,
                                                  storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
        case .SecondScreen:
            vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen2,
                                                  storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen2
        case .ThirdScreen:
            vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen3,
                                                  storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen3
        case .KycScreen:
            vc = Utilities.shared.getViewController(identifier: .kycViewController,
                                                  storyboardType: .bottomSheetPopups) as! KYCViewController
        case .FourthScreen:
            vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen4,
                                                  storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen4
        case .FifthScreen:
            vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen5,
                                                  storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen5
        case .SixthScreen:
            vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen6,
                                                  storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen6
        case .SeventhScreen:
            vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen7,
                                                  storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen7
        case .ReturnDashboard:
            vc = Utilities.shared.getViewController(identifier: .profileViewController,
                                                  storyboardType: .bottomSheetPopups) as! ProfileViewController
        }
        
        configureKYCDelegate(for: vc)
        self.navigate(to: vc)
    }
    
    private func configureKYCDelegate(for viewController: UIViewController) {
        if let kycVC = viewController as? CompleteVerificationProfileScreen1 {
            kycVC.delegateKYC = self
        } else if let kycVC = viewController as? CompleteVerificationProfileScreen2 {
            kycVC.delegateKYC = self
        } else if let kycVC = viewController as? CompleteVerificationProfileScreen3 {
            kycVC.delegateKYC = self
        } else if let kycVC = viewController as? CompleteVerificationProfileScreen4 {
            kycVC.delegateKYC = self
        } else if let kycVC = viewController as? CompleteVerificationProfileScreen5 {
            kycVC.delegateKYC = self
        } else if let kycVC = viewController as? CompleteVerificationProfileScreen6 {
            kycVC.delegateKYC = self
        } else if let kycVC = viewController as? CompleteVerificationProfileScreen7 {
            kycVC.delegateKYC = self
        } else if let kycVC = viewController as? ProfileViewController {
            kycVC.delegateKYC = self
        }
    }
}
