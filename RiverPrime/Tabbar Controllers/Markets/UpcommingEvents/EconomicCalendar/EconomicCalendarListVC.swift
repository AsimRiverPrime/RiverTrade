//
//  EconomicCalendarListVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 16/12/2024.
//

import UIKit

class EconomicCalendarListVC: BaseViewController {
    
    @IBOutlet weak var firstIcon: UIImageView!
    @IBOutlet weak var secondIcon: UIImageView!
    @IBOutlet weak var thridIcon: UIImageView!
    
    @IBOutlet weak var lbl_impactValue: UILabel!
    @IBOutlet weak var btn_impact: UIButton!
    @IBOutlet weak var tableView_economic: UITableView!
    
    var impactList = ["All","High", "Middle", "Low", "Lowest"]
    
    var allEvents : [Event] = []
    var filteredEvents: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Received Payloads: \(allEvents)")
        
        filteredEvents = allEvents
        tableView_economic.registerCells([
            UpcomingEventsTableViewCell.self
        ])
        
        tableView_economic.dataSource = self
        tableView_economic.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: MarketsViewController(), navController: self.navigationController, title: "", leftTitle: "", rightTitle: "", textColor: .lightGray, barColor: .clear)
    }
    func sortLatestDate () {
        filteredEvents.sort { payload1, payload2 in
            guard let date1 = DateHelper.convertToDate(from: payload1.date),
                  let date2 = DateHelper.convertToDate(from: payload2.date) else { return false }
            return date1 > date2
        }
    }
    
//    func convertToDate(from dateString: String) -> Date? {
//        let dateFormatter = DateFormatter()
//        
//        // Try parsing with milliseconds first
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
//        if let date = dateFormatter.date(from: dateString) {
//            return date
//        }
//        
//        // If that fails, try parsing without milliseconds
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        return dateFormatter.date(from: dateString)
//    }
    
//    func timeAgo(from dateString: String) -> String {
//        guard let apiDate = convertToDate(from: dateString) else {
//            return "Invalid Date"
//        }
//        
//        // Use UTC for current date as well to normalize the comparison
//        let currentDate = Date()
//        let utcCurrentDate = Calendar.current.date(byAdding: .second, value: -TimeZone.current.secondsFromGMT(), to: currentDate)!
//        
//        let difference = utcCurrentDate.timeIntervalSince(apiDate) // Time difference in seconds
//        print("API Date: \(apiDate), Current UTC Date: \(utcCurrentDate), Difference: \(difference)")
//        
//        if difference < 0 {
//            return "In the future" // Optional: Handle future dates explicitly
//        } else if difference < 60 {
//            return "\(Int(difference))s ago" // Less than 1 minute
//        } else if difference < 3600 {
//            let minutes = Int(difference) / 60
//            return "\(minutes)m ago" // Less than 1 hour
//        } else if difference < 86400 {
//            let hours = Int(difference) / 3600
//            let minutes = (Int(difference) % 3600) / 60
//            return "\(hours)h \(minutes)m ago" // Less than 1 day
//        } else {
//            let days = Int(difference) / 86400
//            return "\(days)d ago" // More than 1 day
//        }
//    }
    
    @IBAction func impactButtonAction(_ sender: UIButton) {
        self.dynamicDropDownButton(sender, list: impactList) { index, item in
            print("drop down index = \(index)")
            print("drop down item = \(item)")
            sender.setTitle("", for: .normal)
            self.lbl_impactValue.text = item
            
            self.filterEvents(byImpact: item)
            
            if item == "High" {
                self.firstIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
                self.secondIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
                self.thridIcon.image = UIImage(systemName: "star.fill")?.tint(with: .systemYellow)
            }else if item == "Middle"{
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
           } else {
               filteredEvents = allEvents.filter { event in
                   let eventImpact = mapImpactValue(impactLevel: event.importance)
                   return eventImpact == impact
               }
           }
           tableView_economic.reloadData()
       }

       func mapImpactValue(impactLevel: Int) -> String {
           switch impactLevel {
           case 0: return "Lowest"
           case 1: return "Low"
           case 2: return "Middle"
           case 3: return "High"
           default: return "All"
           }
       }
}

extension EconomicCalendarListVC: UITableViewDelegate, UITableViewDataSource {
    
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
       
        let payload = filteredEvents[indexPath.row]
       
        cell.configure(with: payload)
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

