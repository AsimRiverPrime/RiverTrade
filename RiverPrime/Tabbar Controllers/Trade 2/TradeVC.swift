//
//  TradeVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/07/2024.
//

import UIKit
import Starscream
import Alamofire
import AEXML
import Foundation

protocol TradeDetailTapDelegate: AnyObject {
    func tradeDetailTap(indexPath: IndexPath, details: TradeDetails)
}

struct SymbolCompleteList {
    var tickMessage: TradeDetails?
    var historyMessage: SymbolChartData?
}

class TradeVC: UIView {
    
    
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblViewTopConstraint: NSLayoutConstraint!
    
    weak var delegate: TradeInfoTapDelegate?
    weak var delegateDetail: TradeDetailTapDelegate?
   
    var odooClientService = OdooClient()
    
//     let viewModel = TradesViewModel()
    let vm = TradeVM()
     
//    var symbolDataArray: [SymbolData] = []
    
    var getSymbolData = [SymbolCompleteList]()
    
    public override func awakeFromNib() {
        ActivityIndicator.shared.show(in: self)
        
        odooClientService.sendSymbolDetailRequest()
        odooClientService.tradeSymbolDetailDelegate = self
        
        
////        vm.webSocketManager.connectWebSocket()
//        
////        NotificationCenter.default.addObserver(self, selector: #selector(socketConnectivity(_:)), name: .checkSocketConnectivity, object: nil)
////        
        //MARK: - START SOCKET.
        vm.webSocketManager.delegateSocketMessage = self
        vm.webSocketManager.connectWebSocket()
        
        //MARK: - Handle tableview constraints according to the device logical height.
        //        setTableViewLayoutConstraints()
        setTableViewLayoutTopConstraints()
        
        tblView.registerCells([
            AccountTableViewCell.self,TradeTVC.self, TradeTableViewCell.self
        ])
        
        tblView.delegate = self
        tblView.dataSource = self
      
        
//        // Bind the ViewModel's data update closure to reload the table view
//        vm.onTradesUpdated = { [weak self] in
//            if !GlobalVariable.instance.changeSector {
//                self?.tblView.reloadData()
//            }
////            self?.tblView.reloadData()
//////            if !GlobalVariable.instance.isStopTick {
//////                self?.tblView.reloadData()
////////                self?.refreshSectionRow(at: 2, row: 0)
//////            } else {
//////                if !GlobalVariable.instance.isStopHistory {
//////                    self?.refreshSectionRow(at: 2, row: 0)
//////                }
////////                self?.refreshSectionRow(at: 2, row: 0)
//////            }
//        }
    }
    
    @objc private func socketConnectivity(_ notification: NSNotification) {
        if let listData = notification.userInfo?["isConnect"] as? String {
            print("listData = \(listData)") // TODO: get bool value in string.
            odooClientService.sendSymbolDetailRequest()
            odooClientService.tradeSymbolDetailDelegate = self
        }
    }
    
    class func getView()->TradeVC {
        return Bundle.main.loadNibNamed("TradeVC", owner: self, options: nil)?.first as! TradeVC
    }
    
    func dismissView() {
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
            return vm.numberOfRows()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: AccountTableViewCell.self, for: indexPath)
            cell.setHeaderUI(.trade)
            //            cell.delegate = self
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(with: TradeTVC.self, for: indexPath)
            cell.delegate = self
//            cell.config(GlobalVariable.instance.symbolDataArray)
            cell.config(GlobalVariable.instance.sectors)
            cell.backgroundColor = .clear
            
