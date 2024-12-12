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

class TradeViewController: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var tblSearchView: UITableView!
    
    weak var delegate: TradeInfoTapDelegate?
    weak var delegateDetail: TradeDetailTapDelegate?
    
    let vm = TradeVM()
    
    var getSymbolData = [SymbolCompleteList]()
    var focusedSymbols = ["EURUSD", "GBPUSD", "CHFUSD", "USDJPY", "Gold", "Silver", "DJ130", "BRENT"]
    
    var searchSectorData = ["Currency", "Commodities", "Energy", "Indices"]
    var symbolDataSectorSelected = false
    var symbolDataSectorSelectedIndex = Int()
    var selectedSectorGroup: SectorGroup? = nil
    
    var timer: Timer?
    var timeLeft = 60 // seconds
    var isTimerRunMoreThenOnce = false
    var symbolDataObj: SymbolData?
    
    @IBOutlet weak var labelAmmount: UILabel!
    
    @IBOutlet weak var lbl_account: UILabel!
    @IBOutlet weak var lbl_accountType: UILabel!
    
    @IBOutlet weak var tf_searchSymbol: UITextField!
    @IBOutlet weak var searchCloseButton: UIButton!
    
    var layout = UICollectionViewFlowLayout()
    
    var model = [TradeInfo]()
    var selectedIndex = 0
    
    weak var delegateCollectionView: TradeInfoTapDelegate?
    var symbolDataSector: [SectorGroup] = []
    var filteredData: [SectorGroup] = []
    
//    var getSectorData: [SectorGroup] = {
//        if filteredData.count != 0 {
//            return filteredData
//        } else {
//            return symbolDataSector
//        }
//    }()
    
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationTradeApiUpdate(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.TradeApiUpdateConstant.key), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
        
        callCollectionViewAtStart()
        
    }
    
    @IBAction func searchCloseButton(_ sender: UIButton) {
        
        symbolDataSector.removeAll()
        //MARK: - Set all sectors by default.
        symbolDataSector = GlobalVariable.instance.sectors
        self.symbolDataSectorSelected = false
//        self.searchCloseButton.isHidden = true
        self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        self.tblView.isHidden = false
        self.tblSearchView.isHidden = true
        self.tf_searchSymbol.resignFirstResponder()
        
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
//                    symbolDataObj = GlobalVariable.instance.symbolDataArray[0]
                    
                    GlobalVariable.instance.symbolDataUpdatedList = GlobalVariable.instance.symbolDataArray
                    
                    symbolDataSector = GlobalVariable.instance.sectors
                    
                    
                    
                    
//                    let symbols = GlobalVariable.instance.symbolDataArray
//                    let sectors = GlobalVariable.instance.sectors
//
//                    // Get the sector at the given index
//                    let selectedSector = sectors[collectionViewIndex]
//
//                    // Filter symbols that belong to the selected sector
//                    let filteredSymbols = symbols.filter { $0.sector == selectedSector.sector }
//
//                    // Create a SectorGroup for the selected sector and its symbols
//                    let sectorGroup = SectorGroup(sector: selectedSector.sector, symbols: filteredSymbols)
//
//                    selectedSectorGroup = sectorGroup
                    
//                    for item in GlobalVariable.instance.symbolDataArray {
//                        selectedSectorGroup
//                    }
                    
                    
                    
                    
                    
                    //MARK: - Get the list and save localy and set sectors and symbols.
                    processSymbols(GlobalVariable.instance.symbolDataArray)
                    
                    //MARK: - Reload tablview when all data set into the list at first time.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.tblView.reloadData()
                    }
                    
                   
                }
                
                delegate = self
                config(GlobalVariable.instance.sectors)
                
                delegateDetail = self
                
