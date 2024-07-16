//
//  TradeViewController.swift
//  RiverPrime
//
//  Created by Ahmad on 13/07/2024.
//

import UIKit

class TradeViewController: UIViewController {
    @IBOutlet weak var tblView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.registerCells([
            AccountTableViewCell.self,TradeTypeTableViewCell.self, TradeTableViewCell.self
            ])
        tblView.reloadData()

    }
    

}

extension TradeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return 1
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: AccountTableViewCell.self, for: indexPath)
            cell.setHeaderUI(.trade)
//            cell.delegate = self
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(with: TradeTypeTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(with: TradeTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            return cell
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300.0
        }else if indexPath.section == 1{
            return 50
            
        }else{
            return 100.0
        }
    }
    
}