            return cell
            
        }else  {
            /*
            let cell = tableView.dequeueReusableCell(with: TradeTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            
//            if GlobalVariable.instance.changeSymbol {
//                return cell
//            }
            
            let trade = vm.trade(at: indexPath)
            
            var symbolDataObj: SymbolData?
            
            if let obj = GlobalVariable.instance.symbolDataArray.first(where: {$0.name == trade.symbol}) {
                symbolDataObj = obj
                //   print("\(obj.icon_url)")
            }
            
            cell.configure(with: trade , symbolDataObj: symbolDataObj)
            */
            
            let cell = tableView.dequeueReusableCell(with: TradeTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            
//            let trade = vm.trade(at: indexPath)
            let trade = getSymbolData[0].tickMessage//?[indexPath.row]
            
            var symbolDataObj: SymbolData?
            
            if let obj = GlobalVariable.instance.symbolDataArray.first(where: {$0.name == trade?.symbol}) {
                symbolDataObj = obj
                //   print("\(obj.icon_url)")
            }
            
            cell.configure(with: trade! , symbolDataObj: symbolDataObj)
            
//            let cell = TradeTableViewCell.cellForTableView(tableView, atIndexPath: indexPath, trades: vm.trades)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            
        } else if indexPath.section == 2 {
            
            let selectedSymbol = Array(WebSocketManager.shared.trades.keys)[indexPath.row]
            if let tradeDetail = WebSocketManager.shared.trades[selectedSymbol] {
                delegateDetail?.tradeDetailTap(indexPath: indexPath, details: tradeDetail)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300.0
        }else if indexPath.section == 1{
            return 40
            
        }else{
            return 90.0
        }
    }
    
    func refreshSection(at section: Int) {
        let indexSet = IndexSet(integer: section)
        tblView.reloadSections(indexSet, with: .automatic)
        
    }
    
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
                tblViewTopConstraint.constant = -30
                
            } else if screen_height >= 852.0 && screen_height <= 932.0 {
                //MARK: - iphone14 pro, iphone14, iphone14 Plus, iphone14 Pro Max
                tblViewTopConstraint.constant = -60
                
            } else {
                //MARK: - other iphone if not in the above check's.
                tblViewTopConstraint.constant = 0
            }
            
        } else {
            //MARK: - iPad
            
        }
        
    }
    
}

extension TradeVC: GetSocketMessages {
    
    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?, historyMessage: SymbolChartData?) {
        switch socketMessageType {
        case .tick:
            
//            for i in 0...getSymbolData.count {
////                for i in 0...item.tickMessage!.count-1 {
////                    if item.tickMessage?[i].symbol == tickMessage?.symbol {
////                        getSymbolData.insert(SymbolCompleteList(tickMessage: tickMessage), at: i)
////                    }
////                }
////                if getSymbolData
//                if let tickMsg = getSymbolData[i].tickMessage, let getTick = tickMessage {
//                    if tickMsg.symbol == getTick.symbol {
//    //                    getSymbolData.insert(SymbolCompleteList(tickMessage: tickMessage), at: i)
//                        getSymbolData[i].tickMessage = tickMessage
//                        refreshSectionRow(at: 2, row: i)
//                        return
//                    }
//                }
//            }
            
            if let getTick = tickMessage {
                if let index = getSymbolData.firstIndex(where: { $0.tickMessage?.symbol == getTick.symbol }) {
                    getSymbolData[index].tickMessage = tickMessage
                    refreshSectionRow(at: 2, row: index)
                    return
                }
            }

            
//            var tempList = [SymbolCompleteList]()
//            for item in getSymbolData {
//                tempList
//                if let tickMsg = item.tickMessage, let getTick = tickMessage {
//                    if tickMsg.symbol == getTick.symbol {
//                        
//                    }
//                }
//            }
            
//            getSymbolData.append(SymbolCompleteList(tickMessage: vm.trades))
//            
//            refreshSection(at: 2)
            
            
            break
        case .history:
            
            break
        }
    }
    
}

extension TradeVC: TradeInfoTapDelegate {
    
