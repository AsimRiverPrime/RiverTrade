//
//  DepositViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit

class DepositViewController: BaseViewController {
    
    @IBOutlet weak var deposit_tableView: UITableView!
    
    var bank_item = ["Bank Card", "Skrill" , "Venmo", "PayPal","BitCoin"]
    
    weak var delegateCompeleteProfile: DashboardVCDelegate?
    weak var delegate2 : CompleteProfileButtonDelegate?
    
    var profileStep = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegateCompeleteProfile = self
        self.delegate2 = self
        
        deposit_tableView.registerCells([
            ProfileTopTableViewCell.self, ListingTableViewCell.self
        ])
        
        deposit_tableView.reloadData()

        self.deposit_tableView.delegate = self
        self.deposit_tableView.dataSource = self

        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            if let _profileStep = savedUserData["profileStep"] as? Int{
                profileStep = _profileStep
            }
        }
    }
}

extension DepositViewController: UITableViewDelegate, UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int {
           return 2
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return 1
        }
    }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(with: ProfileTopTableViewCell.self, for: indexPath)
                cell.lbl_title.text = "Deposit"
                cell.delegate = self
//                cell.view_profileComplete.isHidden = true
//               let hieght = cell.bounds.height
//                cell.heightAnchor.constraint(equalToConstant: hieght - 100)
                return cell
            } else  {
                let cell = tableView.dequeueReusableCell(with: ListingTableViewCell.self, for: indexPath)
                cell.lblTitle.text = "Deposit using Trust wallet" //self.bank_item[indexPath.row]
                cell.icon_bank.image = UIImage(named: "trustWallet")
                cell.icon_bank.layer.cornerRadius = 0
                cell.icon_bank.backgroundColor = .clear
                return cell
            }
            
            
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if indexPath.section == 0 {
                return 230
            }else{
                return 180
            }
        }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension DepositViewController: DashboardVCDelegate {
    func navigateToCompeletProfile() {
        print("move to completeprofile screen")
        
        if profileStep == 0 {
            if let kycVc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "KYCViewController") {
                self.navigate(to: kycVc)
            }
        }else if profileStep == 1 {
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .dashboard) as! CompleteVerificationProfileScreen1
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        }else if profileStep == 2 {
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen7, storyboardType: .dashboard) as! CompleteVerificationProfileScreen7
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        }else{
            self.ToastMessage("Already Done KYC")
        }
        
    }
}

extension DepositViewController: CompleteProfileButtonDelegate {
    
    func didTapCompleteProfileButtonInCell() {
        print("profile header complete btn click")
        delegateCompeleteProfile?.navigateToCompeletProfile()
    }
    
}
