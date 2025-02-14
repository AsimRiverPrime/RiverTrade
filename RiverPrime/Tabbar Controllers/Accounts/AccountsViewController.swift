//
//  AccountsViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//
import Foundation
import UIKit
import SDWebImage

protocol AccountInfoTapDelegate: AnyObject {
    func accountInfoTap(_ accountInfo: AccountInfo)
}

protocol CreateAccountInfoTapDelegate: AnyObject {
    func createAccountInfoTap(_ createAccountInfo: CreateAccountInfo)
}

enum OPCNavigationType {
    case open(OpenModel)
    case pending(PendingModel)
    case close(NewCloseModel)
}

protocol OPCNavigationDelegate: AnyObject {
    func navigateOPC(_ opcNavigationType: OPCNavigationType)
}

enum OPCType {
    case open([OpenModel])
    case pending([PendingModel])
    case close([NewCloseModel])
}

protocol OPCDelegate: AnyObject {
    func getOPCData(opcType: OPCType)
}

class AccountsViewController: BaseViewController {
    
    @IBOutlet weak var view_topHeader: UIView!
    //    @IBOutlet weak var view_depositWithdraw: UIView!
    @IBOutlet weak var view_CreateNewAcct: UIView!
    
    //    @IBOutlet weak var lbl_greetingCreateNew: UILabel!
    @IBOutlet weak var image_createNew: UIImageView!
    @IBOutlet weak var lbl_userNameCreateNew: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    //    @IBOutlet weak var lbl_greeting: UILabel!
    @IBOutlet weak var lbl_account: UILabel!
    //    @IBOutlet weak var lbl_MT5: UILabel!
    @IBOutlet weak var lbl_accountType: UILabel!
    
    @IBOutlet weak var labelAmmount: UILabel!
    @IBOutlet weak var tblView: UITableView!
    //    var model: [String] = ["Open","Pending","Close","image"]
    @IBOutlet weak var lbl_amountPercent: UILabel!
    
    @IBOutlet weak var btn_deposit: CardViewButton!
    @IBOutlet weak var btn_withdraw: CardViewButton!
    @IBOutlet weak var btn_history: CardViewButton!
    @IBOutlet weak var btn_details: CardViewButton!
    @IBOutlet weak var btn_creat: CardViewButton!
    
    weak var delegate: AccountInfoTapDelegate?
    weak var delegateCreateAccount: CreateAccountInfoTapDelegate?
    weak var delegateOPCNavigation: OPCNavigationDelegate?
    weak var newAccoutDelegate : CreateAccountUpdateProtocol?
    
    var opcList: OPCType? = .open([])
    var totalProfitOpenClose = Double()
    var emptyListCount = 0
    
    var profileStep = 0
    var demoAccountCreated = Bool()
    var balance = String()
    var isRealAcount = Bool()
    
    var odooClientService = OdooClientNew()
    
    let webSocketManager = WebSocketManager.shared
    
    var getSymbolData = [SymbolCompleteList]()
    
    //MARK: - START CollectionView work.
    @IBOutlet weak var tradeTypeCollectionView: UICollectionView!
    var model: [String] = ["Open","Pending","Closed","image"/*,"test","test1","test2","test3"*/]
    var refreshList = ["Month", "Year", "Today"]
    var selectedIndex = 0
    
    var vm = TradeTypeCellVM()
    
    let activityIndicator = NewActivityIndicator()
    
    weak var delegateCollectionView: OPCDelegate?
    //MARK: - END CollectionView work.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setGradientBackground()
        dashboardDatainit()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.opcCallingAtStart(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.OPCUpdateConstant.key), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
        
        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
        
        collectionViewinit()
        
        GlobalVariable.instance.lastSelectedOPCIndex = IndexPath(row: 0, section: 0)
        
        GlobalVariable.instance.controllerName = "AccountVC"
        NotificationCenter.default.addObserver(self, selector: #selector(self.FaceAfterLoginUpdate(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.FaceAfterLoginConstant.key), object: nil)
        
    }
    
    @objc private func FaceAfterLoginUpdate(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let receivedString = userInfo[NotificationObserver.Constants.FaceAfterLoginConstant.title] as? String {
            print("Received string: \(receivedString)")
            
            if receivedString == "AccountVC" {
                let faceIdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! PasscodeFaceIDVC
                faceIdVC.afterLoginNavigation = true
                self.navigate(to: faceIdVC)
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
        
//        delegate = self
//        delegateCreateAccount = self
        delegateOPCNavigation = self
        delegateCollectionView = self
        
        if let tabBarController = self.tabBarController as? HomeTabbarViewController {
            tabBarController.delegateSocketMessage = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileData(_:)), name: Notification.Name("UpdateProfileData"), object: nil)
        
        callCollectionViewAtStart()
        accountData()
        
        
    }
    
    private func callCollectionViewAtStart() {
        
        let indexPath = GlobalVariable.instance.lastSelectedOPCIndex
        
        if tradeTypeCollectionView.cellForItem(at: indexPath) != nil {
            selectedIndex = indexPath.row
            
            if indexPath.row != model.count-1 {
                fetchPositions(index: indexPath.row)
            }
            
            tradeTypeCollectionView.reloadData()
        }
        
    }
    
    @objc func updateProfileData(_ notification: Notification) {
        // Retrieve the user info dictionary from the notification
        if let userInfo = notification.userInfo {
            if let updatedImage = userInfo["profileImage"] as? UIImage {
                userImage.image = updatedImage
                image_createNew.image = updatedImage
            }
            if let updatedName = userInfo["userName"] as? String {
                lbl_name.text = updatedName
                lbl_userNameCreateNew.text = updatedName
            }
        }
    }
    
    @IBAction func createNewAccount_action(_ sender: Any) {
        let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .bottomSheetPopups) as! SelectAccountTypeVC
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
    }
    