    func tradeInfoTap(_ tradeInfo: SectorGroup, index: Int) {
        
//        setModel(tradeInfo)
        
        print("tradeInfo = \(tradeInfo)")
        
        GlobalVariable.instance.changeSector = true
        
        setTradeModel(collectionViewIndex: index)
        
//        refreshSection(at: 2)
        /*
        
        let symbol = getSavedSymbols().map { $0 }
        let sector = tradeInfo //GlobalVariable.instance.sectors.map { $0.sector }
        GlobalVariable.instance.getSelectedSectorSymbols.1.removeAll()
        guard let mySymbol = symbol else { return }
        for item in mySymbol {
            if sector.sector == item.sector {
                GlobalVariable.instance.getSelectedSectorSymbols.1.append(item.name)
//                viewModel.trades.append(TradeDetails(datetime: item., symbol: <#T##String#>, ask: <#T##Double#>, bid: <#T##Double#>))
//                viewModel.removeTradeList()
            }
        }
        vm.removeTradeList()
        refreshSection(at: 2)
        vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: GlobalVariable.instance.getSelectedSectorSymbols.1)
//        refreshSection(at: 1)
       
//        tblView.reloadData()
        
        */
        
    }
}

extension TradeVC: TradeSymbolDetailDelegate {
    func tradeSymbolDetailSuccess(response: String) {
//        print("\n \(response) ")
        convertXMLIntoJson(response)
        ActivityIndicator.shared.hide(from: self)
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
                           let symbolDisplayName = parsedData["display_name"] as? String, let symbolSector = parsedData["sector"] as? String, let symbolDigits = parsedData["digits"] as? String, let symbolMobile_available = parsedData["mobile_available"] as? String {
                         
                            GlobalVariable.instance.symbolDataArray.append(SymbolData(id: symbolId , name: symbolName , description: symbolDescription , icon_url: symbolIcon , volumeMin: symbolVolumeMin , volumeMax: symbolVolumeMax , volumeStep: symbolVolumeStep , contractSize: symbolContractSize , displayName: symbolDisplayName , sector: symbolSector , digits: symbolDigits, mobile_available: symbolMobile_available ))
                        }
                           
                        print("symbol data array : \(GlobalVariable.instance.symbolDataArray.count)")
                       
                        print("\n the parsed value is :\(parsedData)")
                    }
                }
//                print("GlobalVariable.instance.symbolDataArray = \(GlobalVariable.instance.symbolDataArray)")
                processSymbols(GlobalVariable.instance.symbolDataArray)
                self.tblView.reloadData()
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
    
    //MARK: - This is chatgptcode just for reference.
    /*
    func parseSymbols(from jsonString: String) -> [SymbolData] {
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let symbols = try decoder.decode([SymbolData].self, from: data)
            return symbols
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }

    func filterSymbolsBySector(symbols: [SymbolData], sector: String) -> [String] {
        return symbols.filter { $0.sector == sector }.map { $0.displayName }
    }
    */
    
    //MARK: - And this is the code where we use the above chatgpt commented code.    
    /*
    import Foundation
    import Starscream

    // Define the WebSocketManager
    class WebSocketManager: WebSocketDelegate {
        var socket: WebSocket!
        
        init() {
            var request = URLRequest(url: URL(string: "wss://mbe.riverprime.com/mobile_web_socket")!)
            request.timeoutInterval = 5
            socket = WebSocket(request: request)
            socket.delegate = self
        }
        
        func connect() {
            socket.connect()
        }
        
        func disconnect() {
            socket.disconnect()
        }
        
        func send(message: [String: Any]) {
            do {
                let data = try JSONSerialization.data(withJSONObject: message, options: [])
                socket.write(data: data)
            } catch {
                print("Error serializing message: \(error)")
            }
        }
        
        func websocketDidConnect(socket: WebSocketClient) {
            print("WebSocket connected")
        }

        func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
            if let error = error {
                print("WebSocket disconnected with error: \(error)")
            } else {
                print("WebSocket disconnected")
            }
        }

        func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
            print("Received text: \(text)")
        }

        func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
            print("Received data: \(data)")
        }
    }

    // Usage

    let jsonString = """
    [... Your JSON data ...]
    """

    let symbols = parseSymbols(from: jsonString)

    // Create a WebSocketManager instance
    let webSocketManager = WebSocketManager()

    // Connect to the WebSocket
    webSocketManager.connect()

    // Define the sectors
    let sectors = ["Currency", "Commodities", "Energy", "Indices"]

    // Iterate over each sector and send subscription messages
    for sector in sectors {
        let filteredSymbols = filterSymbolsBySector(symbols: symbols, sector: sector)
        let message: [String: Any] = [
            "event_name": "subscribe",
            "data": [
                "last": 0,
                "channels": filteredSymbols.isEmpty ? [""] : filteredSymbols
            ]
        ]
        webSocketManager.send(message: message)
    }
    */
    
    
    
    
    
    
    
    
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
        