//                tradeTVCCollectionView.delegate = self
//                tradeTVCCollectionView.dataSource = self
//                tradeTVCCollectionView.register(UINib(nibName: "TradeCVCCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TradeCVCCollectionViewCell")
                
                accountData()
            }
        }
    }
    
    private func dashboardinit() {
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            // Access specific values from the dictionary
            
            if let profileStep1 = savedUserData["profileStep"] as? Int, let isCreateDemoAccount = savedUserData["demoAccountCreated"] as? Bool {
                //                profileStep = profileStep1
                GlobalVariable.instance.isAccountCreated = isCreateDemoAccount
                
                let password = UserDefaults.standard.string(forKey: "password")
                if password == nil && isCreateDemoAccount == true {
                    showPopup()
                }else{
                    print("the password is: \(password ?? "")")
                    
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
                        print("response of get balance: \(response)")
                        if response == "Invalid Response" {
                            //                            self.balance = "0.0"
                            return
                        }
                        //                        self.balance = response
                        GlobalVariable.instance.balanceUpdate = response //self.balance
                        print("GlobalVariable.instance.balanceUpdate = \(GlobalVariable.instance.balanceUpdate)")
                        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
                        
                        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.OPCUpdateConstant.key, dict: [NotificationObserver.Constants.OPCUpdateConstant.title: "Open"])
                        
                    })
                }
            }
        }
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
        var account_type = String()
        var account_group = String()
        //        var login_Id = Int()
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            // Access specific values from the dictionary
            
            if let loginID = savedUserData["loginId"] as? Int, let isCreateDemoAccount = savedUserData["demoAccountCreated"] as? Bool, let accountType = savedUserData["demoAccountGroup"] as? String, let isRealAccount = savedUserData["realAccountCreated"] as? Bool  {
                
                //                login_Id = loginID
                
                if isCreateDemoAccount == true {
                    account_type = " Demo "
                    account_group = " \(accountType) "
                }
                if isRealAccount == true {
                    account_type = " Real "
                    account_group = " \(accountType) "
                }
                
                if accountType == "Pro Account" {
                    account_group = " PRO "
                }else if accountType == "Prime Account" {
                    account_group = " PRIME "
                }else if accountType == "Premium Account" {
                    account_group = " PREMIUM "
                }else{
                }
                lbl_account.text = account_type
                lbl_accountType.text = account_group
            }
        }
    }
    
    func config(_ symbolData: [SectorGroup]){
        self.symbolDataSector = symbolData
//        self.tradeTVCCollectionView.reloadData()
    }
}

extension TradeViewController {
    
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

extension TradeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tblView.isHidden == false {
            return 1
        } else {
            if symbolDataSectorSelected {
//                return symbolDataSector[0/*symbolDataSectorSelectedIndex*/].symbols.count
                return getSectorData[0].symbols.count
            } else {
                return 1
            }
        }
        
//        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        tblView.isHidden = true
//        tblSearchView.isHidden = false
        if tblView.isHidden == false {
            //MARK: - get this list data from symbol api.
            return getSymbolData.count
        } else {
            return getSectorData.count //symbolDataSector.count
        }
//        //MARK: - get this list data from symbol api.
//        return getSymbolData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.keyboardDismissMode = .onDrag
//        
//        if tf_searchSymbol.text == "" {
//            tf_searchSymbol.resignFirstResponder()
//        }
        
