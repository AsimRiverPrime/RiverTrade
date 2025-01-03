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

    let odooServer = OdooClientNew()
    var allPayloads: [PayloadItem] = []
    var filteredPayloads: [PayloadItem] = []
    
    var allEvents: [Event] = []
    var filteredEvents: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        odooServer.topNewsDelegate = self
        odooServer.economicCalendarDelegate = self
        
        tblView.registerCells([
           EconomicCalendarSection.self, UpcomingEventsTableViewCell.self, TopNewsSection.self, TopNewsTableViewCell.self
        ])
        tblView.reloadData()
        tblView.dataSource = self
        tblView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let (currentDate, tomorrowDate) = getCurrentAndTomorrowDate()
        print("currentDate: \(currentDate) , tomorrowDate: \(tomorrowDate)")
        odooServer.getCalendarDataRecords(fromDate: currentDate, toDate: tomorrowDate)
        odooServer.getNewsRecords()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)

        getinitialBalance()
        
    }
    
    func getCurrentAndTomorrowDate() -> (String, String) {
        let currentDate = Date() // Current date and time
        let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)! // Add 1 day
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Format to match your API requirement
        
        let currentDateString = dateFormatter.string(from: currentDate)
        let tomorrowDateString = dateFormatter.string(from: tomorrowDate)
        
        return (currentDateString, tomorrowDateString)
    }
    
}

extension MarketsViewController {
    func getinitialBalance(){
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            self.lbl_accountGroup.text = defaultAccount.groupName
            lbl_accountType.text = defaultAccount.isReal == true ? "Real" : "Demo"
        }
        let getbalanceApi = TradeTypeCellVM()
        getbalanceApi.getUserBalance(completion: { result in
            switch result {
            case .success(let responseModel):
                // Save the response model or use it as needed
                print("Balance: \(responseModel.result.user.balance)")
                print("Equity: \(responseModel.result.user.equity)")
                self.labelAmmount.text = "$\(responseModel.result.user.balance)"
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
    
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            self.lbl_accountGroup.text = defaultAccount.groupName
            lbl_accountType.text = defaultAccount.isReal == true ? "Real" : "Demo"
        }
        
        if let ammount = notification.userInfo?[NotificationObserver.Constants.BalanceUpdateConstant.title] as? String {
            print("Received ammount: \(ammount)")
            self.labelAmmount.text = "$\(ammount)"
        }
        
    }
    
}

extension MarketsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            // Economic Calendar Section
            return 1 + filteredEvents.count // One row for `EconomicCalendarSection` and 3 for `UpcomingEventsTableViewCell`
        } else if section == 1 {
            // Top News Section
            return 1 + filteredPayloads.count // One row for `TopNewsSection` and others for `TopNewsTableViewCell`
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            // Economic Calendar Section
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EconomicCalendarSection", for: indexPath) as! EconomicCalendarSection
                cell.selectionStyle = .none
                cell.viewAllAction = { [unowned self] in
                    if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "EconomicCalendarListVC") as? EconomicCalendarListVC {
                        
                        vc.allEvents = self.allEvents
                        self.navigate(to: vc)
                    }
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingEventsTableViewCell", for: indexPath) as! UpcomingEventsTableViewCell
                cell.selectionStyle = .none
                
                let payloadIndex = indexPath.row - 1 // Subtract 1 for the header row
                let payload = filteredEvents[payloadIndex]
            
                cell.configure(with: payload)
                return cell
            }
        } else if indexPath.section == 1 {
            // Top News Section
            if indexPath.row == 0 {
                // Top News Section Header
                let cell = tableView.dequeueReusableCell(withIdentifier: "TopNewsSection", for: indexPath) as! TopNewsSection
                cell.selectionStyle = .none
                cell.viewAllAction = { [unowned self] in
                    if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "TopNewsViewController") as? TopNewsViewController {
                        
                        vc.allPayloads = allPayloads
                        self.navigate(to: vc)
                    }
                }
                return cell
            } else {
                // Top News Payload Rows
                let payloadIndex = indexPath.row - 1 // Subtract 1 for the header row
                let payload = filteredPayloads[payloadIndex]
                let cell = tableView.dequeueReusableCell(withIdentifier: "TopNewsTableViewCell", for: indexPath) as! TopNewsTableViewCell
                cell.selectionStyle = .none
                cell.lbl_title.text = payload.title
                
                cell.lbl_date.text = DateHelper.timeAgo(from: payload.date)
                                
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            // Economic Calendar Section
            if indexPath.row == 0 {
                return 40 // Height for EconomicCalendarSection cell
            } else {
                return 80 // Height for UpcomingEventsTableViewCell
            }
        } else if indexPath.section == 1 {
            // Top News Section
            if indexPath.row == 0 {
                return 40 // Height for TopNewsSection cell
            } else {
                return 80 // Height for TopNewsTableViewCell
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
            }else{
                let index = indexPath.row - 1
                let selectedItem = filteredEvents[index]
                if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "EconomicCalendarDetailVC") as? EconomicCalendarDetailVC {
                    
                    vc.selectedItem = selectedItem
                    self.navigate(to: vc)
                }
            }
        }else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                
            }else{
                let index = indexPath.row - 1
                let selectedItem = filteredPayloads[index]
                if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "TopNewsDetailVC") as? TopNewsDetailVC {
                    
                    vc.selectedItem = selectedItem
                    self.navigate(to: vc)
                }
            }
        }
    }


}
extension MarketsViewController: TopNewsProtocol {
    func topNewsSuccess(response: TopNewsModel/*[PayloadItem]*/) {
        print(response)
        let topNewsModel = response
        handleResponse(topNewsModel)
    }
    
    func topNewsFailure(error: any Error) {
        print(error)
    }
    
    func filterImportantNews() {
        filteredPayloads = allPayloads.filter { $0.importance == 1}
        print("filteredPayloads: \(filteredPayloads)")
    }
    
    func handleResponse(_ model: TopNewsModel/*[PayloadItem]*/) {
        allPayloads = model.result.payload
//        allPayloads = model
        print("allPayloads: \(allPayloads)")
        
        updateUI()
    }
    func updateUI() {
        filterImportantNews()
        filteredPayloads.sort { payload1, payload2 in
            guard let date1 = DateHelper.convertToDate(from: payload1.date),
                  let date2 = DateHelper.convertToDate(from: payload2.date) else { return false }
            return date1 > date2
        }
        tblView.reloadData()
    }
}

extension MarketsViewController: EconomicCalendarProtocol {
    func economicCalendarSuccess(response: EconomicCalendarModel) {
        print("economic events result\(response)")
        let economicCalendarModel = response
        handleResponse(economicCalendarModel)
    }
    
    func economicCalendarFailure(error: any Error) {
        print(error)
    }
  
    func calendarFilterImportantEvents() {
        filteredEvents = allEvents.filter { $0.importance == 1 }
        print("filtered Events: \(filteredEvents)")
    }
    
    func handleResponse(_ model: EconomicCalendarModel/*[PayloadItem]*/) {
        allEvents = model.result.payload
//        allPayloads = model
        print("all Events: \(allEvents)")
        
        updateEconomicUI()
    }
    func updateEconomicUI() {
        calendarFilterImportantEvents()
        filteredPayloads.sort { payload1, payload2 in
            guard let date1 = DateHelper.convertToDate(from: payload1.date),
                  let date2 = DateHelper.convertToDate(from: payload2.date) else { return false }
            return date1 > date2
        }
        tblView.reloadData()
    }
}
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