    func accountData() {
        
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            //print("\n Default Account User: \(defaultAccount)")
           
            lbl_account.text = defaultAccount.isReal == true ? "Real" : "Demo"
            lbl_accountType.text = defaultAccount.groupName
            isRealAcount = defaultAccount.isReal == true ? true : false
        }
                           
                          
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
         
            if let _name = savedUserData["fullName"] as? String {
                
                if let imageData = UserDefaults.standard.data(forKey: "userProfileImage"),
                   let savedImage = UIImage(data: imageData) {
                    userImage.image = savedImage
                }else{
                    userImage.image = UIImage(named: "avatarIcon")
                }
                
                lbl_name.text = _name
                lbl_userNameCreateNew.text = _name
                
            }
        }
    }
    
    func dashboardDatainit() {
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(self.MetaTraderLogin(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.MetaTraderLoginConstant.key), object: nil)
        if GlobalVariable.instance.isAccountCreated { //MARK: - if account is already created.
            view_topHeader.isHidden = false
            //            view_depositWithdraw.isHidden = false
            btn_creat.isHidden = false
            btn_deposit.isHidden = false
            btn_details.isHidden = false
            btn_history.isHidden = false
            btn_withdraw.isHidden = false
            view_CreateNewAcct.isHidden = true
            self.tblView.isHidden = false
            self.tradeTypeCollectionView.isHidden = false
            tblView.registerCells([
                /*AccountTableViewCell.self, TradeTypeTableViewCell.self, */Total_PLCell.self, TransactionCell.self, PendingOrderCell.self, CloseOrderCell.self, EmptyCell.self
            ])
        } else { //MARK: - if no account exist.
            view_topHeader.isHidden = true
            btn_creat.isHidden = true
            btn_deposit.isHidden = true
            btn_details.isHidden = true
            btn_history.isHidden = true
            btn_withdraw.isHidden = true
            //            view_depositWithdraw.isHidden = true
            view_CreateNewAcct.isHidden = false
            self.tblView.isHidden = true
            self.tradeTypeCollectionView.isHidden = true
            tblView.registerCells([
                /*CreateAccountTVCell.self, TradeTypeTableViewCell.self, CreateAccountTVCell.self*/ Total_PLCell.self, TransactionCell.self, PendingOrderCell.self, CloseOrderCell.self, EmptyCell.self
            ])
        }
        // Retrieve the data from UserDefaults
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            //print("saved User Data: \(savedUserData)")
            // Access specific values from the dictionary
            
            if let profileStep1 = savedUserData["profileStep"] as? Int{
                profileStep = profileStep1
//                GlobalVariable.instance.isAccountCreated = isCreateDemoAccount
                
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(apiSuccessHandler), name: NSNotification.Name("accountCreate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.MetaTraderLogin(_:)), name: .MetaTraderLogin, object: nil) // NSNotification.Name("metaTraderLogin")
        
    }
    
    func collectionViewinit() {
        tradeTypeCollectionView.delegate = self
        tradeTypeCollectionView.dataSource = self
        tradeTypeCollectionView.register(UINib(nibName: "TradeTypeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TradeTypeCollectionViewCell")
        tradeTypeCollectionView.isScrollEnabled = false
        
        fetchPositions(index: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.OPCListDissmisal(_:)), name: .OPCListDismissall, object: nil)
    }
    
    @IBAction func profileBtnAction(_ sender: Any) {
        let vc = Utilities.shared.getViewController(identifier: .profileViewController, storyboardType: .dashboard) as! ProfileViewController
        self.navigate(to: vc)
    }
    @IBAction func profileBtnAction_CreateNewAcct(_ sender: Any) {
        let vc = Utilities.shared.getViewController(identifier: .profileViewController, storyboardType: .dashboard) as! ProfileViewController
        self.navigate(to: vc)
    }
    
    @IBAction func depositAction(_ sender: Any) {
        if isRealAcount{
            let vc = Utilities.shared.getViewController(identifier: .depositViewController, storyboardType: .dashboard) as! DepositViewController
            // vc.delegateCompeleteProfile = self
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        }else{
            if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DemoDepositVC") as? DemoDepositVC {
                
                self.navigate(to: vc)
            }
        }
    }
    
    @IBAction func withDrawAction(_ sender: Any) {
        
        let hasUploadBill = UserDefaults.standard.bool(forKey: "hasUploadBill")
        if isRealAcount{
                if !hasUploadBill {
                    // Present the controller
                    if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "WithdrawPreRequirmentVC") as? WithdrawPreRequirmentVC {
                        self.navigate(to: vc)
                }
                }else{
                    let vc = Utilities.shared.getViewController(identifier: .withdrawViewController, storyboardType: .dashboard) as! WithdrawViewController
                    PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
                }
      
        }else{
            if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DemoWithdrawalVC") as? DemoWithdrawalVC {
                self.navigate(to: vc)
            }
        }
    }
    
    @IBAction func historyAction(_ sender: Any) {
        let vc = Utilities.shared.getViewController(identifier: .historyViewController, storyboardType: .dashboard) as! HistoryViewController
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
    }
    
    @IBAction func detailAction(_ sender: Any) {
        
        let vc = Utilities.shared.getViewController(identifier: .detailsViewController, storyboardType: .dashboard) as! DetailsViewController
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
    }
    
    @IBAction func createAcoountAction(_ sender: Any) {
        let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .bottomSheetPopups) as! SelectAccountTypeVC