//        print("GlobalVariable.instance.sectors = \(GlobalVariable.instance.sectors.map { $0.sector })")
//        print("symbols = \(symbols.map { $0.sector })")
//        print("GlobalVariable.instance.symbolDataArray = \(GlobalVariable.instance.symbolDataArray.map { $0.sector })")
        
        saveSymbolsToDefaults(symbols)
//        print("getSavedSymbols() = \(getSavedSymbols())")
        
//        //MARK: - START SOCKET.
//        vm.webSocketManager.connectWebSocket()
        
        //MARK: - Init it will be zero.
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

extension TradeVC {
    
    private func setTradeModel1(collectionViewIndex: Int) {
        
//        let trade = vm.trade(at: indexPath)
//        
//        var symbolDataObj: SymbolData?
//        
//        if let obj = GlobalVariable.instance.symbolDataArray.first(where: {$0.name == trade.symbol}) {
//            symbolDataObj = obj
//            //   print("\(obj.icon_url)")
//        }
        
        
        
        
        
//        let data = GlobalVariable.instance.symbolDataArray.map { $0 }
//        let sector = GlobalVariable.instance.sectors.map { $0 }
//        
//        vm.trades.removeAll()
//        for item in data {
//            vm.trades.append(TradeDetails(datetime: 0, symbol: item.name, ask: 0.0, bid: 0.0))
//        }
        
        let symbols = GlobalVariable.instance.symbolDataArray.map { $0 }
        let sectors = GlobalVariable.instance.sectors.map { $0 }
        
//        // Define the sectors
//        let sectors = ["Currency", "Commodities", "Energy", "Indices"]
        
        vm.trades.removeAll()
        GlobalVariable.instance.filteredSymbols.removeAll()
        GlobalVariable.instance.filteredSymbolsUrl.removeAll()
        // Iterate over each sector and send subscription messages
        for i in 0...sectors.count-1 {
            let filteredSymbols = filterSymbolsBySector(symbols: symbols, sector: sectors[i].sector)
            let filteredSymbolsUrl = filterSymbolsImageBySector(symbols: symbols, sector: sectors[i].sector)
            
//            print("filteredSymbols = \(filteredSymbols)")
            GlobalVariable.instance.filteredSymbols.append(filteredSymbols)
//            if filteredSymbolsUrl.count == 0 {
//                GlobalVariable.instance.filteredSymbolsUrl.append([""])
//            } else {
//                GlobalVariable.instance.filteredSymbolsUrl.append(filteredSymbolsUrl)
//            }
            GlobalVariable.instance.filteredSymbolsUrl.append(filteredSymbolsUrl)
//            vm.trades.append(TradeDetails(datetime: 0, symbol: item.name, ask: 0.0, bid: 0.0))
            
//            let message: [String: Any] = [
//                "event_name": "subscribe",
//                "data": [
//                    "last": 0,
//                    "channels": filteredSymbols.isEmpty ? [""] : filteredSymbols
//                ]
//            ]
//            webSocketManager.send(message: message)
        }
        
        /*
        let initialSymbols = GlobalVariable.instance.filteredSymbols.map { $0[collectionViewIndex] }
        print("initialSymbols = \(initialSymbols)")
        for symbols in initialSymbols {
            vm.trades.append(TradeDetails(datetime: 0, symbol: symbols, ask: 0.0, bid: 0.0))
        }
        */
        
        print("GlobalVariable.instance.filteredSymbolsUrl = \(GlobalVariable.instance.filteredSymbolsUrl)")
        
        for j in 0...GlobalVariable.instance.filteredSymbols[collectionViewIndex].count-1 {
            vm.trades.append(TradeDetails(datetime: 0, symbol: GlobalVariable.instance.filteredSymbols[collectionViewIndex][j], ask: 0.0, bid: 0.0, url: GlobalVariable.instance.filteredSymbolsUrl[collectionViewIndex][j], close: nil))
//            vm.trades.append(TradeDetails(datetime: 0, symbol: GlobalVariable.instance.filteredSymbols[collectionViewIndex][j], ask: 0.0, bid: 0.0))
        }
        
//        for i in 0...GlobalVariable.instance.filteredSymbols.count-1 {
//            for j in 0...GlobalVariable.instance.filteredSymbols[i].count-1 {
//                vm.trades.append(TradeDetails(datetime: 0, symbol: GlobalVariable.instance.filteredSymbols[i][j], ask: 0.0, bid: 0.0))
//            }
//        }
        
    }
    
