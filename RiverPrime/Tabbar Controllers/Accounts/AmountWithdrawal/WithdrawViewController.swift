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
            ProfileTopTableViewCell.self, ListingTableViewCell.self
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
                let cell = tableView.dequeueReusableCell(with: ProfileTopTableViewCell.self, for: indexPath)
            
                cell.lbl_title.text = "Withdraw"
                cell.imageIcon.isHidden = true
                cell.btn_edit.isHidden = true
                cell.btn_editProfile.isHidden = true
//                cell.delegate = self
                return cell
            } else  {
                let cell = tableView.dequeueReusableCell(with: ListingTableViewCell.self, for: indexPath)
                cell.lblTitle.text = self.bank_item[indexPath.row]
                cell.selectionStyle = .none
                return cell
            }
            
            
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if indexPath.section == 0 {
                return 200
            }else{
                return 170
            }
        }
        
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

