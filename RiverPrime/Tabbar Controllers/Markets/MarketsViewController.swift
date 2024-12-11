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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
        
        tblView.registerCells([
            /*MarketTopMoversTableViewCell.self, TradingSignalTableViewCell.self,*/ UpcomingEventsTableViewCell.self, TopNewsTableViewCell.self
            ])
        tblView.reloadData()
        tblView.dataSource = self
        tblView.delegate = self
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
//        if section == 0 {
//            return 1
//        }else if section == 1 {
//            return 1
//        }else
        if section == 0 {
            return 1
//        }else if section == 3 {
//            return 1
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//            if indexPath.section == 0 {
//            let cell = tableView.dequeueReusableCell(with: MarketTopMoversTableViewCell.self, for: indexPath)
//            cell.backgroundColor = .clear
//                cell.selectionStyle = .none
//            self.view.setNeedsLayout()
//            return cell
//            
//        }else if indexPath.section == 1 {
//            let cell = tableView.dequeueReusableCell(with: TradingSignalTableViewCell.self, for: indexPath)
//            cell.backgroundColor = .clear
//            cell.selectionStyle = .none
//            self.view.setNeedsLayout()
//            return cell
//        }else
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: UpcomingEventsTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            self.view.setNeedsLayout()
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(with: TopNewsTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.viewAllAction  = { [unowned self] in
                if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "TopNewsViewController") {
                    self.navigate(to: vc)
                }
              
              }
            return cell
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            return 250
//        }else if indexPath.section == 1 {
//            return 330
//            
//        }else
        if indexPath.section == 0 {
            return 300
            
        }else{
            return 300
        }
    }
    
}