//        vc.newAccoutDelegate = self
        vc.dismissDelegate = self
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
    }
    
    @IBAction func percentAction(_ sender: UIButton) {
        
//        self.dynamicDropDownButton(sender, list: refreshList) { index, item in
//            print("drop down index = \(index)")
//            print("drop down item = \(item)")
//            sender.setTitle("", for: .normal)
//        }
        
    }
    
    
    deinit {
        // Remove observer when the view controller is deallocated
        NotificationCenter.default.removeObserver(self, name: Notification.Name("UpdateProfileData"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("apiSuccessNotification"), object: nil)
        //        NotificationCenter.default.removeObserver(self)
    }
}

extension AccountsViewController: BottomSheetDismissDelegate {
  
    func presentNextBottomSheet(screen: createAccountType, AccountReal : Bool, accounts: [AccountModel], index: Int) {
        switch screen {
        case .selectAccountType:
           
                let vc = Utilities.shared.getViewController(identifier: .createAccountSelectTradeType, storyboardType: .bottomSheetPopups) as! CreateAccountSelectTradeType
            if AccountReal {
                      vc.isRealAccount = true
                  }else{
                      vc.isRealAccount = false
                  }
            vc.dismissDelegate = self
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            
        case .selectAccount:
          
            break
        case .createAccount:
           
            let vc = Utilities.shared.getViewController(identifier: .createAccountTypeVC, storyboardType: .bottomSheetPopups) as! CreateAccountTypeVC
            vc.dismissDelegate = self
            vc.account = accounts[index]
            vc.isReal = AccountReal
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        }
    }
  
    
}

extension AccountsViewController {
    
    @objc func notificationPopup(_ notification: NSNotification) {
        
        if let ammount = notification.userInfo?[NotificationObserver.Constants.BalanceUpdateConstant.title] as? String {
            print("Received ammount in account Home vc: \(ammount)")
            let amount = String.formatStringNumber(ammount)
            self.labelAmmount.text = "$\(String(describing: amount))"
//            self.labelAmmount.text = "$\(ammount)"
            
            if ammount == "0.0" {
                self.lbl_amountPercent.text = "0.0%"
            }else{
                let balancePercent = ((Double(ammount) ?? 0.0) - 10000.0) / 10000.0 * 100 // change with starting balance when account first deposit occure
                self.lbl_amountPercent.text = "\(balancePercent)".trimmedTrailingZeros() + "%"
              
            }
            accountData()
        }
        
    }
    
    @objc func opcCallingAtStart(_ notification: NSNotification) {
        
        if let opc = notification.userInfo?[NotificationObserver.Constants.OPCUpdateConstant.title] as? String {
            print("Received opc: \(opc)")
            if opc == "Open" {
                
                switch opcList {
                case .open(_):
                    
                    let indexPath = IndexPath(row: 0, section: 1)
                    tblView.reloadRows(at: [indexPath], with: .none)
                    
                    break
                case .pending(_):
                    
                    break
                case .close(_):
                    
                    break
                case .none: break
                }
                
            }
        }
        
    }
    
