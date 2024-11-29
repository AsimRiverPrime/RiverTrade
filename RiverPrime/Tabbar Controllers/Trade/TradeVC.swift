
import UIKit
import Starscream
import Alamofire
//import AEXML
import Foundation

//protocol TradeDetailTapDelegate: AnyObject {
//    func tradeDetailTap(indexPath: IndexPath, getSymbolData: SymbolCompleteList)
//}
//
//struct SymbolCompleteList {
//    var tickMessage: TradeDetails?
//    var historyMessage: SymbolChartData?
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
//    
//    init(id: String, name: String, description: String, icon_url: String, volumeMin: String, volumeMax: String, volumeStep: String, contractSize: String, displayName: String, sector: String, digits: String, stopsLevel: String, swapLong: String, swapShort: String, spreadSize: String, mobile_available: String, yesterday_close: String) {
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
//    }
//    
//}
//
//struct SectorGroup {
//    let sector: String
//    let symbols: [SymbolData]
//}

class TradeVC: UIView {
    
    
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblViewTopConstraint: NSLayoutConstraint!
    
    weak var delegate: TradeInfoTapDelegate?
    weak var delegateDetail: TradeDetailTapDelegate?
   
//    var odooClientService = OdooClient()
    
    let vm = TradeVM()
     
    var getSymbolData = [SymbolCompleteList]()
    
    var timer: Timer?
    var timeLeft = 60 // seconds
    var isTimerRunMoreThenOnce = false
    var symbolDataObj: SymbolData?
    
    public override func awakeFromNib() {
//        ActivityIndicator.shared.show(in: self)
        
        //MARK: - Call Symbol Api and their delegate method to get data.
//        odooClientService.sendSymbolDetailRequest()
//        odooClientService.tradeSymbolDetailDelegate = self
        //MARK: - if Symbol Api data is exist then we must set our list data.
        if GlobalVariable.instance.symbolDataArray.count != 0 {
            //MARK: - Get the list and save localy and set sectors and symbols.
            processSymbols(GlobalVariable.instance.symbolDataArray)
            
            //MARK: - Reload tablview when all data set into the list at first time.
            self.tblView.reloadData()
        }
        //MARK: - START SOCKET and call delegate method to get data from socket.
        vm.webSocketManager.delegateSocketMessage = self
        vm.webSocketManager.delegateSocketPeerClosed = self
//        vm.webSocketManager.connectWebSocket()
        
        isTimerRunMoreThenOnce = false
        
        //MARK: - Handle tableview constraints according to the device logical height.
        //        setTableViewLayoutConstraints()
        setTableViewLayoutTopConstraints()
        
        tblView.registerCells([
            TradeHeaderTVCell.self,TradeTVC.self, TradeTableViewCell.self
        ])
        
        tblView.delegate = self
        tblView.dataSource = self
      
    }
    
    class func getView()->TradeVC {
        return Bundle.main.loadNibNamed("TradeVC", owner: self, options: nil)?.first as! TradeVC
    }
    