        if tblView.isHidden == false {
            
            // Register the nib for the table view cell
            let nib = UINib(nibName: "TradeTableViewCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "TradeTableViewCell")
            
            
            let cell = tableView.dequeueReusableCell(with: TradeTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            //MARK: - getSymbolData list is comming from symbol api.
            let trade = getSymbolData[indexPath.row].tickMessage//?[indexPath.row]
            
            
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
            
            let data = getSectorData[indexPath.row] //symbolDataSector[indexPath.row]
            
            if symbolDataSectorSelected {
                cell.textLabel?.text = data.symbols[indexPath.section].name
                cell.detailTextLabel?.text = data.symbols[indexPath.section].description
            } else {
                cell.textLabel?.text = data.sector
                cell.detailTextLabel?.text = ""
            }
            
//            cell.textLabel?.text = data.sector
//            cell.detailTextLabel?.text = ""
            
            return cell
            
        }
        
//        let cell = tableView.dequeueReusableCell(with: TradeTableViewCell.self, for: indexPath)
//        cell.backgroundColor = .clear
//        cell.selectionStyle = .none
//        //MARK: - getSymbolData list is comming from symbol api.
//        let trade = getSymbolData[indexPath.row].tickMessage//?[indexPath.row]
//
//
//        //MARK: - Get selected sector value and compare with repeated sector values and show the list of symbols with in this sector.
//        if let obj = GlobalVariable.instance.symbolDataArray.first(where: {$0.name == trade?.symbol}) {
//            symbolDataObj = obj
//        }
//
//        //MARK: - Showing the list of Symbols according to the selected sector in else statement.
//        cell.configure(with: trade! , symbolDataObj: symbolDataObj)
//
//        // Disable interaction for specific cells
//        if !(getSymbolData[indexPath.row].isTickFlag ?? false) { //MARK: - User Interface disabled, when tick flag is false.
//            cell.isUserInteractionEnabled = false
//            cell.contentView.alpha = 0.5 // Visual cue that the cell is disabled
//            // No selection effect
//        } else {
//            cell.isUserInteractionEnabled = true
//            cell.contentView.alpha = 1.0
//        }
//
//        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tblView.isHidden == false {
            
            //MARK: - When we click on the symbol list index then it should move and show history data into the detail page.
            let getSymbolData = getSymbolData[indexPath.row]
            if getSymbolData.historyMessage?.chartData.count != 0 {
                delegateDetail?.tradeDetailTap(indexPath: indexPath, getSymbolData: getSymbolData)
            }
            
        } else {
            
//            let data = symbolDataSector[indexPath.row]
//            selectedIndex = indexPath.row
//            GlobalVariable.instance.lastSelectedSectorIndex = indexPath
//            self.delegate?.tradeInfoTap(data, index: indexPath.row)
            
            if symbolDataSectorSelected {
                
                // Ensure we update the table view on the main thread
                DispatchQueue.main.async { [self] in
                    
                let item = getSectorData[indexPath.row].symbols[indexPath.section] //symbolDataSector[indexPath.row].symbols[indexPath.section]
                
                // Check if the symbol already exists
                if getSymbolData.contains(where: { $0.tickMessage?.symbol == item.name }) {
//                    self.navigationController?.view.makeToast("Symbol is already exist.")
                    Alert.showAlert(withMessage: "Symbol is already exist.", andTitle: item.name, on: self)
                    return
                }
                
                symbolDataSectorSelected = false
                tblView.isHidden = false
                tblSearchView.isHidden = true
                tf_searchSymbol.text = ""
//                searchCloseButton.isHidden = true
                self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)

                tf_searchSymbol.resignFirstResponder()
                
                let tradedetail = TradeDetails(datetime: 0, symbol: item.name, ask: 0.0, bid: 0.0, url: item.icon_url, close: nil)
                let symbolChartData = SymbolChartData(symbol: item.name, chartData: [])
                getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, historyMessage: symbolChartData, icon_url: item.icon_url, isTickFlag: false, isHistoryFlag: false, isHistoryFlagTimer: false))
                
                GlobalVariable.instance.symbolDataUpdatedList.append(item)
                
                GlobalVariable.instance.previouseSymbolList.append(item.name)
                
                //MARK: - START calling Socket message from here.
                vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbol: item.name)
                
                    let newIndexPath = IndexPath(row: getSymbolData.count - 1, section: 0)
                    tblView.insertRows(at: [newIndexPath], with: .automatic)
                }
//                tblView.reloadData()
                
            } else {
                self.tf_searchSymbol.resignFirstResponder()
                getTradeSector(collectionViewIndex: indexPath.row)
            }
            
//            getTradeSector(collectionViewIndex: indexPath.row)
            
        }
        
//        //MARK: - When we click on the symbol list index then it should move and show history data into the detail page.
//        let getSymbolData = getSymbolData[indexPath.row]
//        if getSymbolData.historyMessage?.chartData.count != 0 {
//            delegateDetail?.tradeDetailTap(indexPath: indexPath, getSymbolData: getSymbolData)
//        }
//
//        //        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tblView.isHidden == false {
            return 80.0
        } else {
            return 50.0
        }
        
