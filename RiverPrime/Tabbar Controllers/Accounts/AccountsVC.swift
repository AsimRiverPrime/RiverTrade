//
//  AccountsVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/07/2024.
//

import UIKit

protocol AccountInfoTapDelegate: AnyObject {
    func accountInfoTap(_ accountInfo: AccountInfo)
    
}

protocol CreateAccountInfoTapDelegate: AnyObject {
    func createAccountInfoTap(_ createAccountInfo: CreateAccountInfo)
}

class AccountsVC: UIView {
    
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblViewTopConstraint: NSLayoutConstraint!
    
    weak var delegate: AccountInfoTapDelegate?
    weak var delegateCreateAccount: CreateAccountInfoTapDelegate?
    
    var model: [String] = ["Open","Pending","Close","image"]
    
//    var opcList: (String,[OpenModel]) = ("",[])
    var opcList: OPCType? = .open([])

    public override func awakeFromNib() {
        
        //MARK: - Handle tableview constraints according to the device logical height.
//        setTableViewLayoutConstraints()
        setTableViewLayoutTopConstraints()
        
        /*
        if GlobalVariable.instance.isAccountCreated { //MARK: - if account is already created.
            
        } else { //MARK: - if no account exist.
            
        }
        */
        
        if GlobalVariable.instance.isAccountCreated { //MARK: - if account is already created.
            tblView.registerCells([
                AccountTableViewCell.self, TradeTypeTableViewCell.self, TransactionCell.self, PendingOrderCell.self, CloseOrderCell.self
            ])
        } else { //MARK: - if no account exist.
            tblView.registerCells([
                CreateAccountTVCell.self, TradeTypeTableViewCell.self, TransactionCell.self, PendingOrderCell.self, CloseOrderCell.self
            ])
        }
      
        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
    }
    