    func dismissView(_ trade: Bool) {
        timer?.invalidate()
        timer = nil
        if !trade {
            
            print("GlobalVariable.instance.previouseSymbolList = \(GlobalVariable.instance.previouseSymbolList)")
            
            //MARK: - START calling Socket message from here.
            vm.webSocketManager.sendWebSocketMessage(for: "unsubscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList, isTradeDismiss: true)
            
            //MARK: - Remove symbol local after unsubcibe.
            GlobalVariable.instance.previouseSymbolList.removeAll()
            
        }
        UIView.animate(
            withDuration: 0.4,
            delay: 0.04,
            animations: {
                self.alpha = 0
            }, completion: { (complete) in
                self.removeFromSuperview()
//                self.viewModel.webSocketManager.closeWebSockets() // or send unsubcribe call for socket stop
            })
    }
    
}

extension TradeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return 1
        }else{
            //MARK: - get this list data from symbol api.
            return getSymbolData.count //vm.numberOfRows()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: TradeHeaderTVCell.self, for: indexPath)
//            cell.setHeaderUI(.trade)
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(with: TradeTVC.self, for: indexPath)
            
            //MARK: - Get sector values from Symbol Api also call delegate method because when we click on different sectors then list should update through this delegate method.
            cell.delegate = self
            cell.config(GlobalVariable.instance.sectors)
            
            cell.backgroundColor = .clear
            
            return cell
            
        }else  {
            
            let cell = tableView.dequeueReusableCell(with: TradeTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            
            //MARK: - getSymbolData list is comming from symbol api.
            let trade = getSymbolData[indexPath.row].tickMessage//?[indexPath.row]
           
            
            //MARK: - Get selected sector value and compare with repeated sector values and show the list of symbols with in this sector.
            if let obj = GlobalVariable.instance.symbolDataArray.first(where: {$0.name == trade?.symbol}) {
                symbolDataObj = obj
                //   print("\(obj.icon_url)")
            }
            
//            if GlobalVariable.instance.isProcessingSymbol { // MARK: - When History data coming from API then IF Statement is working and update chart according to the values.
//                GlobalVariable.instance.isProcessingSymbol = false
//                let getSymbolData = getSymbolData[indexPath.row]
//                cell.configureChart(getSymbolData: getSymbolData)
//            } else { //MARK: - Showing the list of Symbols according to the selected sector in else statement.
//                cell.configure(with: trade! , symbolDataObj: symbolDataObj)
//            }
            
            //MARK: - Showing the list of Symbols according to the selected sector in else statement.
                cell.configure(with: trade! , symbolDataObj: symbolDataObj)
            
            // Disable interaction for specific cells
            if !(getSymbolData[indexPath.row].isTickFlag ?? false) { //MARK: - User Interface disabled, when tick flag is false.
                cell.isUserInteractionEnabled = false
                cell.contentView.alpha = 0.5 // Visual cue that the cell is disabled
                cell.selectionStyle = .none // No selection effect
            } else {
                cell.isUserInteractionEnabled = true
                cell.contentView.alpha = 1.0
                cell.selectionStyle = .none
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            
            
            
        } else if indexPath.section == 2 {
            
            //MARK: - When we click on the symbol list index then it should move and show history data into the detail page.
            let getSymbolData = getSymbolData[indexPath.row]
            if getSymbolData.historyMessage?.chartData.count != 0 {
                delegateDetail?.tradeDetailTap(indexPath: indexPath, getSymbolData: getSymbolData)
            }
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        }else if indexPath.section == 1{
            return 50
            
        }else{
            return 90.0
        }
    }
    
    //MARK: - Just reload the given tableview section.
    func refreshSection(at section: Int) {
        let indexSet = IndexSet(integer: section)
        tblView.reloadSections(indexSet, with: .automatic)
        
    }
    
    //MARK: - Reload the given section and row of tableview.
    func refreshSectionRow(at section: Int, row: Int) {
        let indexPath = IndexPath(row: row, section: section)
        tblView.reloadRows(at: [indexPath], with: .none)
    }
}


//MARK: - Set TableViewTopConstraint.
extension TradeVC {
    
    private func setTableViewLayoutTopConstraints() {
        
        if UIDevice.isPhone {
            print("screen_height = \(screen_height)")
            if screen_height >= 667.0 && screen_height <= 736.0 {
                //MARK: - iphone6s, iphoneSE, iphone7 plus
                tblViewTopConstraint.constant = -20
                
            } else if screen_height == 812.0 {
                //MARK: - iphoneXs
                tblViewTopConstraint.constant = -45
                
            } else if screen_height >= 852.0 && screen_height <= 932.0 {
                //MARK: - iphone14 pro, iphone14, iphone14 Plus, iphone14 Pro Max
                tblViewTopConstraint.constant = -60
                
            }else if screen_height == 844.0 {
                //MARK: - iphone12 pro,
                tblViewTopConstraint.constant = -55
            } else {
                //MARK: - other iphone if not in the above check's.
                tblViewTopConstraint.constant = 0
            }
            
        } else {
            //MARK: - iPad
            
        }
        
    }
    
}

extension TradeVC: SocketPeerClosed {
    
    func peerClosed() {
        
        GlobalVariable.instance.changeSector = true
        
        setTradeModel(collectionViewIndex: GlobalVariable.instance.getSectorIndex)
    
    }
    
}

extension TradeVC {
    