//        return 80.0
    }
    
    // MARK: - Table View Delegate (Delete Action)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Ensure we update the table view on the main thread
            DispatchQueue.main.async { [self] in
                removeDeletedSymbolFromList(indexPath: indexPath)
                
                // Animate the deletion of the row
//                tableView.deleteRows(at: [indexPath], with: .automatic)
                // Perform batch updates on the table view to delete rows
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
            }
        }
    }
    
    // UIScrollViewDelegate method to hide the keyboard when the table view scrolls
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // Dismiss the keyboard when scrolling begins
////            view.endEditing(true)
//            symbolDataSectorSelected = false
//            tblView.isHidden = false
//            tblSearchView.isHidden = true
            tf_searchSymbol.resignFirstResponder()
        }
    
    private func removeDeletedSymbolFromList(indexPath: IndexPath) {
        var getDeletedSymbol = getSymbolData[indexPath.row].tickMessage?.symbol ?? ""
        
////        print("Before GlobalVariable.instance.symbolDataUpdatedList = \(GlobalVariable.instance.symbolDataUpdatedList)")
//        print("Before getSymbolData = \(getSymbolData.count)")
        
        //MARK: - START calling Socket message from here.
        vm.webSocketManager.sendWebSocketMessage(for: "unsubscribeTrade", symbolList: [getDeletedSymbol])
        
        GlobalVariable.instance.previouseSymbolList.remove(at: indexPath.row)
        // Remove the item from the data source
        getSymbolData.remove(at: indexPath.row)
        symbolDataSectorSelected = false
        
//        getSectorData
//        symbolDataSector
        
        if GlobalVariable.instance.symbolDataUpdatedList.count != 0 {
            for i in 0...GlobalVariable.instance.symbolDataUpdatedList.count-1 {
                if GlobalVariable.instance.symbolDataUpdatedList[i].name == getDeletedSymbol {
                    GlobalVariable.instance.symbolDataUpdatedList.remove(at: i)
                    break
                }
            }
        }
        
////        print("After GlobalVariable.instance.symbolDataUpdatedList = \(GlobalVariable.instance.symbolDataUpdatedList)")
//        print("After getSymbolData = \(getSymbolData.count)")
        
        //GlobalVariable.instance.symbolDataArray
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
        
//        setTradeModel(collectionViewIndex: GlobalVariable.instance.getSectorIndex)
        setTradeModel()
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
                        if !flag/* && !GlobalVariable.instance.isProcessingSymbol*/ {
                            getSymbolData[index].isHistoryFlag = true
                            ////                               GlobalVariable.instance.isProcessingSymbol = true
                            //                               vm.webSocketManager.sendHistoryWebSocketMessage(for: "subscribeHistory", symbol: getTick.symbol)
                            
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
                                            //                                               vm.webSocketManager.sendHistoryWebSocketMessage(for: "subscribeHistory", symbol: getTick.symbol)
                                            
                                            fetchHistoryChartData(getTick.symbol)
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    //MARK: - If tick flag is true then we just update the label only not reload the tableview.
                    //                    if getSymbolData[index].isTickFlag ?? false {
                    let indexPath = IndexPath(row: index, section: 0)
                    if let cell = tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
                        getSymbolData[index].isTickFlag = true
                        //                               cell.lblAmount.text = "\(getSymbolData[index].tickMessage?.bid ?? 0.0)".trimmedTrailingZeros()
                        cell.setStyledLabel(value: getSymbolData[index].tickMessage?.bid ?? 0.0, digit: cell.digits ?? 0, label: cell.lbl_bidAmount)
                        cell.setStyledLabel(value: getSymbolData[index].tickMessage?.ask ?? 0.0, digit: cell.digits ?? 0, label: cell.lbl_askAmount)
                        
                        let pipsValues = cell.calculatePips(ask: getSymbolData[index].tickMessage?.ask ?? 0.0, bid: getSymbolData[index].tickMessage?.bid ?? 0.0, digits: cell.digits ?? 0)
                        cell.lbl_pipsValues.text = "\(pipsValues)"
                        
                        let createDate = Date(timeIntervalSince1970: Double(getSymbolData[index].tickMessage?.datetime ?? 0))
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "HH:mm:ss"
                        dateFormatter.timeZone = .current
                        
                        let datee = dateFormatter.string(from: createDate)
                        
                        cell.lbl_datetime.text = datee
                        
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
                        
                        print("\n new value is: \(newValue) \n the different in points: \(diff)")
                        
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
            
//            setTradeModel(collectionViewIndex: GlobalVariable.instance.getSectorIndex)
            setTradeModel()
            
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
        
        //MARK: - When click on sector to change the values then it should unsubcribe first and then update new selected sector.
        
        print("tradeInfo = \(tradeInfo)")
        
        GlobalVariable.instance.getSectorIndex = index
        
        //MARK: - START calling Socket message from here.
        vm.webSocketManager.sendWebSocketMessage(for: "unsubscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList)
        
        //MARK: - Remove symbol local after unsubcibe.
        GlobalVariable.instance.previouseSymbolList.removeAll()
        
        if vm.webSocketManager.isSocketConnected() {
            print("Socket is connected")
        } else {
            print("Socket is not connected")
        }
    }
}

//MARK: - Symbol API calling at the start and Save list local and set sectors in the collectionview (Section 1).
extension TradeViewController {
    func filterSymbolsBySector(symbols: [SymbolData], sector: String) -> [String] {
        return symbols.filter { $0.sector == sector }.map { $0.displayName }
    }
    
    func filterSector(symbols: [SymbolData], sector: String) -> [SymbolData] {
        return symbols.filter { $0.sector == sector }.map { $0 }
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
extension TradeViewController {
    
    //MARK: - Update all list when selector will change, and update tick socket message according to the selected sector.
    private func setTradeModel(collectionViewIndex: Int) {
        
        GlobalVariable.instance.tradeCollectionViewIndex.0 = collectionViewIndex
        
        let symbols = GlobalVariable.instance.symbolDataArray
        let sectors = GlobalVariable.instance.sectors
        
        // Clear previous data
        //        vm.trades.removeAll()
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
        let selectedSymbols = GlobalVariable.instance.filteredSymbols[safe: collectionViewIndex] ?? []
        let selectedUrls = GlobalVariable.instance.filteredSymbolsUrl[safe: collectionViewIndex] ?? []
        
        GlobalVariable.instance.tradeCollectionViewIndex.1.removeAll()
        getSymbolData.removeAll()
        var count = 0
        for (symbol, url) in zip(selectedSymbols, selectedUrls) {
            count += 1
            GlobalVariable.instance.tradeCollectionViewIndex.1.append(count)
            let tradedetail = TradeDetails(datetime: 0, symbol: symbol, ask: 0.0, bid: 0.0, url: url, close: nil)
            let symbolChartData = SymbolChartData(symbol: symbol, chartData: [])
            //            vm.trades.append(tradedetail)
            //            getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, historyMessage: symbolChartData))
            getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, historyMessage: symbolChartData, icon_url: url, isTickFlag: false, isHistoryFlag: false, isHistoryFlagTimer: false))
        }
        
      //  print("GlobalVariable.instance.filteredSymbolsUrl = \(GlobalVariable.instance.filteredSymbolsUrl)")
        
        GlobalVariable.instance.isProcessingSymbol = false
        
        refreshSection(at: 0)
        
        //MARK: - Save symbol local to unsubcibe.
        GlobalVariable.instance.previouseSymbolList = selectedSymbols
        
        //MARK: - Merge OPEN list with the given list.
        let getList = Array(Set(GlobalVariable.instance.openSymbolList + selectedSymbols)) //GlobalVariable.instance.openSymbolList + selectedSymbols
        
        //MARK: - START calling Socket message from here.
        vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: getList)
        
        timer?.invalidate()
        timer = nil
        GlobalVariable.instance.isProcessingSymbolTimer = false
        start60SecondsCountdown()
        
    }
    
    private func setTradeModel() {
        
//        GlobalVariable.instance.tradeCollectionViewIndex.0 = collectionViewIndex
        
        let symbols = GlobalVariable.instance.symbolDataArray
        let sectors = GlobalVariable.instance.sectors
        
        // Clear previous data
        //        vm.trades.removeAll()
        GlobalVariable.instance.filteredSymbols.removeAll()
        GlobalVariable.instance.filteredSymbolsUrl.removeAll()
        
        // Populate filteredSymbols and filteredSymbolsUrl for each sector
        for sector in sectors {
            let filteredSymbols = filterSymbolsBySector(symbols: symbols, sector: sector.sector)
            let filteredSymbolsUrl = filterSymbolsImageBySector(symbols: symbols, sector: sector.sector)
            
            GlobalVariable.instance.filteredSymbols.append(filteredSymbols)
            GlobalVariable.instance.filteredSymbolsUrl.append(filteredSymbolsUrl)
        }
        
        GlobalVariable.instance.tradeCollectionViewIndex.1.removeAll()
        getSymbolData.removeAll()
        
//        // Filtered array based on the focusedSymbols
//        var filteredSymbolDataArray: [SymbolData] {
//            return GlobalVariable.instance.symbolDataArray.filter { focusedSymbols.contains($0.name) }
//        }
//
//        // Filtered names based on focusedSymbols
//        var filteredSymbolNames: [String] {
//            return GlobalVariable.instance.symbolDataArray
//                .filter { focusedSymbols.contains($0.name) }  // Filter based on names
//                .map { $0.name }  // Map to just the names
//        }
//
//        for item in filteredSymbolDataArray {
//            let tradedetail = TradeDetails(datetime: 0, symbol: item.name, ask: 0.0, bid: 0.0, url: item.icon_url, close: nil)
//            let symbolChartData = SymbolChartData(symbol: item.name, chartData: [])
//            getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, historyMessage: symbolChartData, icon_url: item.icon_url, isTickFlag: false, isHistoryFlag: false, isHistoryFlagTimer: false))
//        }
        
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
            getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, historyMessage: symbolChartData, icon_url: item.icon_url, isTickFlag: false, isHistoryFlag: false, isHistoryFlagTimer: false))
        }
        
      //  print("GlobalVariable.instance.filteredSymbolsUrl = \(GlobalVariable.instance.filteredSymbolsUrl)")
        
        GlobalVariable.instance.isProcessingSymbol = false
        
