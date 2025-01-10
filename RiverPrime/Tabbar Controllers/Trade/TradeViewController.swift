
//
//  TradeViewController.swift
//  RiverPrime
//
//  Created by Ross on 13/07/2024.
//

import UIKit
import Starscream
import Alamofire
import Foundation

protocol TradeInfoTapDelegate: AnyObject {
    func tradeInfoTap(_ tradeInfo: SectorGroup, index: Int)
}

struct TradeInfo {
    var name = String()
}

protocol TradeDetailTapDelegate: AnyObject {
    func tradeDetailTap(indexPath: IndexPath, getSymbolData: SymbolCompleteList)
}

struct SymbolCompleteList {
    var tickMessage: TradeDetails?
    var yesterday_close: String?
    var trading_sessions_ids: [Int]?
    var historyMessage: SymbolChartData?
    var icon_url: String?
    var isTickFlag: Bool?
    var isHistoryFlag: Bool?
    var isHistoryFlagTimer: Bool?
}

struct SymbolData: Codable {
    let id: String
    let name: String
    let description: String
    let icon_url: String
    let volumeMin: String
    let volumeMax: String
    let volumeStep: String
    let contractSize: String
    let displayName: String
    let sector: String
    let digits: String
    let stopsLevel: String
    let swapLong: String
    let swapShort: String
    let spreadSize: String
    let mobile_available: String
    let yesterday_close: String
    let is_mobile_favorite: Bool
    let trading_sessions_ids: [Int]
    
    init(id: String, name: String, description: String, icon_url: String, volumeMin: String, volumeMax: String, volumeStep: String, contractSize: String, displayName: String, sector: String, digits: String, stopsLevel: String, swapLong: String, swapShort: String, spreadSize: String, mobile_available: String, yesterday_close: String,is_mobile_favorite:Bool,trading_sessions_ids: [Int] ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon_url = icon_url
        self.volumeMin = volumeMin
        self.volumeMax = volumeMax
        self.volumeStep = volumeStep
        self.contractSize = contractSize
        self.displayName = displayName
        self.sector = sector
        self.digits = digits
        self.spreadSize = spreadSize
        self.swapLong = swapLong
        self.swapShort = swapShort
        self.stopsLevel = stopsLevel
        self.mobile_available = mobile_available
        self.yesterday_close = yesterday_close
        self.is_mobile_favorite = is_mobile_favorite
        self.trading_sessions_ids = trading_sessions_ids
    }
    
}

struct SectorGroup {
    let sector: String
    let symbols: [SymbolData]
}

class TradeViewController: BaseViewController {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var tblSearchView: UITableView!
    
    weak var delegate: TradeInfoTapDelegate?
    weak var delegateDetail: TradeDetailTapDelegate?
    
    let vm = TradeVM()
    
    var getSymbolData = [SymbolCompleteList]()
    var focusedSymbols = ["EURUSD", "GBPUSD", "CHFUSD", "USDJPY", "Gold", "Silver", "DJ130", "BRENT"]
    
    var searchSectorData = ["Currency", "Commodities", "Energy", "Indices"]
    var symbolDataSectorSelected = false
    var showEmptySearch = false
    //    var symbolDataSectorSelectedIndex = Int()
    //    var selectedSectorGroup: SectorGroup? = nil
    
    var timer: Timer?
    var timeLeft = 60 // seconds
    var isTimerRunMoreThenOnce = false
    var symbolDataObj: SymbolData?
    
    @IBOutlet weak var labelAmmount: UILabel!
    
    @IBOutlet weak var lbl_account: UILabel!
    @IBOutlet weak var lbl_accountType: UILabel!
    
    @IBOutlet weak var tf_searchSymbol: UITextField!
    @IBOutlet weak var searchCloseButton: UIButton!
    
    weak var delegateCollectionView: TradeInfoTapDelegate?
    var symbolDataSector: [SectorGroup] = []
    var filteredData: [SectorGroup] = []
    