    private func setTradeModel(collectionViewIndex: Int) {
        
        GlobalVariable.instance.tradeCollectionViewIndex.0 = collectionViewIndex
        
        let symbols = GlobalVariable.instance.symbolDataArray
        let sectors = GlobalVariable.instance.sectors
        
        // Clear previous data
        vm.trades.removeAll()
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
        let selectedSymbols = GlobalVariable.instance.filteredSymbols[collectionViewIndex] ?? []
        let selectedUrls = GlobalVariable.instance.filteredSymbolsUrl[collectionViewIndex] ?? []
        
        GlobalVariable.instance.tradeCollectionViewIndex.1.removeAll()
        getSymbolData.removeAll()
        var count = 0
        for (symbol, url) in zip(selectedSymbols, selectedUrls) {
            count += 1
            GlobalVariable.instance.tradeCollectionViewIndex.1.append(count)
            let tradedetail = TradeDetails(datetime: 0, symbol: symbol, ask: 0.0, bid: 0.0, url: url, close: nil)
            vm.trades.append(tradedetail)
            getSymbolData.append(SymbolCompleteList(tickMessage: tradedetail))
        }
        
        print("GlobalVariable.instance.filteredSymbolsUrl = \(GlobalVariable.instance.filteredSymbolsUrl)")
        
        GlobalVariable.instance.isProcessingSymbol = false
        
//        getSymbolData.removeAll()
//        getSymbolData.append(SymbolCompleteList(tickMessage: vm.trades))
        
        refreshSection(at: 2)
        
        //MARK: - START calling Socket message from here.
        vm.webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: selectedSymbols)
    }

    
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
    let mobile_available: String
    
    init(id: String, name: String, description: String, icon_url: String, volumeMin: String, volumeMax: String, volumeStep: String, contractSize: String, displayName: String, sector: String, digits: String, mobile_available: String) {
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
        self.mobile_available = mobile_available
        
    }
    
}

struct SectorGroup {
    let sector: String
    let symbols: [SymbolData]
}






