    //MARK: - START CollectionView work.
    @objc private func OPCListDissmisal(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let receivedString = userInfo["OPCType"] as? String {
            print("Received string: \(receivedString)")
            if receivedString == "Open" {
                DispatchQueue.global(qos: .background).async { [weak self] in
                    guard let self = self else { return }
                    
                    self.vm.OPCApi(index: 0) { openData, pendingData, closeData, error in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("Error fetching positions: \(error)")
                                // Handle the error (e.g., show an alert)
                            } else if let positions = openData {
                                
                                GlobalVariable.instance.openSymbolList.removeAll()
                                
                                let symbols = positions.map { self.getSymbol(item: $0.symbol) }
                                GlobalVariable.instance.openSymbolList = symbols
                                
                                self.delegateCollectionView?.getOPCData(opcType: .open(positions))
                                
                            }
                        }
                    }
                    
                    
                    
                    //MARK: - START Call balance api
                    
                    let getbalanceApi = TradeTypeCellVM()
                    
                    getbalanceApi.getBalance(completion: { response in
                        print("response of get balance in Account home vc: \(response)")
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
                    
                    //MARK: - END Call balance api
                    
                    
                    
                }
            }else if receivedString == "Pending" {
                DispatchQueue.global(qos: .background).async { [weak self] in
                    self?.vm.OPCApi(index: 1) { openData, pendingData, closeData, error in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("Error fetching positions: \(error)")
                                
                            } else if let orders = pendingData {
                                self?.delegateCollectionView?.getOPCData(opcType: .pending(orders))
                            }
                        }
                    }
                }
            }
        }
        // Execute the fetch on a background thread
        
        
    }
    //MARK: - END CollectionView work.
    
    
    @objc private func MetaTraderLogin(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let receivedString = userInfo[NotificationObserver.Constants.MetaTraderLoginConstant.title] as? MetaTraderType {
            print("Received string: \(receivedString)")
            switch receivedString {
            case .Balance:
                let getbalanceApi = TradeTypeCellVM()
                
                getbalanceApi.getUserBalance(completion: { result in
                    switch result {
                    case .success(let responseModel):
                        // Save the response model or use it as needed
                        print("Balance: \(responseModel.result.user.balance)")
                        print("Equity: \(responseModel.result.user.equity)")
                        
                        // Example: Storing in a singleton for global access
                        UserManager.shared.currentUser = responseModel.result.user
                        
                    case .failure(let error):
                        print("Failed to fetch balance: \(error.localizedDescription)")
                    }
                })
                
                
                getbalanceApi.getBalance(completion: { response in
                    print("response of get balance in HomeAccount vc : \(response)")
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
        //            setAccountsButton()
        dashboardDatainit()
    }
    
}
extension AccountsViewController: CreateAccountUpdateProtocol {
    func updateAccountBalance(isNewAccount: Bool) {
        let getbalanceApi = TradeTypeCellVM()
        
        getbalanceApi.getUserBalance(completion: { result in
            switch result {
            case .success(let responseModel):
                // Save the response model or use it as needed
                print("Balance: \(responseModel.result.user.balance)")
                print("Equity: \(responseModel.result.user.equity)")
                
                // Example: Storing in a singleton for global access
                UserManager.shared.currentUser = responseModel.result.user
             
                self.balance = "\(responseModel.result.user.balance)"
                GlobalVariable.instance.balanceUpdate = self.balance
                //                    NotificationCenter.default.post(name: .BalanceUpdate, object: nil,  userInfo: ["BalanceUpdateType": self.balance])
                NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: self.balance])
                
                NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.OPCUpdateConstant.key, dict: [NotificationObserver.Constants.OPCUpdateConstant.title: "Open"])
                
            case .failure(let error):
                print("Failed to fetch balance: \(error.localizedDescription)")
            }
        })
        
    }
    
    
}
extension AccountsViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Just reload the given tableview section.
    func refreshSection(at section: Int) {
        let indexSet = IndexSet(integer: section)
        tblView.reloadSections(indexSet, with: .none)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 //5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if emptyListCount != 0 { //TODO: If Open, Pending, Close is empty then section 2 (Total P/L) should be hide as well.
                return 0
            }
            return 1
        }else if section == 1 {
            switch opcList {
            case .open(let open):
                return open.count
            case .pending(let pending):
                return pending.count
            case .close(let close):
                
                return close.count
            case .none:
                return 0
            }
        } else {
            return emptyListCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: Total_PLCell.self, for: indexPath)
            //            cell.delegate = self
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.textLabel?.text = "Total P&L"
            cell.textLabel?.font = .boldSystemFont(ofSize: 16)
            cell.detailTextLabel?.text = "\(totalProfitOpenClose)".trimmedTrailingZeros()
            
            cell.textLabel?.textColor = UIColor(red: 126/255.0, green: 130/255.0, blue: 153/255.0, alpha: 1.0)
            
            if totalProfitOpenClose < 0.0 {
                cell.detailTextLabel?.textColor = .systemRed
            }else{
                cell.detailTextLabel?.textColor = .systemGreen
            }
            // Remove the existing border
            cell.layer.borderWidth = 0
            
            // Create a top border view
            let topBorder = CALayer()
            topBorder.borderColor = UIColor.black.cgColor
            topBorder.borderWidth = 3
            topBorder.frame = CGRect(x: 20, y: 0, width: cell.bounds.width - 40, height: 0.5)
            cell.layer.addSublayer(topBorder)
            
            return cell
            
        } else if indexPath.section == 1 {
            
            switch opcList {
            case .open(let openData):
                //                    cell.symbolName.text = openData[indexPath.row].symbol
                
                let cell = tableView.dequeueReusableCell(with: TransactionCell.self, for: indexPath)
                cell.selectionStyle = .none
                if GlobalVariable.instance.isAccountCreated {
                    cell.isHidden = false
                    
                    cell.getCellData(open: openData, indexPath: indexPath/*, trade: trade!, symbolDataObj: symbolDataObj*/)
                    
                }else{
                    cell.isHidden = true
                }
                return cell
                
            case .pending(let pendingData):
                
                let cell = tableView.dequeueReusableCell(with: PendingOrderCell.self, for: indexPath)
                cell.selectionStyle = .none
                if GlobalVariable.instance.isAccountCreated {
                    cell.isHidden = false
                    
                    cell.getCellData(pending: pendingData, indexPath: indexPath)
                    
                }else{
                    cell.isHidden = true
                }
                return cell
                
            case .close(let closeData):
                
                let cell = tableView.dequeueReusableCell(with: CloseOrderCell.self, for: indexPath)
                cell.selectionStyle = .none
                if GlobalVariable.instance.isAccountCreated {
                    cell.isHidden = false
                    
                    cell.getCellData(close: closeData, indexPath: indexPath)
                    
                }else{
                    cell.isHidden = true
                }
                return cell
                
            case .none:
                return UITableViewCell()
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(with: EmptyCell.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
//            cell.emptyLabelMessage.text = "No Position Data Found."
//            cell.lbl_secondMessage.text = ""
            
            switch opcList {
            case .open(let open):
                cell.emptyLabelMessage.text = "No Open Order."
                cell.lbl_secondMessage.text = "No orders Use the opportunity to trade on the world’s major financial markets"
            case .pending(let pending):
                cell.emptyLabelMessage.text = "No Pending Order."
                cell.lbl_secondMessage.text = "Use the oppottunity to trade on the word’s major financial markets"
            case .close(let close):
                cell.emptyLabelMessage.text = "No Close Order."
                cell.lbl_secondMessage.text = "for the last 30 days"
            case .none:
                cell.emptyLabelMessage.text = "No Data Found."
                cell.lbl_secondMessage.text = ""
            }
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 45
            
        }else if indexPath.section == 1{
            return 85.0
        } else {
            return 185.0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            switch opcList {
            case .open(let openData):
                
                let vc = Utilities.shared.getViewController(identifier: .openTicketBottomSheetVC, storyboardType: .bottomSheetPopups) as! OpenTicketBottomSheetVC
                
                vc.openData = openData[indexPath.row]
                vc.getIndex = indexPath
                
                PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customMedium, VC: vc)
                
                
                break
            case .pending(let pendingData):
                
                let vc = Utilities.shared.getViewController(identifier: .pendingTicketBottomSheetVC, storyboardType: .bottomSheetPopups) as! PendingTicketBottomSheetVC
                
                vc.pendingData = pendingData[indexPath.row]
                
                PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customMedium, VC: vc)
                
                break
            case .close(let closeData):
                
                let vc = Utilities.shared.getViewController(identifier: .closeTicketBottomSheetVC, storyboardType: .bottomSheetPopups) as! CloseTicketBottomSheetVC
                
                vc.closeData = closeData[indexPath.row]
                
                PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customSmall, VC: vc)
                
                break
            case .none: break
            }
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
//
//extension AccountsViewController: AccountInfoDelegate {
//    func accountInfoTap1(_ accountInfo: AccountInfo) {
//        print("delegte called  \(accountInfo)" )
//        
//        switch accountInfo {
//            
//        case .deposit:
//            
//            delegate?.accountInfoTap(.deposit)
//            break
//        case .withDraw:
//            
//            delegate?.accountInfoTap(.withDraw)
//            break
//        case .history:
//            
//            delegate?.accountInfoTap(.history)
//            break
//        case .detail:
//            
//            delegate?.accountInfoTap(.detail)
//            break
//        case .notification:
//            
//            delegate?.accountInfoTap(.notification)
//            break
//        case .createAccount:
//            delegate?.accountInfoTap(.createAccount)
//            break
//        }
//        
//        
//    }
//    
//    
//}

