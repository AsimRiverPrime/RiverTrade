
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
    let serverId: [ServerID]
    
    init(id: String, name: String, description: String, icon_url: String, volumeMin: String, volumeMax: String, volumeStep: String, contractSize: String, displayName: String, sector: String, digits: String, stopsLevel: String, swapLong: String, swapShort: String, spreadSize: String, mobile_available: String, yesterday_close: String,is_mobile_favorite:Bool,trading_sessions_ids: [Int], serverId: [ServerID] ) {
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
        self.serverId = serverId
    }
    
}

struct ServerID : Codable {
    let id: Int
    let name: String
}

struct SectorGroup {
    let sector: String
    let symbols: [SymbolData]
}

class TradeViewController: BaseViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var tblView: UITableView!
//    @IBOutlet weak var tblSearchView: UITableView!
    
    private var isSearching = false
    
    //    weak var delegate: TradeInfoTapDelegate?
    weak var delegateDetail: TradeDetailTapDelegate?
    
    let vm = TradeVM()
    
    var getSymbolData = [SymbolCompleteList]()
    var focusedSymbols = ["EURUSD", "GBPUSD", "CHFUSD", "Gold", "Silver", "DJ130", "BRENT"]
    
    var searchSectorData = ["Currency", "Commodities", "Energy", "Indices"]
    var symbolDataSectorSelected = false
 
    var timer: Timer?
    var timeLeft = 60 // seconds
    var isTimerRunMoreThenOnce = false
    var symbolDataObj: SymbolData?
    
    var tradeTypeCellVM = TradeTypeCellVM()
    
    @IBOutlet weak var badgeLabel: UILabel!
    
    @IBOutlet weak var viewBadge: CardView!
    @IBOutlet weak var labelAmmount: UILabel!
    
    @IBOutlet weak var lbl_account: UILabel!
    @IBOutlet weak var lbl_accountType: UILabel!
    
    @IBOutlet weak var searchContainerView: UIView!
    
    @IBOutlet weak var tf_searchSymbol: UITextField!
    @IBOutlet weak var searchCloseButton: UIButton!
    
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var alaramButton: UIButton!
    
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint! // Link height constraint of searchBar
    
    private var isSearchBarHidden = true
    
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

        searchBarHeightConstraint.constant = 0 // Initially hide the search bar
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
 
        let shouldHide = GlobalVariable.instance.guestAccount
        [labelAmmount, lbl_account, lbl_accountType].forEach {
            $0?.isHidden = shouldHide
        }
        
        viewWillAppearData()
        updateIndicator()
    }
    
    private func updateIndicator() {
        
        //MARK: - If tick flag is true then we just update the label only not reload the tableview.
        if getSymbolData.count != 0 {
            for i in 0...getSymbolData.count-1 {
                let indexPath = IndexPath(row: i, section: 0)
                if let cell = tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
                    //MARK: - Check if Open position have data then match it with our trade list and show color to our View.
                    if GlobalVariable.instance.openSymbolList.contains(getSymbolData[i].tickMessage!.symbol) {
                        for j in 0...GlobalVariable.instance.openSymbolList.count-1 {
                            if GlobalVariable.instance.openSymbolList[j].contains(getSymbolData[i].tickMessage!.symbol) {
                                
                                if GlobalVariable.instance.myProfitLossForOpenSymbolList.count != 0 {
                                    //
                                    var symbolProfitLossSum: [String: Double] = [:]
                                    
                                    // Iterate through openSymbolList to calculate total profit/loss for duplicate symbols
                                    for (index, symbol) in GlobalVariable.instance.openSymbolList.enumerated() {
                                        if GlobalVariable.instance.openSymbolList.count != GlobalVariable.instance.myProfitLossForOpenSymbolList.count {
                                            break
                                        }
                                        let profitLoss = GlobalVariable.instance.myProfitLossForOpenSymbolList[index]
                                        symbolProfitLossSum[symbol, default: 0.0] += profitLoss
                                    }
                                    
                                    // Get the symbol from tableView cell
                                    let currentSymbol = getSymbolData[i].tickMessage!.symbol
                                    
                                    // Check if the symbol exists in the summed profit/loss dictionary
                                    if let totalProfitLoss = symbolProfitLossSum[currentSymbol] {
                                        if totalProfitLoss > 0.0 {
                                            cell.openPosSymbolColorView.backgroundColor = .systemGreen
                                         } else if totalProfitLoss < 0.0 {
                                            cell.openPosSymbolColorView.backgroundColor = .systemRed
                                         }
                                        break
                                    }
                                }
                                
                                if GlobalVariable.instance.myProfitLossForOpenSymbolList.count != 0 {
                                    if GlobalVariable.instance.openSymbolList.count != GlobalVariable.instance.myProfitLossForOpenSymbolList.count {
                                        cell.openPosSymbolColorView.backgroundColor = UIColor.clear 
                                        break
                                    }
                                    if GlobalVariable.instance.myProfitLossForOpenSymbolList[j] < 0.0 {
                                        cell.openPosSymbolColorView.backgroundColor = .systemRed
                                     } else {
                                        cell.openPosSymbolColorView.backgroundColor = .systemGreen
                                     }
                                } else {
                                 }
                                break
                            }
                        }
                        
                    } else {
                        cell.lblCurrencySymbl.textColor = .white
                        cell.openPosSymbolColorView.backgroundColor = UIColor.clear // Default color
                    }
                }
            }
        }
        
    }
    
    func viewWillAppearData() {
        
        GlobalVariable.instance.socketTimerCount = 0
        
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
        NotificationCenter.default.addObserver(self, selector: #selector(handleBadgeUpdate(_:)), name: NSNotification.Name("UpdateBadge"), object: nil)
        APP_DELEGATE.updateBadgeCount()
        accountData()
         self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        self.searchCloseButton.setTitle("", for: .normal)
        
         self.tblView.isHidden = false
        
        self.tf_searchSymbol.delegate = self
        // Add a target to update search on text change
        self.tf_searchSymbol.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        
        if let tabBarController = self.tabBarController as? HomeTabbarViewController {
            tabBarController.delegateSocketMessage = self
            tabBarController.delegateSocketNotSendData = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.OPCListDissmisal(_:)), name: .OPCListDismissall, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationTradeApiUpdate(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.TradeApiUpdateConstant.key), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.MetaTraderLogin(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.MetaTraderLoginConstant.key), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.OpenPositionViewUpdate(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.CheckOpenPositionConstant.key), object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(self.UpdateTradeList(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.UpdateTradeListConstant.key), object: nil)
        
        if GlobalVariable.instance.realAccount {
             NotificationCenter.default.addObserver(self, selector: #selector(self.updateAccountList), name: NSNotification.Name(rawValue: "updateSelectedAccountListForRealAccount"), object: nil)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.accountChangeUpdation(_:)), name: .accountChangeUpdation, object: nil)
 
        if let symbolNames = Session.instance.filteredSymbolData {
           
            //MARK: - Merge OPEN list with the given list.
            let getList = Array(Set(GlobalVariable.instance.openSymbolList + symbolNames.map(\.name)))
            GlobalVariable.instance.previouseSymbolList = getList
            
            //MARK: - START calling Socket message from here.
            vm.webSocketManager.sendWebSocketMessage(for: "unsubscribeTrade", symbolList: getList)
            
            //MARK: - START calling Socket message from here.
            vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: getList)
            
            //MARK: - This check is added for removing extra dots and fix text and fonts of trade list.
            if getSymbolData.count != 0 {
                for i in 0...getSymbolData.count-1 {
                    let indexPath = IndexPath(row: i, section: 0)
                    if let cell = tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
                        getSymbolData[i].isTickFlag = true
                        cell.setStyledLabel(value: getSymbolData[i].tickMessage?.bid ?? 0.0, digit: cell.digits ?? 0, label: cell.lbl_bidAmount)
                        cell.setStyledLabel(value: getSymbolData[i].tickMessage?.ask ?? 0.0, digit: cell.digits ?? 0, label: cell.lbl_askAmount)
                    }
                }
            }
        }
    }
    
//    @objc private func accountChangeUpdation123(_ notification: Notification) {
//        if let userInfo = notification.userInfo,
//           let receivedString = userInfo["accountChangeUpdation"] as? String {
//            print("Received string: \(receivedString)")
//            if receivedString == "accountChangeUpdation" {
//                DispatchQueue.global(qos: .background).async { [weak self] in
//                    guard let self = self else { return }
//                    
//                    openData()
//          
//                }
//            }
//        }
//    }
    
    @objc private func accountChangeUpdation(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let receivedString = userInfo["accountChangeUpdation"] as? String {
            print("Received string: \(receivedString)")
            if receivedString == "accountChangeUpdation" {
                
                // MARK: - Check and reconnect socket if needed
                if !vm.webSocketManager.isSocketConnected() {
                    print("Socket not connected, reconnecting...")
                    vm.webSocketManager.connectWebSocket(socketURLType: GlobalVariable.instance.socketURLType)
                    
                    // Wait a moment for connection to establish before proceeding
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        guard let self = self else { return }
                        self.openData()
                        self.resubscribeToSymbols()
                    }
                } else {
                    print("Socket is connected, proceeding with data update")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        DispatchQueue.global(qos: .background).async { [weak self] in
                            guard let self = self else { return }
                            self.openData()
                        }
                        // Resubscribe to symbols after data is loaded
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                            guard let self = self else { return }
                            self.resubscribeToSymbols()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Add this new method to resubscribe to symbols
    private func resubscribeToSymbols() {
        // Get the current symbol list (favorite symbols + open positions)
        var symbolList: [String] = []
        
        // Add favorite symbols if available
        if let filteredSymbols = Session.instance.filteredSymbolData {
            symbolList.append(contentsOf: filteredSymbols.map { $0.name })
        }
        
        // Add open position symbols
        symbolList.append(contentsOf: GlobalVariable.instance.openSymbolList)
        
        // Remove duplicates
        let uniqueSymbolList = Array(Set(symbolList))
        
        if !uniqueSymbolList.isEmpty {
            print("Resubscribing to symbols: \(uniqueSymbolList)")
            
            // Update the previous symbol list
            GlobalVariable.instance.previouseSymbolList = uniqueSymbolList
            
            // Unsubscribe first (clean slate)
            vm.webSocketManager.sendWebSocketMessage(for: "unsubscribeTrade", symbolList: uniqueSymbolList, isTradeDismiss: true)
            
            // Then resubscribe
            vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: uniqueSymbolList)
        }
    }
    
    @objc private func OPCListDissmisal(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let receivedString = userInfo["OPCType"] as? String {
            print("Received string: \(receivedString)")
            if receivedString == "Open" {
                DispatchQueue.global(qos: .background).async { [weak self] in
                    guard let self = self else { return }
                    
                    openData()
          
                }
            }
        }
    }
    
    private func getSymbol(item: String) -> String {
        
        var getSymbol = ""
        
       if item.contains(".") {
            getSymbol = String(item.dropLast())
        } else {
            getSymbol = item
        }
        
        return getSymbol
        
    }
    
    func openData() {
        // Execute the fetch on a background thread
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            self.tradeTypeCellVM.OPCApi(index: 0) { openData, pendingData, closeData, error in
                DispatchQueue.main.async {
                    
                    if let error = error {
                        print("Error fetching positions: \(error)")
                        // Handle the error (e.g., show an alert)
                    } else if let positions = openData {
                        
                        //MARK: - START to update values for socket dynamic method at start.
                        GlobalVariable.instance.openList = positions
                        
                        GlobalVariable.instance.getSymbolData.removeAll()
                        
                        for item in positions {
                            
                            let getSymbol = self.getSymbol(item: item.symbol)
                            
                            GlobalVariable.instance.getSymbolData.append(SymbolCompleteList(tickMessage: TradeDetails(datetime: 0, symbol: getSymbol, ask: 0.0, bid: 0.0, url: "", close: 0, ask_high: 0, bid_low: 0)))
                        }
                        //MARK: - END to update values for socket dynamic method at start.
                        
                        GlobalVariable.instance.openSymbolList.removeAll()
                        
                        let symbols = positions.map { self.getSymbol(item: $0.symbol) }
                        GlobalVariable.instance.openSymbolList = symbols
                         
                        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
                        
                    }
 
                }
            }
        }
    }
    
    @objc func updateAccountList() {
        
        var isPhoneVerified = Bool()
        var isEmailVerified = Bool()
        var registrationType : Int?
        
        var userEmail = String()
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let profileStep1 = savedUserData["profileStep"] as? Int, let _email = savedUserData["email"] as? String, let _userId = savedUserData["uid"] as? String, let _registrationType = savedUserData["registrationType"] as? Int, let _isPhoneVerified = savedUserData["phoneVerified"] as? Bool, let _isEmailVerified = savedUserData["emailVerified"] as? Bool  {
 
                userEmail = _email
                registrationType = _registrationType
                isPhoneVerified = _isPhoneVerified
                isEmailVerified = _isEmailVerified
             }
        }
    
        if GlobalVariable.instance.realAccount {
            if registrationType == 1 && !isEmailVerified {
                
                let vc = Utilities.shared.getViewController(identifier: .emailSendVC, storyboardType: .bottomSheetPopups) as! EmailSendVC
                vc.UserEmail = userEmail
                self.navigate(to: vc)
            }else if !isPhoneVerified {
                
                let vc = Utilities.shared.getViewController(identifier: .phoneVerifyVC, storyboardType: .main) as! PhoneVerifyVC
                vc.userEmail = userEmail
                 self.navigate(to: vc)
            }else{
             }
         }
     }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        
        if scrollVelocity > 0 && isSearchBarHidden { // Scrolling up
            showSearchBar()
        } else if scrollVelocity < 0 && !isSearchBarHidden { // Scrolling down
            hideSearchBar()
        }
    }
    
    private func showSearchBar() {
        UIView.animate(withDuration: 0.3) {
            self.searchBarHeightConstraint.constant = 50 // Adjust to original height of search bar
            self.view.layoutIfNeeded()
        }
        isSearchBarHidden = false
    }
    
    private func hideSearchBar() {
        UIView.animate(withDuration: 0.3) {
            self.searchBarHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        isSearchBarHidden = true
    }
    @objc func handleBadgeUpdate(_ notification: Notification) {
        if let count = notification.userInfo?["count"] as? Int {
            updateButtonBadge(count: count)
        }
    }
    func updateButtonBadge(count: Int) {
        if count > 0 {
            badgeLabel.text = count > 9 ? "+9" : "\(count)"
            viewBadge.isHidden = false
               badgeLabel.isHidden = false
           } else {
               badgeLabel.isHidden = true
               viewBadge.isHidden = true
           }
    }
    
    @objc private func FaceAfterLoginUpdate(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let receivedString = userInfo[NotificationObserver.Constants.FaceAfterLoginConstant.title] as? String {
            print("Received string: \(receivedString)")
            
            if receivedString == "TradeVC" {
                let faceIdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! PasscodeFaceIDVC
                faceIdVC.afterLoginNavigation = true

                faceIdVC.modalPresentationStyle = .overFullScreen
                if let sheet = faceIdVC.sheetPresentationController {
//                        sheet.detents = [.medium(), .large()] // Adjust as needed
                        sheet.prefersGrabberVisible = true
                    }
                guard let topVC = faceIdVC.topMostViewController() else { return }
                topVC.present(faceIdVC, animated: true, completion: nil)
            }
         }
    }
    
    @objc private func UpdateTradeList(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let receivedString = userInfo[NotificationObserver.Constants.UpdateTradeListConstant.title] as? String {
            print("Received string: \(receivedString)")
            
            if receivedString == "UpdateTradeList" {
                
                DispatchQueue.main.async { [self] in
  
                    filteredData = []
                     symbolDataSectorSelected = false
                    isSearching = false
                    tblView.isHidden = false
                     tf_searchSymbol.text = ""
                    tf_searchSymbol.resignFirstResponder()
                    self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
    
                    DispatchQueue.main.async {
                        self.tblView.delegate = self
                        self.tblView.dataSource = self
                        self.tblView.reloadData()
                    }
                  }
             }
         }
    }
    
    @IBAction func alaramBtnAction(_ sender: Any) {
         let vc = Utilities.shared.getViewController(identifier: .alarmAlertVC, storyboardType: .bottomSheetPopups) as! AlarmAlertVC
        self.navigate(to: vc)
         
    }
    
    @IBAction func notificationBtnAction(_ sender: Any) {
         UIApplication.shared.applicationIconBadgeNumber = 0
 
           // Update UI
           updateButtonBadge(count: 0)

        
        let vc = Utilities.shared.getViewController(identifier: .notificationViewController, storyboardType: .bottomSheetPopups) as! NotificationViewController
        
        self.navigate(to: vc) 
        
    }
   
    @IBAction func searchCloseButton(_ sender: UIButton) {
        if let currentImage = self.searchCloseButton.image(for: .normal),
           currentImage.isEqual(UIImage(systemName: "magnifyingglass")) {
            
            print("The button image is magnifyingglass.")
            
            // Start search
            symbolDataSector.removeAll()
            symbolDataSector = GlobalVariable.instance.sectors
            filteredData = []

            isSearching = true
            symbolDataSectorSelected = false // ← Add this line to match default behavior

            self.searchCloseButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
            self.tblView.isHidden = false
            
            DispatchQueue.main.async {
                self.tblView.reloadData()
            }

        } else {
            print("The button image is crossBtn.")
            // Close search
            symbolDataSector.removeAll()
            symbolDataSector = GlobalVariable.instance.sectors
            filteredData = []

            isSearching = false // ← Important
            symbolDataSectorSelected = false // ← Important to show getSymbolData

            self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            self.tf_searchSymbol.text = ""
            self.tf_searchSymbol.resignFirstResponder()
            self.tblView.isHidden = false
            
            DispatchQueue.main.async {
                self.tblView.reloadData()
            }
        }
    }
    
    @objc func notificationTradeApiUpdate(_ notification: NSNotification) {
        
        if let update = notification.userInfo?[NotificationObserver.Constants.TradeApiUpdateConstant.title] as? String {
//            print("update: \(update)")
            
            if update == "TradeApiUpdate" {
                
                vm.webSocketManager.delegateSocketPeerClosed = self
                
                isTimerRunMoreThenOnce = false
                 
                filteredData = []
                symbolDataSectorSelected = false
                isSearching = false
                tblView.isHidden = false
 
                tf_searchSymbol.text = ""
                tf_searchSymbol.resignFirstResponder()
                self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
                 
                tblView.registerCells([
                    TradeTableViewCell.self, SearchTableViewCell.self
                ])
                
                tblView.delegate = self
                tblView.dataSource = self
 
                //MARK: - if Symbol Api data is exist then we must set our list data.
                if Session.instance.symbolData?.count != 0 {
                    
                    //MARK: - This Check is handle for Offline data.
                    if !GlobalVariable.instance.socketNotSendData {
                         
                        symbolDataSector = GlobalVariable.instance.sectors
                        
                        //MARK: - Get the list and save localy and set sectors and symbols.
                        processSymbols(Session.instance.symbolData ?? [])
                        
                        //MARK: - Reload tablview when all data set into the list at first time.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.tblView.delegate = self
                            self.tblView.dataSource = self
                            self.tblView.reloadData()
                        }
                        
                    }
                     
                }
                
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
                        
                        GlobalVariable.instance.balanceUpdate = "\(responseModel.result.user.balance)"

                        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
                        
                        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.OPCUpdateConstant.key, dict: [NotificationObserver.Constants.OPCUpdateConstant.title: "Open"])
                        
                    case .failure(let error):
                        print("Failed to fetch balance: \(error.localizedDescription)")
                    }
                })
        
                break
            case .GetBalance:
                break
            case .None:
                break
            }
        }
    }
    
    @objc private func OpenPositionViewUpdate(_ notification: Notification) {
        if let update = notification.userInfo?[NotificationObserver.Constants.CheckOpenPositionConstant.title] as? String {
//            print("update: \(update)")
            
            if update == "openPositionViewUpdate" {
                //MARK: - If tick flag is true then we just update the label only not reload the tableview.
                if getSymbolData.count != 0 {
                    for i in 0...getSymbolData.count-1 {
                        let indexPath = IndexPath(row: i, section: 0)
                        if let cell = tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
                            //MARK: - Check if Open position have data then match it with our trade list and show color to our View.
                            if GlobalVariable.instance.openSymbolList.contains(getSymbolData[i].tickMessage!.symbol) {
                                for j in 0...GlobalVariable.instance.openSymbolList.count-1 {
                                    if GlobalVariable.instance.openSymbolList[j].contains(getSymbolData[i].tickMessage!.symbol) {
 
                                        if GlobalVariable.instance.myProfitLossForOpenSymbolList.count != 0 {
                                            //
                                            var symbolProfitLossSum: [String: Double] = [:]
                                            
                                            // Iterate through openSymbolList to calculate total profit/loss for duplicate symbols
                                            for (index, symbol) in GlobalVariable.instance.openSymbolList.enumerated() {
                                                let profitLoss = GlobalVariable.instance.myProfitLossForOpenSymbolList[index]
                                                symbolProfitLossSum[symbol, default: 0.0] += profitLoss
                                            }
                                            
                                            // Get the symbol from tableView cell
                                            let currentSymbol = getSymbolData[i].tickMessage!.symbol
                                            
                                            // Check if the symbol exists in the summed profit/loss dictionary
                                            if let totalProfitLoss = symbolProfitLossSum[currentSymbol] {
                                                if totalProfitLoss > 0.0 {
                                                    cell.openPosSymbolColorView.backgroundColor = .systemGreen
                                                 } else if totalProfitLoss < 0.0 {
                                                    cell.openPosSymbolColorView.backgroundColor = .systemRed
                                                 }
                                                break
                                            }
                                        }
                                        
                                        if GlobalVariable.instance.myProfitLossForOpenSymbolList.count != 0 {
                                            if GlobalVariable.instance.myProfitLossForOpenSymbolList[j] < 0.0 {
                                                cell.openPosSymbolColorView.backgroundColor = .systemRed
                                             } else {
                                                cell.openPosSymbolColorView.backgroundColor = .systemGreen
                                             }
                                        } else {
                                            }
                                        break
                                    }
                                }
                                
                            } else {
                                cell.lblCurrencySymbl.textColor = .white
                                cell.openPosSymbolColorView.backgroundColor = UIColor.clear // Default color
                            }
                        }
                    }
                }
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
                
                if GlobalVariable.instance.getBalanceHidden == "$•••••••" {
                    self.labelAmmount.text = GlobalVariable.instance.getBalanceHidden
                }
                
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
     }
    
    @objc func notificationPopup(_ notification: NSNotification) {
        
        if let ammount = notification.userInfo?[NotificationObserver.Constants.BalanceUpdateConstant.title] as? String {
             let amount = String.formatStringNumber(ammount)
            self.labelAmmount.text = "$\(String(describing: amount))"
            
            if GlobalVariable.instance.getBalanceHidden == "$•••••••" {
                labelAmmount.text = GlobalVariable.instance.getBalanceHidden
            }
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
     }
}

extension TradeViewController: StartOffLineDataDelegate {
    
    func startOfflineData() {
        //MARK: - Get the list and save localy and set sectors and symbols.
        processSymbols(Session.instance.symbolData ?? [], isINIT: true)
    }
 }

//MARK: - Symbol API calling at the start and Save list local and set sectors in the collectionview (Section 1).
extension TradeViewController {
   
    private func processSymbols(_ symbols: [SymbolData], isINIT: Bool = false) {
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
      
        setTradeModel(isINIT: isINIT)
        refreshSection(at: 0)
    }
   
    private func saveSymbolsToDefaults(_ symbols: [SymbolData]) {
        let savedSymbolsKey = "savedSymbolsKey"
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(symbols) {
            UserDefaults.standard.set(encoded, forKey: savedSymbolsKey)
        }
    }
    
    private func setTradeModel(isINIT: Bool = false) {
        
        guard let symboleData = Session.instance.symbolData else { return }
                
        getSymbolData.removeAll()
        
        self.focusedSymbols.removeAll()
        
        //MARK: - This Check is only work when "Session.instance.filteredSymbolData" -> Have data and this list is update when the symbols will add or remove.
        if let checkFilteredSymbolData = Session.instance.filteredSymbolData {
            if checkFilteredSymbolData.count != 0 {
                setDataIntoList(filterfavoriteSymbols: checkFilteredSymbolData, symbolData: symboleData, isINIT: isINIT)
                return
            }
        }
        
        let filterfavoriteSymbols = symboleData.filter { $0.is_mobile_favorite }
        
        if Session.instance.filteredSymbolData?.count == 0 || Session.instance.filteredSymbolData == nil {
            Session.instance.filteredSymbolData = filterfavoriteSymbols
        }
 
        setDataIntoList(filterfavoriteSymbols: filterfavoriteSymbols, symbolData: symboleData, isINIT: isINIT)
     }
    
    private func setDataIntoList(filterfavoriteSymbols: [SymbolData], symbolData: [SymbolData], isINIT: Bool = false) {
 
        self.focusedSymbols = filterfavoriteSymbols.map { $0.name }
        
        // Combined filtered data and names
        var filteredSymbolsData: (data: [SymbolData], names: [String]) {
            //            let filtered = GlobalVariable.instance.symbolDataArray.filter { focusedSymbols.contains($0.name) }
            let filtered = symbolData.filter { focusedSymbols.contains($0.name) }
            let names = filtered.map { $0.name }
            return (data: filtered, names: names)
        }
         
        delegateDetail = self
        
        for item in filteredSymbolsData.data {
            let tradedetail = TradeDetails(datetime: 0, symbol: item.name, ask: Double(item.yesterday_close) ?? 0.0, bid: Double(item.yesterday_close) ?? 0.0, url: item.icon_url, close: nil, ask_high: 0, bid_low: 0)
            let symbolChartData = SymbolChartData(symbol: item.name, chartData: [])
            getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, yesterday_close: item.yesterday_close, trading_sessions_ids: item.trading_sessions_ids, historyMessage: symbolChartData, icon_url: item.icon_url, isTickFlag: true, isHistoryFlag: true, isHistoryFlagTimer: true))
            
         }
        
        //MARK: - Reload tablview when all data set into the list at first time.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.tblView.delegate = self
            self.tblView.dataSource = self
            self.tblView.reloadData()
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
        
        if isINIT {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
                print("This code runs after a 1-second delay")
                
                if getSymbolData.count == 0 {
                    return
                }
                
                for i in 0...getSymbolData.count-1 {
                    
                    //MARK: - If tick flag is true then we just update the label only not reload the tableview.
                    let indexPath = IndexPath(row: i, section: 0)
                    if let cell = tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
                        getSymbolData[i].isTickFlag = true
                        
                        getSymbolData[i].isHistoryFlag = true
 
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
    }
    
    //MARK: - Just reload the given tableview section.
    func refreshSection(at section: Int) {
        let indexSet = IndexSet(integer: section)
        tblView.reloadSections(indexSet, with: .automatic)
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
        tblView.isHidden = false
        isSearching = true
        
        DispatchQueue.main.async {
            self.tblView.delegate = self
            self.tblView.dataSource = self
            self.tblView.reloadData()
        }
    }
    
}

extension TradeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {

        if !isSearching && !symbolDataSectorSelected {
            return 1
        } else {

            if symbolDataSectorSelected {
                return getSectorData.count
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if !isSearching && !symbolDataSectorSelected {
           
            return getSymbolData.count
        } else {
           
            if symbolDataSectorSelected {
                return getSectorData[section].symbols.count
            } else {
                return getSectorData.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
        if !isSearching && !symbolDataSectorSelected {
            return 80.0
        } else {
            return 50.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.keyboardDismissMode = .onDrag
         
        if !isSearching && !symbolDataSectorSelected {
            
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
            cell.configure(with: trade! , symbolDataObj: symbolDataObj, indexPath: indexPath)
        
            cell.onLabelSymbolTapped = { [weak self] in
                       guard let self = self else { return }
                print("press the symbol label")
                
                if indexPath.row < getSymbolData.count { // Ensure index is valid
                       let symbolData = getSymbolData[indexPath.row]
                       print("Pressed the symbol label: \(symbolData)")
//                    if symbolData.historyMessage?.chartData.count != 0 {
                        delegateDetail?.tradeDetailTap(indexPath: indexPath, getSymbolData: symbolData)
//                    }
                   } else {
                       print("Index out of range: \(indexPath.row)")
                   }
 
            }
            cell.onLabelAskTapped = { [weak self] in
                guard let self = self else { return }
                print("press the bid label")
                if GlobalVariable.instance.guestAccount {
                    
                    Alert.ShowWindowAlert("It looks like you don't have an account yet. Would you like to create one now?\n\n Create an account to unlock all feature!", andTitle: "No Account Found!", OKButtonText: "CREATE ACCOUNT", window: SCENE_DELEGATE.window!) { ok in
                        let vc = Utilities.shared.getViewController(identifier: .viewController, storyboardType: .main) as! ViewController
                        self.navigate(to: vc)
                    } andCompletionHandler: { cancel in
                        print("Cancel")
                    }
                    
                }else{
                    let vc = Utilities.shared.getViewController(identifier: .ticketVC, storyboardType: .bottomSheetPopups) as! TicketVC
                    vc.titleString = "SELL"
                    
                    let _getSymbolData = getSymbolData[indexPath.row]
                    vc.getSymbolDetail = _getSymbolData
                    vc.orderCreatedDelegate = self
                    PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
                }
            }

            cell.onLabelBidTapped = { [weak self] in
                guard let self = self else { return }
                print("press the ask label")
                if GlobalVariable.instance.guestAccount {
                    
                    Alert.ShowWindowAlert("It looks like you don't have an account yet. Would you like to create one now?\n\n Create an account to unlock all feature!", andTitle: "No Account Found!", OKButtonText: "CREATE ACCOUNT", window: SCENE_DELEGATE.window!) { ok in
                        let vc = Utilities.shared.getViewController(identifier: .viewController, storyboardType: .main) as! ViewController
                        self.navigate(to: vc)
                    } andCompletionHandler: { cancel in
                        print("Cancel")
                    }
                    
                }else{
                    let vc = Utilities.shared.getViewController(identifier: .ticketVC, storyboardType: .bottomSheetPopups) as! TicketVC
                    
                    vc.titleString = "BUY"
                    let _getSymbolData = getSymbolData[indexPath.row]
                    vc.getSymbolDetail = _getSymbolData
                    vc.orderCreatedDelegate = self
                    PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
                }
            }
           
            return cell
            
        } else {
            
            // Register the nib for the table view cell
            let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "SearchTableViewCell")
            
            
            let cell = tableView.dequeueReusableCell(with: SearchTableViewCell.self, for: indexPath)
    
            if symbolDataSectorSelected {
             
                let sectorGroup: [SectorGroup]
                if symbolDataSectorSelected && !filteredData.isEmpty {
                    sectorGroup = filteredData
                } else {
                    sectorGroup = symbolDataSector
                }
                
                if sectorGroup.count == 0 {
             
                    if let data = getSectorData[safe: indexPath.section],
                       let symbol = data.symbols[safe: indexPath.row] {
                        cell.textLabel?.text = symbol.name
                        cell.detailTextLabel?.text = symbol.description
                    }
                } else {
                    if let sector = sectorGroup[safe: indexPath.section],
                       let symbol = sector.symbols[safe: indexPath.row] {
    //                    let data = getSectorData[indexPath.section]
                        
                        cell.textLabel?.text = symbol.name
                        cell.detailTextLabel?.text = symbol.description
                    }
                }
                 
            } else {
                let data = getSectorData[indexPath.row]
                
                cell.textLabel?.text = data.sector
                cell.detailTextLabel?.text = ""
            }
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        if !isSearching && !symbolDataSectorSelected {
            
            //MARK: - When we click on the symbol list index then it should move and show history data into the detail page.
            let getSymbolData = getSymbolData[indexPath.row]
            if getSymbolData.historyMessage?.chartData.count != 0 {
 
            }
            
        } else {
            
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
                     symbolDataSectorSelected = false
                    tblView.isHidden = false
                    
                    isSearching = false
                    
                    tf_searchSymbol.text = ""
                    tf_searchSymbol.resignFirstResponder()
                    self.searchCloseButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
                    
                    let tradedetail = TradeDetails(datetime: 0, symbol: item.name, ask: 0.0, bid: 0.0, url: item.icon_url, close: nil, ask_high: 0, bid_low: 0)
                    let symbolChartData = SymbolChartData(symbol: item.name, chartData: [])
                    getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, trading_sessions_ids: item.trading_sessions_ids, historyMessage: symbolChartData, icon_url: item.icon_url, isTickFlag: false, isHistoryFlag: false, isHistoryFlagTimer: false))
                    
                    Session.instance.filteredSymbolData?.append(item)
                     
                    GlobalVariable.instance.symbolDataUpdatedList.append(item)
                    
                    GlobalVariable.instance.previouseSymbolList.append(item.name)
                     
                    DispatchQueue.main.async {
                        self.tblView.delegate = self
                        self.tblView.dataSource = self
                        self.tblView.reloadData()
                    }
 
                    //MARK: - START calling Socket message from here.
                    vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbol: item.name)
                 }
 
            } else {
                
                isSearching = true
                
                self.tf_searchSymbol.resignFirstResponder()
                getTradeSector(collectionViewIndex: indexPath.row)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Table View Delegate (Delete Action)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
 
        if !isSearching && !symbolDataSectorSelected {
            if editingStyle == .delete {
                // Ensure we update the table view on the main thread
                DispatchQueue.main.async { [self] in
                    let getDeletedSymbol = getSymbolData[indexPath.row].tickMessage?.symbol ?? ""
                    
                    //MARK: - START calling Socket message from here.
                    vm.webSocketManager.sendWebSocketMessage(for: "unsubscribeTrade", symbolList: [getDeletedSymbol])
                    
                    print("GlobalVariable.instance.previouseSymbolList = \(GlobalVariable.instance.previouseSymbolList)")
                    
                    GlobalVariable.instance.previouseSymbolList.remove(at: indexPath.row)
                    // Remove the item from the data source
                    getSymbolData.remove(at: indexPath.row)
                    Session.instance.filteredSymbolData?.remove(at: indexPath.row)
                    
                    filteredData = []
                    symbolDataSectorSelected = false
                    tblView.isHidden = false
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
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                    tableView.reloadData()
                }
            }
        }
    }
    
}

extension TradeViewController: TradeDetailTapDelegate {
    func tradeDetailTap(indexPath: IndexPath, getSymbolData: SymbolCompleteList) {
 
        let vc = Utilities.shared.getViewController(identifier: .alarmsVC, storyboardType: .bottomSheetPopups) as! AlarmsVC
        vc.symbolName = getSymbolData.tickMessage?.symbol ?? ""
        if let cell = tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
            vc.digits = cell.digits ?? 0
//            print("\n tradevc digits is: \(cell.digits)")
        }
        self.navigate(to: vc)
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
                        
//                        cell.lbl_bid_low.text = "L: \(getSymbolData[index].tickMessage?.bid_low ?? 0)"
                        let formattedBidLow = String(format: "%.\(cell.digits ?? 2)f", getSymbolData[index].tickMessage?.bid_low ?? 0)
                        cell.lbl_bid_low.text = "L: \(formattedBidLow)"
                        let formattedAskHigh = String(format: "%.\(cell.digits ?? 2)f", getSymbolData[index].tickMessage?.ask_high ?? 0)
                        cell.lbl_ask_high.text = "H: \(formattedAskHigh)"
                        
                        let pipsValues = cell.calculatePips(ask: getSymbolData[index].tickMessage?.ask ?? 0.0, bid: getSymbolData[index].tickMessage?.bid ?? 0.0, digits: cell.digits ?? 0)
                        cell.lbl_pipsValues.text = "\(pipsValues)"
                        
                        if let timestamp = getSymbolData[index].tickMessage?.datetime {
 
                            let createDate = Date(timeIntervalSince1970: Double(timestamp))
 
                            let adjustedDate = createDate.addingTimeInterval(-2 * 3600)
 
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "HH:mm:ss" // Desired time format
                            dateFormatter.locale = Locale(identifier: "en_GB") //  en_GB for 24 hours en_US for 12 hours
                            dateFormatter.timeZone =  .current //TimeZone(identifier: "Asia/Dubai")   // Use local time zone (UTC+4, etc.)
                            
                            let localTimeString = dateFormatter.string(from: adjustedDate)
 
                            cell.lbl_datetime.text = localTimeString
                        } else {
                            print("Missing or Invalid Timestamp")
                            cell.lbl_datetime.text = "Invalid Date"
                        }
                        
                        let bid = getSymbolData[index].tickMessage?.bid ?? 0.0
                        var oldBid =  Double()
                        
                        if cell.lblCurrencySymbl.text == tickMessage?.symbol {
                            
                            guard let symboleData = Session.instance.symbolData else { return }
                            
                            let yesterdayClose_value = symboleData.filter { $0.name == getSymbolData[index].tickMessage?.symbol }.map { $0.yesterday_close }
 
                            oldBid = Double(yesterdayClose_value[0]) ?? 0.0
                        }
                        
                        let diff = bid - oldBid
                        let percentageChange = (diff / oldBid) * 100
                        let newValue = (percentageChange * 100.0) / 100.0
                        let percent = String(newValue).trimmedTrailingZeros()
                         
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
                vm.webSocketManager.connectWebSocket(socketURLType: GlobalVariable.instance.socketURLType)
            }
            
            break
        }
    }
    
    func start60SecondsCountdown() {
        timeLeft = 60 // Reset to 60 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.updateTimer()
        } //Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
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
  