    var getSectorData: [SectorGroup] {
        return filteredData.isEmpty ? symbolDataSector : filteredData
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tf_searchSymbol.attributedPlaceholder = NSAttributedString(
            string: "Search symbol here",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        dashboardinit()
        GlobalVariable.instance.lastSelectedSectorIndex = IndexPath(row: 0, section: 0)
        
        GlobalVariable.instance.controllerName = "TradeVC"
        NotificationCenter.default.addObserver(self, selector: #selector(self.FaceAfterLoginUpdate(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.FaceAfterLoginConstant.key), object: nil)
        if GlobalVariable.instance.isAppStartAfterLogin {
            GlobalVariable.instance.isAppStartAfterLogin = false
                    
            NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.FaceAfterLoginConstant.key, dict: [NotificationObserver.Constants.FaceAfterLoginConstant.title: GlobalVariable.instance.controllerName])
                    
        }
        
    }
    
    @objc private func FaceAfterLoginUpdate(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let receivedString = userInfo[NotificationObserver.Constants.FaceAfterLoginConstant.title] as? String {
            print("Received string: \(receivedString)")
            
            if receivedString == "TradeVC" {
                let faceIdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! PasscodeFaceIDVC
                faceIdVC.afterLoginNavigation = true
                self.navigate(to: faceIdVC)
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
        
        accountData()
        //        self.searchCloseButton.isHidden = true
        self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        self.searchCloseButton.setTitle("", for: .normal)
        
        self.tblSearchView.isHidden = true
        self.tblView.isHidden = false
        
        self.tf_searchSymbol.delegate = self
        // Add a target to update search on text change
        self.tf_searchSymbol.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        
        if let tabBarController = self.tabBarController as? HomeTabbarViewController {
            tabBarController.delegateSocketMessage = self
            tabBarController.delegateSocketNotSendData = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationTradeApiUpdate(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.TradeApiUpdateConstant.key), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.MetaTraderLogin(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.MetaTraderLoginConstant.key), object: nil)
        
       
        callCollectionViewAtStart()
        
    }
    
    @IBAction func alaramBtnAction(_ sender: Any) {
        Alert.showAlert(withMessage: "Alarm Screen available soon", andTitle: "Alarm", on: self)
    }
    
    @IBAction func notificationBtnAction(_ sender: Any) {
        Alert.showAlert(withMessage: "Notification Screen available soon", andTitle: "Notification", on: self)
    }
    
    @IBAction func searchCloseButton(_ sender: UIButton) {
            
            if let currentImage = self.searchCloseButton.image(for: .normal),
               currentImage.isEqual(UIImage(systemName: "magnifyingglass")) {
                print("The button image is magnifyingglass.")
                symbolDataSector.removeAll()
                //MARK: - Set all sectors by default.
                symbolDataSector = GlobalVariable.instance.sectors
                filteredData = []
                showEmptySearch = false
                tblView.isHidden = true
                tblSearchView.isHidden = false
                self.searchCloseButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
                tblSearchView.delegate = self
                tblSearchView.dataSource = self
                tblSearchView.reloadData()
            }else{
                
                symbolDataSector.removeAll()
                //MARK: - Set all sectors by default.
                symbolDataSector = GlobalVariable.instance.sectors
                //        self.symbolDataSectorSelected = false
                filteredData = []
                showEmptySearch = false
                self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
                self.tblView.isHidden = false
                self.tblSearchView.isHidden = true
                self.tf_searchSymbol.text = ""
                self.tf_searchSymbol.resignFirstResponder()
                
            }
            
           
        
    }
    
    private func callCollectionViewAtStart() {
        
        let indexPath = GlobalVariable.instance.lastSelectedSectorIndex //IndexPath(row: 0, section: 0)
        
        //        if tradeTVCCollectionView.cellForItem(at: indexPath) != nil {
        //            // Scroll to the selected item
        //            tradeTVCCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        //
        //            let data = symbolDataSector[indexPath.row]
        //            selectedIndex = indexPath.row
        //            self.delegate?.tradeInfoTap(data, index: indexPath.row)
        //            tradeTVCCollectionView.reloadData()
        //        }
        
    }
    
    @objc func notificationTradeApiUpdate(_ notification: NSNotification) {
        
        if let update = notification.userInfo?[NotificationObserver.Constants.TradeApiUpdateConstant.title] as? String {
            print("update: \(update)")
            
            if update == "TradeApiUpdate" {
                
                vm.webSocketManager.delegateSocketPeerClosed = self
                
                isTimerRunMoreThenOnce = false
                
                tblView.registerCells([
                    /*AccountTableViewCell.self,TradeTVC.self, */TradeTableViewCell.self
                ])
                
                tblView.delegate = self
                tblView.dataSource = self
                
                tblSearchView.registerCells([
                    SearchTableViewCell.self
                ])
                
                tblSearchView.delegate = self
                tblSearchView.dataSource = self
                
                //MARK: - if Symbol Api data is exist then we must set our list data.
                if GlobalVariable.instance.symbolDataArray.count != 0 {
                    
                    //MARK: - This Check is handle for Offline data.
                    if !GlobalVariable.instance.socketNotSendData {
                        
                        GlobalVariable.instance.symbolDataUpdatedList = GlobalVariable.instance.symbolDataArray
                        
                        symbolDataSector = GlobalVariable.instance.sectors
                        
                        //MARK: - Get the list and save localy and set sectors and symbols.
                        processSymbols(GlobalVariable.instance.symbolDataArray)
                        
                        //MARK: - Reload tablview when all data set into the list at first time.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.tblView.delegate = self
                            self.tblView.dataSource = self
                            self.tblView.reloadData()
                        }
                        
                    }
                    
                }
                
                delegate = self
                config(GlobalVariable.instance.sectors)
                
                delegateDetail = self
                
                accountData()
            }
        }
    }
    
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
                    print("response of get balance in trade Vc: \(response)")
                    if response == "Invalid Response" {
//                        self.balance = "0.0"
                        return
                    }
//                    self.balance = response
//                    GlobalVariable.instance.balanceUpdate = self.balance
                    GlobalVariable.instance.balanceUpdate = response
//                    NotificationCenter.default.post(name: .BalanceUpdate, object: nil,  userInfo: ["BalanceUpdateType": self.balance])
                    NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
                 
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
    
    private func dashboardinit() {
        
        //MARK: - START Update Change.
        accountData()
        
        let getbalanceApi = TradeTypeCellVM()
        getbalanceApi.getUserBalance(completion: { result in
            switch result {
            case .success(let responseModel):
                // Save the response model or use it as needed
                print("Balance: \(responseModel.result.user.balance)")
                print("Equity: \(responseModel.result.user.equity)")
                self.labelAmmount.text = "$\(responseModel.result.user.balance)"
                // Example: Storing in a singleton for global access
                UserManager.shared.currentUser = responseModel.result.user
                
                GlobalVariable.instance.balanceUpdate = "\(responseModel.result.user.balance)" //self.balance
                print("GlobalVariable.instance.balanceUpdate = \(GlobalVariable.instance.balanceUpdate)")
                NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
                
                NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.OPCUpdateConstant.key, dict: [NotificationObserver.Constants.OPCUpdateConstant.title: "Open"])
                
            case .failure(let error):
                print("Failed to fetch balance: \(error.localizedDescription)")
            }
        })
        
//        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
//            print("saved User Data: \(savedUserData)")
            // Access specific values from the dictionary
            
//            
//            //MARK: - START Update Change.
//            let getbalanceApi = TradeTypeCellVM()
//            getbalanceApi.getUserBalance(completion: { result in
//                switch result {
//                case .success(let responseModel):
//                    // Save the response model or use it as needed
//                    print("Balance: \(responseModel.result.user.balance)")
//                    print("Equity: \(responseModel.result.user.equity)")
//                    self.labelAmmount.text = "$\(responseModel.result.user.balance)"
//                    // Example: Storing in a singleton for global access
//                    UserManager.shared.currentUser = responseModel.result.user
//                    
//                    GlobalVariable.instance.balanceUpdate = "\(responseModel.result.user.balance)" //self.balance
//                    print("GlobalVariable.instance.balanceUpdate = \(GlobalVariable.instance.balanceUpdate)")
//                    NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
//                    
//                    NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.OPCUpdateConstant.key, dict: [NotificationObserver.Constants.OPCUpdateConstant.title: "Open"])
//                    
//                case .failure(let error):
//                    print("Failed to fetch balance: \(error.localizedDescription)")
//                }
//            })
            
//            if let profileStep1 = savedUserData["profileStep"] as? Int, let isCreateDemoAccount = savedUserData["demoAccountCreated"] as? Bool {
//                //                profileStep = profileStep1
//                GlobalVariable.instance.isAccountCreated = isCreateDemoAccount
//
//                let password = UserDefaults.standard.string(forKey: "password")
//                if password == nil && isCreateDemoAccount == true {
//                    showPopup()
//                }else{
//                    print("the password is: \(password ?? "")")
//
//                    let getbalanceApi = TradeTypeCellVM()
//                    getbalanceApi.getUserBalance(completion: { result in
//                        switch result {
//                        case .success(let responseModel):
//                            // Save the response model or use it as needed
//                            print("Balance: \(responseModel.result.user.balance)")
//                            print("Equity: \(responseModel.result.user.equity)")
//
//                            // Example: Storing in a singleton for global access
//                            UserManager.shared.currentUser = responseModel.result.user
//
//                        case .failure(let error):
//                            print("Failed to fetch balance: \(error.localizedDescription)")
//                        }
//                    })
//
//                    getbalanceApi.getBalance(completion: { response in
//                        print("response of get balance: \(response)")
//                        if response == "Invalid Response" {
//                            //                            self.balance = "0.0"
//                            return
//                        }
//                        //                        self.balance = response
//                        GlobalVariable.instance.balanceUpdate = response //self.balance
//                        print("GlobalVariable.instance.balanceUpdate = \(GlobalVariable.instance.balanceUpdate)")
//                        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
//
//                        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.OPCUpdateConstant.key, dict: [NotificationObserver.Constants.OPCUpdateConstant.title: "Open"])
//
//                    })
//                }
//            }
            //MARK: - END Update Change.
//        }
    }
    
    @objc func notificationPopup(_ notification: NSNotification) {
        
        if let ammount = notification.userInfo?[NotificationObserver.Constants.BalanceUpdateConstant.title] as? String {
            print("Received ammount: \(ammount)")
            self.labelAmmount.text = "$\(ammount)"
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
    }
    
    func accountData() {
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            self.lbl_accountType.text = defaultAccount.groupName
            lbl_account.text = defaultAccount.isReal == true ? "Real" : "Demo"
        }
       
    }
    
    func config(_ symbolData: [SectorGroup]){
        self.symbolDataSector = symbolData
        //        self.tradeTVCCollectionView.reloadData()
    }
}

extension TradeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tblView.isHidden == false {
            return 1
        } else {
            if showEmptySearch {
                return 0
            }
            //            if !filteredData.isEmpty {
            if symbolDataSectorSelected {
                return getSectorData.count
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !tblView.isHidden {
            return getSymbolData.count
        } else {
            if showEmptySearch {
                return 0
            }
            //            if !filteredData.isEmpty {
            if symbolDataSectorSelected {
                return getSectorData[section].symbols.count
            } else {
                return getSectorData.count
            }
        }
        //        return getSymbolData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.keyboardDismissMode = .onDrag
        
        if !tblView.isHidden {
            
            // Register the nib for the table view cell
            let nib = UINib(nibName: "TradeTableViewCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "TradeTableViewCell")
            
            
            let cell = tableView.dequeueReusableCell(with: TradeTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            //MARK: - getSymbolData list is comming from symbol api.
            let trade = getSymbolData[indexPath.row].tickMessage
            
            //MARK: - Get selected sector value and compare with repeated sector values and show the list of symbols with in this sector.
            if let obj = GlobalVariable.instance.symbolDataArray.first(where: {$0.name == trade?.symbol}) {
                symbolDataObj = obj
            }
            
            //MARK: - Showing the list of Symbols according to the selected sector in else statement.
            cell.configure(with: trade! , symbolDataObj: symbolDataObj)
            
            // Disable interaction for specific cells
            if !(getSymbolData[indexPath.row].isTickFlag ?? false) { //MARK: - User Interface disabled, when tick flag is false.
                cell.isUserInteractionEnabled = false
                cell.contentView.alpha = 0.5 // Visual cue that the cell is disabled
                // No selection effect
            } else {
                cell.isUserInteractionEnabled = true
                cell.contentView.alpha = 1.0
            }
            
            return cell
            
        } else {
            
            // Register the nib for the table view cell
            let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "SearchTableViewCell")
            
            
            let cell = tableView.dequeueReusableCell(with: SearchTableViewCell.self, for: indexPath)
            
            //            if !filteredData.isEmpty {
            if symbolDataSectorSelected {
                //                symbolDataSectorSelected = false
                let data = getSectorData[indexPath.section]
                
                cell.textLabel?.text = data.symbols[indexPath.row].name
                cell.detailTextLabel?.text = data.symbols[indexPath.row].description
            } else {
                let data = getSectorData[indexPath.row]
                
                cell.textLabel?.text = data.sector
                cell.detailTextLabel?.text = ""
            }
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tblView.isHidden {
            
            //MARK: - When we click on the symbol list index then it should move and show history data into the detail page.
            let getSymbolData = getSymbolData[indexPath.row]
            if getSymbolData.historyMessage?.chartData.count != 0 {
                delegateDetail?.tradeDetailTap(indexPath: indexPath, getSymbolData: getSymbolData)
            }
            
        } else {
            
            //            if !filteredData.isEmpty {
            if symbolDataSectorSelected {
                
                // Ensure we update the table view on the main thread
                DispatchQueue.main.async { [self] in
                    
                    let item = getSectorData[indexPath.section].symbols[indexPath.row]
                    
                    // Check if the symbol already exists
                    if getSymbolData.contains(where: { $0.tickMessage?.symbol == item.name }) {
                        Alert.showAlert(withMessage: "Symbol is already exist.", andTitle: item.name, on: self)
                        return
                    }
                    
                    filteredData = []
                    showEmptySearch = false
                    symbolDataSectorSelected = false
                    tblView.isHidden = false
                    tblSearchView.isHidden = true
                    tf_searchSymbol.text = ""
                    tf_searchSymbol.resignFirstResponder()
                    self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
                    
                    let tradedetail = TradeDetails(datetime: 0, symbol: item.name, ask: 0.0, bid: 0.0, url: item.icon_url, close: nil)
                    let symbolChartData = SymbolChartData(symbol: item.name, chartData: [])
                    getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, trading_sessions_ids: item.trading_sessions_ids, historyMessage: symbolChartData, icon_url: item.icon_url, isTickFlag: false, isHistoryFlag: false, isHistoryFlagTimer: false))
                    //                    getSymbolData.insert((SymbolCompleteList(tickMessage: tradedetail, historyMessage: symbolChartData, icon_url: item.icon_url, isTickFlag: false, isHistoryFlag: false, isHistoryFlagTimer: false)), at: getSymbolData.count)
                    
                    GlobalVariable.instance.symbolDataUpdatedList.append(item)
                    
                    GlobalVariable.instance.previouseSymbolList.append(item.name)
                    
                    tblSearchView.delegate = nil
                    tblSearchView.dataSource = nil
                    
                    let newIndexPath = IndexPath(row: getSymbolData.count - 1, section: 0)
                    tblView.insertRows(at: [newIndexPath], with: .automatic)
                    
                    //MARK: - START calling Socket message from here.
                    vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbol: item.name)
                    
                }
                //                tblView.reloadData()
                
            } else {
                self.tf_searchSymbol.resignFirstResponder()
                getTradeSector(collectionViewIndex: indexPath.row)
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !tblView.isHidden {
            return 80.0
        } else {
            return 50.0
        }
    }
    
    // MARK: - Table View Delegate (Delete Action)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if !tblView.isHidden {
            if editingStyle == .delete {
                // Ensure we update the table view on the main thread
                DispatchQueue.main.async { [self] in
                    var getDeletedSymbol = getSymbolData[indexPath.row].tickMessage?.symbol ?? ""
                    
                    //MARK: - START calling Socket message from here.
                    vm.webSocketManager.sendWebSocketMessage(for: "unsubscribeTrade", symbolList: [getDeletedSymbol])
                    
                    GlobalVariable.instance.previouseSymbolList.remove(at: indexPath.row)
                    // Remove the item from the data source
                    getSymbolData.remove(at: indexPath.row)
                    
                    filteredData = []
                    showEmptySearch = false
                    symbolDataSectorSelected = false
                    tblView.isHidden = false
                    tblSearchView.isHidden = true
                    tf_searchSymbol.text = ""
                    tf_searchSymbol.resignFirstResponder()
                    self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
                    
                    if GlobalVariable.instance.symbolDataUpdatedList.count != 0 {
                        for i in 0...GlobalVariable.instance.symbolDataUpdatedList.count-1 {
                            if GlobalVariable.instance.symbolDataUpdatedList[i].name == getDeletedSymbol {
                                GlobalVariable.instance.symbolDataUpdatedList.remove(at: i)
                                break
                            }
                        }
                    }
                    
                    // Animate the deletion of the row
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    //MARK: - Just reload the given tableview section.
    func refreshSection(at section: Int) {
        let indexSet = IndexSet(integer: section)
        tblView.reloadSections(indexSet, with: .automatic)
        
    }
    
}

extension TradeViewController: SocketPeerClosed {
    
    func peerClosed() {
        
        GlobalVariable.instance.changeSector = true
        
        ////        getSymbolData.removeAll()
        //
        //        setTradeModel()
    }
}

extension TradeViewController {
    
    private func fetchHistoryChartData(_ symbol: String) {
        
        vm.fetchChartHistory(symbol: symbol) { result in
            switch result {
            case .success(let responseData):
                
                if let index = self.getSymbolData.firstIndex(where: { $0.tickMessage?.symbol == responseData.symbol }) {
                    self.getSymbolData[index].historyMessage = responseData
                    
                    let indexPath = IndexPath(row: index, section: 0)
                    if let cell = self.tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
                        
                        GlobalVariable.instance.isProcessingSymbolTimer = false
                    }
                    return
                }
                
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
    }
    
}

//MARK: - This Func is handle for Offline data.
extension TradeViewController: SocketNotSendDataDelegate {
    
    func socketNotSendData() {
        
        getSymbolData.removeAll()
        
        self.focusedSymbols.removeAll()
        let filterfavoriteSymbols = GlobalVariable.instance.symbolDataArray.filter { $0.is_mobile_favorite }
        
        self.focusedSymbols = filterfavoriteSymbols.map { $0.name }
        
        // Combined filtered data and names
        var filteredSymbolsData: (data: [SymbolData], names: [String]) {
            //            let filtered = GlobalVariable.instance.symbolDataArray.filter { focusedSymbols.contains($0.name) }
            let filtered = GlobalVariable.instance.symbolDataUpdatedList.filter { focusedSymbols.contains($0.name) }
            let names = filtered.map { $0.name }
            return (data: filtered, names: names)
        }
        
        for item in filteredSymbolsData.data {
            let tradedetail = TradeDetails(datetime: 0, symbol: item.name, ask: Double(item.yesterday_close) ?? 0.0, bid: Double(item.yesterday_close) ?? 0.0, url: item.icon_url, close: nil)
            let symbolChartData = SymbolChartData(symbol: item.name, chartData: [])
            getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, yesterday_close: item.yesterday_close, trading_sessions_ids: item.trading_sessions_ids, historyMessage: symbolChartData, icon_url: item.icon_url, isTickFlag: true, isHistoryFlag: true, isHistoryFlagTimer: true))
        }
        
        GlobalVariable.instance.isProcessingSymbol = false
        
        //MARK: - Save symbol local to unsubcibe.
        GlobalVariable.instance.previouseSymbolList = filteredSymbolsData.names
        
        //MARK: - Merge OPEN list with the given list.
        let getList = Array(Set(GlobalVariable.instance.openSymbolList + filteredSymbolsData.names))
        
        //MARK: - START calling Socket message from here.
        vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: getList)
        
        timer?.invalidate()
        timer = nil
        GlobalVariable.instance.isProcessingSymbolTimer = false
        start60SecondsCountdown()
        
        
        
        
        
        if getSymbolData.count == 0 {
            return
        }
        
        for i in 0...getSymbolData.count-1 {
            
            //MARK: - If tick flag is true then we just update the label only not reload the tableview.
            let indexPath = IndexPath(row: i, section: 0)
            if let cell = tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
                getSymbolData[i].isTickFlag = true
                
                getSymbolData[i].isHistoryFlag = true
                fetchHistoryChartData(getSymbolData[i].tickMessage?.symbol ?? "")
                
                print("getSymbolData[\(i)].yesterday_close = \(getSymbolData[i].yesterday_close ?? "0.0")")
                cell.setStyledLabel(value: Double(getSymbolData[i].yesterday_close ?? "0.0") ?? 0.0, digit: cell.digits ?? 0, label: cell.lbl_bidAmount)
                cell.setStyledLabel(value: Double(getSymbolData[i].yesterday_close ?? "0.0") ?? 0.0, digit: cell.digits ?? 0, label: cell.lbl_askAmount)
              
                let pipsValues = cell.calculatePips(ask: Double(getSymbolData[i].yesterday_close ?? "0.0") ?? 0.0, bid: Double(getSymbolData[i].yesterday_close ?? "0.0") ?? 0.0, digits: cell.digits ?? 0)
                cell.lbl_pipsValues.text = "\(pipsValues)"
                cell.lblPercent.text = "0%"
                    //MARK: - User Interface enabled, when tick flag is true.
                    cell.isUserInteractionEnabled = true
                    cell.contentView.alpha = 1.0
                
                GlobalVariable.instance.socketNotSendData = true
                    
                }
            
        }
        
    }
    
}

//MARK: - Get Socket Tick, History and Unsubcribe and update the list accordingly.
extension TradeViewController: GetSocketMessages {
    
    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?) {
        switch socketMessageType {
        case .tick:
            
            //MARK: - Compare the symbol which is coming from Socket with our Selected Sector symbol list and update our list (getSymbolData).
            if let getTick = tickMessage {
                if let index = getSymbolData.firstIndex(where: { $0.tickMessage?.symbol == getTick.symbol }) {
                    getSymbolData[index].tickMessage = tickMessage
                    
                    if let flag = getSymbolData[index].isHistoryFlag {
                        if !flag {
                            getSymbolData[index].isHistoryFlag = true
                            
                            fetchHistoryChartData(getTick.symbol)
                            
                        } else {
                            if !GlobalVariable.instance.isProcessingSymbol {
                                GlobalVariable.instance.isProcessingSymbol = true
                                start60SecondsCountdown()
                            } else {
                                if let flagTimer = getSymbolData[index].isHistoryFlagTimer {
                                    if !flagTimer && !GlobalVariable.instance.isProcessingSymbolTimer {
                                        if isTimerRunMoreThenOnce {
                                            getSymbolData[index].isHistoryFlag = true
                                            GlobalVariable.instance.isProcessingSymbolTimer = true
                                            getSymbolData[index].isHistoryFlagTimer = true
                                            
                                            fetchHistoryChartData(getTick.symbol)
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    //MARK: - If tick flag is true then we just update the label only not reload the tableview.
                    let indexPath = IndexPath(row: index, section: 0)
                    if let cell = tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
                        getSymbolData[index].isTickFlag = true
                        cell.setStyledLabel(value: getSymbolData[index].tickMessage?.bid ?? 0.0, digit: cell.digits ?? 0, label: cell.lbl_bidAmount)
                        cell.setStyledLabel(value: getSymbolData[index].tickMessage?.ask ?? 0.0, digit: cell.digits ?? 0, label: cell.lbl_askAmount)
                        
                        let pipsValues = cell.calculatePips(ask: getSymbolData[index].tickMessage?.ask ?? 0.0, bid: getSymbolData[index].tickMessage?.bid ?? 0.0, digits: cell.digits ?? 0)
                        cell.lbl_pipsValues.text = "\(pipsValues)"
                        
                        if let timestamp = getSymbolData[index].tickMessage?.datetime {
                            print("Raw UNIX Timestamp: \(timestamp)") // Debugging
                            print("System Time Zone: \(TimeZone.current)")
                            // Step 1: Convert UNIX timestamp (seconds) to Date
                            let createDate = Date(timeIntervalSince1970: Double(timestamp))
                            print("Converted Date: \(createDate)") // Debugging
                       
                            let adjustedDate = createDate.addingTimeInterval(-2 * 3600)
                                print("Adjusted Date (After subtracting 2 hours): \(adjustedDate)")
                            // Step 2: Format the Date into local time
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "HH:mm:ss" // Desired time format
                            dateFormatter.locale = Locale(identifier: "en_GB") //  en_GB for 24 hours en_US for 12 hours
                            dateFormatter.timeZone =  .current //TimeZone(identifier: "Asia/Dubai")   // Use local time zone (UTC+4, etc.)

                            let localTimeString = dateFormatter.string(from: adjustedDate)
                            print("Formatted Local Time: \(localTimeString)") // Debugging

                            // Step 3: Assign the formatted time to the label
                            cell.lbl_datetime.text = localTimeString
                        } else {
                            print("Missing or Invalid Timestamp")
                            cell.lbl_datetime.text = "Invalid Date"
                        }
                            
//                            let createDate = Date(timeIntervalSince1970: Double(getSymbolData[index].tickMessage?.datetime ?? 0))
//
//                            let dateFormatter = DateFormatter()
//                            dateFormatter.dateFormat = "HH:mm:ss"
//                            dateFormatter.timeZone = .current
//
//                            let datee = dateFormatter.string(from: createDate)
                            
                            //                        cell.lbl_datetime.text = datee
                            
                            let bid = getSymbolData[index].tickMessage?.bid ?? 0.0
                            var oldBid =  Double()
                            
                            if cell.lblCurrencySymbl.text == tickMessage?.symbol {
                                let yesterdayClose_value = GlobalVariable.instance.symbolDataArray.filter { $0.name == getSymbolData[index].tickMessage?.symbol }.map { $0.yesterday_close }
                                print("symbolyesterday_close = \(yesterdayClose_value)")
                                oldBid = Double(yesterdayClose_value[0]) ?? 0.0
                            }
                            
                            let diff = bid - oldBid
                            let percentageChange = (diff / oldBid) * 100
                            let newValue = (percentageChange * 100.0) / 100.0
                            let percent = String(newValue).trimmedTrailingZeros()
                            
//                            print("\n new value is: \(newValue) \n the different in points: \(diff)")
                            
                            let pointsValues = cell.calculatePointDifferencePips(currentBid: (getSymbolData[index].tickMessage?.bid ?? 0.0), lastCloseBid: oldBid, decimalPrecision: cell.digits ?? 0)
                            
                            cell.lblPercent.text = "\(percent)%"
                            
                            if percent.contains("inf") {
                                cell.lblPercent.text = "0.0%"
                            }
                            
                            if newValue > 0.0 {
                                cell.profitIcon.image = UIImage(systemName: "arrow.up")
                                cell.profitIcon.tintColor = .systemGreen
                                cell.lblPercent.textColor = .systemGreen
                                
                                cell.lbl_pointsDiff.text = "+\(pointsValues)"
                                
                            } else {
                                cell.profitIcon.image = UIImage(systemName: "arrow.down")
                                cell.profitIcon.tintColor = .systemRed
                                cell.lblPercent.textColor = .systemRed
                                
                                cell.lbl_pointsDiff.text = "-\(pointsValues)"
                            }
                            
                            //MARK: - User Interface enabled, when tick flag is true.
                            cell.isUserInteractionEnabled = true
                            cell.contentView.alpha = 1.0
                            
                        }
                        
                        return
                    }
                }
                
                break
                
            case .Unsubscribed:
                
                //MARK: - Before change any sector we must unsubcribe already selected and then again update according to the new selected sector.
                
                GlobalVariable.instance.changeSector = true
                
                if GlobalVariable.instance.previouseSymbolList.count == 0 {
                    //MARK: - Merge OPEN list with the given list.
                    let getList = Array(Set(GlobalVariable.instance.openSymbolList))
                    
                    //MARK: - Save symbol local to unsubcibe.
                    GlobalVariable.instance.previouseSymbolList = getList
                    
                    //MARK: - START calling Socket message from here.
                    vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: getList)
                }
                
                
                
                
                if vm.webSocketManager.isSocketConnected() {
                    print("Socket is connected")
                } else {
                    print("Socket is not connected")
                    //MARK: - START SOCKET.
                    //                   vm.webSocketManager.delegateSocketMessage = self
                    vm.webSocketManager.connectWebSocket()
                }
                
                break
            }
        }
        
        func start60SecondsCountdown() {
            timeLeft = 60 // Reset to 60 seconds
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
        
        @objc func updateTimer() {
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                timer?.invalidate()
                timer = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.getSymbolData.indices.forEach { index in
                        self.getSymbolData[index].isHistoryFlagTimer = false
                    }
                    self.isTimerRunMoreThenOnce = true
                    GlobalVariable.instance.isProcessingSymbol = false
                }
            }
        }
        
    }
    
    //MARK: - Sector Click Delegate method here.
    extension TradeViewController: TradeInfoTapDelegate {
        
        func tradeInfoTap(_ tradeInfo: SectorGroup, index: Int) {
          
        }
    }
    
    //MARK: - Symbol API calling at the start and Save list local and set sectors in the collectionview (Section 1).
    extension TradeViewController {
       
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
            //        setTradeModel(collectionViewIndex: 0)
            setTradeModel()
            refreshSection(at: 0)
        }
       
        private func saveSymbolsToDefaults(_ symbols: [SymbolData]) {
            let savedSymbolsKey = "savedSymbolsKey"
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(symbols) {
                UserDefaults.standard.set(encoded, forKey: savedSymbolsKey)
            }
        }
       
    }
    
    //MARK: - Main and final list which is change when the sector is set and all the symbols which is on the selected sector.
    extension TradeViewController {
       
        private func setTradeModel() {
            
            
            getSymbolData.removeAll()
            
            self.focusedSymbols.removeAll()
            let filterfavoriteSymbols = GlobalVariable.instance.symbolDataArray.filter { $0.is_mobile_favorite }
            
            self.focusedSymbols = filterfavoriteSymbols.map { $0.name }
            
            // Combined filtered data and names
            var filteredSymbolsData: (data: [SymbolData], names: [String]) {
                //            let filtered = GlobalVariable.instance.symbolDataArray.filter { focusedSymbols.contains($0.name) }
                let filtered = GlobalVariable.instance.symbolDataUpdatedList.filter { focusedSymbols.contains($0.name) }
                let names = filtered.map { $0.name }
                return (data: filtered, names: names)
            }
            
            for item in filteredSymbolsData.data {
                let tradedetail = TradeDetails(datetime: 0, symbol: item.name, ask: 0.0, bid: 0.0, url: item.icon_url, close: nil)
                let symbolChartData = SymbolChartData(symbol: item.name, chartData: [])
                getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, yesterday_close: item.yesterday_close, trading_sessions_ids: item.trading_sessions_ids, historyMessage: symbolChartData, icon_url: item.icon_url, isTickFlag: false, isHistoryFlag: false, isHistoryFlagTimer: false))
            }
            
            GlobalVariable.instance.isProcessingSymbol = false
            
            //MARK: - Save symbol local to unsubcibe.
            GlobalVariable.instance.previouseSymbolList = filteredSymbolsData.names
            
            //MARK: - Merge OPEN list with the given list.
            let getList = Array(Set(GlobalVariable.instance.openSymbolList + filteredSymbolsData.names))
            
            //MARK: - START calling Socket message from here.
            vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: getList)
            
