//
//  CreateAccountVC.swift
//  RiverPrime
//
//  Created by abrar ul haq on 03/08/2024.
//

import UIKit

//protocol CreateAccountInfoTapDelegate: AnyObject {
//    func createAccountInfoTap(_ createAccountInfo: CreateAccountInfo)
//}

class CreateAccountVC: UIView {
    
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblViewTopConstraint: NSLayoutConstraint!
    
    weak var delegate: CreateAccountInfoTapDelegate?
    
    public override func awakeFromNib() {
        
        //MARK: - Handle tableview constraints according to the device logical height.
//        setTableViewLayoutConstraints()
        setTableViewLayoutTopConstraints()
        
        tblView.registerCells([
            CreateAccountTVCell.self
        ])
      
        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
    }
    
    class func getView()->CreateAccountVC {
        return Bundle.main.loadNibNamed("CreateAccountVC", owner: self, options: nil)?.first as! CreateAccountVC
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

extension CreateAccountVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } /*else if section == 1 {
            return 1
        }else{
            return 4
        }*/
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: CreateAccountTVCell.self, for: indexPath)
//            cell.setHeaderUI(.account)
            cell.delegate = self
            return cell
            
        } /*else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(with: TradeTypeTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(with: TransactionCell.self, for: indexPath)
            return cell
        }*/
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300
        } /*else if indexPath.section == 1{
            return 40
            
        }else{
            return 100.0
        }*/
        
        return 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 1 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "TradeTypeTableViewCell") as? TradeTypeTableViewCell
//            
//            
//        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CreateAccountVC: CreateAccountInfoDelegate {
    
    func createAccountInfoTap(_ createAccountInfo: CreateAccountInfo) {
        print("delegte called  \(createAccountInfo)" )
        
        switch createAccountInfo {
        case .createNew:
            delegate?.createAccountInfoTap(.createNew)
            break
        case .unarchive:
            delegate?.createAccountInfoTap(.unarchive)
            break
        case .notification:
            delegate?.createAccountInfoTap(.notification)
            break
        }
    }
    
}

extension CreateAccountVC {
    
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
