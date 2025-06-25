//
//  MarketsViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/07/2024.
//

import UIKit

class MarketsViewController: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var labelAmmount: UILabel!
    
    @IBOutlet weak var lbl_accountType: UILabel!
    @IBOutlet weak var lbl_accountGroup: UILabel!

    private let odooServer = OdooClientNew()
    var allPayloads: [PayloadItem] = []
    var filteredPayloads: [PayloadItem] = []
    
    var allEvents: [Event] = []
    var filteredEvents: [Event] = []
    
    // Keep track of balance API request to cancel if needed
    private var balanceRequest: TradeTypeCellVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ MarketsViewController viewDidLoad - \(self)")
        
        odooServer.topNewsDelegate = self
        
        tblView.registerCells([
            TopNewsSection.self, TopNewsTableViewCell.self
        ])
        tblView.reloadData()
        tblView.dataSource = self
        tblView.delegate = self
        
        GlobalVariable.instance.controllerName = "NewsVC"
        
        // Add observers
        addNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("✅ MarketsViewController viewWillAppear - \(self)")
        
        // Re-add observers every time we appear (in case they were removed)
        addNotificationObservers()
        
        // Re-set delegate in case it was cleared
        odooServer.topNewsDelegate = self
        
        odooServer.getNewsRecords()
//        getinitialBalance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("⚠️ MarketsViewController viewWillDisappear - \(self)")
        
        // Only remove observers, but keep data and delegates for when we return
        removeNotificationObservers()
        
        // Cancel any ongoing balance requests
        balanceRequest = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("❌ MarketsViewController viewDidDisappear - \(self)")
    }
    
    // MARK: - Notification Management
    private func addNotificationObservers() {
        // Remove first to avoid duplicate observers
        removeNotificationObservers()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(faceAfterLoginUpdate(_:)),
            name: NSNotification.Name(rawValue: NotificationObserver.Constants.FaceAfterLoginConstant.key),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPopup(_:)),
            name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key),
            object: nil
        )
    }
    
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: NotificationObserver.Constants.FaceAfterLoginConstant.key),
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key),
            object: nil
        )
    }
    
    // MARK: - Cleanup
    private func cleanup() {
        // Remove notification observers
        removeNotificationObservers()
        
        // Clear delegate references
        odooServer.topNewsDelegate = nil
        
        // Cancel any ongoing balance requests
        balanceRequest = nil
        
        // Clear arrays to help with memory
        allPayloads.removeAll()
        filteredPayloads.removeAll()
        allEvents.removeAll()
        filteredEvents.removeAll()
        
        // Clear table view delegates
        tblView?.delegate = nil
        tblView?.dataSource = nil
    }
    
    @objc private func faceAfterLoginUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let receivedString = userInfo[NotificationObserver.Constants.FaceAfterLoginConstant.title] as? String else {
            return
        }
        
        print("Received string: \(receivedString)")
        
        if receivedString == "NewsVC" {
            guard let faceIdVC = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as? PasscodeFaceIDVC else {
                return
            }
            
            faceIdVC.afterLoginNavigation = true
            faceIdVC.modalPresentationStyle = .overFullScreen
            
            if let sheet = faceIdVC.sheetPresentationController {
                sheet.prefersGrabberVisible = true
            }
            
            guard let topVC = faceIdVC.topMostViewController() else { return }
            topVC.present(faceIdVC, animated: true, completion: nil)
        }
    }
    
    deinit {
        print("🗑️ MarketsViewController DEINIT called for \(self)")
        
        // Final cleanup in case viewWillDisappear wasn't called
        cleanup()
    }
}