            timer?.invalidate()
            timer = nil
            GlobalVariable.instance.isProcessingSymbolTimer = false
            start60SecondsCountdown()
            
        }
        
        private func getTradeSector(collectionViewIndex: Int) {
            
            GlobalVariable.instance.tradeCollectionViewIndex.0 = collectionViewIndex
            
            let symbols = GlobalVariable.instance.symbolDataArray
            let sectors = GlobalVariable.instance.sectors
            
            // Get the sector at the given index
            let selectedSector = sectors[collectionViewIndex]
            
            // Filter symbols that belong to the selected sector
            let filteredSymbols = symbols.filter { $0.sector == selectedSector.sector }
            
            // Create a SectorGroup for the selected sector and its symbols
            let sectorGroup = SectorGroup(sector: selectedSector.sector, symbols: filteredSymbols)
            
            //        selectedSectorGroup = sectorGroup
            
            symbolDataSector.removeAll()
            // Append the sector group to symbolDataSector
            symbolDataSector.append(sectorGroup)
            
            symbolDataSectorSelected = true
            //        symbolDataSectorSelectedIndex = collectionViewIndex
            
            
            tblSearchView.delegate = self
            tblSearchView.dataSource = self
            tblSearchView.reloadData()
            
        }
        
        
    }
    
    extension TradeViewController: TradeDetailTapDelegate {
        func tradeDetailTap(indexPath: IndexPath, getSymbolData: SymbolCompleteList) {
            let vc = Utilities.shared.getViewController(identifier: .tradeDetalVC, storyboardType: .bottomSheetPopups) as! TradeDetalVC
            
            vc.getSymbolData = getSymbolData
            vc.icon_url = getSymbolData.icon_url ?? ""
            
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        }
        
    }
    
    extension TradeViewController: UITextFieldDelegate {
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            if textField == tf_searchSymbol {
                symbolDataSector.removeAll()
                //MARK: - Set all sectors by default.
                symbolDataSector = GlobalVariable.instance.sectors
                filteredData = []
                showEmptySearch = false
                tblView.isHidden = true
                tblSearchView.isHidden = false
                self.searchCloseButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
                tblSearchView.delegate = self
                tblSearchView.dataSource = self
                tblSearchView.reloadData()
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            if textField == tf_searchSymbol {
                if textField.text == "" {
                    symbolDataSector.removeAll()
                    //MARK: - Set all sectors by default.
                    symbolDataSector = GlobalVariable.instance.sectors
                    tblSearchView.delegate = self
                    tblSearchView.dataSource = self
                    tblSearchView.reloadData()
                }
            }
        }
        
        // UITextField target method to handle text changes
        @objc func searchTextChanged() {
            // Filter the data based on the search text
            let searchText = tf_searchSymbol.text?.lowercased() ?? ""
            
            if searchText.isEmpty {
                filteredData = [] // If the search text is empty, show all data
                symbolDataSectorSelected = false
                showEmptySearch = false
            } else {
                
                // If no sector is selected, filter symbols across all sectors
                let filteredSymbols = symbolDataSector.flatMap { sectorGroup in
                    sectorGroup.symbols.filter { $0.name.lowercased().contains(searchText) }
                }
                
                // Regroup filtered symbols into their respective sectors
                filteredData = symbolDataSector.compactMap { sectorGroup in
                    let filteredSectorSymbols = filteredSymbols.filter { $0.sector == sectorGroup.sector }
                    return filteredSectorSymbols.isEmpty ? nil : SectorGroup(sector: sectorGroup.sector, symbols: filteredSectorSymbols)
                }
                
                if filteredData.count == 0 {
                    showEmptySearch = true
                } else {
                    showEmptySearch = false
                }
                
                symbolDataSectorSelected = true
            }
            
            tblSearchView.delegate = self
            tblSearchView.dataSource = self
            // Reload the table view to show the filtered data
            tblSearchView.reloadData()
        }
        
        // Optional: Dismiss the keyboard when the user taps 'Return'
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
    }
   





