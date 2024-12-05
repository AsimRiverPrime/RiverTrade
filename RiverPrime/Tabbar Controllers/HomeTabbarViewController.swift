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
    
////    var opcList: OPCType? = .open([])
//    var openList = [OpenModel]()
//    var tickMessage = [TradeDetails]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarAppearance = UITabBarAppearance()
        let tabBarItemAppearance = UITabBarItemAppearance()
        tabBarAppearance.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)

        tabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        tabBarItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemYellow]
        tabBarItemAppearance.selected.iconColor =   UIColor.systemYellow
      
        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if GlobalVariable.instance.isReturnToProfile == true {
//            setProfileButton()
            GlobalVariable.instance.isReturnToProfile = false
        }else{
            //MARK: - START Symbol api calling.
            symbolApiCalling()
           
            //MARK: - START SOCKET and call delegate method to get data from socket.
            webSocketManager.connectWebSocket()
            webSocketManager.delegateSocketData = self
//            setAccountsButton()
        }
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
        print("\n symbol resposne is: \(response) ")
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
                print("\n Processing entry \(index + 1) of \(resultArray.count)")
                
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
                        yesterday_close: String(symbolyesterday_close)
                    )
                )
                
                print("Added symbol: \(symbolName) with ID: \(symbolId)")
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
            
//            tickMessage.append(TradeDetails(datetime: 0, symbol: <#T##String#>, ask: <#T##Double#>, bid: <#T##Double#>, url: <#T##String?#>, close: <#T##Int?#>))
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
                    
                    //MARK: - This Notification is only use to update trader at first time when api call is completed, it just update trader that api call is completed.
                    NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.TradeApiUpdateConstant.key, dict: [NotificationObserver.Constants.TradeApiUpdateConstant.title: "TradeApiUpdate"])

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
                        
////
////                        self?.delegateCollectionView?.getOPCData(opcType: .open(positions))
//
////                        self.opcList = opcType
////                        self?.opcList = openData
//
//                        self?.openList = positions
//
////                        switch self?.opcList {
////                        case .open(let open):
////
////                            break
////                        case .pending(let pending):
////                            break
////                        case .close(let close):
////                            break
////                        case .none:
////                            break
////                        }

                    }
                }
            }
        }
    }
    
}

