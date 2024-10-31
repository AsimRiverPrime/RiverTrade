//
//  DashboardVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 16/07/2024.
//

import UIKit
import AEXML


enum CustomTabBarType {
    case Accounts
    case Trade
    case Markets
    case Results
    case Profile
}

protocol DashboardVCDelegate: AnyObject {
    func navigateToCompeletProfile()
}

class DashboardVC: BaseViewController {
    
    @IBOutlet weak var myViewFragment: UIView!
    @IBOutlet weak var myCustomTabbarView: UIView!
    
    @IBOutlet weak var AccountsButton: UIButton!
    @IBOutlet weak var TradeButton: UIButton!
    @IBOutlet weak var MarketsButton: UIButton!
    @IBOutlet weak var ResultsButton: UIButton!
    @IBOutlet weak var ProfileButton: UIButton!
    
    @IBOutlet weak var AccountsImage: UIImageView!
    @IBOutlet weak var TradeImage: UIImageView!
    @IBOutlet weak var MarketsImage: UIImageView!
    @IBOutlet weak var ResultsImage: UIImageView!
    @IBOutlet weak var ProfileImage: UIImageView!
    
    @IBOutlet weak var AccountsLabel: UILabel!
    @IBOutlet weak var TradeLabel: UILabel!
    @IBOutlet weak var MarketsLabel: UILabel!
    @IBOutlet weak var ResultsLabel: UILabel!
    @IBOutlet weak var ProfileLabel: UILabel!
    
    @IBOutlet weak var AccountsView: CardView!
    @IBOutlet weak var TradeView: CardView!
    @IBOutlet weak var MarketsView: CardView!
    @IBOutlet weak var ResultsView: CardView!
    @IBOutlet weak var ProfileView: CardView!
    
    var createAccountVC = CreateAccountVC()
    var accountsVC = AccountsVC()
    var tradeVC = TradeVC()
    var marketsVC = MarketsVC()
    var resultVC = ResultVC()
    var profileVC = ProfileVC()
    
    var profileStep = 0
    var demoAccountCreated = Bool()
    var balance = String()
    
    var odooClientService = OdooClient()
    
