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
    
    // Make odooServer a weak reference or properly manage its lifecycle
    private let odooServer = OdooClientNew()
    
    var allEvents: [Event] = []
    var filteredEvents: [Event] = []
    
    // Keep track of balance API request to cancel if needed
//    private var balanceRequest: TradeTypeCellVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ CalendarVC viewDidLoad - \(self)")
        
        lbl_noEvents.isHidden = true
        odooServer.economicCalendarDelegate = self
        
        tblView.registerCells([
           EconomicCalendarSection.self, UpcomingEventsTableViewCell.self
        ])
        tblView.reloadData()
        tblView.dataSource = self
        tblView.delegate = self
        
        GlobalVariable.instance.controllerName = "MarketVC"
        
        // Add observers
        addNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("✅ CalendarVC viewWillAppear - \(self)")
        
        // Re-add observers every time we appear (in case they were removed)
        addNotificationObservers()
        
        // Re-set delegate in case it was cleared
        odooServer.economicCalendarDelegate = self
        
        let (currentDate, tomorrowDate) = getCurrentAndTomorrowDate()
        print("currentDate: \(currentDate) , tomorrowDate: \(tomorrowDate)")
        odooServer.getCalendarDataRecords(fromDate: currentDate, toDate: tomorrowDate)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("⚠️ CalendarVC viewWillDisappear - \(self)")
        
        // Only remove observers, but keep data and delegates for when we return
        removeNotificationObservers()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("❌ CalendarVC viewDidDisappear - \(self)")
    }
    
    // MARK: - Notification Management
    private func addNotificationObservers() {
        // Remove first to avoid duplicate observers
        removeNotificationObservers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(faceAfterLoginUpdate(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.FaceAfterLoginConstant.key),object: nil )
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key),object: nil)
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
        odooServer.economicCalendarDelegate = nil
        
        // Cancel any ongoing balance requests
//        balanceRequest = nil
        
        // Clear arrays to help with memory
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
        
        if receivedString == "MarketVC" {
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

    private func getCurrentAndTomorrowDate() -> (String, String) {
        let currentDate = Date()
        let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let currentDateString = dateFormatter.string(from: currentDate)
        let tomorrowDateString = dateFormatter.string(from: tomorrowDate)
        
        return (currentDateString, tomorrowDateString)
    }
    
    deinit {
        print("🗑️ CalendarVC DEINIT called for \(self)")
        
        // Final cleanup in case viewWillDisappear wasn't called
        cleanup()
    }
}

// MARK: - Balance Management
extension CalendarVC {

    @objc func notificationPopup(_ notification: NSNotification) {
        guard let defaultAccount = UserAccountManager.shared.getDefaultAccount() else {
            return
        }
        
        self.lbl_accountGroup.text = defaultAccount.groupName
        lbl_accountType.text = defaultAccount.isReal == true ? "Real" : "Demo"
        
        if let ammount = notification.userInfo?[NotificationObserver.Constants.BalanceUpdateConstant.title] as? String {
            print("Received ammount in Calendar vc: \(ammount)")
            let amount = String.formatStringNumber(ammount)
            self.labelAmmount.text = "$\(String(describing: amount))"
        }
    }
    
    @IBAction func impactButtonAction(_ sender: UIButton) {
        self.dynamicDropDownButton(sender, list: impactList) { [weak self] index, item in
            guard let self = self else { return }
            
            print("drop down index = \(index)")
            print("drop down item = \(item)")
            
            sender.setTitle("", for: .normal)
            self.lbl_impactValue.text = "Importance " + item
            self.lbl_impactLevel.text = item
            self.filterEvents(byImpact: item)
            self.updateStarIcons(for: item)
        }
    }
    
    private func updateStarIcons(for item: String) {
        let yellowStar = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
        let grayStar = UIImage(systemName: "star.fill")?.tint(with: .lightGray)
        
        switch item {
        case "High":
            firstIcon.image = yellowStar
            secondIcon.image = yellowStar
            thridIcon.image = yellowStar
        case "Medium":
            firstIcon.image = yellowStar
            secondIcon.image = yellowStar
            thridIcon.image = grayStar
        case "Low":
            firstIcon.image = yellowStar
            secondIcon.image = grayStar
            thridIcon.image = grayStar
        case "Lowest":
            firstIcon.image = grayStar
            secondIcon.image = grayStar
            thridIcon.image = grayStar
        default: // "All"
            firstIcon.image = yellowStar
            secondIcon.image = yellowStar
            thridIcon.image = yellowStar
        }
    }
    
    // MARK: - Filtering Logic
    func filterEvents(byImpact impact: String) {
        if impact == "All" {
            filteredEvents = allEvents
        } else {
            filteredEvents = allEvents.filter { event in
                let eventImpact = mapImpactValue(impactLevel: event.importance)
                return eventImpact == impact
            }
        }
        
        lbl_noEvents.isHidden = !filteredEvents.isEmpty
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

// MARK: - TableView DataSource & Delegate
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
        
        guard let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "EconomicCalendarDetailVC") as? EconomicCalendarDetailVC else {
            return
        }
        
        vc.selectedItem = selectedItem
        self.navigate(to: vc)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Economic Calendar Protocol
extension CalendarVC: EconomicCalendarProtocol {
    func economicCalendarSuccess(response: EconomicCalendarModel) {
        print("\n economic calendar events result: \(response)")
        handleResponse(response)
    }
    
    func economicCalendarFailure(error: any Error) {
        print("Economic calendar error: \(error)")
    }
  
    func calendarFilterImportantEvents() {
        filteredEvents = allEvents
        print("filtered Events for calender : \(filteredEvents)")
    }
    
    func handleResponse(_ model: EconomicCalendarModel) {
        allEvents = model.result.payload
        print("all Events for calendar: \(allEvents)")
        updateEconomicUI()
    }
    
    func updateEconomicUI() {
        calendarFilterImportantEvents()
        
        filteredEvents.sort { payload1, payload2 in
            guard let date1 = DateHelper.convertToDate(from: payload1.date),
                  let date2 = DateHelper.convertToDate(from: payload2.date) else {
                return false
            }
            return date1 > date2
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Update the no events label
            self.lbl_noEvents.isHidden = !self.filteredEvents.isEmpty
            
            // Reload table view
            self.tblView.reloadData()
            
            print("📊 Table view reloaded with \(self.filteredEvents.count) events")
        }
    }
}