//extension AccountsViewController: CreateAccountInfoDelegate {
//    
//    func createAccountInfoTap1(_ createAccountInfo: CreateAccountInfo) {
//        print("delegte called  \(createAccountInfo)" )
//        
//        switch createAccountInfo {
//        case .createNew:
//            print("Create new")
//            let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .bottomSheetPopups) as! SelectAccountTypeVC
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customSmall, VC: vc)
//            
//            break
//        case .unarchive:
//            print("Unarchive")
//            let vc = Utilities.shared.getViewController(identifier: .unarchiveAccountTypeVC, storyboardType: .bottomSheetPopups) as! UnarchiveAccountTypeVC
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
//            break
//        case .notification:
//            let vc = Utilities.shared.getViewController(identifier: .notificationViewController, storyboardType: .bottomSheetPopups) as! NotificationViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//            break
//        }
//    }
//    
//}

extension AccountsViewController: OPCDelegate {
    func getOPCData(opcType: OPCType) {
        print("opcType = \(opcType)")
        
        self.opcList = opcType
        
        switch opcType {
        case .open(let open):
            
            if open.count == 0 {
                emptyListCount = 1
                
                NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
            } else {
                emptyListCount = 0
            }
            
        case .pending(let pending):
            
            if pending.count == 0 {
                emptyListCount = 1
            } else {
                emptyListCount = 0
            }
        case .close(let close):
            
            if close.count == 0 {
                emptyListCount = 1
            } else {
                emptyListCount = 0
            }
            
        }
        tblView.reloadData()
        
        //MARK: - START SOCKET and call delegate method to get data from socket.
        //        webSocketManager.delegateSocketMessage = self
        webSocketManager.delegateSocketPeerClosed = self
        
        //MARK: - unsubscribeTrade first.
        print("GlobalVariable.instance.previouseSymbolList = \(GlobalVariable.instance.previouseSymbolList)")
        //MARK: - START calling Socket message from here.
        webSocketManager.sendWebSocketMessage(for: "unsubscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList, isTradeDismiss: true)
        //MARK: - Remove symbol local after unsubcibe.
        GlobalVariable.instance.previouseSymbolList.removeAll()
        
        let symbolList = getFormattedSymbols(opcType: opcType)
        GlobalVariable.instance.previouseSymbolList = symbolList
        
        //MARK: - Merge OPEN list with the given list.
        let getList = Array(Set(GlobalVariable.instance.openSymbolList + symbolList)) //GlobalVariable.instance.openSymbolList + symbolList
        
        //MARK: - START calling Socket message from here.
        webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: getList)
        
        
    }
    
    private func getSymbol(item: String) -> String {
        
        var getSymbol = ""
        
        if item.contains("..") {
            getSymbol = String(item.dropLast())
            getSymbol = String(getSymbol.dropLast())
        } else if item.contains(".") {
            getSymbol = String(item.dropLast())
        } else {
            getSymbol = item
        }
        
        return getSymbol
        
    }
    