     let webSocketManager = WebSocketManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.MetaTraderLogin(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.MetaTraderLoginConstant.key), object: nil)
        
        // Retrieve the data from UserDefaults
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            // Access specific values from the dictionary
            
            if let profileStep1 = savedUserData["profileStep"] as? Int, let isCreateDemoAccount = savedUserData["demoAccountCreated"] as? Bool {
                profileStep = profileStep1
                GlobalVariable.instance.isAccountCreated = isCreateDemoAccount
               
                let password = UserDefaults.standard.string(forKey: "password")
                if password == nil && isCreateDemoAccount == true {
                    showPopup()
                }else{
                    print("the password is: \(password ?? "")")
                    
                    let getbalanceApi = TradeTypeCellVM()
                    getbalanceApi.getBalance(completion: { response in
                        print("response of get balance: \(response)")
                        if response == "Invalid Response" {
                            self.balance = "0.0"
                            return
                        }
                        self.balance = response
                        GlobalVariable.instance.balanceUpdate = self.balance
                        print("GlobalVariable.instance.balanceUpdate = \(GlobalVariable.instance.balanceUpdate)")
                        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: self.balance])
                    
                        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.OPCUpdateConstant.key, dict: [NotificationObserver.Constants.OPCUpdateConstant.title: "Open"])

                    })
                }
            }
        }
       
        if GlobalVariable.instance.isReturnToProfile == true {
            setProfileButton()
            GlobalVariable.instance.isReturnToProfile = false
        }else{
            //MARK: - START Symbol api calling.
            symbolApiCalling()
           
            //MARK: - START SOCKET and call delegate method to get data from socket.
//            webSocketManager.delegateSocketMessage = self
//            webSocketManager.delegateSocketPeerClosed = self
            webSocketManager.connectWebSocket()
            webSocketManager.connectHistoryWebSocket()
            setAccountsButton()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(apiSuccessHandler), name: NSNotification.Name("accountCreate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.MetaTraderLogin(_:)), name: .MetaTraderLogin, object: nil) // NSNotification.Name("metaTraderLogin")
    }
    
    @objc private func MetaTraderLogin(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let receivedString = userInfo[NotificationObserver.Constants.MetaTraderLoginConstant.title] as? MetaTraderType {
            print("Received string: \(receivedString)")
            switch receivedString {
            case .Balance:
                let getbalanceApi = TradeTypeCellVM()
                getbalanceApi.getBalance(completion: { response in
                    print("response of get balance: \(response)")
                    if response == "Invalid Response" {
                        self.balance = "0.0"
                        return
                    }
                    self.balance = response
                    GlobalVariable.instance.balanceUpdate = self.balance
//                    NotificationCenter.default.post(name: .BalanceUpdate, object: nil,  userInfo: ["BalanceUpdateType": self.balance])
                    NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: self.balance])
                 
                    NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.OPCUpdateConstant.key, dict: [NotificationObserver.Constants.OPCUpdateConstant.title: "Open"])

                })
                break
            case .GetBalance:
                break
            case .None:
                break
            }
        }
    }
    
    @objc func apiSuccessHandler() {
           // Perform necessary updates
           print("Add account success & notification received!")
            setAccountsButton()
    }
    deinit {
           NotificationCenter.default.removeObserver(self, name: NSNotification.Name("apiSuccessNotification"), object: nil)
//        NotificationCenter.default.removeObserver(self)
       }
    
    override func viewWillAppear(_ animated: Bool) {
        //        self.setNavBar(vc: self, isBackButton: true, isBar: true)
        //        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
        
    }
    
    override func viewDidLayoutSubviews() {
        createAccountVC.frame = self.view.bounds
        accountsVC.frame = self.view.bounds
        tradeVC.frame = self.view.bounds
        marketsVC.frame = self.view.bounds
        resultVC.frame = self.view.bounds
        profileVC.frame = self.view.bounds
        //        bookFragment.frame = self.view.bounds
        //        homeAllReservationFragment.frame = self.view.bounds
        //        socialDistancePopupView.frame = self.view.bounds //MARK: - For Social distance popup.
    }
    
    @IBAction func AccountsButton(_ sender: UIButton) {
        
        setAccountsButton()
    }
    
    @IBAction func TradeButton(_ sender: UIButton) {
        
        setTradeButton()
    }
    
    @IBAction func MarketsButton(_ sender: UIButton) {
        
        setMarketsButton()
    }
    
    @IBAction func ResultsButton(_ sender: UIButton) {
        setResultsButton()
    }
    
    @IBAction func ProfileButton(_ sender: UIButton) {
        setProfileButton()
    }
    
}

//MARK: - Custom Tab bar handling.
extension DashboardVC {
    
    private func setAccountsButton() {
        
        CustomBarStatus(customTabBarType: .Accounts)
    }
    
    private func setTradeButton() {
        CustomBarStatus(customTabBarType: .Trade)
    }
    
    private func setMarketsButton() {
        CustomBarStatus(customTabBarType: .Markets)
    }
    
    private func setResultsButton() {
        CustomBarStatus(customTabBarType: .Results)
    }
    
    private func setProfileButton() {
        CustomBarStatus(customTabBarType: .Profile)
    }
    