// MARK: - Balance Management
extension MarketsViewController {
//    func getinitialBalance() {
//        guard let defaultAccount = UserAccountManager.shared.getDefaultAccount() else {
//            return
//        }
//        
//        self.lbl_accountGroup.text = defaultAccount.groupName
//        lbl_accountType.text = defaultAccount.isReal == true ? "Real" : "Demo"
//        
//        // Store reference to cancel if needed
//        let getbalanceApi = TradeTypeCellVM()
//        self.balanceRequest = getbalanceApi
//        
//        getbalanceApi.getUserBalance(completion: { [weak self] result in
//            // Clear the request reference
//            self?.balanceRequest = nil
//            
//            guard let self = self else { return }
//            
//            switch result {
//            case .success(let responseModel):
//                print("Balance: \(responseModel.result.user.balance)")
//                print("Equity: \(responseModel.result.user.equity)")
//                
//                let balance = responseModel.result.user.balance
//                
//                DispatchQueue.main.async { [weak self] in
//                    self?.labelAmmount.text = "$\(String.formatStringNumber(String(balance)))"
//                }
//                
//                UserManager.shared.currentUser = responseModel.result.user
//                
//                GlobalVariable.instance.balanceUpdate = "\(responseModel.result.user.balance)"
//                print("GlobalVariable.instance.balanceUpdate = \(GlobalVariable.instance.balanceUpdate)")
//                
//                NotificationObserver.shared.postNotificationObserver(
//                    key: NotificationObserver.Constants.BalanceUpdateConstant.key,
//                    dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate]
//                )
//                
//                NotificationObserver.shared.postNotificationObserver(
//                    key: NotificationObserver.Constants.OPCUpdateConstant.key,
//                    dict: [NotificationObserver.Constants.OPCUpdateConstant.title: "Open"]
//                )
//                
//            case .failure(let error):
//                print("Failed to fetch balance: \(error.localizedDescription)")
//            }
//        })
//    }
    
    @objc func notificationPopup(_ notification: NSNotification) {
        guard let defaultAccount = UserAccountManager.shared.getDefaultAccount() else {
            return
        }
        
        self.lbl_accountGroup.text = defaultAccount.groupName
        lbl_accountType.text = defaultAccount.isReal == true ? "Real" : "Demo"
        
        if let ammount = notification.userInfo?[NotificationObserver.Constants.BalanceUpdateConstant.title] as? String {
            print("Received ammount in news vc: \(ammount)")
            let amount = String.formatStringNumber(ammount)
            self.labelAmmount.text = "$\(String(describing: amount))"
            
            if GlobalVariable.instance.getBalanceHidden == "$•••••••" {
                labelAmmount.text = GlobalVariable.instance.getBalanceHidden
            }
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension MarketsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Top News Section
        return min(5, 1 + filteredPayloads.count) // 1 header + up to 4 news items
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Top News Section
        if indexPath.row == 0 {
            // Top News Section Header
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopNewsSection", for: indexPath) as! TopNewsSection
            cell.selectionStyle = .none
            cell.viewAllAction = { [weak self] in
                guard let self = self else { return }
                
                if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "TopNewsViewController") as? TopNewsViewController {
                    vc.allPayloads = self.allPayloads
                    self.navigate(to: vc)
                }
            }
            return cell
        } else {
            // Top News Payload Rows
            let payloadIndex = indexPath.row - 1 // Subtract 1 for the header row
            
            guard payloadIndex < filteredPayloads.count else {
                return UITableViewCell()
            }
            
            let payload = filteredPayloads[payloadIndex]
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopNewsTableViewCell", for: indexPath) as! TopNewsTableViewCell
            cell.selectionStyle = .none
            
            cell.configure(with: payload)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 40 // Height for TopNewsSection cell
        } else {
            return 80 // Height for TopNewsTableViewCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // Header row - no action needed
            return
        } else {
            let index = indexPath.row - 1
            
            guard index < filteredPayloads.count else {
                return
            }
            
            let selectedItem = filteredPayloads[index]
            
            if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "TopNewsDetailVC") as? TopNewsDetailVC {
                vc.selectedItem = selectedItem
                self.navigate(to: vc)
            }
        }
    }
}

// MARK: - Top News Protocol
extension MarketsViewController: TopNewsProtocol {
    func topNewsSuccess(response: TopNewsModel) {
        print("\n top news result: \(response)")
        handleResponse(response)
    }
    
    func topNewsFailure(error: any Error) {
        print("Top news error: \(error)")
    }
    
    func filterImportantNews() {
        filteredPayloads = allPayloads
        print("\nfilteredPayloads:--------> \(filteredPayloads)")
    }
    
    func handleResponse(_ model: TopNewsModel) {
        allPayloads = model.result.payload
        print("\n allPayloads of TopNewsModel:----> \(allPayloads)")
        updateUI()
    }

    func updateUI() {
        filterImportantNews()
        
        filteredPayloads.sort { payload1, payload2 in
            guard let date1 = DateHelper.convertToDate(from: payload1.date),
                  let date2 = DateHelper.convertToDate(from: payload2.date) else {
                return false
            }
            return date1 > date2
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.tblView.reloadData()
            print("📊 Table view reloaded with \(self.filteredPayloads.count) news items")
        }
    }
}

