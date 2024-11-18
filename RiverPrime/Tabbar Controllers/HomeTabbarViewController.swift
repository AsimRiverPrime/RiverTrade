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
        
//        UITabBar.appearance().barTintColor = UIColor.black
//        UITabBar.appearance().tintColor = UIColor.systemYellow
//        UITabBar.appearance().unselectedItemTintColor = .black

        
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemYellow], for: .selected)
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        
//        let selectedImageAccount = UIImage(named: "Teamwork")?.withRenderingMode(.alwaysTemplate)
//        let deSelectedImageAccount = UIImage(named: "account")?.withRenderingMode(.alwaysTemplate)
//        if let tabBarItem = self.tabBar.items?[0] {
//            tabBarIteam = tabBarItem
//            tabBarIteam.image = deSelectedImageAccount
//            tabBarIteam.selectedImage = selectedImageAccount
//        }
//        
//        let selectedImageTrade =  UIImage(named: "tradeIconSelect")?.withRenderingMode(.alwaysOriginal)
//        let deselectedImageTrade = UIImage(named: "tradeIcon")?.withRenderingMode(.alwaysOriginal)
//        if let tabBarItem = self.tabBar.items?[1] {
//            tabBarIteam = tabBarItem
//            tabBarIteam.image = deselectedImageTrade
//            tabBarIteam.selectedImage =  selectedImageTrade
//        }
//        
//        let selectedImageMarket =  UIImage(named: "marketIconSelect")?.withRenderingMode(.alwaysOriginal)
//        let deselectedImageMarket = UIImage(named: "marketIcon")?.withRenderingMode(.alwaysOriginal)
//        
//        if let tabBarItem = self.tabBar.items?[2] {
//            tabBarIteam = tabBarItem
//            tabBarIteam.image = deselectedImageMarket
//            tabBarIteam.selectedImage = selectedImageMarket
//            
//        }
//        let selectedImageResult =  UIImage(named: "resultIconSelect")?.withRenderingMode(.alwaysOriginal)
//        let deselectedImageResult = UIImage(named: "resultIcon")?.withRenderingMode(.alwaysOriginal)
//        
//        if let tabBarItem = self.tabBar.items?[3] {
//            tabBarIteam = tabBarItem
//            tabBarIteam.image = deselectedImageResult
//            tabBarIteam.selectedImage = selectedImageResult
//        }
//        let selectedImageProfile =  UIImage(named: "profileIconSelect")?.withRenderingMode(.alwaysOriginal)
//        let deselectedImageProfile = UIImage(named: "profileIcon")?.withRenderingMode(.alwaysOriginal)
//        
//        if let tabBarItem = self.tabBar.items?[4] {
//            tabBarIteam = tabBarItem
//            tabBarIteam.image = deselectedImageProfile
//            tabBarIteam.selectedImage = selectedImageProfile
//        }
        
        
        
        // selected tab background color
//        let numberOfItems = CGFloat(tabBar.items!.count)
//        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)
//        
////        tabBar.backgroundImage = UIImage.imageWithColor(color: UIColor.lightGray, size: tabBarItemSize)
////        tabBar.selectionIndicatorImage = UIImage.imageWithColor(color: UIColor.black , size: tabBarItemSize)
////        tabBar.selectionIndicatorImage = UIImage.withRoundedCorners(radius: 7, size: tabBarItemSize)
////        
////        // initaial tab bar index
////        tabBar.selectionIndicatorImage = UIImage(named: "selectedBg")
////        tabBar.backgroundImage = UIImage(named: "unSelectBg")
//        self.selectedIndex = 0
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
        }
        
        GlobalVariable.instance.tradeCollectionViewIndex.1.removeAll()

    }
}
