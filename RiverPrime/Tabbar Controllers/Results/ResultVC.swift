//
//  ResultVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 22/07/2024.
//

import UIKit

class ResultVC: UIView {
    
    
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblViewTopConstraint: NSLayoutConstraint!
    
    //    weak var delegate: AccountInfoTapDelegate?
    
    //    var model: [String] = ["Open","Pending","Close","image"]
    
    public override func awakeFromNib() {
        
        //MARK: - Handle tableview constraints according to the device logical height.
        //        setTableViewLayoutConstraints()
        setTableViewLayoutTopConstraints()
        
        //        tblView.registerCells([
        //            AccountTableViewCell.self, TradeTypeTableViewCell.self, TransactionCell.self
        //        ])
        
        tblView.registerCells([
            AccountTableViewCell.self,MarketTopMoversTableViewCell.self, TradingSignalTableViewCell.self, UpcomingEventsTableViewCell.self, TopNewsTableViewCell.self
        ])
        
        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
    }
    
    class func getView()->MarketsVC {
        return Bundle.main.loadNibNamed("MarketsVC", owner: self, options: nil)?.first as! MarketsVC
    }
    
    func dismissView() {
        UIView.animate(
            withDuration: 0.4,
            delay: 0.04,
            animations: {
                self.alpha = 0
            }, completion: { (complete) in
                self.removeFromSuperview()
            })
    }
    
    
}

extension ResultVC: UITableViewDelegate, UITableViewDataSource {
    
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
            
            self.setNeedsLayout()
            return cell
            
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(with: TradingSignalTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            
            self.setNeedsLayout()
            return cell
        }else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(with: UpcomingEventsTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            
            self.setNeedsLayout()
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

//extension MarketsVC: UITableViewDelegate, UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//            return 3
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return 1
//        }else if section == 1 {
//            return 1
//        }else{
//            return 4
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        if indexPath.section == 0 {
//            let cell = tableView.dequeueReusableCell(with: AccountTableViewCell.self, for: indexPath)
//            cell.setHeaderUI(.account)
//            cell.delegate = self
//            return cell
//
//        } else if indexPath.section == 1 {
//            let cell = tableView.dequeueReusableCell(with: TradeTypeTableViewCell.self, for: indexPath)
//            cell.backgroundColor = .clear
//            return cell
//
//        }else{
//            let cell = tableView.dequeueReusableCell(with: TransactionCell.self, for: indexPath)
//            return cell
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            return 397.0
//        }else if indexPath.section == 1{
//            return 40
//
//        }else{
//            return 100.0
//        }
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 1 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "TradeTypeTableViewCell") as? TradeTypeTableViewCell
//
//
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//}

//extension MarketsVC: AccountInfoDelegate {
//    func accountInfoTap(_ accountInfo: AccountInfo) {
//        print("delegte called  \(accountInfo)" )
//
//        switch accountInfo {
//
//        case .deposit:
////            let vc = Utilities.shared.getViewController(identifier: .depositViewController, storyboardType: .dashboard) as! DepositViewController
////            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//            delegate?.accountInfoTap(.deposit)
//            break
//        case .withDraw:
////            let vc = Utilities.shared.getViewController(identifier: .withdrawViewController, storyboardType: .dashboard) as! WithdrawViewController
////            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//            delegate?.accountInfoTap(.withDraw)
//            break
//        case .history:
////            let vc = Utilities.shared.getViewController(identifier: .historyViewController, storyboardType: .dashboard) as! HistoryViewController
////            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//            delegate?.accountInfoTap(.history)
//            break
//        case .detail:
////            let vc = Utilities.shared.getViewController(identifier: .detailsViewController, storyboardType: .dashboard) as! DetailsViewController
////            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//            delegate?.accountInfoTap(.detail)
//            break
//        case .notification:
////            let vc = Utilities.shared.getViewController(identifier: .notificationViewController, storyboardType: .dashboard) as! NotificationViewController
////            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//            delegate?.accountInfoTap(.notification)
//            break
//        }
//
//
//    }
//
//
//}

extension ResultVC {
    
    //MARK: - Set TableViewTopConstraint.
    private func setTableViewLayoutTopConstraints() {
        
        if UIDevice.isPhone {
            print("screen_height = \(screen_height)")
            if screen_height >= 667.0 && screen_height <= 736.0 {
                //MARK: - iphone6s, iphoneSE, iphone7 plus
                tblViewTopConstraint.constant = -20
                
            } else if screen_height == 812.0 {
                //MARK: - iphoneXs
                tblViewTopConstraint.constant = -30
                
            } else if screen_height >= 852.0 && screen_height <= 932.0 {
                //MARK: - iphone14 pro, iphone14, iphone14 Plus, iphone14 Pro Max
                tblViewTopConstraint.constant = -60
                
            } else {
                //MARK: - other iphone if not in the above check's.
                tblViewTopConstraint.constant = 0
            }
            
        } else {
            //MARK: - iPad
            
        }
        
    }
    
    private func setTableViewLayoutConstraints() {
        
        if UIDevice.isPhone {
            print("screen_height = \(screen_height)")
            if screen_height >= 667.0 && screen_height <= 736.0 {
                //MARK: - iphone6s, iphoneSE, iphone7 plus
                tableViewBottomConstraint.constant = 145
                
            } else if screen_height == 812.0 {
                //MARK: - iphoneXs
                tableViewBottomConstraint.constant = 165
                
            } else if screen_height >= 852.0 && screen_height <= 932.0 {
                //MARK: - iphone14 pro, iphone14, iphone14 Plus, iphone14 Pro Max
                tableViewBottomConstraint.constant = 175
                
            } else {
                //MARK: - other iphone if not in the above check's.
                tableViewBottomConstraint.constant = 165
            }
            
        }
        
    }
    
}