//MARK: - Get Socket Tick, History and Unsubcribe and update the list accordingly.
extension HomeTabbarViewController: GetSocketData {
    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?, historyMessage: SymbolChartData?) {
               switch socketMessageType {
               case .tick:
                   var  roundValue = String()
                   //MARK: - Compare the symbol which is coming from Socket with our Selected Sector symbol list and update our list (getSymbolData).
                   if let getTick = tickMessage {
//                       let openData = GlobalVariable.instance.openList
                       
                       if let index = GlobalVariable.instance.getSymbolData.firstIndex(where: { /*print("$0.symbol = \(getSymbol(item: $0.symbol))"); print("getTick.symbol = \(getTick.symbol)"); return*/ getSymbol(item: $0.tickMessage?.symbol ?? "") == getTick.symbol }) {
                           GlobalVariable.instance.getSymbolData[index].tickMessage = tickMessage
                         
                           let openData = GlobalVariable.instance.openList
                           if openData.count != 0 {
////                               var profitLoss = Double()
////                               var myTPValue = [Double]()
////                               print("tickMessage = \(tickMessage)\n")
//                               print("GlobalVariable.instance.getSymbolData = \(GlobalVariable.instance.getSymbolData)\n")
////                               print("GlobalVariable.instance.symbolDataArray = \(GlobalVariable.instance.symbolDataArray)\n")
//                               for i in 0...openData.count-1 {
//                                   print("openData[\(i)] = \(openData[i])")
//                               }
                               
                               var tpValue = [Double]()
                               tpValue.removeAll()
                               var total = 0.0
                               for i in 0...openData.count-1 {
                                   //                                   profitLoss += openData[i].profit
                                   ////                                   total += profitLoss
                                   
                                   //                                   let myIndexPath = IndexPath(row: i, section: 1)
                                   
                                   //if cell.lbl_symbolName.text == openData[index].symbol && cell.volume == (Double(openData[myIndexPath.row].volume) / 10000) {
//                                   print("getSymbol(item: tickMessage?.symbol) = \(getSymbol(item: tickMessage?.symbol ?? ""))")
//                                   print("getSymbol(item: openData[i].symbol) = \(getSymbol(item: openData[i].symbol))\n")
//                                   print("Double(openData[index].volume / 10000) = \(Double(openData[index].volume / 10000))")
//                                   print("Double(openData[i].volume) / 10000 = \(Double(openData[i].volume) / 10000)\n")
                                   if getSymbol(item: tickMessage?.symbol ?? "") == getSymbol(item: openData[i].symbol) /*&& Double(openData[index].volume / 10000) == Double(openData[i].volume) / 10000*/ {
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
                               
                               //MARK: - START Set Total P/L

//                               let totalProfitOpenClose = openData.enumerated().reduce(0.0) { (total, indexValue) -> Double in
//                                   let (index, item) = indexValue
//                                   let myIndexPath = IndexPath(row: index, section: 1)
//
//                                   if GlobalVariable.instance.isAccountCreated {
//                                       // Safely unwrap the profit value
////                                               let getProfit = Double(roundValue) ?? 0.0
//
//                                       let getProfit = Double(item.profit)
//                                       print("getProfit \(index) = \(getProfit)")
//
//                                       return total + getProfit
//                                   }
//
//                                   return total
//                               }
                               
                               
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
                   
                   delegateSocketMessage?.tradeUpdates(socketMessageType: .tick, tickMessage: tickMessage, historyMessage: nil)
                   break
               case .history:
                   
                   delegateSocketMessage?.tradeUpdates(socketMessageType: .history, tickMessage: nil, historyMessage: historyMessage)
                   break
                   
               case .Unsubscribed:
                   
//                   //MARK: - Before change any sector we must unsubcribe already selected and then again update according to the new selected sector.
//
//                   GlobalVariable.instance.changeSector = true
//
//                   //            setTradeModel(collectionViewIndex: GlobalVariable.instance.getSectorIndex)
//
//                   if webSocketManager.isSocketConnected() {
//                       print("Socket is connected")
//                   } else {
//                       print("Socket is not connected")
//                       //MARK: - START SOCKET.
//                       webSocketManager.delegateSocketMessage = self
//                       webSocketManager.connectWebSocket()
//                   }
                   
//                   webSocketManager.delegateSocketData = self
                   delegateSocketMessage?.tradeUpdates(socketMessageType: .Unsubscribed, tickMessage: nil, historyMessage: nil)
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




































////
////  TabbarViewController.swift
////  RiverPrime
////
////  Created by Ross Rostane on 10/07/2024.
////
//
//import UIKit
//
//class HomeTabbarViewController: UITabBarController {
//
//    var tabBarIteam = UITabBarItem()
//
//    var odooClientService = OdooClientNew()
//
//    let webSocketManager = WebSocketManager.shared
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let tabBarAppearance = UITabBarAppearance()
//        let tabBarItemAppearance = UITabBarItemAppearance()
//        tabBarAppearance.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
//
//        tabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
//        tabBarItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemYellow]
//        tabBarItemAppearance.selected.iconColor =   UIColor.systemYellow
//
//        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
//
//        tabBar.standardAppearance = tabBarAppearance
//        tabBar.scrollEdgeAppearance = tabBarAppearance
//
////        UITabBar.appearance().barTintColor = UIColor.black
////        UITabBar.appearance().tintColor = UIColor.systemYellow
////        UITabBar.appearance().unselectedItemTintColor = .black
//
//
////        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemYellow], for: .selected)
////        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
//
////        let selectedImageAccount = UIImage(named: "Teamwork")?.withRenderingMode(.alwaysTemplate)
////        let deSelectedImageAccount = UIImage(named: "account")?.withRenderingMode(.alwaysTemplate)
////        if let tabBarItem = self.tabBar.items?[0] {
////            tabBarIteam = tabBarItem
////            tabBarIteam.image = deSelectedImageAccount
////            tabBarIteam.selectedImage = selectedImageAccount
////        }
////
////        let selectedImageTrade =  UIImage(named: "tradeIconSelect")?.withRenderingMode(.alwaysOriginal)
////        let deselectedImageTrade = UIImage(named: "tradeIcon")?.withRenderingMode(.alwaysOriginal)
////        if let tabBarItem = self.tabBar.items?[1] {
////            tabBarIteam = tabBarItem
////            tabBarIteam.image = deselectedImageTrade
////            tabBarIteam.selectedImage =  selectedImageTrade
////        }
////
////        let selectedImageMarket =  UIImage(named: "marketIconSelect")?.withRenderingMode(.alwaysOriginal)
////        let deselectedImageMarket = UIImage(named: "marketIcon")?.withRenderingMode(.alwaysOriginal)
////
////        if let tabBarItem = self.tabBar.items?[2] {
////            tabBarIteam = tabBarItem
////            tabBarIteam.image = deselectedImageMarket
////            tabBarIteam.selectedImage = selectedImageMarket
////
////        }
////        let selectedImageResult =  UIImage(named: "resultIconSelect")?.withRenderingMode(.alwaysOriginal)
////        let deselectedImageResult = UIImage(named: "resultIcon")?.withRenderingMode(.alwaysOriginal)
////
////        if let tabBarItem = self.tabBar.items?[3] {
////            tabBarIteam = tabBarItem
////            tabBarIteam.image = deselectedImageResult
////            tabBarIteam.selectedImage = selectedImageResult
////        }
////        let selectedImageProfile =  UIImage(named: "profileIconSelect")?.withRenderingMode(.alwaysOriginal)
////        let deselectedImageProfile = UIImage(named: "profileIcon")?.withRenderingMode(.alwaysOriginal)
////
////        if let tabBarItem = self.tabBar.items?[4] {
////            tabBarIteam = tabBarItem
////            tabBarIteam.image = deselectedImageProfile
////            tabBarIteam.selectedImage = selectedImageProfile
////        }
//
//
//
//        // selected tab background color
////        let numberOfItems = CGFloat(tabBar.items!.count)
////        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)
////
//////        tabBar.backgroundImage = UIImage.imageWithColor(color: UIColor.lightGray, size: tabBarItemSize)
//////        tabBar.selectionIndicatorImage = UIImage.imageWithColor(color: UIColor.black , size: tabBarItemSize)
//////        tabBar.selectionIndicatorImage = UIImage.withRoundedCorners(radius: 7, size: tabBarItemSize)
//////
//////        // initaial tab bar index
//////        tabBar.selectionIndicatorImage = UIImage(named: "selectedBg")
//////        tabBar.backgroundImage = UIImage(named: "unSelectBg")
////        self.selectedIndex = 0
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        if GlobalVariable.instance.isReturnToProfile == true {
////            setProfileButton()
//            GlobalVariable.instance.isReturnToProfile = false
//        }else{
//            //MARK: - START Symbol api calling.
//            symbolApiCalling()
//
//            //MARK: - START SOCKET and call delegate method to get data from socket.
//            webSocketManager.connectWebSocket()
////            setAccountsButton()
//        }
//    }
//
//}
//
//extension UIImage {
//
//
//    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
//        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        color.setFill()
//        UIRectFill(rect)
//        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return image
//    }
//
//    class func withRoundedCorners(radius: CGFloat? = nil , size: CGSize) -> UIImage? {
//        let maxRadius = min(size.width, size.height) / 2
//        let cornerRadius: CGFloat
//        if let radius = radius, radius > 0 && radius <= maxRadius {
//            cornerRadius = radius
//        } else {
//            cornerRadius = maxRadius
//        }
//
//        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
//
//        UIRectFill(rect)
//
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image
//    }
//
//}
//
//extension HomeTabbarViewController {
//
//    private func symbolApiCalling() {
//
//        //MARK: - Call Symbol Api and their delegate method to get data.
//        odooClientService.sendSymbolDetailRequest()
//        odooClientService.tradeSymbolDetailDelegate = self
//
//    }
//
//}
//
////MARK: - Symbol API calling at the start and Save list local and set sectors in the collectionview (Section 1).
//extension HomeTabbarViewController: TradeSymbolDetailDelegate {
//    func tradeSymbolDetailSuccess(response: [String: Any]) {
//        print("\n symbol resposne is: \(response) ")
////        convertXMLIntoJson(response)
//        convertJSONIntoSymbols(response)
//        ActivityIndicator.shared.hide(from: self.view)
//    }
//
//    func tradeSymbolDetailFailure(error: any Error) {
//        print("\n the trade symbol detail Error response: \(error) ")
//    }
//
//    func convertJSONIntoSymbols(_ jsonResponse: [String: Any]) {
//        if let resultArray = jsonResponse["result"] as? [[String: Any]] {
//            print("Result Array count: \(resultArray.count)")
//
//            for (index, result) in resultArray.enumerated() {
//                print("\n Processing entry \(index + 1) of \(resultArray.count)")
//
//                // Extract data, providing default values or handling optionals where needed
//                let symbolId = result["id"] as? Int ?? -1
//                let symbolName = result["name"] as? String ?? "Unknown"
//                let symbolDescription = result["description"] as? String ?? "No description"
//                let symbolIcon = result["icon_url"] as? String ?? ""
//                let symbolVolumeMin = result["volume_min"] as? Int ?? 0
//                let symbolVolumeMax = result["volume_max"] as? Int ?? 0
//                let symbolVolumeStep = result["volume_step"] as? Int ?? 0
//                let symbolContractSize = result["contract_size"] as? Int ?? 0
//                let symbolDisplayName = result["display_name"] as? String ?? symbolName
//                let symbolSector = result["sector"] as? String ?? "Unknown Sector"
//                let symbolDigits = result["digits"] as? Int ?? 0
//                let symbolMobileAvailable = result["mobile_available"] as? Int ?? 0
//                let symbolSwapLong = result["swap_long"] as? Double ?? 0.0
//                let symbolStopsLevel = result["stops_level"] as? Double ?? 0.0
//                let symbolSpreadSize = result["spread_size"] as? Double ?? 0.0
//                let symbolSwapShort = result["swap_short"] as? Double ?? 0.0
//                let symbolyesterday_close = result["yesterday_close"] as? Double ?? 0.0
//
//                // Modify the icon URL if needed
//                let modifiedUrl = symbolIcon
//                    .replacingOccurrences(of: "-01.svg", with: ".png")
//                    .replacingOccurrences(of: ".com/", with: ".com/png/")
//
//                let originalDescription = symbolDescription
//                let modifiedDescription = originalDescription.replacingOccurrences(of: "\\s*\\(.*\\)", with: "", options: .regularExpression)
//
//                // Append to the symbol data array
//                GlobalVariable.instance.symbolDataArray.append(
//                    SymbolData(
//                        id: String(symbolId),
//                        name: symbolName,
//                        description: modifiedDescription,
//                        icon_url: modifiedUrl,
//                        volumeMin: String(symbolVolumeMin),
//                        volumeMax: String(symbolVolumeMax),
//                        volumeStep: String(symbolVolumeStep),
//                        contractSize: String(symbolContractSize),
//                        displayName: symbolDisplayName,
//                        sector: symbolSector,
//                        digits: String(symbolDigits),
//                        stopsLevel: String(symbolStopsLevel),
//                        swapLong: String(symbolSwapLong),
//                        swapShort: String(symbolSwapShort),
//                        spreadSize: String(symbolSpreadSize),
//                        mobile_available: String(symbolMobileAvailable),
//                        yesterday_close: String(symbolyesterday_close)
//                    )
//                )
//
//                print("Added symbol: \(symbolName) with ID: \(symbolId)")
//            }
//
//            print("Total symbols added: \(GlobalVariable.instance.symbolDataArray.count)")
////             Process and save symbols
//            processSymbols(GlobalVariable.instance.symbolDataArray)
//        } else {
//            print("Error: Invalid JSON structure")
//        }
//    }
//
//
//    func filterSymbolsBySector(symbols: [SymbolData], sector: String) -> [String] {
//        return symbols.filter { $0.sector == sector }.map { $0.displayName }
//    }
//
//    func filterSymbolsImageBySector(symbols: [SymbolData], sector: String) -> [String] {
//        return symbols.filter { $0.sector == sector }.map { $0.icon_url }
//    }
//
//    private func processSymbols(_ symbols: [SymbolData]) {
//        var sectorDict = [String: [SymbolData]]()
//
//        // Group symbols by sector
//        for symbol in symbols {
//            sectorDict[symbol.sector, default: []].append(symbol)
//        }
//
//        // Sort the sectors by key
//        let sortedSectors = sectorDict.keys.sorted()
//
//        // Create SectorGroup from sorted keys
//        GlobalVariable.instance.sectors = sortedSectors.map {
//            SectorGroup(sector: $0, symbols: sectorDict[$0]!)
//        }
//
//        saveSymbolsToDefaults(symbols)
//
//        // Initialize with the first index
//        setTradeModel(collectionViewIndex: 0)
//    }
//
//
//    private func saveSymbolsToDefaults(_ symbols: [SymbolData]) {
//        let savedSymbolsKey = "savedSymbolsKey"
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(symbols) {
//            UserDefaults.standard.set(encoded, forKey: savedSymbolsKey)
//        }
//    }
//
//    func getSavedSymbols() -> [SymbolData]? {
//        let savedSymbolsKey = "savedSymbolsKey"
//        if let savedSymbols = UserDefaults.standard.data(forKey: savedSymbolsKey) {
//            let decoder = JSONDecoder()
//            return try? decoder.decode([SymbolData].self, from: savedSymbols)
//        }
//        return nil
//    }
//
//}
//
////MARK: - Main and final list which is change when the sector is set and all the symbols which is on the selected sector.
//extension HomeTabbarViewController {
//    func showPopup() {
//        let storyboard = UIStoryboard(name: "BottomSheetPopups", bundle: nil)
//
//        // Replace "PopupViewController" with the actual identifier of your popup view controller
//        if let popupVC = storyboard.instantiateViewController(withIdentifier: "LoginPopupVC") as? LoginPopupVC {
//            // Set modal presentation style
//            popupVC.modalPresentationStyle = .overFullScreen// .overCurrentContext    // You can use .overFullScreen for full-screen dimming
//
//            popupVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//            popupVC.view.alpha = 0
//            // Optional: Set modal transition style (this is for animation)
//            popupVC.modalTransitionStyle = .crossDissolve
//            popupVC.metaTraderType = .Balance
//
//            // Present the popup
//            self.present(popupVC, animated: true, completion: nil)
//        }
//    }
//    //MARK: - Update all list when selector will change, and update tick socket message according to the selected sector.
//    private func setTradeModel(collectionViewIndex: Int) {
//
//        GlobalVariable.instance.tradeCollectionViewIndex.0 = collectionViewIndex
//
//        let symbols = GlobalVariable.instance.symbolDataArray
//        let sectors = GlobalVariable.instance.sectors
//
//        // Clear previous data
//        GlobalVariable.instance.filteredSymbols.removeAll()
//        GlobalVariable.instance.filteredSymbolsUrl.removeAll()
//
//        // Populate filteredSymbols and filteredSymbolsUrl for each sector
//        for sector in sectors {
//            let filteredSymbols = filterSymbolsBySector(symbols: symbols, sector: sector.sector)
//            let filteredSymbolsUrl = filterSymbolsImageBySector(symbols: symbols, sector: sector.sector)
//
//            GlobalVariable.instance.filteredSymbols.append(filteredSymbols)
//            GlobalVariable.instance.filteredSymbolsUrl.append(filteredSymbolsUrl)
//        }
//
//        GlobalVariable.instance.tradeCollectionViewIndex.1.removeAll()
//
//    }
//}
















































////
////  TabbarViewController.swift
////  RiverPrime
////
////  Created by Ross Rostane on 10/07/2024.
////
//
//import UIKit
//
//class HomeTabbarViewController: UITabBarController {
//    
//    var tabBarIteam = UITabBarItem()
//    
//    var odooClientService = OdooClientNew()
//    
//    let webSocketManager = WebSocketManager.shared
//    
//    var vm = TradeTypeCellVM()
//    
//////    var opcList: OPCType? = .open([])
////    var openList = [OpenModel]()
////    var tickMessage = [TradeDetails]()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let tabBarAppearance = UITabBarAppearance()
//        let tabBarItemAppearance = UITabBarItemAppearance()
//        tabBarAppearance.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
//
//        tabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
//        tabBarItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemYellow]
//        tabBarItemAppearance.selected.iconColor =   UIColor.systemYellow
//      
//        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
//        
//        tabBar.standardAppearance = tabBarAppearance
//        tabBar.scrollEdgeAppearance = tabBarAppearance
////        selectedIndex = 1
////        UITabBar.appearance().barTintColor = UIColor.black
////        UITabBar.appearance().tintColor = UIColor.systemYellow
////        UITabBar.appearance().unselectedItemTintColor = .black
//
//        
////        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemYellow], for: .selected)
////        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
//        
////        let selectedImageAccount = UIImage(named: "Teamwork")?.withRenderingMode(.alwaysTemplate)
////        let deSelectedImageAccount = UIImage(named: "account")?.withRenderingMode(.alwaysTemplate)
////        if let tabBarItem = self.tabBar.items?[0] {
////            tabBarIteam = tabBarItem
////            tabBarIteam.image = deSelectedImageAccount
////            tabBarIteam.selectedImage = selectedImageAccount
////        }
////
////        let selectedImageTrade =  UIImage(named: "tradeIconSelect")?.withRenderingMode(.alwaysOriginal)
////        let deselectedImageTrade = UIImage(named: "tradeIcon")?.withRenderingMode(.alwaysOriginal)
////        if let tabBarItem = self.tabBar.items?[1] {
////            tabBarIteam = tabBarItem
////            tabBarIteam.image = deselectedImageTrade
////            tabBarIteam.selectedImage =  selectedImageTrade
////        }
////
////        let selectedImageMarket =  UIImage(named: "marketIconSelect")?.withRenderingMode(.alwaysOriginal)
////        let deselectedImageMarket = UIImage(named: "marketIcon")?.withRenderingMode(.alwaysOriginal)
////
////        if let tabBarItem = self.tabBar.items?[2] {
////            tabBarIteam = tabBarItem
////            tabBarIteam.image = deselectedImageMarket
////            tabBarIteam.selectedImage = selectedImageMarket
////
////        }
////        let selectedImageResult =  UIImage(named: "resultIconSelect")?.withRenderingMode(.alwaysOriginal)
////        let deselectedImageResult = UIImage(named: "resultIcon")?.withRenderingMode(.alwaysOriginal)
////
////        if let tabBarItem = self.tabBar.items?[3] {
////            tabBarIteam = tabBarItem
////            tabBarIteam.image = deselectedImageResult
////            tabBarIteam.selectedImage = selectedImageResult
////        }
////        let selectedImageProfile =  UIImage(named: "profileIconSelect")?.withRenderingMode(.alwaysOriginal)
////        let deselectedImageProfile = UIImage(named: "profileIcon")?.withRenderingMode(.alwaysOriginal)
////
////        if let tabBarItem = self.tabBar.items?[4] {
////            tabBarIteam = tabBarItem
////            tabBarIteam.image = deselectedImageProfile
////            tabBarIteam.selectedImage = selectedImageProfile
////        }
//        
//        
//        
//        // selected tab background color
////        let numberOfItems = CGFloat(tabBar.items!.count)
////        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)
////
//////        tabBar.backgroundImage = UIImage.imageWithColor(color: UIColor.lightGray, size: tabBarItemSize)
//////        tabBar.selectionIndicatorImage = UIImage.imageWithColor(color: UIColor.black , size: tabBarItemSize)
//////        tabBar.selectionIndicatorImage = UIImage.withRoundedCorners(radius: 7, size: tabBarItemSize)
//////
//////        // initaial tab bar index
//////        tabBar.selectionIndicatorImage = UIImage(named: "selectedBg")
//////        tabBar.backgroundImage = UIImage(named: "unSelectBg")
////        self.selectedIndex = 0
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        if GlobalVariable.instance.isReturnToProfile == true {
////            setProfileButton()
//            GlobalVariable.instance.isReturnToProfile = false
//        }else{
//            //MARK: - START Symbol api calling.
//            symbolApiCalling()
//           
//            //MARK: - START SOCKET and call delegate method to get data from socket.
//            webSocketManager.connectWebSocket()
//            webSocketManager.delegateSocketData = self
////            setAccountsButton()
//        }
//    }
//    
//}
//
//extension UIImage {
//    
//    
//    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
//        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        color.setFill()
//        UIRectFill(rect)
//        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return image
//    }
//    
//    class func withRoundedCorners(radius: CGFloat? = nil , size: CGSize) -> UIImage? {
//        let maxRadius = min(size.width, size.height) / 2
//        let cornerRadius: CGFloat
//        if let radius = radius, radius > 0 && radius <= maxRadius {
//            cornerRadius = radius
//        } else {
//            cornerRadius = maxRadius
//        }
//        
//        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
//        
//        UIRectFill(rect)
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image
//    }
//    
//}
//
//extension HomeTabbarViewController {
//    
//    private func symbolApiCalling() {
//        
//        //MARK: - Call Symbol Api and their delegate method to get data.
//        odooClientService.sendSymbolDetailRequest()
//        odooClientService.tradeSymbolDetailDelegate = self
//       
//    }
//    
//}
//
////MARK: - Symbol API calling at the start and Save list local and set sectors in the collectionview (Section 1).
//extension HomeTabbarViewController: TradeSymbolDetailDelegate {
//    func tradeSymbolDetailSuccess(response: [String: Any]) {
//        print("\n symbol resposne is: \(response) ")
////        convertXMLIntoJson(response)
//        convertJSONIntoSymbols(response)
//        ActivityIndicator.shared.hide(from: self.view)
//    }
//    
//    func tradeSymbolDetailFailure(error: any Error) {
//        print("\n the trade symbol detail Error response: \(error) ")
//    }
//    
//    func convertJSONIntoSymbols(_ jsonResponse: [String: Any]) {
//        if let resultArray = jsonResponse["result"] as? [[String: Any]] {
//            print("Result Array count: \(resultArray.count)")
//            
//            for (index, result) in resultArray.enumerated() {
//                print("\n Processing entry \(index + 1) of \(resultArray.count)")
//                
//                // Extract data, providing default values or handling optionals where needed
//                let symbolId = result["id"] as? Int ?? -1
//                let symbolName = result["name"] as? String ?? "Unknown"
//                let symbolDescription = result["description"] as? String ?? "No description"
//                let symbolIcon = result["icon_url"] as? String ?? ""
//                let symbolVolumeMin = result["volume_min"] as? Int ?? 0
//                let symbolVolumeMax = result["volume_max"] as? Int ?? 0
//                let symbolVolumeStep = result["volume_step"] as? Int ?? 0
//                let symbolContractSize = result["contract_size"] as? Int ?? 0
//                let symbolDisplayName = result["display_name"] as? String ?? symbolName
//                let symbolSector = result["sector"] as? String ?? "Unknown Sector"
//                let symbolDigits = result["digits"] as? Int ?? 0
//                let symbolMobileAvailable = result["mobile_available"] as? Int ?? 0
//                let symbolSwapLong = result["swap_long"] as? Double ?? 0.0
//                let symbolStopsLevel = result["stops_level"] as? Double ?? 0.0
//                let symbolSpreadSize = result["spread_size"] as? Double ?? 0.0
//                let symbolSwapShort = result["swap_short"] as? Double ?? 0.0
//                let symbolyesterday_close = result["yesterday_close"] as? Double ?? 0.0
//
//                // Modify the icon URL if needed
//                let modifiedUrl = symbolIcon
//                    .replacingOccurrences(of: "-01.svg", with: ".png")
//                    .replacingOccurrences(of: ".com/", with: ".com/png/")
//                
//                let originalDescription = symbolDescription
//                let modifiedDescription = originalDescription.replacingOccurrences(of: "\\s*\\(.*\\)", with: "", options: .regularExpression)
//
//                // Append to the symbol data array
//                GlobalVariable.instance.symbolDataArray.append(
//                    SymbolData(
//                        id: String(symbolId),
//                        name: symbolName,
//                        description: modifiedDescription,
//                        icon_url: modifiedUrl,
//                        volumeMin: String(symbolVolumeMin),
//                        volumeMax: String(symbolVolumeMax),
//                        volumeStep: String(symbolVolumeStep),
//                        contractSize: String(symbolContractSize),
//                        displayName: symbolDisplayName,
//                        sector: symbolSector,
//                        digits: String(symbolDigits),
//                        stopsLevel: String(symbolStopsLevel),
//                        swapLong: String(symbolSwapLong),
//                        swapShort: String(symbolSwapShort),
//                        spreadSize: String(symbolSpreadSize),
//                        mobile_available: String(symbolMobileAvailable),
//                        yesterday_close: String(symbolyesterday_close)
//                    )
//                )
//                
//                print("Added symbol: \(symbolName) with ID: \(symbolId)")
//            }
//            
//            print("Total symbols added: \(GlobalVariable.instance.symbolDataArray.count)")
////             Process and save symbols
//            processSymbols(GlobalVariable.instance.symbolDataArray)
//        } else {
//            print("Error: Invalid JSON structure")
//        }
//    }
// 
//    
//    func filterSymbolsBySector(symbols: [SymbolData], sector: String) -> [String] {
//        return symbols.filter { $0.sector == sector }.map { $0.displayName }
//    }
//    
//    func filterSymbolsImageBySector(symbols: [SymbolData], sector: String) -> [String] {
//        return symbols.filter { $0.sector == sector }.map { $0.icon_url }
//    }
//    
//    private func processSymbols(_ symbols: [SymbolData]) {
//        var sectorDict = [String: [SymbolData]]()
//        
//        // Group symbols by sector
//        for symbol in symbols {
//            sectorDict[symbol.sector, default: []].append(symbol)
//        }
//        
//        // Sort the sectors by key
//        let sortedSectors = sectorDict.keys.sorted()
//        
//        // Create SectorGroup from sorted keys
//        GlobalVariable.instance.sectors = sortedSectors.map {
//            SectorGroup(sector: $0, symbols: sectorDict[$0]!)
//        }
//        
//        saveSymbolsToDefaults(symbols)
//        
//        // Initialize with the first index
//        setTradeModel(collectionViewIndex: 0)
//    }
//
//    
//    private func saveSymbolsToDefaults(_ symbols: [SymbolData]) {
//        let savedSymbolsKey = "savedSymbolsKey"
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(symbols) {
//            UserDefaults.standard.set(encoded, forKey: savedSymbolsKey)
//        }
//    }
//    
//    func getSavedSymbols() -> [SymbolData]? {
//        let savedSymbolsKey = "savedSymbolsKey"
//        if let savedSymbols = UserDefaults.standard.data(forKey: savedSymbolsKey) {
//            let decoder = JSONDecoder()
//            return try? decoder.decode([SymbolData].self, from: savedSymbols)
//        }
//        return nil
//    }
//    
//}
//
////MARK: - Main and final list which is change when the sector is set and all the symbols which is on the selected sector.
//extension HomeTabbarViewController {
//    func showPopup() {
//        let storyboard = UIStoryboard(name: "BottomSheetPopups", bundle: nil)
//        
//        // Replace "PopupViewController" with the actual identifier of your popup view controller
//        if let popupVC = storyboard.instantiateViewController(withIdentifier: "LoginPopupVC") as? LoginPopupVC {
//            // Set modal presentation style
//            popupVC.modalPresentationStyle = .overFullScreen// .overCurrentContext    // You can use .overFullScreen for full-screen dimming
//           
//            popupVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//            popupVC.view.alpha = 0
//            // Optional: Set modal transition style (this is for animation)
//            popupVC.modalTransitionStyle = .crossDissolve
//            popupVC.metaTraderType = .Balance
//            
//            // Present the popup
//            self.present(popupVC, animated: true, completion: nil)
//        }
//    }
//    //MARK: - Update all list when selector will change, and update tick socket message according to the selected sector.
//    private func setTradeModel(collectionViewIndex: Int) {
//        
//        GlobalVariable.instance.tradeCollectionViewIndex.0 = collectionViewIndex
//        
//        let symbols = GlobalVariable.instance.symbolDataArray
//        let sectors = GlobalVariable.instance.sectors
//        
//        // Clear previous data
//        GlobalVariable.instance.filteredSymbols.removeAll()
//        GlobalVariable.instance.filteredSymbolsUrl.removeAll()
//        
//        // Populate filteredSymbols and filteredSymbolsUrl for each sector
//        for sector in sectors {
//            let filteredSymbols = filterSymbolsBySector(symbols: symbols, sector: sector.sector)
//            let filteredSymbolsUrl = filterSymbolsImageBySector(symbols: symbols, sector: sector.sector)
//            
//            GlobalVariable.instance.filteredSymbols.append(filteredSymbols)
//            GlobalVariable.instance.filteredSymbolsUrl.append(filteredSymbolsUrl)
//            
////            tickMessage.append(TradeDetails(datetime: 0, symbol: <#T##String#>, ask: <#T##Double#>, bid: <#T##Double#>, url: <#T##String?#>, close: <#T##Int?#>))
//        }
//        //tickMessage
//        GlobalVariable.instance.tradeCollectionViewIndex.1.removeAll()
//        
////        openData()
//
//    }
//}
//
//extension HomeTabbarViewController {
//    
////    func openData() {
////        // Execute the fetch on a background thread
////        DispatchQueue.global(qos: .background).async { [weak self] in
////            self?.vm.OPCApi(index: 0) { openData, pendingData, closeData, error in
////                DispatchQueue.main.async {
////                    if let error = error {
////                        print("Error fetching positions: \(error)")
////                        // Handle the error (e.g., show an alert)
////                    } else if let positions = openData {
//////
//////                        self?.delegateCollectionView?.getOPCData(opcType: .open(positions))
////
//////                        self.opcList = opcType
//////                        self?.opcList = openData
////
////                        self?.openList = positions
////
//////                        switch self?.opcList {
//////                        case .open(let open):
//////
//////                            break
//////                        case .pending(let pending):
//////                            break
//////                        case .close(let close):
//////                            break
//////                        case .none:
//////                            break
//////                        }
////
////                    }
////                }
////            }
////        }
////    }
//    
//}
//
////MARK: - Get Socket Tick, History and Unsubcribe and update the list accordingly.
//extension HomeTabbarViewController: GetSocketData {
//    func tradeUpdates(socketMessageType: SocketMessageType, tickMessage: TradeDetails?, historyMessage: SymbolChartData?) {
//               switch socketMessageType {
//               case .tick:
//                   var  roundValue = String()
//                   //MARK: - Compare the symbol which is coming from Socket with our Selected Sector symbol list and update our list (getSymbolData).
//                   if let getTick = tickMessage {
//                       let openData = GlobalVariable.instance.openList
//                       
//                       if let index = GlobalVariable.instance.getSymbolData.firstIndex(where: { /*print("$0.symbol = \(getSymbol(item: $0.symbol))"); print("getTick.symbol = \(getTick.symbol)"); return*/ getSymbol(item: $0.tickMessage?.symbol ?? "") == getTick.symbol }) {
//                           GlobalVariable.instance.getSymbolData[index].tickMessage = tickMessage
//                           
//                           if openData.count != 0 {
//                               var profitLoss = Double()
//                               for i in 0...openData.count-1 {
////                                   let myIndexPath = IndexPath(row: i, section: 1)
//                                   
//                                   let x =  openData[index].symbol.dropLast()
//                                   if let contractValue = (GlobalVariable.instance.symbolDataArray.firstIndex(where: {$0.name == x })) {
//                                       let symbolContractSize = GlobalVariable.instance.symbolDataArray[contractValue].contractSize
//                                       
//                                       if GlobalVariable.instance.getSymbolData.count != 0 {
//                                           let bid = GlobalVariable.instance.getSymbolData[index].tickMessage?.bid ?? 0.0
//                                           let priceOpen = Double(openData[i].priceOpen)
//                                           let volume = Double(openData[i].volume) / 10000
//                                           let contractSize = Double(symbolContractSize)!
//                                           
////                                           profitLoss = (bid - priceOpen) * volume * contractSize
//                                           if openData[i].action == 1 {
//                                               profitLoss = (priceOpen - bid) * volume * contractSize
//                                           }else {
//                                               profitLoss = (bid - priceOpen) * volume * contractSize
//                                           }
//                                           
////                                           profitLoss = (bid - priceOpen) * volume * contractSize
//                                           
//                                           roundValue = String(format: "%.3f", profitLoss)
//                                       }
//                                       
//                                       
//                                       //MARK: - START Set Total P/L
//                                       
//                                       let totalProfitOpenClose = openData.enumerated().reduce(0.0) { (total, indexValue) -> Double in
//                                           let (index, item) = indexValue
//                                           let myIndexPath = IndexPath(row: index, section: 1)
//                                           
//                                           if GlobalVariable.instance.isAccountCreated {
//                                               // Safely unwrap the profit value
////                                               let getProfit = Double(roundValue) ?? 0.0
//                                              
//                                               let getProfit = Double(item.profit)
//                                               print("getProfit \(index) = \(getProfit)")
//                                              
//                                               return total + getProfit
//                                           }
//                                           
//                                           return total
//                                       }
//                                       
//                                       print("Total Profit Open Close: \(totalProfitOpenClose)")
//                                       
//                                       //MARK: - END Set Total P/L
//                                       
//                                       let totalProfit = Double(String(format: "%.3f", totalProfitOpenClose))
//                                       let balance = Double(GlobalVariable.instance.balanceUpdate)
//                                       
//                                       if balance == nil {
//                                           let finalTotal = 0.0
//                                           
//                                           let _finalTotal = String(format: "%.2f", finalTotal)
//                                           
//                                           NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: _finalTotal])
//                                           
//                                       }else{
//                                           let finalTotal = (totalProfit ?? 0.0) + (balance ?? 0.0)
//                                           
//                                           let _finalTotal = String(format: "%.2f", finalTotal)
//                                           
//                                           NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: _finalTotal])
//                                           
//                                       }
//                                       
//                                       
//                                   }
//                                   
//                               }
//                           }
//                           
//                       }
//                        
////                       if (self.openList.firstIndex(where: { $0.symbol == getTick.symbol }) != nil) {
////
////                       }
//                       
////                       if let index = self.openList.firstIndex(where: { $0.symbol == getTick.symbol }) {
////                           getSymbolData[index].tickMessage = tickMessage
////
//////                           let indexPath = IndexPath(row: index, section: 2)
////                           let indexPath = IndexPath(row: index, section: 0)
////
////
////
////
////
////
////
////                           totalProfitOpenClose = 0.0
////                           var profitLoss = Double()
////                           //MARK: - Get All Matched Symbols data and Set accordingly.
////
////                           for i in 0...self.openList.count-1 {
////
//////                                   let myIndexPath = IndexPath(row: i, section: 3)
////                               let myIndexPath = IndexPath(row: i, section: 1)
////                               print("my current index \(myIndexPath)")
////
////                               if let cell = tblView.cellForRow(at: myIndexPath) as? TransactionCell {
////                                   if GlobalVariable.instance.isAccountCreated {
////                                       cell.isHidden = false
////
////                                       if cell.lbl_symbolName.text == self.openList[index].symbol && cell.volume == (Double(self.openList[myIndexPath.row].volume) / 10000) {
////                                         let x =  self.openList[index].symbol.dropLast()
////                                           if let contractValue = (GlobalVariable.instance.symbolDataArray.firstIndex(where: {$0.name == x })) {
////                                               let symbolContractSize = GlobalVariable.instance.symbolDataArray[contractValue].contractSize
////
////                                               let bid = getSymbolData[index].tickMessage?.bid ?? 0.0
////                                               let priceOpen = Double(openData[myIndexPath.row].priceOpen)
////                                               let volume = Double(openData[myIndexPath.row].volume) / 10000
////                                               let contractSize = Double(symbolContractSize)!
////
////                                               profitLoss = (bid - priceOpen) * volume * contractSize
////                                           }
////
////                                           if profitLoss < 0.0 {
////                                               cell.lbl_profitValue.textColor = .systemRed
////
////                                           }else{
////                                               cell.lbl_profitValue.textColor = .systemGreen
////
////                                           }
////                                            roundValue = String(format: "%.3f", profitLoss)
////
////                                           cell.lbl_profitValue.text = "$\(roundValue)"
////
////                                           let bidValuess = String(format: "%.3f", getSymbolData[index].tickMessage?.bid ?? 0.0)
////                                           cell.lbl_currentPrice.text = "$\(bidValuess)"
////                                       }
////
////                                   }else{
////                                       cell.isHidden = true
////                                   }
////                               }
////
////                           }
////
////                       //MARK: - START Set Total P/L
////
////                           let totalProfitOpenClose = self.openList.enumerated().reduce(0.0) { (total, indexValue) -> Double in
////                               let (index, item) = indexValue
//////                                   let myIndexPath = IndexPath(row: index, section: 3)
////                               let myIndexPath = IndexPath(row: index, section: 1)
////
////                               if let cell = tblView.cellForRow(at: myIndexPath) as? TransactionCell {
////                                   if GlobalVariable.instance.isAccountCreated {
////                                       cell.isHidden = false
////
////                                       // Safely unwrap the profit value
////                                       let getProfit = Double(roundValue) ?? 0.0
////                                       print("getProfit \(index) = \(getProfit)")
////
////                                       return total + getProfit
////                                   }
////                               }
////
////                               return total
////                           }
////
////                           print("Total Profit Open Close: \(totalProfitOpenClose)")
////
////                           //MARK: - END Set Total P/L
////
////
//////                               let indexPath = IndexPath(row: 0, section: 2) // Adjust to the section and row where the total is displayed
////                           let indexPath = IndexPath(row: 0, section: 0)
////                           if let totalCell = tblView.cellForRow(at: indexPath) as? Total_PLCell {
////                               totalCell.detailTextLabel?.isHidden = false
////                               totalCell.detailTextLabel?.font = .boldSystemFont(ofSize: 16)
////                               totalCell.detailTextLabel?.text =   "$" + String(format: "%.2f", totalProfitOpenClose)
////                               if totalProfitOpenClose < 0.0 {
////                                   totalCell.detailTextLabel?.textColor = .systemRed
////                               }else{
////                                   totalCell.detailTextLabel?.textColor = .systemGreen
////                               }
////                           }
////
////                           let totalProfit = Double(String(format: "%.3f", totalProfitOpenClose))
////                           let balance = Double(GlobalVariable.instance.balanceUpdate)
////
////                           if balance == nil {
////                               let finalTotal = 0.0
////
////                               let _finalTotal = String(format: "%.2f", finalTotal)
////
////                               NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: _finalTotal])
////
////                           }else{
////                               let finalTotal = (totalProfit ?? 0.0) + (balance ?? 0.0)
////
////                               let _finalTotal = String(format: "%.2f", finalTotal)
////
////                               NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: _finalTotal])
////
////                           }
////
////
////
////
////
////
////
////
////
////                           return
////                       }
//                   }
//                   
//                   break
//               case .history:
//                   
//                   break
//                   
//               case .Unsubscribed:
//                   
////                   //MARK: - Before change any sector we must unsubcribe already selected and then again update according to the new selected sector.
////
////                   GlobalVariable.instance.changeSector = true
////
////                   //            setTradeModel(collectionViewIndex: GlobalVariable.instance.getSectorIndex)
////
////                   if webSocketManager.isSocketConnected() {
////                       print("Socket is connected")
////                   } else {
////                       print("Socket is not connected")
////                       //MARK: - START SOCKET.
////                       webSocketManager.delegateSocketMessage = self
////                       webSocketManager.connectWebSocket()
////                   }
//                   
//                   break
//               }
//           }
//    
//    
//    private func getSymbol(item: String) -> String {
//        
//        var getSymbol = ""
//        
//        if item.contains("..") {
//            getSymbol = String(item.dropLast())
//            getSymbol = String(getSymbol.dropLast())
//        } else if item.contains(".") {
//            getSymbol = String(item.dropLast())
//        } else {
//            getSymbol = item
//        }
//        
//        return getSymbol
//        
//    }
//    
//    
//}
