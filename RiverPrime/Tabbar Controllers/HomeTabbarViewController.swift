//
//  TabbarViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 10/07/2024.
//

import UIKit

class HomeTabbarViewController: UITabBarController {
    
    var tabBarIteam = UITabBarItem()
    
    var odooClientService = OdooClientNew()
    
    let webSocketManager = WebSocketManager.shared
    
    var vm = TradeTypeCellVM()
    
    public weak var delegateSocketMessage: GetSocketMessages?
    public weak var delegateSocketNotSendData: SocketNotSendDataDelegate?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarAppearance = UITabBarAppearance()
        let tabBarItemAppearance = UITabBarItemAppearance()
        tabBarAppearance.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        
        tabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        tabBarItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemYellow]
        tabBarItemAppearance.selected.iconColor =   UIColor.systemYellow
        tabBarItemAppearance.normal.iconColor =   UIColor.white
        
        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
        
        //MARK: - START Symbol api calling.
        symbolApiCalling()
        
    }
}

extension UIImage {
    
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    class func withRoundedCorners(radius: CGFloat? = nil , size: CGSize) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}

extension HomeTabbarViewController {
    
    private func symbolApiCalling() {
        
        //MARK: - Call Symbol Api and their delegate method to get data.
        odooClientService.sendSymbolDetailRequest()
        odooClientService.tradeSymbolDetailDelegate = self
       
    }
    
}

//MARK: - Symbol API calling at the start and Save list local and set sectors in the collectionview (Section 1).
extension HomeTabbarViewController: TradeSymbolDetailDelegate {
    func tradeSymbolDetailSuccess(response: [String: Any]) {
     //   print("\n symbol resposne is: \(response) ")
        //        convertXMLIntoJson(response)
        convertJSONIntoSymbols(response)
        ActivityIndicator.shared.hide(from: self.view)
    }
    
    func tradeSymbolDetailFailure(error: any Error) {
        print("\n the trade symbol detail Error response: \(error) ")
    }
    
