//
//  AccountsViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//
import Foundation
import UIKit

class AccountsViewController: UIViewController {
   
    @IBOutlet weak var tblView: UITableView!
    var model: [String] = ["Open","Pending","Close","image"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.registerCells([
            AccountTableViewCell.self, TradeTypeTableViewCell.self, TransactionCell.self
        ])
      
        tblView.reloadData()

    }
}

extension AccountsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return 1
        }else{
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: AccountTableViewCell.self, for: indexPath)
            cell.setHeaderUI(.account)
            cell.delegate = self
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(with: TradeTypeTableViewCell.self, for: indexPath)
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(with: TransactionCell.self, for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 397.0
        }else if indexPath.section == 1{
            return 40
            
        }else{
            return 100.0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TradeTypeTableViewCell") as? TradeTypeTableViewCell
            
            
        }
    }
}

extension AccountsViewController: AccountInfoDelegate {
    func accountInfoTap(_ accountInfo: AccountInfo) {
        print("delegte called  \(accountInfo)" )
        
        switch accountInfo {
       
        case .deposit:
            let vc = Utilities.shared.getViewController(identifier: .depositViewController, storyboardType: .dashboard) as! DepositViewController
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        case .withDraw:
            let vc = Utilities.shared.getViewController(identifier: .withdrawViewController, storyboardType: .dashboard) as! WithdrawViewController
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        case .history:
            let vc = Utilities.shared.getViewController(identifier: .historyViewController, storyboardType: .dashboard) as! HistoryViewController
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        case .detail:
            let vc = Utilities.shared.getViewController(identifier: .detailsViewController, storyboardType: .dashboard) as! DetailsViewController
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        case .notification:
            let vc = Utilities.shared.getViewController(identifier: .notificationViewController, storyboardType: .dashboard) as! NotificationViewController
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        }

        
    }
    
    
}