    //MARK: - Custom tabbarView changing.
    private func CustomBarStatus(customTabBarType: CustomTabBarType) {
        //        let customTabBarType = CustomTabBarType.Accounts
        switch customTabBarType {
        case .Accounts:
            
            AccountsImage.image = UIImage(named: "account")//?.tint(with: UIColor.black)
            AccountsLabel.textColor = UIColor.systemYellow
            AccountsView.backgroundColor = UIColor.splashScreen
            
            TradeImage.image = UIImage(named: "trade")//?.tint(with: UIColor.black)
            TradeLabel.textColor = UIColor.black
            TradeView.backgroundColor = UIColor.lightText
            
            MarketsImage.image = UIImage(named: "market")//?.tint(with: UIColor.black)
            MarketsLabel.textColor = UIColor.black
            MarketsView.backgroundColor = UIColor.lightText
            
            ResultsImage.image = UIImage(named: "Growth")//?.tint(with: UIColor.black)
            ResultsLabel.textColor = UIColor.black
            ResultsView.backgroundColor = UIColor.lightText
            
            ProfileImage.image = UIImage(named: "profile")//?.tint(with: UIColor.black)
            ProfileLabel.textColor = UIColor.black
            ProfileView.backgroundColor = UIColor.lightText
            
            dismissViews(false)
            accountsVC = AccountsVC.getView()
            accountsVC.delegate = self
            accountsVC.delegateCreateAccount = self
            accountsVC.delegateOPCNavigation = self
            addView(customTabBarType: .Accounts)
            
            //            if GlobalVariable.instance.isAccountCreated { //MARK: - if account is already created.
            //                accountsVC = AccountsVC.getView()
            //                accountsVC.delegate = self
            //                addView(customTabBarType: .Accounts)
            //            } else { //MARK: - if no account exist.
            //                createAccountVC = CreateAccountVC.getView()
            //                createAccountVC.delegate = self
            //                self.myViewFragment.addSubview(createAccountVC)
            //            }
            
            break
        case .Trade:
            
            AccountsImage.image = UIImage(named: "Teamwork")//?.tint(with: UIColor.black)
            AccountsLabel.textColor = UIColor.black
            AccountsView.backgroundColor = UIColor.lightText
            
            TradeImage.image = UIImage(named: "tradeIconSelect")//?.tint(with: UIColor.black)
            TradeLabel.textColor = UIColor.systemYellow
            TradeView.backgroundColor = UIColor.splashScreen
            
            MarketsImage.image = UIImage(named: "market")//?.tint(with: UIColor.black)
            MarketsLabel.textColor = UIColor.black
            MarketsView.backgroundColor = UIColor.lightText
            
            ResultsImage.image = UIImage(named: "Growth")//?.tint(with: UIColor.black)
            ResultsLabel.textColor = UIColor.black
            ResultsView.backgroundColor = UIColor.lightText
            
            ProfileImage.image = UIImage(named: "profile")//?.tint(with: UIColor.black)
            ProfileLabel.textColor = UIColor.black
            ProfileView.backgroundColor = UIColor.lightText
            
            dismissViews(true)
            tradeVC = TradeVC.getView()
            //            tradeVC.delegate = self
            tradeVC.delegateDetail = self
            addView(customTabBarType: .Trade)
            
            break
        case .Markets:
            
            AccountsImage.image = UIImage(named: "Teamwork")//?.tint(with: UIColor.black)
            AccountsLabel.textColor = UIColor.black
            AccountsView.backgroundColor = UIColor.lightText
            
            TradeImage.image = UIImage(named: "trade")//?.tint(with: UIColor.black)
            TradeLabel.textColor = UIColor.black
            TradeView.backgroundColor = UIColor.lightText
            
            MarketsImage.image = UIImage(named: "marketIconSelect")//?.tint(with: UIColor.black)
            MarketsLabel.textColor = UIColor.systemYellow
            MarketsView.backgroundColor = UIColor.splashScreen
            
            ResultsImage.image = UIImage(named: "Growth")//?.tint(with: UIColor.black)
            ResultsLabel.textColor = UIColor.black
            ResultsView.backgroundColor = UIColor.lightText
            
            ProfileImage.image = UIImage(named: "profile")//?.tint(with: UIColor.black)
            ProfileLabel.textColor = UIColor.black
            ProfileView.backgroundColor = UIColor.lightText
            
            dismissViews(false)
            marketsVC = MarketsVC.getView()
            //            tradeVC.delegate = self
            addView(customTabBarType: .Markets)
            
            break
        case .Results:
            
            AccountsImage.image = UIImage(named: "Teamwork")//?.tint(with: UIColor.black)
            AccountsLabel.textColor = UIColor.black
            AccountsView.backgroundColor = UIColor.lightText
            
            TradeImage.image = UIImage(named: "trade")//?.tint(with: UIColor.black)
            TradeLabel.textColor = UIColor.black
            TradeView.backgroundColor = UIColor.lightText
            
            MarketsImage.image = UIImage(named: "market")//?.tint(with: UIColor.black)
            MarketsLabel.textColor = UIColor.black
            MarketsView.backgroundColor = UIColor.lightText
            
            ResultsImage.image = UIImage(named: "resultIconSelect")//?.tint(with: UIColor.black)
            ResultsLabel.textColor = UIColor.systemYellow
            ResultsView.backgroundColor = UIColor.splashScreen
            
            ProfileImage.image = UIImage(named: "profile")//?.tint(with: UIColor.black)
            ProfileLabel.textColor = UIColor.black
            ProfileView.backgroundColor = UIColor.lightText
            
            dismissViews(false)
            resultVC = ResultVC.getView()
            resultVC.delegate = self
            //            tradeVC.delegate = self
            addView(customTabBarType: .Results)
            
            break
        case .Profile:
            
            AccountsImage.image = UIImage(named: "Teamwork")//?.tint(with: UIColor.black)
            AccountsLabel.textColor = UIColor.black
            AccountsView.backgroundColor = UIColor.lightText
            
            TradeImage.image = UIImage(named: "trade")//?.tint(with: UIColor.black)
            TradeLabel.textColor = UIColor.black
            TradeView.backgroundColor = UIColor.lightText
            
            MarketsImage.image = UIImage(named: "market")//?.tint(with: UIColor.black)
            MarketsLabel.textColor = UIColor.black
            MarketsView.backgroundColor = UIColor.lightText
            
            ResultsImage.image = UIImage(named: "Growth")//?.tint(with: UIColor.black)
            ResultsLabel.textColor = UIColor.black
            ResultsView.backgroundColor = UIColor.lightText
            
            ProfileImage.image = UIImage(named: "profileIconSelect")//?.tint(with: UIColor.black)
            ProfileLabel.textColor = UIColor.systemYellow
            ProfileView.backgroundColor = UIColor.splashScreen
            
            dismissViews(false)
            profileVC = ProfileVC.getView()
            profileVC.delegateCompeleteProfile = self
            
            addView(customTabBarType: .Profile)
            
            break
        }
    }
    