    func convertJSONIntoSymbols(_ jsonResponse: [String: Any]) {
        if let resultArray = jsonResponse["result"] as? [[String: Any]] {
            print("Result Array count: \(resultArray.count)")
            
            for (index, result) in resultArray.enumerated() {
//                print("\n Processing entry \(index + 1) of \(resultArray.count)")
                
                // Extract data, providing default values or handling optionals where needed
                let symbolId = result["id"] as? Int ?? -1
                let symbolName = result["name"] as? String ?? "Unknown"
                let symbolDescription = result["description"] as? String ?? "No description"
                let symbolIcon = result["icon_url"] as? String ?? ""
                let symbolVolumeMin = result["volume_min"] as? Int ?? 0
                let symbolVolumeMax = result["volume_max"] as? Int ?? 0
                let symbolVolumeStep = result["volume_step"] as? Int ?? 0
                let symbolContractSize = result["contract_size"] as? Int ?? 0
                let symbolDisplayName = result["display_name"] as? String ?? symbolName
                let symbolSector = result["sector"] as? String ?? "Unknown Sector"
                let symbolDigits = result["digits"] as? Int ?? 0
                let symbolMobileAvailable = result["mobile_available"] as? Int ?? 0
                let symbolSwapLong = result["swap_long"] as? Double ?? 0.0
                let symbolStopsLevel = result["stops_level"] as? Double ?? 0.0
                let symbolSpreadSize = result["spread_size"] as? Double ?? 0.0
                let symbolSwapShort = result["swap_short"] as? Double ?? 0.0
                let symbolyesterday_close = result["yesterday_close"] as? Double ?? 0.0
                let symbolis_mobile_favorite = result["is_mobile_favorite"] as? Bool ?? false
                let symboltrade_session = result["trading_sessions_ids"] as? [Int]
                
                // Modify the icon URL if needed
                let modifiedUrl = symbolIcon
                    .replacingOccurrences(of: "-01.svg", with: ".png")
                    .replacingOccurrences(of: ".com/", with: ".com/png/")
                
                let originalDescription = symbolDescription
                let modifiedDescription = originalDescription.replacingOccurrences(of: "\\s*\\(.*\\)", with: "", options: .regularExpression)
                
                // Append to the symbol data array
                GlobalVariable.instance.symbolDataArray.append(
                    SymbolData(
                        id: String(symbolId),
                        name: symbolName,
                        description: modifiedDescription,
                        icon_url: modifiedUrl,
                        volumeMin: String(symbolVolumeMin),
                        volumeMax: String(symbolVolumeMax),
                        volumeStep: String(symbolVolumeStep),
                        contractSize: String(symbolContractSize),
                        displayName: symbolDisplayName,
                        sector: symbolSector,
                        digits: String(symbolDigits),
                        stopsLevel: String(symbolStopsLevel),
                        swapLong: String(symbolSwapLong),
                        swapShort: String(symbolSwapShort),
                        spreadSize: String(symbolSpreadSize),
                        mobile_available: String(symbolMobileAvailable),
                        yesterday_close: String(symbolyesterday_close),
                        is_mobile_favorite: Bool(symbolis_mobile_favorite),
                        trading_sessions_ids: [Int](symboltrade_session ?? [])
                    )
                )
                
//                print("Added symbol: \(symbolName) with ID: \(symbolId) trading_sessions_ids: \(symboltrade_session)")
            }
            
            print("Total symbols added: \(GlobalVariable.instance.symbolDataArray.count)")
            //             Process and save symbols
            processSymbols(GlobalVariable.instance.symbolDataArray)
        } else {
            print("Error: Invalid JSON structure")
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

extension HomeTabbarViewController: SocketConnectionInitDelegate {
    
    func SocketConnectionInit() {
        //MARK: - This Notification is only use to update trader at first time when api call is completed, it just update trader that api call is completed.
        NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.TradeApiUpdateConstant.key, dict: [NotificationObserver.Constants.TradeApiUpdateConstant.title: "TradeApiUpdate"])
    }
    
}

//MARK: - Main and final list which is change when the sector is set and all the symbols which is on the selected sector.
extension HomeTabbarViewController {
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
        //tickMessage
        GlobalVariable.instance.tradeCollectionViewIndex.1.removeAll()
        
        openData()
        
    }
}

extension HomeTabbarViewController {
    
    func openData() {
        // Execute the fetch on a background thread
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            self.vm.OPCApi(index: 0) { openData, pendingData, closeData, error in
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
                            
                            GlobalVariable.instance.getSymbolData.append(SymbolCompleteList(tickMessage: TradeDetails(datetime: 0, symbol: getSymbol, ask: 0.0, bid: 0.0, url: "", close: 0)))
                        }
                        //MARK: - END to update values for socket dynamic method at start.
                        
                        GlobalVariable.instance.openSymbolList.removeAll()
                        
                        let symbols = positions.map { self.getSymbol(item: $0.symbol) }
                        GlobalVariable.instance.openSymbolList = symbols
                        
                    }
                    
                    //MARK: - START SOCKET and call delegate method to get data from socket.
                    self.webSocketManager.connectWebSocket()
                    self.webSocketManager.delegateSocketData = self
                    self.webSocketManager.delegateSocketConnectionInit = self
                    self.webSocketManager.delegateSocketNotSendData = self
                    
//                    //MARK: - This Notification is only use to update trader at first time when api call is completed, it just update trader that api call is completed.
//                    NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.TradeApiUpdateConstant.key, dict: [NotificationObserver.Constants.TradeApiUpdateConstant.title: "TradeApiUpdate"])
                }
            }
        }
    }
    
}

extension HomeTabbarViewController: SocketNotSendDataDelegate {
    func socketNotSendData() {
        
        delegateSocketNotSendData?.socketNotSendData()
        
    }
    
    
}

