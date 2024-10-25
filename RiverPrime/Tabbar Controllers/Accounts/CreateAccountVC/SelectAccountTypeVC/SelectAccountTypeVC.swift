//
//  SelectAccountTypeVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 03/08/2024.
//

import UIKit

struct SelectAccountType {
    var title = String()
    var detail = String()
}

class SelectAccountTypeVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var selectAccountType = [SelectAccountType]()
    
     var loginID = Int()
     var createDemoAccount = String()
     var realAccount = String()
     var accountType = String()
    var mt5 = String()
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.font = FontController.Fonts.Inter_SemiBold.font
        
        setModel()
        registerCell()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
    }
    
    private func setModel() {
        selectAccountType.removeAll()
        
        selectAccountType.append(SelectAccountType(title: "Demo account", detail: "Risk-free account. Trade with Virtual money."))
        selectAccountType.append(SelectAccountType(title: "Real account", detail: "Trade with real money and withdraw any profit you make."))
    }
    
    private func registerCell() {
        
        tableView.registerCells([
            SelectAccountTypeCell.self
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
      
    }
    
}

extension SelectAccountTypeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectAccountType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(with: SelectAccountTypeCell.self, for: indexPath)
        
        let model = selectAccountType[indexPath.row]
        
        cell.textLabel?.font = FontController.Fonts.ListInter_SemiBold.font
        cell.detailTextLabel?.font = FontController.Fonts.ListInter_Regular.font
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        cell.textLabel?.text = model.title
        
        if indexPath.row == 0 {//demo account
            if isAccountExist() {
                cell.detailTextLabel?.text = " # \(self.loginID)\n"  + "\n\(self.accountType) Account"
                cell.accessoryType = .none
            } else {
                cell.detailTextLabel?.text = model.detail
                cell.accessoryType = .disclosureIndicator
            }
        } else if indexPath.row == 1 {//real account
//            if isAccountExist() {
//                cell.detailTextLabel?.text = self.realAccount + "\t\(self.accountType)"
//                cell.accessoryType = .none
//            } else {
//                cell.detailTextLabel?.text = model.detail
//                cell.accessoryType = .disclosureIndicator
//            }
            cell.detailTextLabel?.text = model.detail
            cell.accessoryType = .disclosureIndicator
        }
        
//        cell.detailTextLabel?.text = model.detail
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            //MARK: - Create demo account
            
            if !isAccountExist() {
                //            let vc = Utilities.shared.getViewController(identifier: .createDemoAccountVC, storyboardType: .dashboard) as! CreateDemoAccountVC
                //            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
                let vc = Utilities.shared.getViewController(identifier: .createAccountSelectTradeType, storyboardType: .bottomSheetPopups) as! CreateAccountSelectTradeType
                vc.preferredSheetSizing = .large
                //            PresentModalController.instance.presentBottomSheet(self, VC: vc)
                PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customMedium, VC: vc)
            }
            
        } else if indexPath.row == 1 {
            //MARK: - Create real account
            
        }
    }
}

extension SelectAccountTypeVC {
    
    private func isAccountExist() -> Bool {
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("saved User Data: \(savedUserData)")
            // Access specific values from the dictionary
            
            if let loginID = savedUserData["loginId"] as? Int, let isCreateDemoAccount = savedUserData["demoAccountCreated"] as? Bool, let accountType = savedUserData["demoAccountGroup"] as? String, let isRealAccount = savedUserData["realAccountCreated"] as? Bool  {
                
                self.loginID = loginID
                
                if isCreateDemoAccount == true {
                    self.createDemoAccount = " Demo "
                }
                if isRealAccount == true {
                    self.realAccount = " Real "
                }
                if accountType == "Pro Account" {
                    self.accountType = " PRO "
                    self.mt5 = " MT5 "
                }else if accountType == "Prime Account" {
                    self.accountType = " PRIME "
                    self.mt5 = " MT5 "
                }else if accountType == "Premium Account" {
                    self.accountType = " PREMIUM "
                    self.mt5 = " MT5 "
                }else{
                    self.accountType = ""
                    self.mt5 = ""
                    
                }
                return true
            }
            return false
        }
        return false
    }
    
}
