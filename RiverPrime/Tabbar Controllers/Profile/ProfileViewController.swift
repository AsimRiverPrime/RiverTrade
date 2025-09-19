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

class ProfileViewController: BaseViewController, BottomSheetDismissDelegate, AccountDismisalProtocol{
    
    @IBOutlet weak var tblView: UITableView!
    
    weak var delegateCompeleteProfile: DashboardVCDelegate?
    let webSocketManager = WebSocketManager.shared
    
    var profileStep = Int()
    
    var realAccount: Bool?
//    weak var delegateKYC : KYCVCDelegate?
    var registrationType : Int?
    
    var isPhoneVerified = Bool()
    var isEmailVerified = Bool()
    var userEmail = String()
    var odooClientService = OdooClientNew()
    var showCloseButton = false
    var metaTraderType: MetaTraderType? = .None
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.isScrollEnabled = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: AccountsViewController(), navController: self.navigationController, title: "Profile", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
        
        if showCloseButton {
            let closeImage = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate)
            let closeButton = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(closeButtonTapped))
            closeButton.tintColor = .white
            navigationItem.rightBarButtonItem = closeButton
        }
        
        initTableView_CheckData()
    }
    
    @objc func closeButtonTapped() {
        self.metaTraderType = .Balance
        
        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.MetaTraderLoginConstant.key, dict: [NotificationObserver.Constants.MetaTraderLoginConstant.title: self.metaTraderType ?? MetaTraderType.None])
        
        // Dismiss the modal first
        var root = self.presentingViewController

           // Traverse up the presenting stack
           while let presenter = root?.presentingViewController {
               root = presenter
           }

           root?.dismiss(animated: true) {
               // After all modals are dismissed, ensure we're on AccountVC tab
               if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first(where: { $0.isKeyWindow }),
                  let tabBar = window.rootViewController as? UITabBarController {
                   
                   // Make sure AccountVC tab is selected (adjust index if needed)
                   tabBar.selectedIndex = 2
               }
           }
    }
    
    @objc func updateProfileData(_ notification: Notification) {
        // Retrieve the user info dictionary from the notification
        
        tblView.reloadData()
    }
    
    func accountDismisal() {
        
        print("Account Dismissed through Protocol. in profile screen")
        initTableView_CheckData()
//        let _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
//            //TODO: Navigate to Accounts.
//            if let tabBarController = self.tabBarController as? HomeTabbarViewController {
//                tabBarController.selectedIndex = 0
////                NotificationCenter.default.post(name: .OPCListDismissall, object: nil, userInfo: ["OPCType": "Open"])
//                NotificationCenter.default.post(name: .accountChangeUpdation, object: nil, userInfo: ["accountChangeUpdation": "accountChangeUpdation"])
//
//            }
//        }
        didTapCompleteProfileButtonInCell()
        
    }
    
    func presentNextBottomSheet(screen: createAccountType, AccountReal: Bool, accounts: [AccountModel], index: Int) {
        print("it come to presentNextBottomSheet function in ProfileViewController from selectedAccount_typeVC")
    }
    
    func initTableView_CheckData(){
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let profileStep1 = savedUserData["profileStep"] as? Int, let _email = savedUserData["email"] as? String, let _userId = savedUserData["uid"] as? String, let _registrationType = savedUserData["registrationType"] as? Int, let _isPhoneVerified = savedUserData["phoneVerified"] as? Bool, let _isEmailVerified = savedUserData["emailVerified"] as? Bool  {
                profileStep = profileStep1
                userEmail = _email
                registrationType = _registrationType
                isPhoneVerified = _isPhoneVerified
                isEmailVerified = _isEmailVerified
                UserDefaults.standard.set(_userId, forKey: "userID")
                
                print("\n saved User data from fb: \(savedUserData)")
            }
        }
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            print("\n Default Account User in profileVC: \(defaultAccount)")
            realAccount = defaultAccount.isReal == true ? true : false
        }
        
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
/*            cell.onLogoutTapped = { [weak self] in
                guard let self = self else { return }
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                        Alert.ShowWindowAlert("Are you want to Logout?", andTitle: "Log out", OKButtonText: "Yes", window: keyWindow) { ok in
 
//                    Alert.ShowWindowAlert("Are you want to Logout?", andTitle: "Log out", OKButtonText: "Yes", window: SCENE_DELEGATE.window!) { ok in
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        self.webSocketManager.connectionCheckTimer?.invalidate()
                        self.webSocketManager.connectionCheckTimer = nil
                        
                        self.webSocketManager.DisconnectWebSocket()
                        
                        //MARK: - START calling Socket message from here.
                        //        webSocketManager.sendWebSocketMessage(for: "unsubscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList, isTradeDismiss: false)
                        UserDefaults.standard.removeObject(forKey: "userData")
                        UserDefaults.standard.removeObject(forKey: "savedSymbolsKey")
                        UserDefaults.standard.removeObject(forKey: "userPasswordData")
                        UserDefaults.standard.removeObject(forKey: "userProfileImage")
                        
                        GlobalVariable.instance.isProcessingSymbolTimer = false
                        
                        GlobalVariable.instance.userEmail = ""
                        
                        GlobalVariable.instance.balanceUpdate = "0.0"
                        
                        GlobalVariable.instance.symbolDataArray = []
                        
                        GlobalVariable.instance.changeSector = Bool()
                        GlobalVariable.instance.resultTopButtonType = String()
                        GlobalVariable.instance.isProcessingSymbol = false
                        GlobalVariable.instance.isAppLunch = false
                        GlobalVariable.instance.isAccountCreated = Bool()
                        
                        GlobalVariable.instance.tradeCollectionViewIndex = (0, [])
                        
                        GlobalVariable.instance.sectors = []
                        GlobalVariable.instance.tempSectors = []
                        
                        GlobalVariable.instance.filteredSymbols = [[]]
                        GlobalVariable.instance.filteredSymbolsUrl = [[]]
                        
                        GlobalVariable.instance.getSelectedSectorSymbols = (0, [""])
                        
                        GlobalVariable.instance.historyChartData = [SymbolChartData]()
                        
                        GlobalVariable.instance.isStopTick = false
                        GlobalVariable.instance.isStopHistory = false
                        
                        GlobalVariable.instance.previouseSymbolList = [String]()
                        GlobalVariable.instance.tempPreviouseSymbolList = [String]()
                        
                        //        GlobalVariable.instance.isConnected = false // Track connection state
                        GlobalVariable.instance.getSectorIndex = 0
                        
                        let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                        
                        let navController = UINavigationController(rootViewController: loginVC)
                        SCENE_DELEGATE.window?.rootViewController = navController
                        SCENE_DELEGATE.window?.makeKeyAndVisible()
                        print("log out")
                        
                    } andCompletionHandler: { cancel in
                        print("Cancel")
                    }
                }
            } */
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 220
            
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
//            Alert.showAlert(withMessage: "Please First Create Real Account", andTitle: "Unable to Proceed!", on: self)
            let alert = UIAlertController(
                        title: "📋 Attention!!!",
                        message: "Please First Select or Create Real Account",
                        preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                        guard let self = self else { return }
                        
                        let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .bottomSheetPopups) as! SelectAccountTypeVC
                        //        vc.newAccoutDelegate = self
                        vc.userID =  UserDefaults.standard.string(forKey: "userID") ?? ""
                        vc.dismissDelegate = self
                        vc.accountDismisalProtocol = self
                        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
                   
                     }))

                    present(alert, animated: true, completion: nil)
        }
    }
    
    func didCompletePhoneVerification() {
        // After phone verification is complete, check profileStep
        initTableView_CheckData()
        switch profileStep {
        case 0:
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
             self.navigate(to: vc)
         case 1:
            let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
             self.navigate(to: vc)
         default:
            self.ToastMessage("Already Done KYC")
        }
    }
}
 
extension ProfileViewController: ProfileEditButtonDelegate {
    func didTapEditButtonInCell() {
        let vc = Utilities.shared.getViewController(identifier: .editPhotoVC, storyboardType: .dashboard) as! EditPhotoVC
        self.navigate(to: vc)
    }
    
}