    func getFormattedSymbols(opcType: OPCType) -> [String] {
        
        switch opcList {
        case .open(let openData):
            
            self.getSymbolData.removeAll()
            GlobalVariable.instance.getSymbolData.removeAll()
            for item in openData {
                
                let getSymbol = getSymbol(item: item.symbol)
                
                self.getSymbolData.append(SymbolCompleteList(tickMessage: TradeDetails(datetime: 0, symbol: getSymbol, ask: 0.0, bid: 0.0, url: "", close: 0)))
                GlobalVariable.instance.getSymbolData.append(SymbolCompleteList(tickMessage: TradeDetails(datetime: 0, symbol: getSymbol, ask: 0.0, bid: 0.0, url: "", close: 0)))
            }
            //            let indexPath = IndexPath(row: 0, section: 2)
            let indexPath = IndexPath(row: 0, section: 0)
            if let totalCell = tblView.cellForRow(at: indexPath) as? Total_PLCell {
                totalCell.detailTextLabel?.isHidden = false
            }
            return openData.map { symbol in
                let symbol = symbol
                
                let getSymbol = getSymbol(item: symbol.symbol)
                
                return getSymbol
            }
            
        case .pending(let pendingData):
            
            self.getSymbolData.removeAll()
            for item in pendingData {
                
                let getSymbol = getSymbol(item: item.symbol)
                
                self.getSymbolData.append(SymbolCompleteList(tickMessage: TradeDetails(datetime: 0, symbol: getSymbol, ask: 0.0, bid: 0.0, url: "", close: 0)))
            }
            totalProfitOpenClose = 0.0
            //            let indexPath = IndexPath(row: 0, section: 2)
            let indexPath = IndexPath(row: 0, section: 0)
            if let totalCell = tblView.cellForRow(at: indexPath) as? Total_PLCell {
                totalCell.detailTextLabel?.isHidden = true
            }
            return pendingData.map { symbol in
                let symbol = symbol
                
                let getSymbol = getSymbol(item: symbol.symbol)
                
                return getSymbol
            }
            
        case .close(let closeData):
            
            self.getSymbolData.removeAll()
            for item in closeData {
                
                let getSymbol = getSymbol(item: item.symbol)
                
                self.getSymbolData.append(SymbolCompleteList(tickMessage: TradeDetails(datetime: 0, symbol: getSymbol, ask: 0.0, bid: 0.0, url: "", close: 0)))
                
            }
            totalProfitOpenClose = 0.0
            for i in 0..<closeData.count {
                
                let totalPL = closeData[i].totalProfit
                
                totalProfitOpenClose += totalPL
                
            }
            //            let indexPath = IndexPath(row: 0, section: 2)
            let indexPath = IndexPath(row: 0, section: 0)
            if let totalCell = tblView.cellForRow(at: indexPath) as? Total_PLCell {
                totalCell.detailTextLabel?.isHidden = false
                totalCell.detailTextLabel?.font = .boldSystemFont(ofSize: 16)
                totalCell.detailTextLabel?.text = "$" + String(format: "%.2f", totalProfitOpenClose)
                if totalProfitOpenClose < 0.0 {
                    totalCell.detailTextLabel?.textColor = .systemRed
                }else{
                    totalCell.detailTextLabel?.textColor = .systemGreen
                }
            }
            return closeData.map { symbol in
                var symbol = symbol
                
                var getSymbol = getSymbol(item: symbol.symbol)
                
                return getSymbol
            }
            
        case .none: return []
        }
        
    }
    
}

extension AccountsViewController: SocketPeerClosed {
    
    func peerClosed() {
        
        GlobalVariable.instance.changeSector = true
        
        //        setTradeModel(collectionViewIndex: GlobalVariable.instance.getSectorIndex)
        
    }
    
}