extension TradeViewController: SocketPeerClosed {
    
    func peerClosed() {
        
        GlobalVariable.instance.changeSector = true
        
    }
}

//MARK: - This Func is handle for Offline data.
extension TradeViewController: SocketNotSendDataDelegate {
    
    func socketNotSendData() {
        
        getSymbolData.removeAll()
        
        self.focusedSymbols.removeAll()
        
        guard let symboleData = Session.instance.symbolData else { return }
        
        let filterfavoriteSymbols = symboleData.filter { $0.is_mobile_favorite }
        
        Session.instance.filteredSymbolData = filterfavoriteSymbols
        
        self.focusedSymbols = filterfavoriteSymbols.map { $0.name }
        
        // Combined filtered data and names
        var filteredSymbolsData: (data: [SymbolData], names: [String]) {
            //            let filtered = GlobalVariable.instance.symbolDataArray.filter { focusedSymbols.contains($0.name) }
            let filtered = symboleData.filter { focusedSymbols.contains($0.name) }
            let names = filtered.map { $0.name }
            return (data: filtered, names: names)
        }
        
        for item in filteredSymbolsData.data {
            let tradedetail = TradeDetails(datetime: 0, symbol: item.name, ask: Double(item.yesterday_close) ?? 0.0, bid: Double(item.yesterday_close) ?? 0.0, url: item.icon_url, close: nil, ask_high: 0, bid_low: 0)
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
//                fetchHistoryChartData(getSymbolData[i].tickMessage?.symbol ?? "")
                
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

extension TradeViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tf_searchSymbol {
            symbolDataSector.removeAll()
            //MARK: - Set all sectors by default.
            symbolDataSector = GlobalVariable.instance.sectors
            filteredData = []
//            showEmptySearch = false
            tblView.isHidden = false
            isSearching = true
//            tblSearchView.isHidden = false
            self.searchCloseButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
             
            DispatchQueue.main.async {
                self.tblView.delegate = self
                self.tblView.dataSource = self
                self.tblView.reloadData()
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tf_searchSymbol {
            if textField.text == "" {
                symbolDataSector.removeAll()
                //MARK: - Set all sectors by default.
                symbolDataSector = GlobalVariable.instance.sectors
                
                isSearching = false
                 
                DispatchQueue.main.async {
                    self.tblView.delegate = self
                    self.tblView.dataSource = self
                    self.tblView.reloadData()
                }
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
             isSearching = false
        } else {
            
            isSearching = true
            
            // If no sector is selected, filter symbols across all sectors
            let filteredSymbols = symbolDataSector.flatMap { sectorGroup in
                sectorGroup.symbols.filter { $0.name.lowercased().contains(searchText) }
            }
            
            // Regroup filtered symbols into their respective sectors
            filteredData = symbolDataSector.compactMap { sectorGroup in
                let filteredSectorSymbols = filteredSymbols.filter { $0.sector == sectorGroup.sector }
                return filteredSectorSymbols.isEmpty ? nil : SectorGroup(sector: sectorGroup.sector, symbols: filteredSectorSymbols)
            }
             
            symbolDataSectorSelected = true
        }
        
        DispatchQueue.main.async { [self] in
             
            DispatchQueue.main.async {
                self.tblView.delegate = self
                self.tblView.dataSource = self
                self.tblView.reloadData()
            }
        }
    }
    
    // Optional: Dismiss the keyboard when the user taps 'Return'
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension TradeViewController: IsOrderCreated {
    func orderCreated() {
        
        //TODO: Navigate to Accounts.
        if let tabBarController = tabBarController as? HomeTabbarViewController {
            tabBarController.selectedIndex = 0
        }
    }
}