    private func dismissViews(_ isTrade: Bool) {
        createAccountVC.dismissView()
        accountsVC.dismissView()
        tradeVC.dismissView(isTrade)
        marketsVC.dismissView()
        resultVC.dismissView()
        profileVC.dismissView()
    }
    
    private func addView(customTabBarType: CustomTabBarType) {
        switch customTabBarType {
            
        case .Accounts:
            self.myViewFragment.addSubview(accountsVC)
        case .Trade:
            self.myViewFragment.addSubview(tradeVC)
        case .Markets:
            self.myViewFragment.addSubview(marketsVC)
        case .Results:
            self.myViewFragment.addSubview(resultVC)
        case .Profile:
            self.myViewFragment.addSubview(profileVC)
            
        }
    }
    
}
//MARK: - compelet profile Button Taps is here.
extension DashboardVC: DashboardVCDelegate {
    func navigateToCompeletProfile() {
        //        if let kycVc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "KYCViewController") {
        //            self.navigate(to: kycVc)
        
        if profileStep == 0 {
            if let kycVc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "KYCViewController") {
                self.navigate(to: kycVc)
            }
        }else if profileStep == 1 {
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
            
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        }else if profileStep == 2 {
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen7, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen7
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        }
    }
    
}
//MARK: - AccountInfo Button Taps is here.
extension DashboardVC: AccountInfoTapDelegate {
    func accountInfoTap(_ accountInfo: AccountInfo) {
        print("delegte called  \(accountInfo)" )
        
        switch accountInfo {
            
        case .deposit:
            let vc = Utilities.shared.getViewController(identifier: .depositViewController, storyboardType: .dashboard) as! DepositViewController
           // vc.delegateCompeleteProfile = self
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .withDraw:
//            let vc = Utilities.shared.getViewController(identifier: .withdrawViewController, storyboardType: .dashboard) as! WithdrawViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .history:
            let vc = Utilities.shared.getViewController(identifier: .historyViewController, storyboardType: .dashboard) as! HistoryViewController
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .detail:
            let vc = Utilities.shared.getViewController(identifier: .detailsViewController, storyboardType: .dashboard) as! DetailsViewController
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .notification:
            let vc = Utilities.shared.getViewController(identifier: .notificationViewController, storyboardType: .dashboard) as! NotificationViewController
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .createAccount:
            let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .bottomSheetPopups) as! SelectAccountTypeVC
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customSmall, VC: vc)
            break
        }
    }
}

