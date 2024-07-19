//
//  MarketsViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/07/2024.
//

import UIKit

class MarketsViewController: UIViewController {

    @IBOutlet weak var tblView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.registerCells([
            AccountTableViewCell.self,MarketTopMoversTableViewCell.self, TradingSignalTableViewCell.self, UpcomingEventsTableViewCell.self, TopNewsTableViewCell.self
            ])
        tblView.reloadData()
        tblView.dataSource = self
        tblView.delegate = self
    }
    

}

extension MarketsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return 1
        }else if section == 2 {
            return 1
        }else if section == 3 {
            return 1
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: AccountTableViewCell.self, for: indexPath)
            cell.setHeaderUI(.market)
//            cell.delegate = self
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(with: MarketTopMoversTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
          
            self.view.setNeedsLayout()
            return cell
            
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(with: TradingSignalTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            
            self.view.setNeedsLayout()
            return cell
        }else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(with: UpcomingEventsTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            
            self.view.setNeedsLayout()
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(with: TopNewsTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            return cell
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300.0
        }else if indexPath.section == 1 {
            return 250
            
        }else if indexPath.section == 2 {
            return 300
            
        }else if indexPath.section == 3 {
            return 350
        }else{
            return 350
        }
    }
    
}

