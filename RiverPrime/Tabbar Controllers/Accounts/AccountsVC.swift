//
//  AccountsVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/07/2024.
//

import UIKit

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

class AccountsVC: UIView {
    
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblViewTopConstraint: NSLayoutConstraint!
    
    weak var delegate: AccountInfoTapDelegate?
    weak var delegateCreateAccount: CreateAccountInfoTapDelegate?
    weak var delegateOPCNavigation: OPCNavigationDelegate?

    var opcList: OPCType? = .open([])
    
     let webSocketManager = WebSocketManager.shared
    
   var getSymbolData = [SymbolCompleteList]()
   
    public override func awakeFromNib() {
        
        //MARK: - Handle tableview constraints according to the device logical height.
//        setTableViewLayoutConstraints()
        setTableViewLayoutTopConstraints()
        
       
        if GlobalVariable.instance.isAccountCreated { //MARK: - if account is already created.
            tblView.registerCells([
                AccountTableViewCell.self, TradeTypeTableViewCell.self, TransactionCell.self, PendingOrderCell.self, CloseOrderCell.self
            ])
        } else { //MARK: - if no account exist.
            tblView.registerCells([
                CreateAccountTVCell.self, TradeTypeTableViewCell.self, TransactionCell.self, PendingOrderCell.self, CloseOrderCell.self
            ])
        }
      
        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
    }
    
    class func getView()->AccountsVC {
        return Bundle.main.loadNibNamed("AccountsVC", owner: self, options: nil)?.first as! AccountsVC
    }
    
    func dismissView() {
        UIView.animate(
            withDuration: 0.4,
            delay: 0.04,
            animations: {
                self.alpha = 0
        }, completion: { (complete) in
            self.removeFromSuperview()
        })
    }
    
    
}