//MARK: - Get Socket Tick, History and Unsubcribe and update the list accordingly.
extension HomeTabbarViewController: GetSocketData {
    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?) {
        switch socketMessageType {
        case .tick:
            
            //MARK: - Compare the symbol which is coming from Socket with our Selected Sector symbol list and update our list (getSymbolData).
            if let getTick = tickMessage {
                //                       let openData = GlobalVariable.instance.openList
                
                if let index = GlobalVariable.instance.getSymbolData.firstIndex(where: { /*print("$0.symbol = \(getSymbol(item: $0.symbol))"); print("getTick.symbol = \(getTick.symbol)"); return*/ getSymbol(item: $0.tickMessage?.symbol ?? "") == getTick.symbol }) {
                    GlobalVariable.instance.getSymbolData[index].tickMessage = tickMessage
                    
                    let openData = GlobalVariable.instance.openList
                    if openData.count != 0 {
                        
                        var tpValue = [Double]()
                        tpValue.removeAll()
                        var total = 0.0
                        for i in 0...openData.count-1 {
                            
                            if getSymbol(item: tickMessage?.symbol ?? "") == getSymbol(item: openData[i].symbol) {
                                let x =  openData[index].symbol.dropLast()
                                if let contractValue = (GlobalVariable.instance.symbolDataArray.firstIndex(where: {$0.name == x })) {
                                    let symbolContractSize = GlobalVariable.instance.symbolDataArray[contractValue].contractSize
                                    
                                    let bid = GlobalVariable.instance.getSymbolData[index].tickMessage?.bid ?? 0.0
                                    let priceOpen = Double(openData[i].priceOpen)
                                    let volume = Double(openData[i].volume) / 10000
                                    let contractSize = Double(symbolContractSize)!
                                    
                                    var profitLoss = (bid - priceOpen) * volume * contractSize
                                    if openData[i].action == 1 {
                                        profitLoss = (priceOpen - bid) * volume * contractSize
                                    }
                                    
                                    total += profitLoss
                                    print("profitLoss = \(profitLoss)\n")
                                    print("total = \(total)\n")
                                    
                                    tpValue.append(profitLoss)
                                    
                                }
                            } else {
                                tpValue.append(openData[i].profit)
                            }
                        }
                        
                        print("tpValue = \(tpValue)\n")
                        
                        let totalProfitOpenClose = tpValue.enumerated().reduce(0.0) { (total, indexValue) -> Double in
                            let (index, item) = indexValue
                            if GlobalVariable.instance.isAccountCreated {
                                let getProfit = Double(item)
                                print("getProfit \(index) = \(getProfit)")
                                return total + getProfit
                            }
                            
                            return total
                        }
                        print("Total Profit Open Close: \(totalProfitOpenClose)")
                        
                        //MARK: - END Set Total P/L
                        
                        //                               let totalProfitOpenClose = total
                        
                        let totalProfit = Double(String(format: "%.3f", totalProfitOpenClose))
                        let balance = Double(GlobalVariable.instance.balanceUpdate)
                        
                        if balance == nil {
                            let finalTotal = 0.0
                            
                            let _finalTotal = String(format: "%.2f", finalTotal)
                            
                            NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: _finalTotal])
                            
                        }else{
                            let finalTotal = (totalProfit ?? 0.0) + (balance ?? 0.0)
                            
                            let _finalTotal = String(format: "%.2f", finalTotal)
                            
                            NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: _finalTotal])
                            
                        }
                        
                    }
                    
                }
                
            }
            
            delegateSocketMessage?.tradeUpdates(socketMessageType: .tick, tickMessage: tickMessage)
            break
        
        case .Unsubscribed:
            
            delegateSocketMessage?.tradeUpdates(socketMessageType: .Unsubscribed, tickMessage: nil)
            break
        }
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
}