//
////
////  TradeViewController.swift
////  RiverPrime
////
////  Created by Ross on 13/07/2024.
////
//
//import UIKit
//import Starscream
//import Alamofire
//import Foundation
//
//protocol TradeInfoTapDelegate: AnyObject {
//    func tradeInfoTap(_ tradeInfo: SectorGroup, index: Int)
//}
//
//struct TradeInfo {
//    var name = String()
//}
//
//protocol TradeDetailTapDelegate: AnyObject {
//    func tradeDetailTap(indexPath: IndexPath, getSymbolData: SymbolCompleteList)
//}
//
//struct SymbolCompleteList {
//    var tickMessage: TradeDetails?
//    var yesterday_close: String?
//    var trading_sessions_ids: [Int]?
//    var historyMessage: SymbolChartData?
//    var icon_url: String?
//    var isTickFlag: Bool?
//    var isHistoryFlag: Bool?
//    var isHistoryFlagTimer: Bool?
//}
//
//struct SymbolData: Codable {
//    let id: String
//    let name: String
//    let description: String
//    let icon_url: String
//    let volumeMin: String
//    let volumeMax: String
//    let volumeStep: String
//    let contractSize: String
//    let displayName: String
//    let sector: String
//    let digits: String
//    let stopsLevel: String
//    let swapLong: String
//    let swapShort: String
//    let spreadSize: String
//    let mobile_available: String
//    let yesterday_close: String
//    let is_mobile_favorite: Bool
//    let trading_sessions_ids: [Int]
//    
//    init(id: String, name: String, description: String, icon_url: String, volumeMin: String, volumeMax: String, volumeStep: String, contractSize: String, displayName: String, sector: String, digits: String, stopsLevel: String, swapLong: String, swapShort: String, spreadSize: String, mobile_available: String, yesterday_close: String,is_mobile_favorite:Bool,trading_sessions_ids: [Int] ) {
//        self.id = id
//        self.name = name
//        self.description = description
//        self.icon_url = icon_url
//        self.volumeMin = volumeMin
//        self.volumeMax = volumeMax
//        self.volumeStep = volumeStep
//        self.contractSize = contractSize
//        self.displayName = displayName
//        self.sector = sector
//        self.digits = digits
//        self.spreadSize = spreadSize
//        self.swapLong = swapLong
//        self.swapShort = swapShort
//        self.stopsLevel = stopsLevel
//        self.mobile_available = mobile_available
//        self.yesterday_close = yesterday_close
//        self.is_mobile_favorite = is_mobile_favorite
//        self.trading_sessions_ids = trading_sessions_ids
//    }
//    
//}
//
//struct SectorGroup {
//    let sector: String
//    let symbols: [SymbolData]
//}
//
//class TradeViewController: UIViewController {
//    
//    @IBOutlet weak var tblView: UITableView!
//    @IBOutlet weak var tblSearchView: UITableView!
//    
//    weak var delegate: TradeInfoTapDelegate?
//    weak var delegateDetail: TradeDetailTapDelegate?
//    
//    let vm = TradeVM()
//    
//    var getSymbolData = [SymbolCompleteList]()
//    var focusedSymbols = ["EURUSD", "GBPUSD", "CHFUSD", "USDJPY", "Gold", "Silver", "DJ130", "BRENT"]
//    
//    var searchSectorData = ["Currency", "Commodities", "Energy", "Indices"]
//    var symbolDataSectorSelected = false
//    //    var symbolDataSectorSelectedIndex = Int()
//    //    var selectedSectorGroup: SectorGroup? = nil
//    
//    var timer: Timer?
//    var timeLeft = 60 // seconds
//    var isTimerRunMoreThenOnce = false
//    var symbolDataObj: SymbolData?
//    
//    @IBOutlet weak var labelAmmount: UILabel!
//    
//    @IBOutlet weak var lbl_account: UILabel!
//    @IBOutlet weak var lbl_accountType: UILabel!
//    
//    @IBOutlet weak var tf_searchSymbol: UITextField!
//    @IBOutlet weak var searchCloseButton: UIButton!
//    
//    weak var delegateCollectionView: TradeInfoTapDelegate?
//    var symbolDataSector: [SectorGroup] = []
//    var filteredData: [SectorGroup] = []
//    
//    var getSectorData: [SectorGroup] {
//        return filteredData.isEmpty ? symbolDataSector : filteredData
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tf_searchSymbol.attributedPlaceholder = NSAttributedString(
//            string: "Search symbol here",
//            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
//        )
//        
//        dashboardinit()
//        GlobalVariable.instance.lastSelectedSectorIndex = IndexPath(row: 0, section: 0)
//        
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        
//        //        self.searchCloseButton.isHidden = true
//        self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
//        self.searchCloseButton.setTitle("", for: .normal)
//        
//        self.tblSearchView.isHidden = true
//        self.tblView.isHidden = false
//        
//        self.tf_searchSymbol.delegate = self
//        // Add a target to update search on text change
//        self.tf_searchSymbol.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
//        
//        if let tabBarController = self.tabBarController as? HomeTabbarViewController {
//            tabBarController.delegateSocketMessage = self
//            tabBarController.delegateSocketNotSendData = self
//        }
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationTradeApiUpdate(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.TradeApiUpdateConstant.key), object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
//        
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.MetaTraderLogin(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.MetaTraderLoginConstant.key), object: nil)
//        
//        
//        callCollectionViewAtStart()
//        
//    }
//    @IBAction func alaramBtnAction(_ sender: Any) {
//        Alert.showAlert(withMessage: "Alarm Screen available soon", andTitle: "Alarm", on: self)
//    }
//    
//    @IBAction func notificationBtnAction(_ sender: Any) {
//        Alert.showAlert(withMessage: "Notification Screen available soon", andTitle: "Notification", on: self)
//    }
//    
//    @IBAction func searchCloseButton(_ sender: UIButton) {
//            
//            if let currentImage = self.searchCloseButton.image(for: .normal),
//               currentImage.isEqual(UIImage(systemName: "magnifyingglass")) {
//                print("The button image is magnifyingglass.")
//                symbolDataSector.removeAll()
//                //MARK: - Set all sectors by default.
//                symbolDataSector = GlobalVariable.instance.sectors
//                filteredData = []
//                tblView.isHidden = true
//                tblSearchView.isHidden = false
//                self.searchCloseButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
//                tblSearchView.delegate = self
//                tblSearchView.dataSource = self
//                tblSearchView.reloadData()
//            }else{
//                
//                symbolDataSector.removeAll()
//                //MARK: - Set all sectors by default.
//                symbolDataSector = GlobalVariable.instance.sectors
//                //        self.symbolDataSectorSelected = false
//                filteredData = []
//                self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
//                self.tblView.isHidden = false
//                self.tblSearchView.isHidden = true
//                self.tf_searchSymbol.text = ""
//                self.tf_searchSymbol.resignFirstResponder()
//                
//            }
//            
//           
//        
//    }
//    
//    private func callCollectionViewAtStart() {
//        
//        let indexPath = GlobalVariable.instance.lastSelectedSectorIndex //IndexPath(row: 0, section: 0)
//        
//        //        if tradeTVCCollectionView.cellForItem(at: indexPath) != nil {
//        //            // Scroll to the selected item
//        //            tradeTVCCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
//        //
//        //            let data = symbolDataSector[indexPath.row]
//        //            selectedIndex = indexPath.row
//        //            self.delegate?.tradeInfoTap(data, index: indexPath.row)
//        //            tradeTVCCollectionView.reloadData()
//        //        }
//        
//    }
//    
//    @objc func notificationTradeApiUpdate(_ notification: NSNotification) {
//        
//        if let update = notification.userInfo?[NotificationObserver.Constants.TradeApiUpdateConstant.title] as? String {
//            print("update: \(update)")
//            
//            if update == "TradeApiUpdate" {
//                
//                vm.webSocketManager.delegateSocketPeerClosed = self
//                
//                isTimerRunMoreThenOnce = false
//                
//                tblView.registerCells([
//                    /*AccountTableViewCell.self,TradeTVC.self, */TradeTableViewCell.self
//                ])
//                
//                tblView.delegate = self
//                tblView.dataSource = self
//                
//                tblSearchView.registerCells([
//                    SearchTableViewCell.self
//                ])
//                
//                tblSearchView.delegate = self
//                tblSearchView.dataSource = self
//                
//                //MARK: - if Symbol Api data is exist then we must set our list data.
//                if GlobalVariable.instance.symbolDataArray.count != 0 {
//                    
//                    //MARK: - This Check is handle for Offline data.
//                    if !GlobalVariable.instance.socketNotSendData {
//                        
//                        GlobalVariable.instance.symbolDataUpdatedList = GlobalVariable.instance.symbolDataArray
//                        
//                        symbolDataSector = GlobalVariable.instance.sectors
//                        
//                        //MARK: - Get the list and save localy and set sectors and symbols.
//                        processSymbols(GlobalVariable.instance.symbolDataArray)
//                        
//                        //MARK: - Reload tablview when all data set into the list at first time.
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                            self.tblView.delegate = self
//                            self.tblView.dataSource = self
//                            self.tblView.reloadData()
//                        }
//                        
//                    }
//                    
//                }
//                
//                delegate = self
//                config(GlobalVariable.instance.sectors)
//                
//                delegateDetail = self
//                
//                accountData()
//            }
//        }
//    }
//    
//    @objc private func MetaTraderLogin(_ notification: Notification) {
//        if let userInfo = notification.userInfo,
//           let receivedString = userInfo[NotificationObserver.Constants.MetaTraderLoginConstant.title] as? MetaTraderType {
//            print("Received string: \(receivedString)")
//            switch receivedString {
//            case .Balance:
//                let getbalanceApi = TradeTypeCellVM()
//             
//                getbalanceApi.getUserBalance(completion: { result in
//                    switch result {
//                    case .success(let responseModel):
//                        // Save the response model or use it as needed
//                        print("Balance: \(responseModel.result.user.balance)")
//                        print("Equity: \(responseModel.result.user.equity)")
//                        
//                        // Example: Storing in a singleton for global access
//                        UserManager.shared.currentUser = responseModel.result.user
//                        
//                    case .failure(let error):
//                        print("Failed to fetch balance: \(error.localizedDescription)")
//                    }
//                })
//                
//                
//                getbalanceApi.getBalance(completion: { response in
//                    print("response of get balance in trade Vc: \(response)")
//                    if response == "Invalid Response" {
////                        self.balance = "0.0"
//                        return
//                    }
////                    self.balance = response
////                    GlobalVariable.instance.balanceUpdate = self.balance
//                    GlobalVariable.instance.balanceUpdate = response
////                    NotificationCenter.default.post(name: .BalanceUpdate, object: nil,  userInfo: ["BalanceUpdateType": self.balance])
//                    NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
//                 
//                    NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.OPCUpdateConstant.key, dict: [NotificationObserver.Constants.OPCUpdateConstant.title: "Open"])
//
//                })
//                break
//            case .GetBalance:
//                break
//            case .None:
//                break
//            }
//        }
//    }
//    
//    private func dashboardinit() {
//        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
////            print("saved User Data: \(savedUserData)")
//            // Access specific values from the dictionary
//            
//            
//            //MARK: - START Update Change.
//            let getbalanceApi = TradeTypeCellVM()
//            getbalanceApi.getUserBalance(completion: { result in
//                switch result {
//                case .success(let responseModel):
//                    // Save the response model or use it as needed
//                    print("Balance: \(responseModel.result.user.balance)")
//                    print("Equity: \(responseModel.result.user.equity)")
//                    
//                    // Example: Storing in a singleton for global access
//                    UserManager.shared.currentUser = responseModel.result.user
//                    
//                    GlobalVariable.instance.balanceUpdate = String(responseModel.result.user.balance) //self.balance
//                    print("GlobalVariable.instance.balanceUpdate = \(GlobalVariable.instance.balanceUpdate)")
//                    NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
//                    
//                    NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.OPCUpdateConstant.key, dict: [NotificationObserver.Constants.OPCUpdateConstant.title: "Open"])
//                    
//                case .failure(let error):
//                    print("Failed to fetch balance: \(error.localizedDescription)")
//                }
//            })
//            
//            
//            
//            
//            
////            if let profileStep1 = savedUserData["profileStep"] as? Int, let isCreateDemoAccount = savedUserData["demoAccountCreated"] as? Bool {
////                //                profileStep = profileStep1
////                GlobalVariable.instance.isAccountCreated = isCreateDemoAccount
////
////                let password = UserDefaults.standard.string(forKey: "password")
////                if password == nil && isCreateDemoAccount == true {
////                    showPopup()
////                }else{
////                    print("the password is: \(password ?? "")")
////
////                    let getbalanceApi = TradeTypeCellVM()
////                    getbalanceApi.getUserBalance(completion: { result in
////                        switch result {
////                        case .success(let responseModel):
////                            // Save the response model or use it as needed
////                            print("Balance: \(responseModel.result.user.balance)")
////                            print("Equity: \(responseModel.result.user.equity)")
////
////                            // Example: Storing in a singleton for global access
////                            UserManager.shared.currentUser = responseModel.result.user
////
////                        case .failure(let error):
////                            print("Failed to fetch balance: \(error.localizedDescription)")
////                        }
////                    })
////
////                    getbalanceApi.getBalance(completion: { response in
////                        print("response of get balance: \(response)")
////                        if response == "Invalid Response" {
////                            //                            self.balance = "0.0"
////                            return
////                        }
////                        //                        self.balance = response
////                        GlobalVariable.instance.balanceUpdate = response //self.balance
////                        print("GlobalVariable.instance.balanceUpdate = \(GlobalVariable.instance.balanceUpdate)")
////                        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
////
////                        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.OPCUpdateConstant.key, dict: [NotificationObserver.Constants.OPCUpdateConstant.title: "Open"])
////
////                    })
////                }
////            }
//            //MARK: - END Update Change.
//        }
//    }
//    
//    @objc func notificationPopup(_ notification: NSNotification) {
//        
//        if let ammount = notification.userInfo?[NotificationObserver.Constants.BalanceUpdateConstant.title] as? String {
//            print("Received ammount: \(ammount)")
//            self.labelAmmount.text = "$\(ammount)"
//        }
//        
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        timer?.invalidate()
//        timer = nil
//    }
//    
//    func accountData() {
//        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
//            self.lbl_accountType.text = defaultAccount.groupName
//            lbl_account.text = defaultAccount.isReal == true ? "Real" : "Demo"
//        }
//       
//    }
//    
//    func config(_ symbolData: [SectorGroup]){
//        self.symbolDataSector = symbolData
//        //        self.tradeTVCCollectionView.reloadData()
//    }
//}
//
//extension TradeViewController: UITableViewDelegate, UITableViewDataSource {
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        if tblView.isHidden == false {
//            return 1
//        } else {
//            //            if !filteredData.isEmpty {
//            if symbolDataSectorSelected {
//                return getSectorData.count
//            } else {
//                return 1
//            }
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if !tblView.isHidden {
//            return getSymbolData.count
//        } else {
//            //            if !filteredData.isEmpty {
//            if symbolDataSectorSelected {
//                return getSectorData[section].symbols.count
//            } else {
//                return getSectorData.count
//            }
//        }
//        //        return getSymbolData.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        tableView.keyboardDismissMode = .onDrag
//        
//        if !tblView.isHidden {
//            
//            // Register the nib for the table view cell
//            let nib = UINib(nibName: "TradeTableViewCell", bundle: nil)
//            tableView.register(nib, forCellReuseIdentifier: "TradeTableViewCell")
//            
//            
//            let cell = tableView.dequeueReusableCell(with: TradeTableViewCell.self, for: indexPath)
//            cell.backgroundColor = .clear
//            cell.selectionStyle = .none
//            
//            //MARK: - getSymbolData list is comming from symbol api.
//            let trade = getSymbolData[indexPath.row].tickMessage
//            
//            //MARK: - Get selected sector value and compare with repeated sector values and show the list of symbols with in this sector.
//            if let obj = GlobalVariable.instance.symbolDataArray.first(where: {$0.name == trade?.symbol}) {
//                symbolDataObj = obj
//            }
//            
//            //MARK: - Showing the list of Symbols according to the selected sector in else statement.
//            cell.configure(with: trade! , symbolDataObj: symbolDataObj)
//            
//            // Disable interaction for specific cells
//            if !(getSymbolData[indexPath.row].isTickFlag ?? false) { //MARK: - User Interface disabled, when tick flag is false.
//                cell.isUserInteractionEnabled = false
//                cell.contentView.alpha = 0.5 // Visual cue that the cell is disabled
//                // No selection effect
//            } else {
//                cell.isUserInteractionEnabled = true
//                cell.contentView.alpha = 1.0
//            }
//            
//            return cell
//            
//        } else {
//            
//            // Register the nib for the table view cell
//            let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
//            tableView.register(nib, forCellReuseIdentifier: "SearchTableViewCell")
//            
//            
//            let cell = tableView.dequeueReusableCell(with: SearchTableViewCell.self, for: indexPath)
//            
//            //            if !filteredData.isEmpty {
//            if symbolDataSectorSelected {
//                //                symbolDataSectorSelected = false
//                let data = getSectorData[indexPath.section]
//                
//                cell.textLabel?.text = data.symbols[indexPath.row].name
//                cell.detailTextLabel?.text = data.symbols[indexPath.row].description
//            } else {
//                let data = getSectorData[indexPath.row]
//                
//                cell.textLabel?.text = data.sector
//                cell.detailTextLabel?.text = ""
//            }
//            
//            return cell
//            
//        }
//        
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if !tblView.isHidden {
//            
//            //MARK: - When we click on the symbol list index then it should move and show history data into the detail page.
//            let getSymbolData = getSymbolData[indexPath.row]
//            if getSymbolData.historyMessage?.chartData.count != 0 {
//                delegateDetail?.tradeDetailTap(indexPath: indexPath, getSymbolData: getSymbolData)
//            }
//            
//        } else {
//            
//            //            if !filteredData.isEmpty {
//            if symbolDataSectorSelected {
//                
//                // Ensure we update the table view on the main thread
//                DispatchQueue.main.async { [self] in
//                    
//                    let item = getSectorData[indexPath.section].symbols[indexPath.row]
//                    
//                    // Check if the symbol already exists
//                    if getSymbolData.contains(where: { $0.tickMessage?.symbol == item.name }) {
//                        Alert.showAlert(withMessage: "Symbol is already exist.", andTitle: item.name, on: self)
//                        return
//                    }
//                    
//                    filteredData = []
//                    symbolDataSectorSelected = false
//                    tblView.isHidden = false
//                    tblSearchView.isHidden = true
//                    tf_searchSymbol.text = ""
//                    tf_searchSymbol.resignFirstResponder()
//                    self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
//                    
//                    let tradedetail = TradeDetails(datetime: 0, symbol: item.name, ask: 0.0, bid: 0.0, url: item.icon_url, close: nil)
//                    let symbolChartData = SymbolChartData(symbol: item.name, chartData: [])
//                    getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, trading_sessions_ids: item.trading_sessions_ids, historyMessage: symbolChartData, icon_url: item.icon_url, isTickFlag: false, isHistoryFlag: false, isHistoryFlagTimer: false))
//                    //                    getSymbolData.insert((SymbolCompleteList(tickMessage: tradedetail, historyMessage: symbolChartData, icon_url: item.icon_url, isTickFlag: false, isHistoryFlag: false, isHistoryFlagTimer: false)), at: getSymbolData.count)
//                    
//                    GlobalVariable.instance.symbolDataUpdatedList.append(item)
//                    
//                    GlobalVariable.instance.previouseSymbolList.append(item.name)
//                    
//                    tblSearchView.delegate = nil
//                    tblSearchView.dataSource = nil
//                    
//                    let newIndexPath = IndexPath(row: getSymbolData.count - 1, section: 0)
//                    tblView.insertRows(at: [newIndexPath], with: .automatic)
//                    
//                    //MARK: - START calling Socket message from here.
//                    vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbol: item.name)
//                    
//                }
//                //                tblView.reloadData()
//                
//            } else {
//                self.tf_searchSymbol.resignFirstResponder()
//                getTradeSector(collectionViewIndex: indexPath.row)
//            }
//            
//        }
//        
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if !tblView.isHidden {
//            return 80.0
//        } else {
//            return 50.0
//        }
//    }
//    
//    // MARK: - Table View Delegate (Delete Action)
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if !tblView.isHidden {
//            if editingStyle == .delete {
//                // Ensure we update the table view on the main thread
//                DispatchQueue.main.async { [self] in
//                    var getDeletedSymbol = getSymbolData[indexPath.row].tickMessage?.symbol ?? ""
//                    
//                    //MARK: - START calling Socket message from here.
//                    vm.webSocketManager.sendWebSocketMessage(for: "unsubscribeTrade", symbolList: [getDeletedSymbol])
//                    
//                    GlobalVariable.instance.previouseSymbolList.remove(at: indexPath.row)
//                    // Remove the item from the data source
//                    getSymbolData.remove(at: indexPath.row)
//                    
//                    filteredData = []
//                    symbolDataSectorSelected = false
//                    tblView.isHidden = false
//                    tblSearchView.isHidden = true
//                    tf_searchSymbol.text = ""
//                    tf_searchSymbol.resignFirstResponder()
//                    self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
//                    
//                    if GlobalVariable.instance.symbolDataUpdatedList.count != 0 {
//                        for i in 0...GlobalVariable.instance.symbolDataUpdatedList.count-1 {
//                            if GlobalVariable.instance.symbolDataUpdatedList[i].name == getDeletedSymbol {
//                                GlobalVariable.instance.symbolDataUpdatedList.remove(at: i)
//                                break
//                            }
//                        }
//                    }
//                    
//                    // Animate the deletion of the row
//                    tableView.deleteRows(at: [indexPath], with: .automatic)
//                }
//            }
//        }
//    }
//    
//    //MARK: - Just reload the given tableview section.
//    func refreshSection(at section: Int) {
//        let indexSet = IndexSet(integer: section)
//        tblView.reloadSections(indexSet, with: .automatic)
//        
//    }
//    
//}
//
//extension TradeViewController: SocketPeerClosed {
//    
//    func peerClosed() {
//        
//        GlobalVariable.instance.changeSector = true
//        
//        ////        getSymbolData.removeAll()
//        //
//        //        setTradeModel()
//    }
//}
//
//extension TradeViewController {
//    
//    private func fetchHistoryChartData(_ symbol: String) {
//        
//        vm.fetchChartHistory(symbol: symbol) { result in
//            switch result {
//            case .success(let responseData):
//                
//                if let index = self.getSymbolData.firstIndex(where: { $0.tickMessage?.symbol == responseData.symbol }) {
//                    self.getSymbolData[index].historyMessage = responseData
//                    
//                    let indexPath = IndexPath(row: index, section: 0)
//                    if let cell = self.tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
//                        
//                        GlobalVariable.instance.isProcessingSymbolTimer = false
//                    }
//                    return
//                }
//                
//            case .failure(let error):
//                print("Error fetching data: \(error)")
//            }
//        }
//    }
//    
//}
//
////MARK: - This Func is handle for Offline data.
//extension TradeViewController: SocketNotSendDataDelegate {
//    
//    func socketNotSendData() {
//        
//        getSymbolData.removeAll()
//        
//        self.focusedSymbols.removeAll()
//        let filterfavoriteSymbols = GlobalVariable.instance.symbolDataArray.filter { $0.is_mobile_favorite }
//        
//        self.focusedSymbols = filterfavoriteSymbols.map { $0.name }
//        
//        // Combined filtered data and names
//        var filteredSymbolsData: (data: [SymbolData], names: [String]) {
//            //            let filtered = GlobalVariable.instance.symbolDataArray.filter { focusedSymbols.contains($0.name) }
//            let filtered = GlobalVariable.instance.symbolDataUpdatedList.filter { focusedSymbols.contains($0.name) }
//            let names = filtered.map { $0.name }
//            return (data: filtered, names: names)
//        }
//        
//        for item in filteredSymbolsData.data {
//            let tradedetail = TradeDetails(datetime: 0, symbol: item.name, ask: Double(item.yesterday_close) ?? 0.0, bid: Double(item.yesterday_close) ?? 0.0, url: item.icon_url, close: nil)
//            let symbolChartData = SymbolChartData(symbol: item.name, chartData: [])
//            getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, yesterday_close: item.yesterday_close, trading_sessions_ids: item.trading_sessions_ids, historyMessage: symbolChartData, icon_url: item.icon_url, isTickFlag: true, isHistoryFlag: true, isHistoryFlagTimer: true))
//        }
//        
//        GlobalVariable.instance.isProcessingSymbol = false
//        
//        //MARK: - Save symbol local to unsubcibe.
//        GlobalVariable.instance.previouseSymbolList = filteredSymbolsData.names
//        
//        //MARK: - Merge OPEN list with the given list.
//        let getList = Array(Set(GlobalVariable.instance.openSymbolList + filteredSymbolsData.names))
//        
//        //MARK: - START calling Socket message from here.
//        vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: getList)
//        
//        timer?.invalidate()
//        timer = nil
//        GlobalVariable.instance.isProcessingSymbolTimer = false
//        start60SecondsCountdown()
//        
//        
//        
//        
//        
//        if getSymbolData.count == 0 {
//            return
//        }
//        
//        for i in 0...getSymbolData.count-1 {
//            
//            //MARK: - If tick flag is true then we just update the label only not reload the tableview.
//            let indexPath = IndexPath(row: i, section: 0)
//            if let cell = tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
//                getSymbolData[i].isTickFlag = true
//                
//                getSymbolData[i].isHistoryFlag = true
//                fetchHistoryChartData(getSymbolData[i].tickMessage?.symbol ?? "")
//                
//                print("getSymbolData[\(i)].yesterday_close = \(getSymbolData[i].yesterday_close ?? "0.0")")
//                cell.setStyledLabel(value: Double(getSymbolData[i].yesterday_close ?? "0.0") ?? 0.0, digit: cell.digits ?? 0, label: cell.lbl_bidAmount)
//                cell.setStyledLabel(value: Double(getSymbolData[i].yesterday_close ?? "0.0") ?? 0.0, digit: cell.digits ?? 0, label: cell.lbl_askAmount)
//              
//                    //MARK: - User Interface enabled, when tick flag is true.
//                    cell.isUserInteractionEnabled = true
//                    cell.contentView.alpha = 1.0
//                
//                GlobalVariable.instance.socketNotSendData = true
//                    
//                }
//            
//        }
//        
//    }
//    
//}
//
////MARK: - Get Socket Tick, History and Unsubcribe and update the list accordingly.
//extension TradeViewController: GetSocketMessages {
//    
//    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?) {
//        switch socketMessageType {
//        case .tick:
//            
//            //MARK: - Compare the symbol which is coming from Socket with our Selected Sector symbol list and update our list (getSymbolData).
//            if let getTick = tickMessage {
//                if let index = getSymbolData.firstIndex(where: { $0.tickMessage?.symbol == getTick.symbol }) {
//                    getSymbolData[index].tickMessage = tickMessage
//                    
//                    if let flag = getSymbolData[index].isHistoryFlag {
//                        if !flag {
//                            getSymbolData[index].isHistoryFlag = true
//                            
//                            fetchHistoryChartData(getTick.symbol)
//                            
//                        } else {
//                            if !GlobalVariable.instance.isProcessingSymbol {
//                                GlobalVariable.instance.isProcessingSymbol = true
//                                start60SecondsCountdown()
//                            } else {
//                                if let flagTimer = getSymbolData[index].isHistoryFlagTimer {
//                                    if !flagTimer && !GlobalVariable.instance.isProcessingSymbolTimer {
//                                        if isTimerRunMoreThenOnce {
//                                            getSymbolData[index].isHistoryFlag = true
//                                            GlobalVariable.instance.isProcessingSymbolTimer = true
//                                            getSymbolData[index].isHistoryFlagTimer = true
//                                            
//                                            fetchHistoryChartData(getTick.symbol)
//                                            
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    
//                    //MARK: - If tick flag is true then we just update the label only not reload the tableview.
//                    let indexPath = IndexPath(row: index, section: 0)
//                    if let cell = tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
//                        getSymbolData[index].isTickFlag = true
//                        cell.setStyledLabel(value: getSymbolData[index].tickMessage?.bid ?? 0.0, digit: cell.digits ?? 0, label: cell.lbl_bidAmount)
//                        cell.setStyledLabel(value: getSymbolData[index].tickMessage?.ask ?? 0.0, digit: cell.digits ?? 0, label: cell.lbl_askAmount)
//                        
//                        let pipsValues = cell.calculatePips(ask: getSymbolData[index].tickMessage?.ask ?? 0.0, bid: getSymbolData[index].tickMessage?.bid ?? 0.0, digits: cell.digits ?? 0)
//                        cell.lbl_pipsValues.text = "\(pipsValues)"
//                        
//                        if let timestamp = getSymbolData[index].tickMessage?.datetime {
//                            print("Raw UNIX Timestamp: \(timestamp)") // Debugging
//                            print("System Time Zone: \(TimeZone.current)")
//                            // Step 1: Convert UNIX timestamp (seconds) to Date
//                            let createDate = Date(timeIntervalSince1970: Double(timestamp))
//                            print("Converted Date: \(createDate)") // Debugging
//                       
//                            let adjustedDate = createDate.addingTimeInterval(-2 * 3600)
//                                print("Adjusted Date (After subtracting 2 hours): \(adjustedDate)")
//                            // Step 2: Format the Date into local time
//                            let dateFormatter = DateFormatter()
//                            dateFormatter.dateFormat = "HH:mm:ss" // Desired time format
//                            dateFormatter.locale = Locale(identifier: "en_GB") //  en_GB for 24 hours en_US for 12 hours
//                            dateFormatter.timeZone =  .current //TimeZone(identifier: "Asia/Dubai")   // Use local time zone (UTC+4, etc.)
//
//                            let localTimeString = dateFormatter.string(from: adjustedDate)
//                            print("Formatted Local Time: \(localTimeString)") // Debugging
//
//                            // Step 3: Assign the formatted time to the label
//                            cell.lbl_datetime.text = localTimeString
//                        } else {
//                            print("Missing or Invalid Timestamp")
//                            cell.lbl_datetime.text = "Invalid Date"
//                        }
//                            
////                            let createDate = Date(timeIntervalSince1970: Double(getSymbolData[index].tickMessage?.datetime ?? 0))
////
////                            let dateFormatter = DateFormatter()
////                            dateFormatter.dateFormat = "HH:mm:ss"
////                            dateFormatter.timeZone = .current
////
////                            let datee = dateFormatter.string(from: createDate)
//                            
//                            //                        cell.lbl_datetime.text = datee
//                            
//                            let bid = getSymbolData[index].tickMessage?.bid ?? 0.0
//                            var oldBid =  Double()
//                            
//                            if cell.lblCurrencySymbl.text == tickMessage?.symbol {
//                                let yesterdayClose_value = GlobalVariable.instance.symbolDataArray.filter { $0.name == getSymbolData[index].tickMessage?.symbol }.map { $0.yesterday_close }
//                                print("symbolyesterday_close = \(yesterdayClose_value)")
//                                oldBid = Double(yesterdayClose_value[0]) ?? 0.0
//                            }
//                            
//                            let diff = bid - oldBid
//                            let percentageChange = (diff / oldBid) * 100
//                            let newValue = (percentageChange * 100.0) / 100.0
//                            let percent = String(newValue).trimmedTrailingZeros()
//                            
//                            print("\n new value is: \(newValue) \n the different in points: \(diff)")
//                            
//                            let pointsValues = cell.calculatePointDifferencePips(currentBid: (getSymbolData[index].tickMessage?.bid ?? 0.0), lastCloseBid: oldBid, decimalPrecision: cell.digits ?? 0)
//                            
//                            cell.lblPercent.text = "\(percent)%"
//                            
//                            if percent.contains("inf") {
//                                cell.lblPercent.text = "0.0%"
//                            }
//                            
//                            if newValue > 0.0 {
//                                cell.profitIcon.image = UIImage(systemName: "arrow.up")
//                                cell.profitIcon.tintColor = .systemGreen
//                                cell.lblPercent.textColor = .systemGreen
//                                
//                                cell.lbl_pointsDiff.text = "+\(pointsValues)"
//                                
//                            } else {
//                                cell.profitIcon.image = UIImage(systemName: "arrow.down")
//                                cell.profitIcon.tintColor = .systemRed
//                                cell.lblPercent.textColor = .systemRed
//                                
//                                cell.lbl_pointsDiff.text = "-\(pointsValues)"
//                            }
//                            
//                            //MARK: - User Interface enabled, when tick flag is true.
//                            cell.isUserInteractionEnabled = true
//                            cell.contentView.alpha = 1.0
//                            
//                        }
//                        
//                        return
//                    }
//                }
//                
//                break
//                
//            case .Unsubscribed:
//                
//                //MARK: - Before change any sector we must unsubcribe already selected and then again update according to the new selected sector.
//                
//                GlobalVariable.instance.changeSector = true
//                
//                if GlobalVariable.instance.previouseSymbolList.count == 0 {
//                    //MARK: - Merge OPEN list with the given list.
//                    let getList = Array(Set(GlobalVariable.instance.openSymbolList))
//                    
//                    //MARK: - Save symbol local to unsubcibe.
//                    GlobalVariable.instance.previouseSymbolList = getList
//                    
//                    //MARK: - START calling Socket message from here.
//                    vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: getList)
//                }
//                
//                
//                
//                
//                if vm.webSocketManager.isSocketConnected() {
//                    print("Socket is connected")
//                } else {
//                    print("Socket is not connected")
//                    //MARK: - START SOCKET.
//                    //                   vm.webSocketManager.delegateSocketMessage = self
//                    vm.webSocketManager.connectWebSocket()
//                }
//                
//                break
//            }
//        }
//        
//        func start60SecondsCountdown() {
//            timeLeft = 60 // Reset to 60 seconds
//            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
//        }
//        
//        @objc func updateTimer() {
//            if timeLeft > 0 {
//                timeLeft -= 1
//            } else {
//                timer?.invalidate()
//                timer = nil
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self.getSymbolData.indices.forEach { index in
//                        self.getSymbolData[index].isHistoryFlagTimer = false
//                    }
//                    self.isTimerRunMoreThenOnce = true
//                    GlobalVariable.instance.isProcessingSymbol = false
//                }
//            }
//        }
//        
//    }
//    
//    //MARK: - Sector Click Delegate method here.
//    extension TradeViewController: TradeInfoTapDelegate {
//        
//        func tradeInfoTap(_ tradeInfo: SectorGroup, index: Int) {
//          
//        }
//    }
//    
//    //MARK: - Symbol API calling at the start and Save list local and set sectors in the collectionview (Section 1).
//    extension TradeViewController {
//       
//        private func processSymbols(_ symbols: [SymbolData]) {
//            var sectorDict = [String: [SymbolData]]()
//            
//            // Group symbols by sector
//            for symbol in symbols {
//                sectorDict[symbol.sector, default: []].append(symbol)
//            }
//            
//            // Sort the sectors by key
//            let sortedSectors = sectorDict.keys.sorted()
//            
//            // Create SectorGroup from sorted keys
//            GlobalVariable.instance.sectors = sortedSectors.map {
//                SectorGroup(sector: $0, symbols: sectorDict[$0]!)
//            }
//            
//            saveSymbolsToDefaults(symbols)
//            
//            // Initialize with the first index
//            //        setTradeModel(collectionViewIndex: 0)
//            setTradeModel()
//            refreshSection(at: 0)
//        }
//       
//        private func saveSymbolsToDefaults(_ symbols: [SymbolData]) {
//            let savedSymbolsKey = "savedSymbolsKey"
//            let encoder = JSONEncoder()
//            if let encoded = try? encoder.encode(symbols) {
//                UserDefaults.standard.set(encoded, forKey: savedSymbolsKey)
//            }
//        }
//       
//    }
//    
//    //MARK: - Main and final list which is change when the sector is set and all the symbols which is on the selected sector.
//    extension TradeViewController {
//       
//        private func setTradeModel() {
//            
//            
//            getSymbolData.removeAll()
//            
//            self.focusedSymbols.removeAll()
//            let filterfavoriteSymbols = GlobalVariable.instance.symbolDataArray.filter { $0.is_mobile_favorite }
//            
//            self.focusedSymbols = filterfavoriteSymbols.map { $0.name }
//            
//            // Combined filtered data and names
//            var filteredSymbolsData: (data: [SymbolData], names: [String]) {
//                //            let filtered = GlobalVariable.instance.symbolDataArray.filter { focusedSymbols.contains($0.name) }
//                let filtered = GlobalVariable.instance.symbolDataUpdatedList.filter { focusedSymbols.contains($0.name) }
//                let names = filtered.map { $0.name }
//                return (data: filtered, names: names)
//            }
//            
//            for item in filteredSymbolsData.data {
//                let tradedetail = TradeDetails(datetime: 0, symbol: item.name, ask: 0.0, bid: 0.0, url: item.icon_url, close: nil)
//                let symbolChartData = SymbolChartData(symbol: item.name, chartData: [])
//                getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, yesterday_close: item.yesterday_close, trading_sessions_ids: item.trading_sessions_ids, historyMessage: symbolChartData, icon_url: item.icon_url, isTickFlag: false, isHistoryFlag: false, isHistoryFlagTimer: false))
//            }
//            
//            GlobalVariable.instance.isProcessingSymbol = false
//            
//            //MARK: - Save symbol local to unsubcibe.
//            GlobalVariable.instance.previouseSymbolList = filteredSymbolsData.names
//            
//            //MARK: - Merge OPEN list with the given list.
//            let getList = Array(Set(GlobalVariable.instance.openSymbolList + filteredSymbolsData.names))
//            
//            //MARK: - START calling Socket message from here.
//            vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: getList)
//            
//            timer?.invalidate()
//            timer = nil
//            GlobalVariable.instance.isProcessingSymbolTimer = false
//            start60SecondsCountdown()
//            
//        }
//        
//        private func getTradeSector(collectionViewIndex: Int) {
//            
//            GlobalVariable.instance.tradeCollectionViewIndex.0 = collectionViewIndex
//            
//            let symbols = GlobalVariable.instance.symbolDataArray
//            let sectors = GlobalVariable.instance.sectors
//            
//            // Get the sector at the given index
//            let selectedSector = sectors[collectionViewIndex]
//            
//            // Filter symbols that belong to the selected sector
//            let filteredSymbols = symbols.filter { $0.sector == selectedSector.sector }
//            
//            // Create a SectorGroup for the selected sector and its symbols
//            let sectorGroup = SectorGroup(sector: selectedSector.sector, symbols: filteredSymbols)
//            
//            //        selectedSectorGroup = sectorGroup
//            
//            symbolDataSector.removeAll()
//            // Append the sector group to symbolDataSector
//            symbolDataSector.append(sectorGroup)
//            
//            symbolDataSectorSelected = true
//            //        symbolDataSectorSelectedIndex = collectionViewIndex
//            
//            
//            tblSearchView.delegate = self
//            tblSearchView.dataSource = self
//            tblSearchView.reloadData()
//            
//        }
//        
//        
//    }
//    
//    extension TradeViewController: TradeDetailTapDelegate {
//        func tradeDetailTap(indexPath: IndexPath, getSymbolData: SymbolCompleteList) {
//            let vc = Utilities.shared.getViewController(identifier: .tradeDetalVC, storyboardType: .bottomSheetPopups) as! TradeDetalVC
//            
//            vc.getSymbolData = getSymbolData
//            vc.icon_url = getSymbolData.icon_url ?? ""
//            
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//        }
//        
//    }
//    
//    extension TradeViewController: UITextFieldDelegate {
//        
//        func textFieldDidBeginEditing(_ textField: UITextField) {
//            if textField == tf_searchSymbol {
//                symbolDataSector.removeAll()
//                //MARK: - Set all sectors by default.
//                symbolDataSector = GlobalVariable.instance.sectors
//                filteredData = []
//                tblView.isHidden = true
//                tblSearchView.isHidden = false
//                self.searchCloseButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
//                tblSearchView.delegate = self
//                tblSearchView.dataSource = self
//                tblSearchView.reloadData()
//            }
//        }
//        
//        func textFieldDidEndEditing(_ textField: UITextField) {
//            if textField == tf_searchSymbol {
//                if textField.text == "" {
//                    symbolDataSector.removeAll()
//                    //MARK: - Set all sectors by default.
//                    symbolDataSector = GlobalVariable.instance.sectors
//                    tblSearchView.delegate = self
//                    tblSearchView.dataSource = self
//                    tblSearchView.reloadData()
//                }
//            }
//        }
//        
//        // UITextField target method to handle text changes
//        @objc func searchTextChanged() {
//            // Filter the data based on the search text
//            let searchText = tf_searchSymbol.text?.lowercased() ?? ""
//            
//            if searchText.isEmpty {
//                filteredData = [] // If the search text is empty, show all data
//                symbolDataSectorSelected = false
//            } else {
//                
//                // If no sector is selected, filter symbols across all sectors
//                let filteredSymbols = symbolDataSector.flatMap { sectorGroup in
//                    sectorGroup.symbols.filter { $0.name.lowercased().contains(searchText) }
//                }
//                
//                // Regroup filtered symbols into their respective sectors
//                filteredData = symbolDataSector.compactMap { sectorGroup in
//                    let filteredSectorSymbols = filteredSymbols.filter { $0.sector == sectorGroup.sector }
//                    return filteredSectorSymbols.isEmpty ? nil : SectorGroup(sector: sectorGroup.sector, symbols: filteredSectorSymbols)
//                }
//                
//                symbolDataSectorSelected = true
//            }
//            
//            tblSearchView.delegate = self
//            tblSearchView.dataSource = self
//            // Reload the table view to show the filtered data
//            tblSearchView.reloadData()
//        }
//        
//        // Optional: Dismiss the keyboard when the user taps 'Return'
//        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//            textField.resignFirstResponder()
//            return true
//        }
//        
//    }
//   
