//
//  DetailsViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit

class DetailsViewController: UIViewController {

    
    @IBOutlet weak var detail_tableView: UITableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        
        detail_tableView.registerCells([
            AccountTableViewCell.self, ListingTableViewCell.self
        ])
        detail_tableView.delegate = self
        detail_tableView.dataSource = self
        detail_tableView.reloadData() 
    }
    
    
}
extension DetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
           return 2
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return 2
        }
    }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(with: AccountTableViewCell.self, for: indexPath)
                cell.setHeaderUI(.detail)
//                cell.delegate = self
                
                return cell
            } else  {
                let cell = tableView.dequeueReusableCell(with: ListingTableViewCell.self, for: indexPath)
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