//        refreshSection(at: 0)
        
        //MARK: - Save symbol local to unsubcibe.
        GlobalVariable.instance.previouseSymbolList = filteredSymbolsData.names //filteredSymbolNames
        
        //MARK: - Merge OPEN list with the given list.
        let getList = Array(Set(GlobalVariable.instance.openSymbolList + filteredSymbolsData.names /*filteredSymbolNames*/)) //GlobalVariable.instance.openSymbolList + selectedSymbols
        
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
        
        selectedSectorGroup = sectorGroup
        
        symbolDataSector.removeAll()
        // Append the sector group to symbolDataSector
        symbolDataSector.append(sectorGroup)
        
        symbolDataSectorSelected = true
        symbolDataSectorSelectedIndex = collectionViewIndex
        
        tblSearchView.reloadData()
        
        
        
//        var filteredSector: [[SymbolData]] = [[]]
//
//        // Clear previous data
//        //        vm.trades.removeAll()
//        GlobalVariable.instance.filteredSymbols.removeAll()
//        GlobalVariable.instance.filteredSymbolsUrl.removeAll()
//
//        // Populate filteredSymbols and filteredSymbolsUrl for each sector
//        for sector in sectors {
////            let filteredSymbols = filterSymbolsBySector(symbols: symbols, sector: sector.sector)
////            let filteredSymbolsUrl = filterSymbolsImageBySector(symbols: symbols, sector: sector.sector)
////
////            GlobalVariable.instance.filteredSymbols.append(filteredSymbols)
////            GlobalVariable.instance.filteredSymbolsUrl.append(filteredSymbolsUrl)
//
//            let selectedSector = filterSector(symbols: symbols, sector: sector.sector)
//            filteredSector.append(selectedSector)
//        }
//
////        // Append trades for the selected collectionViewIndex
////        let selectedSymbols = GlobalVariable.instance.filteredSymbols[safe: collectionViewIndex] ?? []
////        let selectedUrls = GlobalVariable.instance.filteredSymbolsUrl[safe: collectionViewIndex] ?? []
//
//        let selectedSectors = filteredSector[safe: collectionViewIndex] ?? []
//
//        var count = 0
//        for (sector) in selectedSectors {
////            count += 1
////            GlobalVariable.instance.tradeCollectionViewIndex.1.append(count)
////            let tradedetail = TradeDetails(datetime: 0, symbol: symbol, ask: 0.0, bid: 0.0, url: url, close: nil)
////            let symbolChartData = SymbolChartData(symbol: symbol, chartData: [])
////            //            vm.trades.append(tradedetail)
////            //            getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, historyMessage: symbolChartData))
////            getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, historyMessage: symbolChartData, icon_url: url, isTickFlag: false, isHistoryFlag: false, isHistoryFlagTimer: false))
//
//            let data = SectorGroup(sector: sector.sector, symbols: <#T##[SymbolData]#>)
//
//            symbolDataSector.append(SectorGroup(sector: sector.sector, symbols: sector.symbols))
//        }
//
////        GlobalVariable.instance.tradeCollectionViewIndex.1.removeAll()
////        symbolDataSector.removeAll()
////        var count = 0
////        for (symbol, url) in zip(selectedSymbols, selectedUrls) {
////            count += 1
////            GlobalVariable.instance.tradeCollectionViewIndex.1.append(count)
////            let tradedetail = TradeDetails(datetime: 0, symbol: symbol, ask: 0.0, bid: 0.0, url: url, close: nil)
////            let symbolChartData = SymbolChartData(symbol: symbol, chartData: [])
////            //            vm.trades.append(tradedetail)
////            //            getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, historyMessage: symbolChartData))
////            getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, historyMessage: symbolChartData, icon_url: url, isTickFlag: false, isHistoryFlag: false, isHistoryFlagTimer: false))
////        }
//
//        print("GlobalVariable.instance.filteredSymbolsUrl = \(GlobalVariable.instance.filteredSymbolsUrl)")
//
//        GlobalVariable.instance.isProcessingSymbol = false
//
//        refreshSection(at: 0)
//
//        //MARK: - Save symbol local to unsubcibe.
//        GlobalVariable.instance.previouseSymbolList = selectedSymbols
//
//        //MARK: - Merge OPEN list with the given list.
//        let getList = Array(Set(GlobalVariable.instance.openSymbolList + selectedSymbols)) //GlobalVariable.instance.openSymbolList + selectedSymbols
//
//        //MARK: - START calling Socket message from here.
//        vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: getList)
//
//        timer?.invalidate()
//        timer = nil
//        GlobalVariable.instance.isProcessingSymbolTimer = false
//        start60SecondsCountdown()
        
    }
    
    
}

