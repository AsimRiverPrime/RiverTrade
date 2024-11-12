//
//  GlobalVariable.swift
//  RiverPrime
//
//  Created by Ross Rostane on 16/07/2024.
//

import Foundation
import UIKit
import CryptoKit

let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate
let SCENE_DELEGATE = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate

class GlobalVariable: NSObject {
    
    static var instance = GlobalVariable()
    
    var isProcessingSymbolTimer: Bool = false
    
    var passwordKey = SymmetricKey(size: .bits256)
    var keyIdentifier = "com.riverTrade.aesPassKey"
    
    var dataBaseName: String = "mbe.riverprime.com" // localhost
    var dbUserName: String =  "ios"
    var dbPassword: String =  "4e9b5768375b5a0acf0c94645eac5cdd9c07c059"
  
    var uid: Int =  0
    var changeSymbol = Bool()
    var loginID: Int = 0
    var isAppBecomeActive = false
   
    var isReturnToProfile = false
    var userEmail: String = ""
    
    var chartType: ChartType = .candlestick
    
    var socketTimer = Double()
    var socketTimerCount = 0
      
    var balanceUpdate = "0.0"
    
    var symbolDataArray: [SymbolData] = []
    
    var changeSector = Bool()
    var resultTopButtonType = String()
    var isProcessingSymbol: Bool = false
    
    var isAccountCreated = Bool()
    
    var tradeCollectionViewIndex: (Int, [Int]) = (0, [])
    
    var trades: [TradeDetails] = []
    
  
    var sectors: [SectorGroup] = []
    var tempSectors: [SectorGroup] = []
    
    var filteredSymbols: [[String]] = [[]]
    var filteredSymbolsUrl: [[String]] = [[]]
    
    var getSelectedSectorSymbols: (Int, [String]) = (0, [""])
    
    var historyChartData = [SymbolChartData]()
    
    var isStopTick: Bool = false
    var isStopHistory: Bool = false
    
    var previouseSymbolList = [String]()
    var tempPreviouseSymbolList = [String]()
    
    var isConnected: Bool = false // Track connection state
    var getSectorIndex = 0
    
    public func showBarBackButton(vc: UIViewController) {
       
        // Hide Navigation Back Button on this View Controller
        vc.navigationItem.setHidesBackButton(false, animated:true);
    }
    
    public func hideBarBackButton(vc: UIViewController) {
        
        // Hide Navigation Back Button on this View Controller
        vc.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    public func showBar(vc: UIViewController){
        vc.navigationController?.isNavigationBarHidden = false
    }
    
    public func hideBar(vc: UIViewController) {
        vc.navigationController?.isNavigationBarHidden = true
    }
    
    public func barDataShowHide(vc: UIViewController, isBackButton: Bool, isBar: Bool) {
        vc.navigationItem.setHidesBackButton(isBackButton, animated:true)
        vc.navigationController?.isNavigationBarHidden = isBar
        vc.navigationController?.setNavigationBarHidden(isBar, animated: true)
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func isIphone() -> Bool {
        
//        switch UIDevice.current.userInterfaceIdiom {
//        case .phone:
//            // It's an iPhone
//            heightConstraint.constant = 35
//        case .pad:
//            // It's an iPad (or macOS Catalyst)
//            heightConstraint.constant = 65
//        @unknown default: break
//            // Uh, oh! What could it be?
//        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad
            return false
        } else {
            // not iPad (iPhone, mac, tv, carPlay, unspecified)
            return true
        }
        
    }
    
}
  
    