extension DashboardVC: CreateAccountInfoTapDelegate {
    
    func createAccountInfoTap(_ createAccountInfo: CreateAccountInfo) {
        print("delegte called  \(createAccountInfo)" )
        
        switch createAccountInfo {
        case .createNew:
            print("Create new")
            let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .bottomSheetPopups) as! SelectAccountTypeVC
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customSmall, VC: vc)
            
            break
        case .unarchive:
            print("Unarchive")
            let vc = Utilities.shared.getViewController(identifier: .unarchiveAccountTypeVC, storyboardType: .bottomSheetPopups) as! UnarchiveAccountTypeVC
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
            break
        case .notification:
            let vc = Utilities.shared.getViewController(identifier: .notificationViewController, storyboardType: .bottomSheetPopups) as! NotificationViewController
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        }
    }
    
}

extension DashboardVC: OPCNavigationDelegate {
    
    func navigateOPC(_ opcNavigationType: OPCNavigationType) {
        
        switch opcNavigationType {
        case .open(let openData):
            
            let vc = Utilities.shared.getViewController(identifier: .openTicketBottomSheetVC, storyboardType: .bottomSheetPopups) as! OpenTicketBottomSheetVC
            
            vc.openData = openData
            
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customMedium, VC: vc)
            
            break
        case .pending(let pendingData):
            
            let vc = Utilities.shared.getViewController(identifier: .pendingTicketBottomSheetVC, storyboardType: .bottomSheetPopups) as! PendingTicketBottomSheetVC
            
            vc.pendingData = pendingData
            
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customMedium, VC: vc)
            
            break
        case .close(let closeData):
            
            let vc = Utilities.shared.getViewController(identifier: .closeTicketBottomSheetVC, storyboardType: .bottomSheetPopups) as! CloseTicketBottomSheetVC
            
            vc.closeData = closeData
            
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customMedium, VC: vc)
            
            break
        }
        
    }
    
}

//MARK: - TradeVC cell Taps is handle here.
extension DashboardVC: TradeDetailTapDelegate {
    func tradeDetailTap(indexPath: IndexPath, getSymbolData: SymbolCompleteList) {
        let vc = Utilities.shared.getViewController(identifier: .tradeDetalVC, storyboardType: .bottomSheetPopups) as! TradeDetalVC
       
        vc.getSymbolData = getSymbolData
        
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
    }
    
}

extension DashboardVC: iResultVCDelegate {
    
    func resultClicks(resultVCType: iResultVCType) {
        switch resultVCType {
        case .SummaryAllRealAccountFilter:
            let vc = Utilities.shared.getViewController(identifier: .allRealAccountsVC, storyboardType: .bottomSheetPopups) as! AllRealAccountsVC
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
            break
        case .DaysFilter:
            break
        case .BenifitAllRealAccountFilter:
            break
        case .ExnessStartTrading:
            let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .bottomSheetPopups) as! SelectAccountTypeVC
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
            break
        case .ExnessTrading:
            let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .bottomSheetPopups) as! SelectAccountTypeVC
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
            break
        }
    }
    
}

extension DashboardVC {
    
    private func symbolApiCalling() {
        
        //MARK: - Call Symbol Api and their delegate method to get data.
        odooClientService.sendSymbolDetailRequest()
        odooClientService.tradeSymbolDetailDelegate = self
       
    }
    
}

//MARK: - Symbol API calling at the start and Save list local and set sectors in the collectionview (Section 1).
extension DashboardVC: TradeSymbolDetailDelegate {
    func tradeSymbolDetailSuccess(response: String) {
        print("\n \(response) ")
        convertXMLIntoJson(response)
        ActivityIndicator.shared.hide(from: self.view)
    }
    
    func tradeSymbolDetailFailure(error: any Error) {
        print("\n the trade symbol detail Error response: \(error) ")
    }
    
