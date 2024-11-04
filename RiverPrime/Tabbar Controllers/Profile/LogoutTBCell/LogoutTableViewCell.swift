//
//  LogoutTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 23/07/2024.
//

import UIKit

class LogoutTableViewCell: UITableViewCell {

    @IBOutlet weak var lbl_email: UILabel!
    
    var userId : String?
    let fireStoreInstance = FirestoreServices()
    let webSocketManager = WebSocketManager.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            // Access specific values from the dictionary
            
            if let _email = savedUserData["email"] as? String , let _userId = savedUserData["uid"] as? String{
                self.lbl_email.text = _email
                self.userId = _userId
               // print("\n userId: \(userId) and userId_firebase: \(userId1)")
            }
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func logOutAction(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
////        let loginVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
//// update the firebase as well login
//        UserDefaults.standard.removeObject(forKey: "userData")
//        UserDefaults.standard.removeObject(forKey: "savedSymbolsKey")
//        WebSocketManager.shared.disconnectWebSocket()
//        
//        let loginVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
//        
//        let navController = UINavigationController(rootViewController: loginVC)
//        SCENE_DELEGATE.window?.rootViewController = navController
//        SCENE_DELEGATE.window?.makeKeyAndVisible()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let loginVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
// update the firebase as well login
        
        webSocketManager.connectionCheckTimer?.invalidate()
        webSocketManager.connectionCheckTimer = nil
        
        webSocketManager.disconnectWebSocket()
//        webSocketManager.disconnectHistoryWebSocket()
        
        //MARK: - START calling Socket message from here.
//        webSocketManager.sendWebSocketMessage(for: "unsubscribeTrade", symbolList: GlobalVariable.instance.previouseSymbolList, isTradeDismiss: false)
        UserDefaults.standard.removeObject(forKey: "userData")
        UserDefaults.standard.removeObject(forKey: "savedSymbolsKey")
        
        
        
        
        
        
        
        
        GlobalVariable.instance.isProcessingSymbolTimer = false
        
////        GlobalVariable.instance.passwordKey = SymmetricKey(size: .bits256)
//        GlobalVariable.instance.keyIdentifier = "com.riverTrade.aesPassKey"
//
//        GlobalVariable.instance.dataBaseName = "mbe.riverprime.com" // localhost
//        GlobalVariable.instance.dbUserName =  "ios"
//        GlobalVariable.instance.dbPassword =  "4e9b5768375b5a0acf0c94645eac5cdd9c07c059"
      
//        GlobalVariable.instance.uid =  0
//        GlobalVariable.instance.changeSymbol = Bool()
//        GlobalVariable.instance.loginID = 0
//        GlobalVariable.instance.isAppBecomeActive = false
       
        GlobalVariable.instance.isReturnToProfile = false
        GlobalVariable.instance.userEmail = ""
        
//        GlobalVariable.instance.socketTimer = Double()
//        GlobalVariable.instance.socketTimerCount = 0
        
        GlobalVariable.instance.balanceUpdate = "0.0"
        
        GlobalVariable.instance.symbolDataArray = []
        
        GlobalVariable.instance.changeSector = Bool()
        GlobalVariable.instance.resultTopButtonType = String()
        GlobalVariable.instance.isProcessingSymbol = false
        
        GlobalVariable.instance.isAccountCreated = Bool()
        
        GlobalVariable.instance.tradeCollectionViewIndex = (0, [])
        
//        GlobalVariable.instance.trades = []
        
      
        GlobalVariable.instance.sectors = []
        GlobalVariable.instance.tempSectors = []
        
        GlobalVariable.instance.filteredSymbols = [[]]
        GlobalVariable.instance.filteredSymbolsUrl = [[]]
        
        GlobalVariable.instance.getSelectedSectorSymbols = (0, [""])
        
        GlobalVariable.instance.historyChartData = [SymbolChartData]()
        
        GlobalVariable.instance.isStopTick = false
        GlobalVariable.instance.isStopHistory = false
        
        GlobalVariable.instance.previouseSymbolList = [String]()
        GlobalVariable.instance.tempPreviouseSymbolList = [String]()
        
//        GlobalVariable.instance.isConnected = false // Track connection state
        GlobalVariable.instance.getSectorIndex = 0
        
        
        
        
        
        
        
        
        
        
        
        
//        webSocketManager.disconnectWebSocket()
//        webSocketManager.disconnectHistoryWebSocket()
        
        let loginVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        
        let navController = UINavigationController(rootViewController: loginVC)
        SCENE_DELEGATE.window?.rootViewController = navController
        SCENE_DELEGATE.window?.makeKeyAndVisible()
    
        
    }
    
    func updateUser() {
        
        guard let userId = userId else{
            return
        }
        var fieldsToUpdate: [String: Any] = [
                
                "login" : false
             ]
        
        fireStoreInstance.updateUserFields(userID: userId, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                print("\n User data save successfully in the fireBase")
            }
        }
    }
    
}