    private func fetchHistoryChartData(_ symbol: String) {
        
        vm.fetchChartHistory(symbol: symbol) { result in
//            print("result of trade history data = \(result)")
            switch result {
            case .success(let responseData):
//                print("Symbol: \(responseData.symbol)")
//                print("Chart Data: \(responseData.chartData)")
                
                if let index = self.getSymbolData.firstIndex(where: { $0.tickMessage?.symbol == responseData.symbol }) {
                    self.getSymbolData[index].historyMessage = responseData
                    
                    let indexPath = IndexPath(row: index, section: 2)
                    if let cell = self.tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
//                            print("getSymbolData[\(index)] = \(getSymbolData[index])")
//   //                        getSymbolData[index].isHistoryFlag = true
//                           GlobalVariable.instance.isProcessingSymbol = false
                        GlobalVariable.instance.isProcessingSymbolTimer = false
//                            cell.configureChart(getSymbolData: getSymbolData[index])
                        cell.configureChart(getSymbolData: responseData)
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
extension TradeVC: GetSocketMessages {
  
    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?, historyMessage: SymbolChartData?) {
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
                           let indexPath = IndexPath(row: index, section: 2)
                           if let cell = tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
                               getSymbolData[index].isTickFlag = true
//                               cell.lblAmount.text = "\(getSymbolData[index].tickMessage?.bid ?? 0.0)".trimmedTrailingZeros()
                             
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
                               print("\n new value is: \(newValue)")
                               
//                               double diff = newBid - oldBid;
//                               double percentageChange = (diff / oldBid) * 100;
//                               return Math.round(percentageChange * 100.0) / 100.0;
                               
                               cell.lblPercent.text = "\(percent) %"
                               
                               if percent.contains("inf") {
                                   cell.lblPercent.text = "0.0 %"
                               }
                               
                               if newValue > 0.0 {
                                   cell.profitIcon.image = UIImage(systemName: "arrow.up")
                                   cell.profitIcon.tintColor = .systemGreen
                                   cell.lblPercent.textColor = .systemGreen
                                   //MARK: - Update options -> Green
                                   
                                   cell.options = AreaSeriesOptions(
                                    priceLineVisible: false,
                                    topColor: "rgba(76, 175, 80, 0.5)",
                                    bottomColor: "rgba(76, 175, 80, 0)",
                                    lineColor: "rgba(76, 175, 80, 1)",
                                    lineWidth: .one
                                   )
                               
                               } else {
                                   cell.profitIcon.image = UIImage(systemName: "arrow.down")
                                   cell.profitIcon.tintColor = .systemRed
                                   cell.lblPercent.textColor = .systemRed
                                   //MARK: - Update options -> Red
                                   cell.options = AreaSeriesOptions(
                                    priceLineVisible: false,
                                    topColor: "rgba(255, 0, 0, 0.5)",
                                    bottomColor: "rgba(255, 0, 0, 0)",
                                    lineColor: "rgba(255, 0, 0, 1)",
                                    lineWidth: .one
                                   )
                                   
                               }
                               
                               //MARK: - User Interface enabled, when tick flag is true.
                               cell.isUserInteractionEnabled = true
                               cell.contentView.alpha = 1.0
                               cell.selectionStyle = .default
                           }
                       
                       return
                   }
               }

               break
           case .history:
               
//               if let getHistory = historyMessage {
//                   if let index = getSymbolData.firstIndex(where: { $0.tickMessage?.symbol == getHistory.symbol }) {
//                       getSymbolData[index].historyMessage = historyMessage
//                       
//                       let indexPath = IndexPath(row: index, section: 2)
//                       if let cell = tblView.cellForRow(at: indexPath) as? TradeTableViewCell {
//                           print("getSymbolData[\(index)] = \(getSymbolData[index])")
////   //                        getSymbolData[index].isHistoryFlag = true
////                           GlobalVariable.instance.isProcessingSymbol = false
//                           GlobalVariable.instance.isProcessingSymbolTimer = false
//                           cell.configureChart(getSymbolData: getSymbolData[index])
//                       }
//                  
//                       return
//                   }
//               }

               break
               
           case .Unsubscribed:
               
               //MARK: - Before change any sector we must unsubcribe already selected and then again update according to the new selected sector.
               
               GlobalVariable.instance.changeSector = true
               
               setTradeModel(collectionViewIndex: GlobalVariable.instance.getSectorIndex)
               
               if vm.webSocketManager.isSocketConnected() {
                   print("Socket is connected")
               } else {
                   print("Socket is not connected")
                   //MARK: - START SOCKET.
                   vm.webSocketManager.delegateSocketMessage = self
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
extension TradeVC: TradeInfoTapDelegate {
    
    func tradeInfoTap(_ tradeInfo: SectorGroup, index: Int) {
        
        //MARK: - When click on sector to change the values then it should unsubcribe first and then update new selected sector.
        
//        setModel(tradeInfo)
        
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
extension TradeVC { //: TradeSymbolDetailDelegate {
//    func tradeSymbolDetailSuccess(response: String) {
////        print("\n \(response) ")
//        convertXMLIntoJson(response)
//        ActivityIndicator.shared.hide(from: self)
//    }
//    
//    func tradeSymbolDetailFailure(error: any Error) {
//        print("\n the trade symbol detail Error response: \(error) ")
//    }
//    
//    func convertXMLIntoJson(_ xmlString: String) {
//        
//        do {
//            let xmlDoc = try AEXMLDocument(xml: xmlString)
//
//            if let xmlDocFile = xmlDoc.root["params"]["param"]["value"]["array"]["data"]["value"].all {
//                
//                
//                for param in xmlDocFile {
//                    if let structElement = param["struct"].first {
//                        var parsedData: [String: Any] = [:]
//                        for member in structElement["member"].all ?? [] {
//                            let name = member["name"].value ?? ""
//                            let value = member["value"].children.first?.value ?? ""
//                            parsedData[name] = value
//                        }
//                        
//                        if let symbolId = parsedData["id"] as? String, let symbolName = parsedData["name"] as? String,
//                            let symbolDescription = parsedData["description"] as? String, let symbolIcon = parsedData["icon_url"] as? String,
//                            let symbolVolumeMin = parsedData["volume_min"] as? String, let symbolVolumeMax = parsedData["volume_max"] as? String,
//                            let symbolVolumeStep = parsedData["volume_step"] as? String, let symbolContractSize = parsedData["contract_size"] as? String,
//                           let symbolDisplayName = parsedData["display_name"] as? String, let symbolSector = parsedData["sector"] as? String, let symbolDigits = parsedData["digits"] as? String, let symbolMobile_available = parsedData["mobile_available"] as? String,  let symbolSwap_long = parsedData["swap_long"] as? String , let symbolStops_level = parsedData["stops_level"] as? String,  let symbolSpread_size = parsedData["spread_size"] as? String, let symbolSwap_short = parsedData["swap_short"] as? String   {
//                         
//                            
//                            let originalUrl = symbolIcon // "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/platinum-01.svg"
//                            print(" originalUrl URL: \(originalUrl)")
//                            // Replace the part of the URL
//                            let modifiedUrl = originalUrl
//                                .replacingOccurrences(of: "-01.svg", with: ".png")
//                                .replacingOccurrences(of: ".com/", with: ".com/png/")
//
//                            print("\n modifiy URL: \(modifiedUrl)")
//                            
//                            GlobalVariable.instance.symbolDataArray.append(SymbolData(id: symbolId , name: symbolName , description: symbolDescription , icon_url: modifiedUrl , volumeMin: symbolVolumeMin , volumeMax: symbolVolumeMax , volumeStep: symbolVolumeStep , contractSize: symbolContractSize , displayName: symbolDisplayName , sector: symbolSector , digits: symbolDigits,  stopsLevel: symbolStops_level, swapLong: symbolSwap_long, swapShort: symbolSwap_short, spreadSize: symbolSpread_size, mobile_available: symbolMobile_available))
//                        }
//                           
//                        print("symbol data array : \(GlobalVariable.instance.symbolDataArray.count)")
//                       
//                        print("\n the parsed value is :\(parsedData)")
//                    }
//                }
////                print("GlobalVariable.instance.symbolDataArray = \(GlobalVariable.instance.symbolDataArray)")
//                
//                //MARK: - Get the list and save localy and set sectors and symbols.
//                processSymbols(GlobalVariable.instance.symbolDataArray)
//                
//                //MARK: - Reload tablview when all data set into the list at first time.
//                self.tblView.reloadData()
//            }
//        } catch {
//            print("Failed to parse XML: \(error.localizedDescription)")
//        }
//
//    }
    
    func filterSymbolsBySector(symbols: [SymbolData], sector: String) -> [String] {
        return symbols.filter { $0.sector == sector }.map { $0.displayName }
    }
    
    func filterSymbolsImageBySector(symbols: [SymbolData], sector: String) -> [String] {
        return symbols.filter { $0.sector == sector }.map { $0.icon_url }
    }
    
    /*
    private func processSymbols(_ symbols: [SymbolData]) {
        var sectorDict = [String: [SymbolData]]()
        
        for symbol in symbols {
            if sectorDict[symbol.sector] != nil {
                sectorDict[symbol.sector]?.append(symbol)
            } else {
                sectorDict[symbol.sector] = [symbol]
            }
        }
        
        GlobalVariable.instance.sectors = sectorDict.map { SectorGroup(sector: $0.key, symbols: $0.value) }
        
        saveSymbolsToDefaults(symbols)
        
        //MARK: - Init it will be zero.
        setTradeModel(collectionViewIndex: 0)
    }
    */
    
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
extension TradeVC {
    
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
            getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail, historyMessage: symbolChartData, isTickFlag: false, isHistoryFlag: false, isHistoryFlagTimer: false))
        }
        
        print("GlobalVariable.instance.filteredSymbolsUrl = \(GlobalVariable.instance.filteredSymbolsUrl)")
        
        GlobalVariable.instance.isProcessingSymbol = false
        
        refreshSection(at: 2)
        
        //MARK: - Save symbol local to unsubcibe.
        GlobalVariable.instance.previouseSymbolList = selectedSymbols
        
        //MARK: - START calling Socket message from here.
        vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: selectedSymbols)
        
        timer?.invalidate()
        timer = nil
        GlobalVariable.instance.isProcessingSymbolTimer = false
        start60SecondsCountdown()
        
    }

    
}

