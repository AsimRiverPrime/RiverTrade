//
//  TopNewsViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/12/2024.
//

import UIKit

class TopNewsViewController: BaseViewController {

    @IBOutlet weak var btn_allNews: UIButton!
    @IBOutlet weak var btn_favorites: UIButton!

    @IBOutlet weak var tableView_News: UITableView!
   
    var allPayloads : [PayloadItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Received Payloads: \(allPayloads)")
        
        tableView_News.registerCells([
         TopNewsTableViewCell.self
            ])
       
        tableView_News.dataSource = self
        tableView_News.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: MarketsViewController(), navController: self.navigationController, title: "", leftTitle: "", rightTitle: "", textColor: .lightGray, barColor: .clear)
    }
    func sortLatestDate () {
        allPayloads.sort { payload1, payload2 in
            guard let date1 = convertToDate(from: payload1.date),
                  let date2 = convertToDate(from: payload2.date) else { return false }
            return date1 > date2
        }
    }
    func convertToDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS" // Match your API time format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Ensure it's in UTC
        return dateFormatter.date(from: dateString)
    }
    func timeAgo(from dateString: String) -> String {
        guard let apiDate = convertToDate(from: dateString) else {
            return "Invalid Date"
        }

        // Use UTC for current date as well to normalize the comparison
        let currentDate = Date()
          let utcCurrentDate = Calendar.current.date(byAdding: .second, value: -TimeZone.current.secondsFromGMT(), to: currentDate)!
          
          let difference = utcCurrentDate.timeIntervalSince(apiDate) // Time difference in seconds
          print("API Date: \(apiDate), Current UTC Date: \(utcCurrentDate), Difference: \(difference)")

          if difference < 0 {
              return "In the future" // Optional: Handle future dates explicitly
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

extension TopNewsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return allPayloads.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(with: TopNewsTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
       
        let payload = allPayloads[indexPath.row]
        cell.lbl_title.text = payload.title
        
        cell.lbl_date.text = timeAgo(from: payload.date)
        
        switch payload.importance {
        case 1:
            cell.firstIcon.image = UIImage(named: "fireIconSelect")
            cell.secondIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
            cell.thridIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
        case 2:
            cell.firstIcon.image = UIImage(named: "fireIconSelect")
            cell.secondIcon.image = UIImage(named: "fireIconSelect")
            cell.thridIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
        case 3:
            cell.firstIcon.image = UIImage(named: "fireIconSelect")
            cell.secondIcon.image = UIImage(named: "fireIconSelect")
            cell.thridIcon.image = UIImage(named: "fireIconSelect")
        default:
            cell.firstIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
            cell.secondIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
            cell.thridIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
        }
        
            return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 80
    }
    
}