//MARK: - Get Socket Tick, History and Unsubcribe and update the list accordingly.
extension AccountsViewController: GetSocketMessages {
    
    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?) {
        switch socketMessageType {
        case .tick:
            
            //MARK: - Compare the symbol which is coming from Socket with our Selected Sector symbol list and update our list (getSymbolData).
            if let getTick = tickMessage {
                
                if let index = getSymbolData.firstIndex(where: { $0.tickMessage?.symbol == getTick.symbol }) {
                    getSymbolData[index].tickMessage = tickMessage
                    
                    //                           let indexPath = IndexPath(row: index, section: 2)
                    let indexPath = IndexPath(row: index, section: 0)
                    
                    switch opcList {
                    case .open(let openData):
                        
                        var _totalProfitOpenClose = totalProfitOpenClose
                        _totalProfitOpenClose = 0.0
                        var profitLoss = Double()
                        var roundValue = String()
                        //MARK: - Get All Matched Symbols data and Set accordingly.
                        if openData.count != 0 {
                            for i in 0...openData.count-1 {
                                
                                //                                   let myIndexPath = IndexPath(row: i, section: 3)
                                let myIndexPath = IndexPath(row: i, section: 1)
                                print("my current index \(myIndexPath)")
                                
                                
                                if let cell = tblView.cellForRow(at: myIndexPath) as? TransactionCell {
                                    if GlobalVariable.instance.isAccountCreated {
                                        cell.isHidden = false
                                        
                                        if cell.lbl_symbolName.text == openData[index].symbol && cell.volume == (Double(openData[myIndexPath.row].volume) / 10000) {
                                            let x =  openData[index].symbol.dropLast()
                                            if let contractValue = (GlobalVariable.instance.symbolDataArray.firstIndex(where: {$0.name == x })) {
                                                let symbolContractSize = GlobalVariable.instance.symbolDataArray[contractValue].contractSize
                                                
                                                let bid = getSymbolData[index].tickMessage?.bid ?? 0.0
                                                let priceOpen = Double(openData[myIndexPath.row].priceOpen)
                                                let volume = Double(openData[myIndexPath.row].volume) / 10000
                                                let contractSize = Double(symbolContractSize)!
                                                
                                                profitLoss = (bid - priceOpen) * volume * contractSize
                                                if openData[myIndexPath.row].action == 1 {
                                                    profitLoss = (priceOpen - bid) * volume * contractSize
                                                }else {
                                                    profitLoss = (bid - priceOpen) * volume * contractSize
                                                }
                                                
                                                //                                            profitLoss = (bid - priceOpen)  volume  contractSize
                                            }
                                            
                                            if profitLoss < 0.0 {
                                                cell.lbl_profitValue.textColor = .systemRed
                                                
                                            }else{
                                                cell.lbl_profitValue.textColor = .systemGreen
                                                
                                            }
                                            roundValue = String(format: "%.2f", profitLoss)
                                            
                                            cell.lbl_profitValue.text = "\(roundValue)"
                                            
                                            let bidValuess = getSymbolData[index].tickMessage?.bid ?? 0.0 //String(format: "%.2f", getSymbolData[index].tickMessage?.bid ?? 0.0)
                                            cell.lbl_currentPrice.text = "$\(bidValuess)"
                                        }
                                        
                                    }else{
                                        cell.isHidden = true
                                    }
                                }
                                
                            }
                        }
                        //MARK: - START Set Total P/L
                        
                        let totalProfitOpenClose = openData.enumerated().reduce(0.0) { (total, indexValue) -> Double in
                            let (index, item) = indexValue
                            //                                   let myIndexPath = IndexPath(row: index, section: 3)
                            let myIndexPath = IndexPath(row: index, section: 1)
                            
                            if let cell = tblView.cellForRow(at: myIndexPath) as? TransactionCell {
                                if GlobalVariable.instance.isAccountCreated {
                                    cell.isHidden = false
                                    
                                    // Safely unwrap the profit value
                                    let getProfit = Double(cell.lbl_profitValue.text ?? "") ?? 0.0
                                    print("getProfit \(index) = \(getProfit)")
                                    
                                    return total + getProfit
                                }
                            }
                            
                            return total
                        }
                        
                        print("Total Profit Open Close: \(totalProfitOpenClose)")
                        
                        //MARK: - END Set Total P/L
                        
                        
                        //                               let indexPath = IndexPath(row: 0, section: 2) // Adjust to the section and row where the total is displayed
                        let indexPath = IndexPath(row: 0, section: 0)
                        if let totalCell = tblView.cellForRow(at: indexPath) as? Total_PLCell {
                            totalCell.detailTextLabel?.isHidden = false
                            totalCell.detailTextLabel?.font = .boldSystemFont(ofSize: 16)
                            totalCell.detailTextLabel?.text = "$" + String(format: "%.2f", totalProfitOpenClose)
                            if totalProfitOpenClose < 0.0 {
                                totalCell.detailTextLabel?.textColor = .systemRed
                            }else{
                                totalCell.detailTextLabel?.textColor = .systemGreen
                            }
                        }
                        
                    case .pending(let pendingData):
                        
                        if let cell = tblView.cellForRow(at: indexPath) as? PendingOrderCell {
                            if GlobalVariable.instance.isAccountCreated {
                                cell.isHidden = false
                                
                            }else{
                                cell.isHidden = true
                            }
                        }
                        
                    case .close(let closeData):
                        
                        if let cell = tblView.cellForRow(at: indexPath) as? CloseOrderCell {
                            if GlobalVariable.instance.isAccountCreated {
                                cell.isHidden = false
                                
                            }else{
                                cell.isHidden = true
                            }
                        }
                        
                    case .none:break
                        
                    }
                    
                    return
                }
            }
            
            break
            
        case .Unsubscribed:
            
            //MARK: - Before change any sector we must unsubcribe already selected and then again update according to the new selected sector.
            
            GlobalVariable.instance.changeSector = true
            
            //            setTradeModel(collectionViewIndex: GlobalVariable.instance.getSectorIndex)
            
            if webSocketManager.isSocketConnected() {
                print("Socket is connected")
            } else {
                print("Socket is not connected")
                //MARK: - START SOCKET.
                //                webSocketManager.delegateSocketMessage = self
                webSocketManager.connectWebSocket()
            }
            
            break
        }
    }
}

//MARK: - START CollectionView work.
extension AccountsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //  return 10 // Number of items in the collection view
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TradeTypeCollectionViewCell", for: indexPath) as! TradeTypeCollectionViewCell
        
        //        cell.onRefreshImageButtonClick = {
        //            [self] sender in
        //            print("onRefreshImageButtonClick")
        //            self.dynamicDropDownButton(sender, list: refreshList) { index, item in
        //                print("drop down index = \(index)")
        //                print("drop down item = \(item)")
        //            }
        //        }
        
        cell.lbl_tradetype.text = model[indexPath.row]
        if indexPath.row == selectedIndex {
            cell.selectedColorView.isHidden = false
            cell.backgroundColor = .clear
            cell.layer.cornerRadius = 15.0
            cell.lbl_tradetype.textColor = .systemYellow
            cell.lbl_tradetype.font = UIFont.boldSystemFont(ofSize: 17)
        }else{
            cell.selectedColorView.isHidden = true
            cell.lbl_tradetype.textColor = UIColor(red: 161/255.0, green: 165/255.0, blue: 181/255.0, alpha: 1.0)
            cell.backgroundColor = .clear
            cell.lbl_tradetype.font = UIFont.systemFont(ofSize: 15)
        }
        if indexPath.row == model.count-1 {
            cell.sepratorView.isHidden = true
            cell.refreshImage.isHidden = true
            cell.refreshImageButton.isHidden = false
            cell.lbl_tradetype.isHidden = true
            
        } else {
            cell.sepratorView.isHidden = true
            cell.refreshImage.isHidden = true
            cell.refreshImageButton.isHidden = true
            cell.lbl_tradetype.isHidden = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath){
            selectedIndex = indexPath.row
            
            GlobalVariable.instance.lastSelectedOPCIndex = indexPath
            
            if indexPath.row != model.count-1 {
                fetchPositions(index: indexPath.row)
            }
            
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath){
            cell.backgroundColor = .clear
            //            self.delegate?.getOPCData(opcType: .open, opcModel: .init(symbol: "Gold"))
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //        let data = model[indexPath.row]
        //        return CGSize(width: data.count + 80, height: 40)
        
        let data = model[indexPath.row]
        
        // Get the screen width (for dynamic sizing based on device type)
        let screenWidth = UIScreen.main.bounds.width
        
        // For iPhone (portrait or landscape), use a smaller item size
        if GlobalVariable.instance.isIphone() { // iPhone typically has a screen width less than 768 points
            return CGSize(width: data.count + 80, height: 25)
        } else {
            //            // For iPad (larger screen), adjust the item size to fit more data
            //            // You can experiment with the values to suit your needs
            //            let itemWidth = (screenWidth - 40) / 4 // Adjust the number of items per row (e.g., 3 items per row)
            //            return CGSize(width: itemWidth, height: 40)
            
            // For iPad, we want all items in one row, so calculate width based on the total number of items
            
            let totalItems = data.count // Total number of items in the collection view
            let padding: CGFloat = 20 // Padding between items (adjust as needed)
            let totalPadding = Int(padding) * (totalItems + 1) // Total padding on both sides of items
            
            // Calculate the item width based on available screen width and padding
            let itemWidth = (screenWidth - CGFloat(totalPadding)) / CGFloat(totalItems)
            
            return CGSize(width: itemWidth, height: 40)
        }
        
    }
}