    func convertXMLIntoJson(_ xmlString: String) {
        
        do {
            let xmlDoc = try AEXMLDocument(xml: xmlString)

            if let xmlDocFile = xmlDoc.root["params"]["param"]["value"]["array"]["data"]["value"].all {
                
                
                for param in xmlDocFile {
                    if let structElement = param["struct"].first {
                        var parsedData: [String: Any] = [:]
                        for member in structElement["member"].all ?? [] {
                            let name = member["name"].value ?? ""
                            let value = member["value"].children.first?.value ?? ""
                            parsedData[name] = value
                        }
                        
                        if let symbolId = parsedData["id"] as? String, let symbolName = parsedData["name"] as? String,
                            let symbolDescription = parsedData["description"] as? String, let symbolIcon = parsedData["icon_url"] as? String,
                            let symbolVolumeMin = parsedData["volume_min"] as? String, let symbolVolumeMax = parsedData["volume_max"] as? String,
                            let symbolVolumeStep = parsedData["volume_step"] as? String, let symbolContractSize = parsedData["contract_size"] as? String,
                           let symbolDisplayName = parsedData["display_name"] as? String, let symbolSector = parsedData["sector"] as? String, let symbolDigits = parsedData["digits"] as? String, let symbolMobile_available = parsedData["mobile_available"] as? String,  let symbolSwap_long = parsedData["swap_long"] as? String , let symbolStops_level = parsedData["stops_level"] as? String,  let symbolSpread_size = parsedData["spread_size"] as? String, let symbolSwap_short = parsedData["swap_short"] as? String   {
                         
                            
                            let originalUrl = symbolIcon // "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/platinum-01.svg"
                            print(" originalUrl URL: \(originalUrl)")
                            // Replace the part of the URL
                            if originalUrl == "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/ndx100-01.svg" {
                                
                            }
                            let modifiedUrl = originalUrl
                                .replacingOccurrences(of: "-01.svg", with: ".png")
                                .replacingOccurrences(of: ".com/", with: ".com/png/")

                            print("\n modifiy URL: \(modifiedUrl)")
                            
                            GlobalVariable.instance.symbolDataArray.append(SymbolData(id: symbolId , name: symbolName , description: symbolDescription , icon_url: modifiedUrl , volumeMin: symbolVolumeMin , volumeMax: symbolVolumeMax , volumeStep: symbolVolumeStep , contractSize: symbolContractSize , displayName: symbolDisplayName , sector: symbolSector , digits: symbolDigits,  stopsLevel: symbolStops_level, swapLong: symbolSwap_long, swapShort: symbolSwap_short, spreadSize: symbolSpread_size, mobile_available: symbolMobile_available))
                        }
                           
                        print("symbol data array count : \(GlobalVariable.instance.symbolDataArray.count)")
                       
                        print("\n the parsed value is :\(parsedData)")
                    }
                }
                
                //MARK: - Get the list and save localy and set sectors and symbols.
                processSymbols(GlobalVariable.instance.symbolDataArray)
                
//                //MARK: - Reload tablview when all data set into the list at first time.
//                self.tblView.reloadData()
            }
        } catch {
            print("Failed to parse XML: \(error.localizedDescription)")
        }

    }
    
    func filterSymbolsBySector(symbols: [SymbolData], sector: String) -> [String] {
        return symbols.filter { $0.sector == sector }.map { $0.displayName }
    }
    
    func filterSymbolsImageBySector(symbols: [SymbolData], sector: String) -> [String] {
        return symbols.filter { $0.sector == sector }.map { $0.icon_url }
    }
    
    private func processSymbols(_ symbols: [SymbolData]) {
        var sectorDict = [String: [SymbolData]]()
        
        // Group symbols by sector
        for symbol in symbols {
            sectorDict[symbol.sector, default: []].append(symbol)
        }
        
        // Sort the sectors by key
        let sortedSectors = sectorDict.keys.sorted()
        
        // Create SectorGroup from sorted keys
        GlobalVariable.instance.sectors = sortedSectors.map {
            SectorGroup(sector: $0, symbols: sectorDict[$0]!)
        }
        
        saveSymbolsToDefaults(symbols)
        
        // Initialize with the first index
        setTradeModel(collectionViewIndex: 0)
    }

    
    private func saveSymbolsToDefaults(_ symbols: [SymbolData]) {
        let savedSymbolsKey = "savedSymbolsKey"
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(symbols) {
            UserDefaults.standard.set(encoded, forKey: savedSymbolsKey)
        }
    }
    
