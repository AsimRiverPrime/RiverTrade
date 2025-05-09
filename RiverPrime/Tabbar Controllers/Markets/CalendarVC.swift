//
//  CalendarVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 02/05/2025.
//

import UIKit

class CalendarVC: BaseViewController {
    
    @IBOutlet weak var firstIcon: UIImageView!
    @IBOutlet weak var secondIcon: UIImageView!
    @IBOutlet weak var thridIcon: UIImageView!
    
    @IBOutlet weak var starView: UIStackView!
    @IBOutlet weak var lbl_impactValue: UILabel!
    @IBOutlet weak var btn_impact: UIButton!
    @IBOutlet weak var lbl_noEvents: UILabel!
    @IBOutlet weak var lbl_impactLevel: UILabel!
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var labelAmmount: UILabel!
    
    @IBOutlet weak var lbl_accountType: UILabel!
    @IBOutlet weak var lbl_accountGroup: UILabel!

    var impactList = ["All","High", "Medium", "Low", "Lowest"]
    
    let odooServer = OdooClientNew()
    
    var allEvents: [Event] = []
    var filteredEvents: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_noEvents.isHidden = true
//        odooServer.topNewsDelegate = self
        odooServer.economicCalendarDelegate = self
        
        tblView.registerCells([
           EconomicCalendarSection.self, UpcomingEventsTableViewCell.self/*, TopNewsSection.self, TopNewsTableViewCell.self*/
        ])
        tblView.reloadData()
        tblView.dataSource = self
        tblView.delegate = self
        
        GlobalVariable.instance.controllerName = "MarketVC"
        NotificationCenter.default.addObserver(self, selector: #selector(self.FaceAfterLoginUpdate(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.FaceAfterLoginConstant.key), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let (currentDate, tomorrowDate) = getCurrentAndTomorrowDate()
        print("currentDate: \(currentDate) , tomorrowDate: \(tomorrowDate)")
        odooServer.getCalendarDataRecords(fromDate: currentDate, toDate: tomorrowDate)
//        odooServer.getNewsRecords()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)

        getinitialBalance()
        
    }
    
    
    @objc private func FaceAfterLoginUpdate(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let receivedString = userInfo[NotificationObserver.Constants.FaceAfterLoginConstant.title] as? String {
            print("Received string: \(receivedString)")
            
            if receivedString == "MarketVC" {
                let faceIdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! PasscodeFaceIDVC
                faceIdVC.afterLoginNavigation = true

                faceIdVC.modalPresentationStyle = .overFullScreen
                if let sheet = faceIdVC.sheetPresentationController {
//                        sheet.detents = [.medium(), .large()] // Adjust as needed
                        sheet.prefersGrabberVisible = true
                    }
                guard let topVC = faceIdVC.topMostViewController() else { return }
                topVC.present(faceIdVC, animated: true, completion: nil)
            }
            
        }
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

extension CalendarVC {
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
                
                let balance = (responseModel.result.user.balance)
                self.labelAmmount.text = "$\(String.formatStringNumber(String(balance)))"

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
            print("Received ammount in market news vc: \(ammount)")
            let amount = String.formatStringNumber(ammount)
            self.labelAmmount.text = "$\(String(describing: amount))"
        }
        
    }
    
    @IBAction func impactButtonAction(_ sender: UIButton) {
        self.dynamicDropDownButton(sender, list: impactList) { index, item in
            print("drop down index = \(index)")
            print("drop down item = \(item)")
            sender.setTitle("", for: .normal)
            self.lbl_impactValue.text = "Importance " + item
            self.lbl_impactLevel.text =  item
            self.filterEvents(byImpact: item)
            
            if item == "High" {
                self.firstIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
                self.secondIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
                self.thridIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
            }else if item == "Medium"{
                self.firstIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
                self.secondIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
                self.thridIcon.image = UIImage(systemName: "star.fill")?.tint(with: .lightGray)
            }else if item == "Low"{
                self.firstIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
                self.secondIcon.image = UIImage(systemName: "star.fill")?.tint(with: .lightGray)
                self.thridIcon.image = UIImage(systemName: "star.fill")?.tint(with: .lightGray)
            }else if item == "Lowest" {
                self.firstIcon.image = UIImage(systemName: "star.fill")?.tint(with: .lightGray)
                self.secondIcon.image = UIImage(systemName: "star.fill")?.tint(with: .lightGray)
                self.thridIcon.image = UIImage(systemName: "star.fill")?.tint(with: .lightGray)
            }else {
//                self.starView.isHidden = true
                self.firstIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
                self.secondIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
                self.thridIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
            }
        }
    
    }
    // MARK: - Filtering Logic
       func filterEvents(byImpact impact: String) {
           if impact == "All" {
               filteredEvents = allEvents
//               self.starView.isHidden = true
           } else {
//               self.starView.isHidden = false
               filteredEvents = allEvents.filter { event in
                   let eventImpact = mapImpactValue(impactLevel: event.importance)
                   return eventImpact == impact
               }
           }
           if filteredEvents.count == 0 {
               lbl_noEvents.isHidden = false
           }else{
               lbl_noEvents.isHidden = true
           }
           tblView.reloadData()
       }

       func mapImpactValue(impactLevel: Int) -> String {
           switch impactLevel {
           case 0: return "Lowest"
           case 1: return "Low"
           case 2: return "Medium"
           case 3: return "High"
           default: return "All"
           }
       }
    
}

extension CalendarVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return filteredEvents.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(with: UpcomingEventsTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
       
        let event = filteredEvents[indexPath.row]
       
        cell.configure(with: event)
            return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = filteredEvents[indexPath.row]
        if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "EconomicCalendarDetailVC") as? EconomicCalendarDetailVC {
            
            vc.selectedItem = selectedItem
            self.navigate(to: vc)
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 80
    }

}

extension CalendarVC: EconomicCalendarProtocol {
    func economicCalendarSuccess(response: EconomicCalendarModel) {
        print("\n economic calendar events result: \(response)")
        let economicCalendarModel = response
        handleResponse(economicCalendarModel)
    }
    
    func economicCalendarFailure(error: any Error) {
        print(error)
    }
  
    func calendarFilterImportantEvents() {
//        filteredEvents = allEvents.filter { $0.importance == 1 }
        filteredEvents = allEvents
        print("filtered Events for calender : \(filteredEvents)")
    }
    
    func handleResponse(_ model: EconomicCalendarModel/*[PayloadItem]*/) {
        allEvents = model.result.payload
//        allPayloads = model
        print("all Events for calendar: \(allEvents)")
        
        updateEconomicUI()
    }
    
    func updateEconomicUI() {
        calendarFilterImportantEvents()
        filteredEvents.sort { payload1, payload2 in
            guard let date1 = DateHelper.convertToDate(from: payload1.date),
                  let date2 = DateHelper.convertToDate(from: payload2.date) else { return false }
            return date1 > date2
        }
        tblView.reloadData()
    }
}
