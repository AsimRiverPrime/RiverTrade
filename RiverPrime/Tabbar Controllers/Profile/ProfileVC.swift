//
//  ProfileVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 23/07/2024.
//

import UIKit

class ProfileVC: UIView {
    
    
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblViewTopConstraint: NSLayoutConstraint!
    
    //    weak var delegate: AccountInfoTapDelegate?
    weak var delegateCompeleteProfile: DashboardVCDelegate?
    //    var model: [String] = ["Open","Pending","Close","image"]
    
    public override func awakeFromNib() {
        
        //MARK: - Handle tableview constraints according to the device logical height.
        setTableViewLayoutTopConstraints()
        
       
        tblView.registerCells([
            ProfileTopTableViewCell.self,BenefitsTableViewCell.self, RefferalProgramTableViewCell.self, SocialTradeTableViewCell.self, SuppotTableViewCell.self, LogoutTableViewCell.self
        ])
        
        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
    }
    
    class func getView()->ProfileVC {
        return Bundle.main.loadNibNamed("ProfileVC", owner: self, options: nil)?.first as! ProfileVC
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

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
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
            let cell = tableView.dequeueReusableCell(with: ProfileTopTableViewCell.self, for: indexPath)
            
            cell.delegate = self
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(with: BenefitsTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
//            
//            cell.onAllRealAccountsFilterButtonClick = {
//                [self] in
//                print("Click on onAllRealAccountsFilterButtonClick")
//                
//            }
//            
//            cell.onDaysFilterButton = {
//                [self] in
//                print("Click on onDaysFilterButton")
//                
//            }
            
            self.setNeedsLayout()
            return cell
            
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(with: RefferalProgramTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            
            self.setNeedsLayout()
            return cell
        }else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(with: SocialTradeTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            
            self.setNeedsLayout()
            return cell
            
        }else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(with: SuppotTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(with: LogoutTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 280
        }else if indexPath.section == 1 {
            return 170
            
        } else if indexPath.section == 2 {
            return 120
            
        }else if indexPath.section == 3 {
            return 190
        }else if indexPath.section == 4 {
            return 390
        }else{
            return 80
        }
    }
    
}

extension ProfileVC: ResultTopDelegate {
    
    func resultTopTap(_ resultTopButtonType: ResultTopButtonType, index: Int) {
        print("resultTopButtonType = \(resultTopButtonType)")
    }
    
}


extension ProfileVC: CompleteProfileButtonDelegate {
    
    func didTapCompleteProfileButtonInCell() {
        delegateCompeleteProfile?.navigateToCompeletProfile()
    }
    
}
extension ProfileVC {
    
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