extension AccountsViewController {
    
    func fetchPositions(index: Int) {
        if index == 0 {
            
            // Execute the fetch on a background thread
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }
                
                self.vm.OPCApi(index: index) { openData, pendingData, closeData, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error fetching positions: \(error)")
                            // Handle the error (e.g., show an alert)
                        } else if let positions = openData {
                            //
                            GlobalVariable.instance.openSymbolList.removeAll()
                            
                            let symbols = positions.map { self.getSymbol(item: $0.symbol) }
                            GlobalVariable.instance.openSymbolList = symbols
                            
                            GlobalVariable.instance.openList = positions
                            self.delegateCollectionView?.getOPCData(opcType: .open(positions))
                            
                        }
                    }
                }
            }
            
        } else if index == 1 {
            
            // Execute the fetch on a background thread
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.vm.OPCApi(index: index) { openData, pendingData, closeData, error in
                    
                    // Switch back to the main thread to update the UI
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error fetching positions: \(error)")
                            // Handle the error (e.g., show an alert)
                        } else if let orders = pendingData {
                            self?.delegateCollectionView?.getOPCData(opcType: .pending(orders))
                        }
                    }
                }
            }
            
        } else if index == 2 {
            
            
            // Execute the fetch on a background thread
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.vm.OPCApi(index: index) { openData, pendingData, closeData, error in
                    
                    // Switch back to the main thread to update the UI
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error fetching positions: \(error)")
                            // Handle the error (e.g., show an alert)
                        } else if let orders = closeData {
                            
                            self?.delegateCollectionView?.getOPCData(opcType: .close(orders))
                        }
                    }
                }
            }
            
        }
    }
    
}

//MARK: - Main and final list which is change when the sector is set and all the symbols which is on the selected sector.
extension AccountsViewController {
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
}

//MARK: - AccountInfo Button Taps is here.
//extension AccountsViewController: AccountInfoTapDelegate {
//    func accountInfoTap(_ accountInfo: AccountInfo) {
//        print("delegte called  \(accountInfo)" )
//
//        switch accountInfo {
//
//        case .deposit:
//            let vc = Utilities.shared.getViewController(identifier: .depositViewController, storyboardType: .dashboard) as! DepositViewController
//            // vc.delegateCompeleteProfile = self
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//            break
//        case .withDraw:
//            //            let vc = Utilities.shared.getViewController(identifier: .withdrawViewController, storyboardType: .dashboard) as! WithdrawViewController
//            //            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//            break
//        case .history:
//            let vc = Utilities.shared.getViewController(identifier: .historyViewController, storyboardType: .dashboard) as! HistoryViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//            break
//        case .detail:
//            let vc = Utilities.shared.getViewController(identifier: .detailsViewController, storyboardType: .dashboard) as! DetailsViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//            break
//        case .notification:
//            let vc = Utilities.shared.getViewController(identifier: .notificationViewController, storyboardType: .dashboard) as! NotificationViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//            break
//        case .createAccount:
//            let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .bottomSheetPopups) as! SelectAccountTypeVC
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customSmall, VC: vc)
//            break
//        }
//    }
//}

//extension AccountsViewController: CreateAccountInfoTapDelegate {
//    
//    func createAccountInfoTap(_ createAccountInfo: CreateAccountInfo) {
//        print("delegte called  \(createAccountInfo)" )
//        
//        switch createAccountInfo {
//        case .createNew:
//            print("Create new")
//            let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .bottomSheetPopups) as! SelectAccountTypeVC
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customSmall, VC: vc)
//            
//            break
//        case .unarchive:
//            print("Unarchive")
//            let vc = Utilities.shared.getViewController(identifier: .unarchiveAccountTypeVC, storyboardType: .bottomSheetPopups) as! UnarchiveAccountTypeVC
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
//            break
//        case .notification:
//            let vc = Utilities.shared.getViewController(identifier: .notificationViewController, storyboardType: .bottomSheetPopups) as! NotificationViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//            break
//        }
//    }
//    
//}

extension AccountsViewController: OPCNavigationDelegate {
    
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
extension UIView {
    func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        
        // Define the colors of the gradient
        gradientLayer.colors = [
            UIColor(red: 20/255, green: 0, blue: 40/255, alpha: 1).cgColor, // start color (dark purple)
            UIColor.black.cgColor               // end color
            
        ]
        
        // Define the gradient direction (top to bottom)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.layer.cornerRadius
        
        // Insert the gradient below all other sublayers
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
