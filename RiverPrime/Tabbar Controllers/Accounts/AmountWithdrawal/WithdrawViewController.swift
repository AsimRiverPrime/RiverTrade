//
//  WithdrawViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit

class WithdrawViewController: UIViewController {
    
    @IBOutlet weak var withDraw_tableView: UITableView!
    
    var bank_item = ["Bank Card", "Skrill" , "Venmo", "PayPal","BitCoin"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        withDraw_tableView.registerCells([
            AccountTableViewCell.self, ListingTableViewCell.self
        ])
        withDraw_tableView.delegate = self
        withDraw_tableView.dataSource = self
        withDraw_tableView.reloadData()

        
    }
}

extension WithdrawViewController: UITableViewDelegate, UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int {
           return 2
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return bank_item.count
        }
    }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(with: AccountTableViewCell.self, for: indexPath)
                cell.setHeaderUI(.withdraw)
//                cell.delegate = self
                
                return cell
            } else  {
                let cell = tableView.dequeueReusableCell(with: ListingTableViewCell.self, for: indexPath)
                cell.lblTitle.text = self.bank_item[indexPath.row]
                return cell
            }
            
            
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if indexPath.section == 0 {
                return 300.0
            }else{
                return 200.0
            }
        }
        
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
}

