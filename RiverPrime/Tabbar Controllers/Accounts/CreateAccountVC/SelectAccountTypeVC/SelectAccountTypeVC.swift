//
//  SelectAccountTypeVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 03/08/2024.
//

import UIKit

struct SelectAccountType {
    var title = String()
    var name = String()
    var loginID = String()
    var balance = String()
    var detail = String()
}

class SelectAccountTypeVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var btn_createAccount: CardViewButton!
    @IBOutlet weak var lbl_accountDescription: UILabel!
    @IBOutlet weak var demo_undelineView: UIView!
    @IBOutlet weak var real_undelineView: UIView!
    @IBOutlet weak var demoButton: UIButton!
    @IBOutlet weak var realButton: UIButton!
    @IBOutlet weak var nodata_label: UILabel!
    
    var selectAccountType = [SelectAccountType]()
    
    var loginID = Int()
    var createDemoAccount = String()
    var realAccount = String()
    var accountType = String()
    var mt5 = String()
    var firestoreObject = FirestoreServices()
    
    var demoData: [[String: Any]] = []
    var realData: [[String: Any]] = []
    var currentData: [[String: Any]] = []
    var  AccountReal = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.btn_createAccount.titleTintColor = .systemYellow
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("\n saved User Data: create account list \(savedUserData)")
            if let uid = savedUserData["uid"] as? String {
                
//                firestoreObject.fetchUserAccountsData(userId: uid)
                
                let savedList = UserDefaults.standard.dictionary(forKey: "userAccountsData")
                print("userAccountsData new is:\(savedList)")
                               
                if let savedList = UserDefaults.standard.dictionary(forKey: "userAccountsData") as? [String: [String: Any]] {
                    // if not working directly move to convert dictionary into json like
//                    if let savedData = UserDefaults.standard.data(forKey: "userAccountsData"),
//                    let jsonObject = try? JSONSerialization.jsonObject(with: savedData, options: []),
//                    let savedList = jsonObject as? [String: [String: Any]] {
                        
                    print("userAccountsData new is:\(savedList)")
                    // Clear the arrays to avoid duplicate data
                    demoData.removeAll()
                    realData.removeAll()
                    for (_, account) in savedList {
                        if let isReal = account["isReal"] as? Int {
                            if isReal == 0 {
                                demoData.append(account)
                            } else if isReal == 1 {
                                realData.append(account)
                            }
                        }
                    }
                    print("Demo Data: \(demoData)")
                    print("Real Data: \(realData)")
                }
            }
        }
        
        if demoData.count == 0 {
            self.nodata_label.isHidden = false
        }else{
            self.nodata_label.isHidden = true
        }
        registerCell()
    }
    
    
    
    private func registerCell() {
        
        tableView.registerCells([
            SelectAccountTypeCell.self
        ])
        //        tableView.isScrollEnabled = false
        currentData = demoData
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        updateButtonStyles(selectedButton: demoButton)
    }
    
    @IBAction func demoButtonTapped(_ sender: UIButton) {
        currentData = demoData
        if realData.count == 0 {
            nodata_label.isHidden = false
            nodata_label.text = "No Demo Account Found"
        }else{
            nodata_label.isHidden = true
        }
        tableView.reloadData()
        updateButtonStyles(selectedButton: sender)
    }
    
    @IBAction func realButtonTapped(_ sender: UIButton) {
        currentData = realData
        if realData.count == 0 {
            nodata_label.isHidden = false
            nodata_label.text = "No Real Account Found"
        }else{
            nodata_label.isHidden = true
        }
        tableView.reloadData()
        updateButtonStyles(selectedButton: sender)
    }
    
    func updateButtonStyles(selectedButton: UIButton) {
        if selectedButton == demoButton {
            demoButton.tintColor = .systemYellow
            realButton.tintColor = .white
            demo_undelineView.backgroundColor = .systemYellow
            real_undelineView.backgroundColor = .lightGray
            self.lbl_accountDescription.text = "Risk-free account. Trade with Virtual money."
            self.btn_createAccount.setTitle("Create Demo Account", for: .normal)
            AccountReal = false
        }else{
            realButton.tintColor = .systemYellow
            demoButton.tintColor = .white
            real_undelineView.backgroundColor = .systemYellow
            demo_undelineView.backgroundColor = .lightGray
            self.lbl_accountDescription.text = "Trade with real money and withdraw any profit you make."
            self.btn_createAccount.setTitle("Create Real Account", for: .normal)
            AccountReal = true
        }
        
    }
    
    @IBAction func createAccount(_ sender: Any) {
        let vc = Utilities.shared.getViewController(identifier: .createAccountSelectTradeType, storyboardType: .bottomSheetPopups) as! CreateAccountSelectTradeType
        vc.preferredSheetSizing = .large
      
        if AccountReal {
            vc.isRealAccount = true
        }else{
            vc.isRealAccount = false
        }
        
        //            PresentModalController.instance.presentBottomSheet(self, VC: vc)
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
    }
}

extension SelectAccountTypeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(with: SelectAccountTypeCell.self, for: indexPath)
        
        let account = currentData[indexPath.row]
                cell.configureCell(account: account)
                cell.delegate = self
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedAccount = currentData[indexPath.row]
           if let accountNumber = selectedAccount["accountNumber"] as? Int {
               didTapButton(accountNumber: accountNumber)
           }
    }
}
extension SelectAccountTypeVC: SelectAccountCellDelegate {
    func didTapButton(accountNumber: Int) {
        // Navigate to the login screen
       if let mtLoginVC = UIStoryboard(name: "BottomSheetPopups", bundle: nil).instantiateViewController(withIdentifier: "LoginPopupVC") as? LoginPopupVC {
           mtLoginVC.loginId = accountNumber
           mtLoginVC.modalPresentationStyle = .overFullScreen// .overCurrentContext    // You can use .overFullScreen for full-screen dimming
            
            mtLoginVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            mtLoginVC.view.alpha = 0
            // Optional: Set modal transition style (this is for animation)
            mtLoginVC.modalTransitionStyle = .crossDissolve
            mtLoginVC.metaTraderType = .Balance
            
            // Present the popup
            self.present(mtLoginVC, animated: true, completion: nil)
        }
    }
}
extension SelectAccountTypeVC {
    func showPopup() {
        let storyboard = UIStoryboard(name: "BottomSheetPopups", bundle: nil)
        
        // Replace "PopupViewController" with the actual identifier of your popup view controller
        if let popupVC = storyboard.instantiateViewController(withIdentifier: "LoginPopupVC") as? LoginPopupVC {
            // Set modal presentation style
            popupVC.modalPresentationStyle = .overFullScreen// .overCurrentContext    // You can use .overFullScreen for full-screen dimming
            
            popupVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            popupVC.view.alpha = 0
            // Optional: Set modal transition style (this is for animation)
            popupVC.modalTransitionStyle = .crossDissolve
            popupVC.metaTraderType = .Balance
            
            // Present the popup
            self.present(popupVC, animated: true, completion: nil)
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
                }else {
                    return false
                }
                
                if isRealAccount == true {
                    self.realAccount = " Real "
                }
                self.accountType = " \(accountType) "
                self.mt5 = " MT5 "
                
                
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