// MARK: - String Extension
extension String {
    /// Returns the flag emoji for the given country code.
    func flagEmoji() -> String {
        let base: UInt32 = 127397
        var flag = ""
        for scalar in self.uppercased().unicodeScalars {
            if let scalarValue = UnicodeScalar(base + scalar.value) {
                flag.unicodeScalars.append(scalarValue)
            }
        }
        return flag
    }
}

//import UIKit
//
//class MarketsViewController: UIViewController {
//    
//         @IBOutlet weak var tblView: UITableView!
//         @IBOutlet weak var labelAmmount: UILabel!
//         
//         @IBOutlet weak var lbl_accountType: UILabel!
//         @IBOutlet weak var lbl_accountGroup: UILabel!
//
//         let odooServer = OdooClientNew()
//         var allPayloads: [PayloadItem] = []
//         var filteredPayloads: [PayloadItem] = []
//         
//         var allEvents: [Event] = []
//         var filteredEvents: [Event] = []
//         
//         override func viewDidLoad() {
//             super.viewDidLoad()
//             odooServer.topNewsDelegate = self
//             
//             tblView.registerCells([
//              /*  EconomicCalendarSection.self, UpcomingEventsTableViewCell.self,*/ TopNewsSection.self, TopNewsTableViewCell.self
//             ])
//             tblView.reloadData()
//             tblView.dataSource = self
//             tblView.delegate = self
//             
//             GlobalVariable.instance.controllerName = "NewsVC"
//             NotificationCenter.default.addObserver(self, selector: #selector(self.FaceAfterLoginUpdate(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.FaceAfterLoginConstant.key), object: nil)
//             
//         }
//         
//    @objc private func FaceAfterLoginUpdate(_ notification: Notification) {
//        if let userInfo = notification.userInfo,
//           let receivedString = userInfo[NotificationObserver.Constants.FaceAfterLoginConstant.title] as? String {
//            print("Received string: \(receivedString)")
//            
//            if receivedString == "NewsVC" {
//                let faceIdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! PasscodeFaceIDVC
//                faceIdVC.afterLoginNavigation = true
//
//                faceIdVC.modalPresentationStyle = .overFullScreen
//                if let sheet = faceIdVC.sheetPresentationController {
////                        sheet.detents = [.medium(), .large()] // Adjust as needed
//                        sheet.prefersGrabberVisible = true
//                    }
//                guard let topVC = faceIdVC.topMostViewController() else { return }
//                topVC.present(faceIdVC, animated: true, completion: nil)
//            }
//            
//        }
//    }
//    
//         
//         override func viewWillAppear(_ animated: Bool) {
//        
//             odooServer.getNewsRecords()
//             
//             NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
//
//             getinitialBalance()
//             
//         }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//        print("MarketVC Deinit called for \(self)")
//    }
//}
//
//     extension MarketsViewController {
//         func getinitialBalance(){
//             if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
//                 self.lbl_accountGroup.text = defaultAccount.groupName
//                 lbl_accountType.text = defaultAccount.isReal == true ? "Real" : "Demo"
//             }
//             let getbalanceApi = TradeTypeCellVM()
//             getbalanceApi.getUserBalance(completion: { result in
//                 switch result {
//                 case .success(let responseModel):
//                     // Save the response model or use it as needed
//                     print("Balance: \(responseModel.result.user.balance)")
//                     print("Equity: \(responseModel.result.user.equity)")
//                     
//                     let balance = (responseModel.result.user.balance)
//                     self.labelAmmount.text = "$\(String.formatStringNumber(String(balance)))"
//
//                     // Example: Storing in a singleton for global access
//                     UserManager.shared.currentUser = responseModel.result.user
//                     
//                     GlobalVariable.instance.balanceUpdate = "\(responseModel.result.user.balance)" //self.balance
//                     print("GlobalVariable.instance.balanceUpdate = \(GlobalVariable.instance.balanceUpdate)")
//                     NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
//                     
//                     NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.OPCUpdateConstant.key, dict: [NotificationObserver.Constants.OPCUpdateConstant.title: "Open"])
//                     
//                 case .failure(let error):
//                     print("Failed to fetch balance: \(error.localizedDescription)")
//                 }
//             })
//         }
//         
//         @objc func notificationPopup(_ notification: NSNotification) {
//         
//             if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
//                 self.lbl_accountGroup.text = defaultAccount.groupName
//                 lbl_accountType.text = defaultAccount.isReal == true ? "Real" : "Demo"
//             }
//             
//             if let ammount = notification.userInfo?[NotificationObserver.Constants.BalanceUpdateConstant.title] as? String {
//                 print("Received ammount in news vc: \(ammount)")
//                 let amount = String.formatStringNumber(ammount)
//                 self.labelAmmount.text = "$\(String(describing: amount))"
//             }
//         }
//         
//     }
//
//     extension MarketsViewController: UITableViewDelegate, UITableViewDataSource {
//         func numberOfSections(in tableView: UITableView) -> Int {
//             return 1
//         }
//         
//         func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
// //            if section == 0 {
// //                // Economic Calendar Section
// //                return min(4, 1 + filteredEvents.count) // 1 header + up to 3 events
// //            } else if section == 1 {
//                 // Top News Section
//                 return min(5, 1 + filteredPayloads.count) // 1 header + up to 3 news items
//         }
//         
//         func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//          
//                 // Top News Section
//                 if indexPath.row == 0 {
//                     // Top News Section Header
//                     let cell = tableView.dequeueReusableCell(withIdentifier: "TopNewsSection", for: indexPath) as! TopNewsSection
//                     cell.selectionStyle = .none
//                     cell.viewAllAction = { [unowned self] in
//                         if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "TopNewsViewController") as? TopNewsViewController {
//                             
//                             vc.allPayloads = allPayloads
//                             self.navigate(to: vc)
//                         }
//                     }
//                     return cell
//                 } else {
//                     // Top News Payload Rows
//                     let payloadIndex = indexPath.row - 1 // Subtract 1 for the header row
//                     let payload = filteredPayloads[payloadIndex]
//                     let cell = tableView.dequeueReusableCell(withIdentifier: "TopNewsTableViewCell", for: indexPath) as! TopNewsTableViewCell
//                     cell.selectionStyle = .none
//                     
//                     cell.configure(with: payload)
//                     
//                     return cell
//                 }
//             
//             return UITableViewCell()
//         }
//         
//         func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//                 if indexPath.row == 0 {
//                     return 40 // Height for TopNewsSection cell
//                 } else {
//                     return 80 // Height for TopNewsTableViewCell
//                 }
// //            }
//             return UITableView.automaticDimension
//         }
//         
//         func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//                 if indexPath.row == 0 {
//                     
//                 }else{
//                     let index = indexPath.row - 1
//                     let selectedItem = filteredPayloads[index]
//                     if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "TopNewsDetailVC") as? TopNewsDetailVC {
//                         
//                         vc.selectedItem = selectedItem
//                         self.navigate(to: vc)
//                     }
//                 }
//             }
//     }
//
//extension MarketsViewController: TopNewsProtocol {
//         func topNewsSuccess(response: TopNewsModel) {
////             print(response)
//             let topNewsModel = response
//             handleResponse(topNewsModel)
//         }
//         
//         func topNewsFailure(error: any Error) {
//             print(error)
//         }
//         
//         func filterImportantNews() {
//     //        filteredPayloads = allPayloads.filter { $0.importance == 1}
//             filteredPayloads = allPayloads
//             print("\nfilteredPayloads:--------> \(filteredPayloads)")
//         }
//         
//         func handleResponse(_ model: TopNewsModel) {
//             allPayloads = model.result.payload
//     //        allPayloads = model
//             print("\n allPayloads of TopNewsModel:----> \(allPayloads)")
//             
//             updateUI()
//         }
//    
//         func updateUI() {
//             filterImportantNews()
//             filteredPayloads.sort { payload1, payload2 in
//                 guard let date1 = DateHelper.convertToDate(from: payload1.date),
//                       let date2 = DateHelper.convertToDate(from: payload2.date) else { return false }
//                 return date1 > date2
//             }
//             tblView.reloadData()
//         }
//    
//   
//    
//     }
//
//
//extension String {
//    /// Returns the flag emoji for the given country code.
//    func flagEmoji() -> String {
//        let base: UInt32 = 127397
//        var flag = ""
//        for scalar in self.uppercased().unicodeScalars {
//            if let scalarValue = UnicodeScalar(base + scalar.value) {
//                flag.unicodeScalars.append(scalarValue)
//            }
//        }
//        return flag
//    }
//}
