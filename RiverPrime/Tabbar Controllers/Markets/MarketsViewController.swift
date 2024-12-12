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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
       
        odooServer.getCalendarDataRecords(fromDate: "2024-12-11", toDate: "2024-12-12")
       
        
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
              return 4 // One row for `TopNewsSection` and 3 for `TopNewsTableViewCell`
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
                   let cell = tableView.dequeueReusableCell(withIdentifier: "TopNewsSection", for: indexPath) as! TopNewsSection
                   cell.selectionStyle = .none
                   cell.viewAllAction = { [unowned self] in
                       if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "TopNewsViewController") {
                           self.navigate(to: vc)
                       }
                   }
                   return cell
               } else {
                   let cell = tableView.dequeueReusableCell(withIdentifier: "TopNewsTableViewCell", for: indexPath) as! TopNewsTableViewCell
                   cell.selectionStyle = .none
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
                    return 100 // Height for TopNewsTableViewCell
                }
            }
            return UITableView.automaticDimension
    }
    

}

//
//extension MarketsViewController: UITableViewDelegate, UITableViewDataSource {
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//            return 2
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        if section == 0 {
////            return 1
////        }else if section == 1 {
////            return 1
////        }else
//        if section == 0 {
//            return 1
////        }else if section == 3 {
////            return 1
//        }else{
//            return 1
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////
////            if indexPath.section == 0 {
////            let cell = tableView.dequeueReusableCell(with: MarketTopMoversTableViewCell.self, for: indexPath)
////            cell.backgroundColor = .clear
////                cell.selectionStyle = .none
////            self.view.setNeedsLayout()
////            return cell
////            
////        }else if indexPath.section == 1 {
////            let cell = tableView.dequeueReusableCell(with: TradingSignalTableViewCell.self, for: indexPath)
////            cell.backgroundColor = .clear
////            cell.selectionStyle = .none
////            self.view.setNeedsLayout()
////            return cell
////        }else
//        if indexPath.section == 0 {
//            let cell = tableView.dequeueReusableCell(with: UpcomingEventsTableViewCell.self, for: indexPath)
//            cell.backgroundColor = .clear
//            cell.selectionStyle = .none
//            self.view.setNeedsLayout()
//            return cell
//            
//        }else{
//            let cell = tableView.dequeueReusableCell(with: TopNewsTableViewCell.self, for: indexPath)
//            cell.backgroundColor = .clear
//            cell.selectionStyle = .none
//            cell.viewAllAction  = { [unowned self] in
//                if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "TopNewsViewController") {
//                    self.navigate(to: vc)
//                }
//              
//              }
//            return cell
//        }
//       
//        
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        if indexPath.section == 0 {
////            return 250
////        }else if indexPath.section == 1 {
////            return 330
////            
////        }else
//        if indexPath.section == 0 {
//            return 300
//            
//        }else{
//            return 300
//        }
//    }
//    
//}