    func getSavedSymbols() -> [SymbolData]? {
        let savedSymbolsKey = "savedSymbolsKey"
        if let savedSymbols = UserDefaults.standard.data(forKey: savedSymbolsKey) {
            let decoder = JSONDecoder()
            return try? decoder.decode([SymbolData].self, from: savedSymbols)
        }
        return nil
    }
    
}

//MARK: - Main and final list which is change when the sector is set and all the symbols which is on the selected sector.
extension DashboardVC {
    func showPopup() {
        let storyboard = UIStoryboard(name: "BottomSheetPopups", bundle: nil)
        
        // Replace "PopupViewController" with the actual identifier of your popup view controller
        if let popupVC = storyboard.instantiateViewController(withIdentifier: "LoginPopupVC") as? LoginPopupVC {
            // Set modal presentation style
            popupVC.modalPresentationStyle = .overFullScreen// .overCurrentContext    // You can use .overFullScreen for full-screen dimming
           
            popupVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            popupVC.view.alpha = 0
            // Optional: Set modal transition style (this is for animation)
            popupVC.modalTransitionStyle = .crossDissolve
            popupVC.metaTraderType = .Balance
            
            // Present the popup
            self.present(popupVC, animated: true, completion: nil)
        }
    }
    //MARK: - Update all list when selector will change, and update tick socket message according to the selected sector.
    private func setTradeModel(collectionViewIndex: Int) {
        
        GlobalVariable.instance.tradeCollectionViewIndex.0 = collectionViewIndex
        
        let symbols = GlobalVariable.instance.symbolDataArray
        let sectors = GlobalVariable.instance.sectors
        
        // Clear previous data
        GlobalVariable.instance.filteredSymbols.removeAll()
        GlobalVariable.instance.filteredSymbolsUrl.removeAll()
        
        // Populate filteredSymbols and filteredSymbolsUrl for each sector
        for sector in sectors {
            let filteredSymbols = filterSymbolsBySector(symbols: symbols, sector: sector.sector)
            let filteredSymbolsUrl = filterSymbolsImageBySector(symbols: symbols, sector: sector.sector)
            
            GlobalVariable.instance.filteredSymbols.append(filteredSymbols)
            GlobalVariable.instance.filteredSymbolsUrl.append(filteredSymbolsUrl)
        }
        
        // Append trades for the selected collectionViewIndex
//        let selectedSymbols = GlobalVariable.instance.filteredSymbols[safe: collectionViewIndex] ?? []
//        let selectedUrls = GlobalVariable.instance.filteredSymbolsUrl[safe: collectionViewIndex] ?? []
        
        GlobalVariable.instance.tradeCollectionViewIndex.1.removeAll()
//        getSymbolData.removeAll()
//        var count = 0
//        for (symbol, url) in zip(selectedSymbols, selectedUrls) {
//            count += 1
//            GlobalVariable.instance.tradeCollectionViewIndex.1.append(count)
//            let tradedetail = TradeDetails(datetime: 0, symbol: symbol, ask: 0.0, bid: 0.0, url: url, close: nil)
//            let symbolChartData = SymbolChartData(symbol: symbol, chartData: [])
//            getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, historyMessage: symbolChartData, isTickFlag: false, isHistoryFlag: false))
//        }
        
//        print("GlobalVariable.instance.filteredSymbolsUrl = \(GlobalVariable.instance.filteredSymbolsUrl)")
//
//        GlobalVariable.instance.isProcessingSymbol = false
//
//        refreshSection(at: 2)
//
//        //MARK: - Save symbol local to unsubcibe.
//        GlobalVariable.instance.previouseSymbolList = selectedSymbols
//
//        //MARK: - START calling Socket message from here.
//        vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: selectedSymbols)
    }

    
}

