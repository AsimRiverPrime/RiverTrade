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
    
    let odooServer = OdooClientNew()
    var allPayloads: [PayloadItem] = []
    var filteredPayloads: [PayloadItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        odooServer.topNewsDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
        
        //        odooServer.getCalendarDataRecords(fromDate: "2024-12-11", toDate: "2024-12-12")
        
        
        tblView.registerCells([
            /*MarketTopMoversTableViewCell.self, TradingSignalTableViewCell.self,*/ EconomicCalendarSection.self, UpcomingEventsTableViewCell.self, TopNewsSection.self, TopNewsTableViewCell.self
        ])
        tblView.reloadData()
        tblView.dataSource = self
        tblView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        odooServer.getNewsRecords()
    }
}

extension MarketsViewController {
    
    @objc func notificationPopup(_ notification: NSNotification) {
        
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
            return 4 // One row for `EconomicCalendarSection` and 3 for `UpcomingEventsTableViewCell`
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
                cell.viewAllAction = {
                    // Handle View All Action
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingEventsTableViewCell", for: indexPath) as! UpcomingEventsTableViewCell
                cell.selectionStyle = .none
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
                
                cell.lbl_date.text = timeAgo(from: payload.date)
                                
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
  
    func convertToDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS" // Match API format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Parse as UTC
        return dateFormatter.date(from: dateString)
    }
    func timeAgo(from dateString: String) -> String {
        guard let apiDate = convertToDate(from: dateString) else {
            return "Invalid Date"
        }

        // Get the current date and adjust to UTC
        let currentDate = Date()
        let utcCurrentDate = Calendar.current.date(byAdding: .second, value: -TimeZone.current.secondsFromGMT(), to: currentDate)!

        print("API Date: \(apiDate), Current UTC Date: \(utcCurrentDate)") // Debugging

        // Time difference in seconds
        let difference = utcCurrentDate.timeIntervalSince(apiDate)
        
        if difference < 0 {
            return "In the future" // Handle future dates explicitly
        } else if difference < 60 {
            return "\(Int(difference))s ago" // Less than 1 minute
        } else if difference < 3600 {
            let minutes = Int(difference) / 60
            return "\(minutes)m ago" // Less than 1 hour
        } else if difference < 86400 {
            let hours = Int(difference) / 3600
            let minutes = (Int(difference) % 3600) / 60
            return "\(hours)h \(minutes)m ago" // Less than 1 day
        } else {
            let days = Int(difference) / 86400
            return "\(days)d ago" // More than 1 day
        }
    }

}
extension MarketsViewController: TopNewsProtocol {
    func topNewsSuccess(response: [PayloadItem]) {
        print(response)
        let topNewsModel = response
        handleResponse(topNewsModel)
    }
    
    func topNewsFailure(error: any Error) {
        print(error)
    }
    
    func filterImportantNews() {
        filteredPayloads = allPayloads.filter { $0.importance == 3 }
        print("filteredPayloads: \(filteredPayloads)")
    }
    
    func handleResponse(_ model: [PayloadItem]) {
//        allPayloads = model.result.payload
        allPayloads = model
        print("allPayloads: \(allPayloads)")
        
        updateUI()
    }
    func updateUI() {
        filterImportantNews()
        filteredPayloads.sort { payload1, payload2 in
            guard let date1 = convertToDate(from: payload1.date),
                  let date2 = convertToDate(from: payload2.date) else { return false }
            return date1 > date2
        }
        tblView.reloadData()
    }
}