/*
[RiverPrime.SymbolData(id: "1", name: "EURUSD", description: "Euro vs US Dollar (1 lot = 100,000 EUR)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/eurusd-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "EURUSD", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "2", name: "GBPUSD", description: "Great Britain Pound vs US Dollar (1 lot = 100,000 GBP)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/gbpusd-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "GBPUSD", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "3", name: "USDCHF", description: "US Dollar vs Swiss Franc (1 lot = 100,000 USD)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/usdchf-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "USDCHF", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "4", name: "USDJPY", description: "US Dollar vs Japanese Yen (1 lot = 100,000 USD)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/usdjpy-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "USDJPY", sector: "Currency", digits: "3", mobile_available: "1"), RiverPrime.SymbolData(id: "5", name: "USDCAD", description: "US Dollar vs Canadian Dollar (1 lot = 100,000 USD)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/usdcad-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "USDCAD", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "6", name: "AUDUSD", description: "Australian Dollar vs US Dollar (1 lot = 100,000 AUD)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/audusd-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "AUDUSD", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "7", name: "AUDNZD", description: "Australian Dollar vs New Zealand Dollar (1 lot = 100,000 AUD)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/audnzd-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "AUDNZD", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "8", name: "AUDCAD", description: "Australian Dollar vs Canadian Dollar (1 lot = 100,000 AUD)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/audcad-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "AUDCAD", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "10", name: "AUDJPY", description: "Australian Dollar vs Japanese Yen (1 lot = 100,000 AUD)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/audjpy-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "AUDJPY", sector: "Currency", digits: "3", mobile_available: "1"), RiverPrime.SymbolData(id: "11", name: "CHFJPY", description: "Swiss Franc vs Japanese Yen (1 lot=100,000 CHF)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/chfjpy-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "CHFJPY", sector: "Currency", digits: "3", mobile_available: "1"), RiverPrime.SymbolData(id: "12", name: "EURGBP", description: "Euro vs Great Britain Pound (1 lot = 100,000 EUR)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/eurgbp-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "EURGBP", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "13", name: "EURAUD", description: "Euro vs Australian Dollar (1 lot = 100,000 EUR)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/euraud-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "EURAUD", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "14", name: "EURCHF", description: "Euro vs Swiss Franc (1 lot = 100,000 EUR)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/eurchf-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "EURCHF", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "15", name: "EURJPY", description: "Euro vs Japanese Yen (1 lot = 100,000 EUR)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/eurjpy-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "EURJPY", sector: "Currency", digits: "3", mobile_available: "1"), RiverPrime.SymbolData(id: "16", name: "EURNZD", description: "Euro vs New Zealand Dollar (1 lot = 100,000 EUR)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/eurnzd-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "EURNZD", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "17", name: "EURCAD", description: "Euro vs Canadian Dollar (1 lot = 100,000 EUR)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/eurcad-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "EURCAD", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "18", name: "GBPCHF", description: "Great Britain Pound vs Swiss Franc (1 lot = 100,000 GBP)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/gbpchf-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "GBPCHF", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "19", name: "GBPJPY", description: "Great Britain Pound vs Japanese Yen (1 lot = 100,000 GBP)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/gbpjpy-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "GBPJPY", sector: "Currency", digits: "3", mobile_available: "1"), RiverPrime.SymbolData(id: "20", name: "CADCHF", description: "Canadian Dollar vs Swiss Franc (1 lot = 100,000 CAD)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/cadchf-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "CADCHF", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "21", name: "CADJPY", description: "Canadian Dollar vs Japanese Yen (1 lot = 100,000 CAD)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/cadjpy-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "CADJPY", sector: "Currency", digits: "3", mobile_available: "1"), RiverPrime.SymbolData(id: "22", name: "GBPAUD", description: "British Pound vs Australian Dollar (1 lot = 100,000 GBP)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/gbpaud-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "GBPAUD", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "23", name: "GBPCAD", description: "Great Britain Pound vs Canadian Dollar (1 lot = 100,000 GBP)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/gbpcad-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "GBPCAD", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "24", name: "GBPNZD", description: "Great British Pound vs New Zealand Dollar (1 lot = 100,000 GBP)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/gbpnzd-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "GBPNZD", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "25", name: "NZDCAD", description: "New Zealand Dollar vs Canadian Dollar (1 lot = 100,000 NZD)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/nzdcad-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "NZDCAD", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "26", name: "NZDCHF", description: "New Zealand Dollar vs Swiss Franc (1 lot = 100,000 NZD)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/nzdchf-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "NZDCHF", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "27", name: "NZDJPY", description: "New Zealand Dollar vs Japanese Yen (1 lot = 100,000 NZD)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/nzdjpy-01.svg", volumeMin: "100", volumeMax: "1000000", volumeStep: "100", contractSize: "100000", displayName: "NZDJPY", sector: "Currency", digits: "3", mobile_available: "1"), RiverPrime.SymbolData(id: "28", name: "NZDUSD", description: "New Zealand Dollar vs US Dollar (1 lot = 100,000 NZD)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/nzdusd-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "NZDUSD", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "29", name: "USDNOK", description: "US Dollar vs Norwegian Krone", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/usdnok-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "USDNOK", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "30", name: "USDSEK", description: "USD vs Swedish Krona", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/usdsek-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "USDSEK", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "31", name: "EURTRY", description: "Euro vs Turkish Lira (1 lot = 100,000 EUR)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/eurtry-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "EURTRY", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "32", name: "USDTRY", description: "US Dollar vs Turkish Lira (1 lot = 100,000 USD)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/usdtry-01.svg", volumeMin: "100", volumeMax: "50000", volumeStep: "100", contractSize: "100000", displayName: "USDTRY", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "35", name: "Gold", description: "Gold Spot", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/gold-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100", displayName: "Gold", sector: "Commodities", digits: "2", mobile_available: "1"), RiverPrime.SymbolData(id: "37", name: "Silver", description: "Silver Spot", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/silver-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "5000", displayName: "Silver", sector: "Commodities", digits: "3", mobile_available: "1"), RiverPrime.SymbolData(id: "127", name: "XAGUSD", description: "Silver Spot", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/xagusd-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "5000", displayName: "XAGUSD", sector: "Commodities", digits: "3", mobile_available: "1"), RiverPrime.SymbolData(id: "128", name: "XAUUSD", description: "Gold Spot", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/xauusd-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100", displayName: "XAUUSD", sector: "Commodities", digits: "2", mobile_available: "1"), RiverPrime.SymbolData(id: "226", name: "FTSE100", description: "UK 100 Index", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/ftse100-01.svg", volumeMin: "100", volumeMax: "100000", volumeStep: "100", contractSize: "10", displayName: "FTSE100", sector: "Indices", digits: "2", mobile_available: "1"), RiverPrime.SymbolData(id: "227", name: "NDX100", description: "US Tech 100 Index", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/ndx100-01.svg", volumeMin: "100", volumeMax: "100000", volumeStep: "100", contractSize: "20", displayName: "NDX100", sector: "Indices", digits: "2", mobile_available: "1"), RiverPrime.SymbolData(id: "228", name: "SPX500", description: "US 500 Index", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/spx500-01.svg", volumeMin: "100", volumeMax: "100000", volumeStep: "100", contractSize: "50", displayName: "SPX500", sector: "Indices", digits: "2", mobile_available: "1"), RiverPrime.SymbolData(id: "287", name: "AUDCHF", description: "Australian Dollar vs Swiss Franc (1 lot = 100,000 AUD)", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/audchf-01.svg", volumeMin: "100", volumeMax: "200000", volumeStep: "100", contractSize: "100000", displayName: "AUDCHF", sector: "Currency", digits: "5", mobile_available: "1"), RiverPrime.SymbolData(id: "288", name: "Platinum", description: "Platinum vs Dollar", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/platinum-01.svg", volumeMin: "100", volumeMax: "50000", volumeStep: "100", contractSize: "100", displayName: "Platinum", sector: "Commodities", digits: "2", mobile_available: "1"), RiverPrime.SymbolData(id: "289", name: "BRENT", description: "Crude Oil Brent", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/brent-01.svg", volumeMin: "100", volumeMax: "100000", volumeStep: "100", contractSize: "1000", displayName: "BRENT", sector: "Energy", digits: "3", mobile_available: "1"), RiverPrime.SymbolData(id: "290", name: "WTI", description: "Crude Oil West Texas", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/wti-01.svg", volumeMin: "100", volumeMax: "100000", volumeStep: "100", contractSize: "1000", displayName: "WTI", sector: "Energy", digits: "3", mobile_available: "1"), RiverPrime.SymbolData(id: "291", name: "DAX40", description: "Germany 40 Index", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/dax40-01.svg", volumeMin: "100", volumeMax: "100000", volumeStep: "100", contractSize: "25", displayName: "DAX40", sector: "Indices", digits: "2", mobile_available: "1"), RiverPrime.SymbolData(id: "292", name: "DJI30", description: "US Wall Street 30 Index", icon_url: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/dji30-01.svg", volumeMin: "100", volumeMax: "100000", volumeStep: "100", contractSize: "5", displayName: "DJI30", sector: "Indices", digits: "2", mobile_available: "1")]
*/