//extension TradeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        //  return 10 // Number of items in the collection view
//        return symbolDataSector.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TradeCVCCollectionViewCell", for: indexPath) as! TradeCVCCollectionViewCell
//        cell.backgroundColor = .clear
//
//        cell.lbl_tradetype.textColor = UIColor(red: 94/255.0, green: 98/255.0, blue: 120/255.0, alpha: 1.0)
//
//        let data = symbolDataSector[indexPath.row]
//        cell.lbl_tradetype.text = data.sector
//
//        if indexPath.row == selectedIndex {
//            cell.selectedColorView.isHidden = false
//            cell.backgroundColor = .clear
//            //            cell.layer.cornerRadius = 15.0
//            cell.lbl_tradetype.textColor = .systemYellow
//            cell.lbl_tradetype.font = UIFont.boldSystemFont(ofSize: 18)
//        }else{
//            cell.selectedColorView.isHidden = true
//            cell.lbl_tradetype.textColor = UIColor(red: 94/255.0, green: 98/255.0, blue: 120/255.0, alpha: 1.0)
//            cell.backgroundColor = .clear
//            cell.lbl_tradetype.font = UIFont.systemFont(ofSize: 16)
//        }
//
//        if indexPath.row == symbolDataSector.count-1 {
//            cell.sepratorView.isHidden = true
//        } else {
//            cell.sepratorView.isHidden = true
//        }
//        return cell
//    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if let cell = collectionView.cellForItem(at: indexPath){
//            // Scroll to the selected item
//            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
//
//            let data = symbolDataSector[indexPath.row]
//            selectedIndex = indexPath.row
//            GlobalVariable.instance.lastSelectedSectorIndex = indexPath
//            self.delegate?.tradeInfoTap(data, index: indexPath.row)
//            collectionView.reloadData()
//        }
//    }
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        if let cell = collectionView.cellForItem(at: indexPath){
//            cell.backgroundColor = .clear
//
//        }
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        //        // get the Collection View width and height
//
//        return CGSize(width: symbolDataSector.count + 65 , height: 35)
//
//    }
//}
//MARK: - TradeVC cell Taps is handle here.

extension TradeViewController: TradeDetailTapDelegate {
    func tradeDetailTap(indexPath: IndexPath, getSymbolData: SymbolCompleteList) {
        let vc = Utilities.shared.getViewController(identifier: .tradeDetalVC, storyboardType: .bottomSheetPopups) as! TradeDetalVC
        
        vc.getSymbolData = getSymbolData
        //        vc.symbolChartData = symbolChartData
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
            tblView.isHidden = true
            tblSearchView.isHidden = false
//            self.searchCloseButton.isHidden = false
            self.searchCloseButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
            tblSearchView.reloadData()
        }
    }
    
    // UITextField target method to handle text changes
    @objc func searchTextChanged() {
        // Filter the data based on the search text
        let searchText = tf_searchSymbol.text?.lowercased() ?? ""
        
        if searchText.isEmpty {
            filteredData = [] // If the search text is empty, show all data
            symbolDataSectorSelected = false
        } else {
//////            filteredData = selectedSectorGroup?.symbols.filter { $0.name.lowercased().contains(searchText) } as! [SectorGroup]
////
////            // Filter the symbolDataSector array based on the search text
////            filteredData = symbolDataSector.map { sectorGroup in
////                let filteredSymbols = sectorGroup.symbols.filter { $0.name.lowercased().contains(searchText) }
////                return SectorGroup(sector: sectorGroup.sector, symbols: filteredSymbols)
////            }.filter { !$0.symbols.isEmpty } // Remove empty sectors with no matching symbols
//
//            // Filter the SymbolData across all sectors by name
//            let filteredSymbols = symbolDataSector.flatMap { sectorGroup in
//                sectorGroup.symbols.filter { $0.name.lowercased().contains(searchText) }
//            }
//
//            // Re-group the filtered symbols into sectors
//            // You may want to group them by sector, for example
//            let groupedBySector = symbolDataSector.compactMap { sectorGroup in
//                let filteredSectorSymbols = filteredSymbols.filter { $0.sector == sectorGroup.sector }
//                return filteredSectorSymbols.isEmpty ? nil : SectorGroup(sector: sectorGroup.sector, symbols: filteredSectorSymbols)
//            }
//
//            // Update filteredData with the grouped sectors containing filtered symbols
//            filteredData = groupedBySector
            
            
            
            
            
            // Check if a sector is selected (this depends on how your sector is selected, assuming it's saved in `selectedSectorGroup`)
            if let selectedSector = selectedSectorGroup {
                // If a sector is selected, filter only the symbols in that sector by name
                filteredData = [SectorGroup(sector: selectedSector.sector, symbols: selectedSector.symbols.filter {
                    $0.name.lowercased().contains(searchText)
                })]
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
            }
            symbolDataSectorSelected = true
        }
        
        // Reload the table view to show the filtered data
        tblSearchView.reloadData()
    }
    
    // Optional: Dismiss the keyboard when the user taps 'Return'
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