extension AccountsVC: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Just reload the given tableview section.
    func refreshSection(at section: Int) {
        let indexSet = IndexSet(integer: section)
        tblView.reloadSections(indexSet, with: .none)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return 1
        }else{
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
            
//            return  //opcList.1.count //4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if GlobalVariable.instance.isAccountCreated { //MARK: - if account is already created.
                let cell = tableView.dequeueReusableCell(with: AccountTableViewCell.self, for: indexPath)
                cell.setHeaderUI(.account)
                cell.delegate = self
                return cell
            } else { //MARK: - if no account exist.
                let cell = tableView.dequeueReusableCell(with: CreateAccountTVCell.self, for: indexPath)
                //            cell.setHeaderUI(.account)
                cell.delegate = self
                return cell
            }
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(with: TradeTypeTableViewCell.self, for: indexPath)
            cell.delegate = self
            cell.backgroundColor = .clear
            return cell
            
        }else{
            
            switch opcList {
            case .open(let openData):
//                    cell.symbolName.text = openData[indexPath.row].symbol
                
                let cell = tableView.dequeueReusableCell(with: TransactionCell.self, for: indexPath)
                if GlobalVariable.instance.isAccountCreated {
                    cell.isHidden = false
                  
                    
                    cell.getCellData(open: openData, indexPath: indexPath/*, trade: trade!, symbolDataObj: symbolDataObj*/)
                    
                }else{
                    cell.isHidden = true
                }
                return cell
                
            case .pending(let pendingData):
                
                let cell = tableView.dequeueReusableCell(with: PendingOrderCell.self, for: indexPath)
                if GlobalVariable.instance.isAccountCreated {
                    cell.isHidden = false
                    
                    cell.getCellData(pending: pendingData, indexPath: indexPath)
                    
                }else{
                    cell.isHidden = true
                }
                return cell
                
            case .close(let closeData):
                
                let cell = tableView.dequeueReusableCell(with: CloseOrderCell.self, for: indexPath)
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
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if GlobalVariable.instance.isAccountCreated { //MARK: - if account is already created.
                return 397.0
            } else { //MARK: - if no account exist.
                return 300.0
            }
        }else if indexPath.section == 1{
            return 45
            
        }else{
            return 85.0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TradeTypeTableViewCell") as? TradeTypeTableViewCell
            
            
        }
        if indexPath.section == 2 {
            
            switch opcList {
            case .open(let openData):
                
                self.delegateOPCNavigation?.navigateOPC(.open(openData[indexPath.row]))
                
                break
            case .pending(let pendingData):
                
                self.delegateOPCNavigation?.navigateOPC(.pending(pendingData[indexPath.row]))
                
                break
            case .close(let closeData):
                
                self.delegateOPCNavigation?.navigateOPC(.close(closeData[indexPath.row]))
                
                break
            case .none: break
            }
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AccountsVC: AccountInfoDelegate {
    func accountInfoTap(_ accountInfo: AccountInfo) {
        print("delegte called  \(accountInfo)" )
        
        switch accountInfo {
       
        case .deposit:
//            let vc = Utilities.shared.getViewController(identifier: .depositViewController, storyboardType: .dashboard) as! DepositViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            delegate?.accountInfoTap(.deposit)
            break
        case .withDraw:
//            let vc = Utilities.shared.getViewController(identifier: .withdrawViewController, storyboardType: .dashboard) as! WithdrawViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            delegate?.accountInfoTap(.withDraw)
            break
        case .history:
//            let vc = Utilities.shared.getViewController(identifier: .historyViewController, storyboardType: .dashboard) as! HistoryViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            delegate?.accountInfoTap(.history)
            break
        case .detail:
//            let vc = Utilities.shared.getViewController(identifier: .detailsViewController, storyboardType: .dashboard) as! DetailsViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            delegate?.accountInfoTap(.detail)
            break
        case .notification:
//            let vc = Utilities.shared.getViewController(identifier: .notificationViewController, storyboardType: .dashboard) as! NotificationViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            delegate?.accountInfoTap(.notification)
            break
        case .createAccount:
            delegate?.accountInfoTap(.createAccount)
            break
        }

        
    }
    
    
}

extension AccountsVC: CreateAccountInfoDelegate {
    
    func createAccountInfoTap(_ createAccountInfo: CreateAccountInfo) {
        print("delegte called  \(createAccountInfo)" )
        
        switch createAccountInfo {
        case .createNew:
            delegateCreateAccount?.createAccountInfoTap(.createNew)
            break
        case .unarchive:
            delegateCreateAccount?.createAccountInfoTap(.unarchive)
            break
        case .notification:
            delegateCreateAccount?.createAccountInfoTap(.notification)
            break
        }
    }
    
}

extension AccountsVC: OPCDelegate {
    func getOPCData(opcType: OPCType) {
        print("opcType = \(opcType)")
        
        self.opcList = opcType
        
        refreshSection(at: 2)
        
        //MARK: - START SOCKET and call delegate method to get data from socket.
        webSocketManager.delegateSocketMessage = self
        webSocketManager.delegateSocketPeerClosed = self
        
        //MARK: - unsubscribeTrade first.
        print("GlobalVariable.instance.previouseSymbolList = \(GlobalVariable.instance.previouseSymbolList)")
        //MARK: - START calling Socket message from here.
        webSocketManager.sendWebSocketMessage(for: "unsubscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList, isTradeDismiss: true)
        //MARK: - Remove symbol local after unsubcibe.
        GlobalVariable.instance.previouseSymbolList.removeAll()
        
        
        
        let symbolList = getFormattedSymbols(opcType: opcType)
        GlobalVariable.instance.previouseSymbolList = symbolList
        //MARK: - START calling Socket message from here.
        webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: symbolList)
        
        
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
            for item in openData {
                
                var getSymbol = getSymbol(item: item.symbol)
                
                self.getSymbolData.append(SymbolCompleteList(tickMessage: TradeDetails(datetime: 0, symbol: getSymbol, ask: 0.0, bid: 0.0, url: "", close: 0)))
            }
            
            return openData.map { symbol in
                var symbol = symbol
                
                var getSymbol = getSymbol(item: symbol.symbol)
                
                return getSymbol
            }
            
        case .pending(let pendingData):
            
            self.getSymbolData.removeAll()
            for item in pendingData {
                
                var getSymbol = getSymbol(item: item.symbol)
                
                self.getSymbolData.append(SymbolCompleteList(tickMessage: TradeDetails(datetime: 0, symbol: getSymbol, ask: 0.0, bid: 0.0, url: "", close: 0)))
            }
            
            return pendingData.map { symbol in
                var symbol = symbol
                
                var getSymbol = getSymbol(item: symbol.symbol)
                
                return getSymbol
            }
            
        case .close(let closeData):
            
            self.getSymbolData.removeAll()
            for item in closeData {
                
                var getSymbol = getSymbol(item: item.symbol)
                
                self.getSymbolData.append(SymbolCompleteList(tickMessage: TradeDetails(datetime: 0, symbol: getSymbol, ask: 0.0, bid: 0.0, url: "", close: 0)))
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

//MARK: - Layout Constraints.
extension AccountsVC {
    
    //MARK: - Set TableViewTopConstraint.
    private func setTableViewLayoutTopConstraints() {
        
        if UIDevice.isPhone {
            print("screen_height = \(screen_height)")
            if screen_height >= 667.0 && screen_height <= 736.0 {
                //MARK: - iphone6s, iphoneSE, iphone7 plus
                tblViewTopConstraint.constant = -20
                
            } else if screen_height == 812.0 {
                //MARK: - iphoneXs
                tblViewTopConstraint.constant = -30
                
            } else if screen_height >= 852.0 && screen_height <= 932.0 {
                //MARK: - iphone14 pro, iphone14, iphone14 Plus, iphone14 Pro Max
                tblViewTopConstraint.constant = -60
                
            }else if screen_height == 844.0 {
                tblViewTopConstraint.constant = -55
            } else {
                //MARK: - other iphone if not in the above check's.
                tblViewTopConstraint.constant = 0
            }
            
        } else {
            //MARK: - iPad
            
        }
        
    }
    
    private func setTableViewLayoutConstraints() {
        
        if UIDevice.isPhone {
            print("screen_height = \(screen_height)")
            if screen_height >= 667.0 && screen_height <= 736.0 {
                //MARK: - iphone6s, iphoneSE, iphone7 plus
                tableViewBottomConstraint.constant = 145
                
            } else if screen_height == 812.0 {
                //MARK: - iphoneXs
                tableViewBottomConstraint.constant = 165
                
            } else if screen_height >= 852.0 && screen_height <= 932.0 {
                //MARK: - iphone14 pro, iphone14, iphone14 Plus, iphone14 Pro Max
                tableViewBottomConstraint.constant = 175
                
            } else if screen_height == 844.0 {
                tableViewBottomConstraint.constant = 175
            } else {
                //MARK: - other iphone if not in the above check's.
                tableViewBottomConstraint.constant = 165
            }
            
        }
        
    }
    
}


extension AccountsVC: SocketPeerClosed {
    
    func peerClosed() {
        
        GlobalVariable.instance.changeSector = true
        
//        setTradeModel(collectionViewIndex: GlobalVariable.instance.getSectorIndex)
        
    }
    
}

//MARK: - Get Socket Tick, History and Unsubcribe and update the list accordingly.
extension AccountsVC: GetSocketMessages {
    
    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?, historyMessage: SymbolChartData?) {
        switch socketMessageType {
        case .tick:
            
            //MARK: - Compare the symbol which is coming from Socket with our Selected Sector symbol list and update our list (getSymbolData).
            if let getTick = tickMessage {
//                let matchedSymbols = getSymbolData.filter { $0.tickMessage?.symbol == getTick.symbol }

                if let index = getSymbolData.firstIndex(where: { $0.tickMessage?.symbol == getTick.symbol }) {
                    getSymbolData[index].tickMessage = tickMessage

//                    //MARK: - If tick flag is true then we just update the label only not reload the tableview.
//                    if getSymbolData[index].isTickFlag ?? false {
                        let indexPath = IndexPath(row: index, section: 2)

                        switch opcList {
                        case .open(let openData):
                            
                            //MARK: - Get All Matched Symbols data and Set accordingly.
                            
                            for i in 0...openData.count-1 {
                                
//                                        for item in matchedSymbols {
//                                            if item.tickMessage?.symbol ==
//                                        }
                                
                                let myIndexPath = IndexPath(row: i, section: 2)
                                
                                if let cell = tblView.cellForRow(at: myIndexPath) as? TransactionCell {
                                    if GlobalVariable.instance.isAccountCreated {
                                        cell.isHidden = false
                                        
//                                        print("cell.lbl_symbolName.text = \(cell.lbl_symbolName.text)")
//                                        print("openData[\(i)].symbol = \(openData[index].symbol)")
                                        if cell.lbl_symbolName.text == openData[index].symbol {
                                            
                                            let profitLoss: Double = Double(openData[index].priceOpen) - (getSymbolData[index].tickMessage?.bid ?? 0.0)
                                            
                                            if profitLoss < 0.0 {
                                                cell.lbl_profitValue.textColor = .systemRed
                                                let roundValue = String(format: "%.2f", profitLoss)
                                                
                                                cell.lbl_profitValue.text = "\(roundValue)"
                                            }else{
                                                cell.lbl_profitValue.textColor = .systemGreen
                                                let roundValue = String(format: "%.2f", profitLoss)
                                                
                                                cell.lbl_profitValue.text = "\(roundValue)"
                                            }
                                            
                                            let bidValuess = String(format: "%.3f", getSymbolData[index].tickMessage?.bid ?? 0.0)
                                            cell.lbl_currentPrice.text = "\(bidValuess)"
                                            
                                        }
                                        
                                    }else{
                                        cell.isHidden = true
                                    }
                                }
                            }
                            
                         
                            
                        case .pending(let pendingData):
                            
                            if let cell = tblView.cellForRow(at: indexPath) as? PendingOrderCell {
                                if GlobalVariable.instance.isAccountCreated {
                                    cell.isHidden = false
                                    
//                                    cell.getCellData(pending: pendingData, indexPath: indexPath)
                                    
                                    
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
                        
//                    } else { //MARK: - Else flag is false it means that this symbol data coming from socket is first time, then we must reload the compared symbol index only.
////                        refreshSectionRow(at: 2, row: index)
//                        getSymbolData[index].isTickFlag = true
//                    }
                    
                    return
                }
            }

            break
        case .history:
            
            if let getHistory = historyMessage {
                if let index = getSymbolData.firstIndex(where: { $0.tickMessage?.symbol == getHistory.symbol }) {
                    getSymbolData[index].historyMessage = historyMessage
                    
                    let indexPath = IndexPath(row: index, section: 2)
                    if let cell = tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
                        cell.configureChart(getSymbolData: getSymbolData[index])
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
                webSocketManager.delegateSocketMessage = self
                webSocketManager.connectWebSocket()
            }
            
            break
        }
    }
    
}