    class func getView()->AccountsVC {
        return Bundle.main.loadNibNamed("AccountsVC", owner: self, options: nil)?.first as! AccountsVC
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

extension AccountsVC: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Just reload the given tableview section.
    func refreshSection(at section: Int) {
        let indexSet = IndexSet(integer: section)
        tblView.reloadSections(indexSet, with: .none)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return 1
        }else{
            switch opcList {
            case .open(let open):
                return open.count
            case .pending(let pending):
                return pending.count
            case .close(let close):
                return close.count
            case .none:
                return 0
            }
            
//            return  //opcList.1.count //4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if GlobalVariable.instance.isAccountCreated { //MARK: - if account is already created.
                let cell = tableView.dequeueReusableCell(with: AccountTableViewCell.self, for: indexPath)
                cell.setHeaderUI(.account)
                cell.delegate = self
                return cell
            } else { //MARK: - if no account exist.
                let cell = tableView.dequeueReusableCell(with: CreateAccountTVCell.self, for: indexPath)
                //            cell.setHeaderUI(.account)
                cell.delegate = self
                return cell
            }
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(with: TradeTypeTableViewCell.self, for: indexPath)
            cell.delegate = self
            cell.backgroundColor = .clear
            return cell
            
        }else{
            
            switch opcList {
            case .open(let openData):
//                    cell.symbolName.text = openData[indexPath.row].symbol
                
                let cell = tableView.dequeueReusableCell(with: TransactionCell.self, for: indexPath)
                if GlobalVariable.instance.isAccountCreated {
                    cell.isHidden = false
                    
                    cell.getCellData(open: openData, indexPath: indexPath)
                    
                }else{
                    cell.isHidden = true
                }
                return cell
                
            case .pending(let pendingData):
                
                let cell = tableView.dequeueReusableCell(with: PendingOrderCell.self, for: indexPath)
                if GlobalVariable.instance.isAccountCreated {
                    cell.isHidden = false
                    
                    cell.getCellData(pending: pendingData, indexPath: indexPath)
                    
                }else{
                    cell.isHidden = true
                }
                return cell
                
            case .close(let closeData):
                
                let cell = tableView.dequeueReusableCell(with: CloseOrderCell.self, for: indexPath)
                if GlobalVariable.instance.isAccountCreated {
                    cell.isHidden = false
                    
                    cell.getCellData(close: closeData, indexPath: indexPath)
                    
                }else{
                    cell.isHidden = true
                }
                return cell
                
            case .none:
                return UITableViewCell()
            }
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if GlobalVariable.instance.isAccountCreated { //MARK: - if account is already created.
                return 397.0
            } else { //MARK: - if no account exist.
                return 300.0
            }
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AccountsVC: AccountInfoDelegate {
    func accountInfoTap(_ accountInfo: AccountInfo) {
        print("delegte called  \(accountInfo)" )
        
        switch accountInfo {
       
        case .deposit:
//            let vc = Utilities.shared.getViewController(identifier: .depositViewController, storyboardType: .dashboard) as! DepositViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            delegate?.accountInfoTap(.deposit)
            break
        case .withDraw:
//            let vc = Utilities.shared.getViewController(identifier: .withdrawViewController, storyboardType: .dashboard) as! WithdrawViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            delegate?.accountInfoTap(.withDraw)
            break
        case .history:
//            let vc = Utilities.shared.getViewController(identifier: .historyViewController, storyboardType: .dashboard) as! HistoryViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            delegate?.accountInfoTap(.history)
            break
        case .detail:
//            let vc = Utilities.shared.getViewController(identifier: .detailsViewController, storyboardType: .dashboard) as! DetailsViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            delegate?.accountInfoTap(.detail)
            break
        case .notification:
//            let vc = Utilities.shared.getViewController(identifier: .notificationViewController, storyboardType: .dashboard) as! NotificationViewController
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            delegate?.accountInfoTap(.notification)
            break
        case .createAccount:
            delegate?.accountInfoTap(.createAccount)
            break
        }

        
    }
    
    
}

extension AccountsVC: CreateAccountInfoDelegate {
    
    func createAccountInfoTap(_ createAccountInfo: CreateAccountInfo) {
        print("delegte called  \(createAccountInfo)" )
        
        switch createAccountInfo {
        case .createNew:
            delegateCreateAccount?.createAccountInfoTap(.createNew)
            break
        case .unarchive:
            delegateCreateAccount?.createAccountInfoTap(.unarchive)
            break
        case .notification:
            delegateCreateAccount?.createAccountInfoTap(.notification)
            break
        }
    }
    
}

extension AccountsVC: OPCDelegate {
    func getOPCData(opcType: OPCType) {
        print("opcType = \(opcType)")
        
        self.opcList = opcType
        
        refreshSection(at: 2)
        
//        switch opcType {
//        case .open(let openData):
//
////            self.opcList.0 = "Open"
////            self.opcList.1.removeAll()
////            self.opcList.1 = openData
//
//            self.opcList = openData
//
//            refreshSection(at: 2)
//
//            break
//
//        case .close(let closeData):
//
////            self.opcList.0 = "Close"
////            self.opcList.1.removeAll()
////            self.opcList.1 = closeData
//
//            refreshSection(at: 2)
//
//            break
//        }
    }
    
//    func getOPCData(opcType: OPCType, openModel: [OpenModel]) {
////        print("OPC Result")
//        print("opcType = \(opcType)")
//        print("openModel = \(openModel)")
//        switch opcType {
//        case .open:
//
//            self.opcList.0 = "Open"
//            self.opcList.1.removeAll()
//            self.opcList.1 = openModel
//
//            refreshSection(at: 2)
//
//            break
//        case .pending:
//
//
//            break
//        case .close:
//
//
//            break
//
//        }
//    }
//
//    func getOPCData(opcType: OPCType, closeModel: [CloseModel]) {
//
//        print("opcType = \(opcType)")
//        print("closeModel = \(closeModel)")
//
//        self.opcList.0 = "Close"
//        self.opcList.1.removeAll()
//        self.opcList.1 = closeModel
//
//        refreshSection(at: 2)
//
//    }
    
}

//MARK: - Layout Constraints.
extension AccountsVC {
    
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
                
            }else if screen_height == 844.0 {
                tblViewTopConstraint.constant = -55
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
                
            } else if screen_height == 844.0 {
                tableViewBottomConstraint.constant = 175
            } else {
                //MARK: - other iphone if not in the above check's.
                tableViewBottomConstraint.constant = 165
            }
            
        }
        
    }
    
}
