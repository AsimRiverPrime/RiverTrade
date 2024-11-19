//
//  ProfileViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/07/2024.
//

import UIKit

class ProfileViewController: BaseViewController{
        
        @IBOutlet weak var tblView: UITableView!
        
//        @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
//        @IBOutlet weak var tblViewTopConstraint: NSLayoutConstraint!
        
        //    weak var delegate: AccountInfoTapDelegate?
        weak var delegateCompeleteProfile: DashboardVCDelegate?
        //    var model: [String] = ["Open","Pending","Close","image"]
        //weak var delegateKYC: KYCVCDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.isScrollEnabled = false
        // Do any additional setup after loading the view.
        tblView.registerCells([
            ProfileTopTableViewCell.self, RefferalProgramTableViewCell.self,  SuppotTableViewCell.self, LogoutTableViewCell.self
        ])
        
        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: AccountsViewController(), navController: self.navigationController, title: "Profile", leftTitle: "", rightTitle: "", textColor: .white, barColor: .clear)
        
    }
}
//        public override func awakeFromNib() {
//            
//            //MARK: - Handle tableview constraints according to the device logical height.
//            setTableViewLayoutTopConstraints()
//            
//           
//        
//        
//        class func getView()->ProfileVC {
//            return Bundle.main.loadNibNamed("ProfileVC", owner: self, options: nil)?.first as! ProfileVC
//        }
//        
//        func dismissView() {
//            UIView.animate(
//                withDuration: 0.4,
//                delay: 0.04,
//                animations: {
//                    self.alpha = 0
//                }, completion: { (complete) in
//                    self.removeFromSuperview()
//                })
//        }
//        
        
//    }

    extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 4
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if section == 0 {
                return 1
            }else if section == 1 {
                return 1
            }else if section == 2 {
                return 1
            
            }else{
                return 1
            }
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(with: ProfileTopTableViewCell.self, for: indexPath)
                
                cell.delegate = self
                cell.selectionStyle = .none
                cell.editDelegate = self
                return cell
                
    //        } else if indexPath.section == 1 {
    //            let cell = tableView.dequeueReusableCell(with: BenefitsTableViewCell.self, for: indexPath)
    //            cell.backgroundColor = .clear
    ////
    ////            cell.onAllRealAccountsFilterButtonClick = {
    ////                [self] in
    ////                print("Click on onAllRealAccountsFilterButtonClick")
    ////
    ////            }
    ////
    ////            cell.onDaysFilterButton = {
    ////                [self] in
    ////                print("Click on onDaysFilterButton")
    ////
    ////            }
    //
    //            self.setNeedsLayout()
    //            return cell
                
            } else if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(with: RefferalProgramTableViewCell.self, for: indexPath)
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
//                self.setNeedsLayout()
                return cell
            }else if indexPath.section == 2 {
    //            let cell = tableView.dequeueReusableCell(with: SocialTradeTableViewCell.self, for: indexPath)
    //            cell.backgroundColor = .clear
    //
    //            self.setNeedsLayout()
    //            return cell
    //
    //        }else if indexPath.section == 4 {
                let cell = tableView.dequeueReusableCell(with: SuppotTableViewCell.self, for: indexPath)
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(with: LogoutTableViewCell.self, for: indexPath)
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                return cell
            }
            
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if indexPath.section == 0 {
                return 200
                
            }else if indexPath.section == 1 {
                return 110
                
            } else if indexPath.section == 2 {
                return 310
                
            }else{
                return 80
            }
        }
        
    }

//    extension ProfileViewController: ResultTopDelegate {
//        
//        func resultTopTap(_ resultTopButtonType: ResultTopButtonType, index: Int) {
//            print("resultTopButtonType = \(resultTopButtonType)")
//        }
//        
//    }


    extension ProfileViewController: CompleteProfileButtonDelegate {
        
        func didTapCompleteProfileButtonInCell() {
//            delegateCompeleteProfile?.navigateToCompeletProfile()
//            if profileStep == 0 {
//                if let kycVc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "KYCViewController") {
//                  
//                    self.navigate(to: kycVc)
//                }
//            }else if profileStep == 1 {
//                let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
//                vc.delegateKYC = self
//                PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//            }else if profileStep == 2 {
//                let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen7, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen7
//                vc.delegateKYC = self
//                PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//            }else{
//                self.ToastMessage("Already Done KYC")
//            }
//            
        }
        
    }

extension ProfileViewController: ProfileEditButtonDelegate {
    func didTapEditButtonInCell() {
        let vc = Utilities.shared.getViewController(identifier: .editPhotoVC, storyboardType: .dashboard) as! EditPhotoVC
        self.navigate(to: vc)
    }
    
}
        
        //MARK: - Set TableViewTopConstraint.
//        private func setTableViewLayoutTopConstraints() {
//            
//            if UIDevice.isPhone {
//                print("screen_height = \(screen_height)")
//                if screen_height >= 667.0 && screen_height <= 736.0 {
//                    //MARK: - iphone6s, iphoneSE, iphone7 plus
//                    tblViewTopConstraint.constant = -20
//                    
//                } else if screen_height == 812.0 {
//                    //MARK: - iphoneXs
//                    tblViewTopConstraint.constant = -45
//                    
//                } else if screen_height >= 852.0 && screen_height <= 932.0 {
//                    //MARK: - iphone14 pro, iphone14, iphone14 Plus, iphone14 Pro Max
//                    tblViewTopConstraint.constant = -60
//                    
//                }else if screen_height == 844.0 {
//                    tblViewTopConstraint.constant = -55
//                }  else {
//                    //MARK: - other iphone if not in the above check's.
//                    tblViewTopConstraint.constant = 0
//                }
//                
//            } else {
//                //MARK: - iPad
//                
//            }
//            
//        }
        
//        private func setTableViewLayoutConstraints() {
//            
//            if UIDevice.isPhone {
//                print("screen_height = \(screen_height)")
//                if screen_height >= 667.0 && screen_height <= 736.0 {
//                    //MARK: - iphone6s, iphoneSE, iphone7 plus
//                    tableViewBottomConstraint.constant = 145
//                    
//                } else if screen_height == 812.0 {
//                    //MARK: - iphoneXs
//                    tableViewBottomConstraint.constant = 165
//                    
//                } else if screen_height >= 852.0 && screen_height <= 932.0 {
//                    //MARK: - iphone14 pro, iphone14, iphone14 Plus, iphone14 Pro Max
//                    tableViewBottomConstraint.constant = 175
//                    
//                } else {
//                    //MARK: - other iphone if not in the above check's.
//                    tableViewBottomConstraint.constant = 165
//                }
//                
//            }
//            
//        }
        
  

