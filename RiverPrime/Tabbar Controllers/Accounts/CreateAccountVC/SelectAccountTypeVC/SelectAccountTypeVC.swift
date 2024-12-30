//
//  SelectAccountTypeVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 03/08/2024.
//

import UIKit
enum createAccountType {
    case selectAccount
    case selectAccountType
    case createAccount
}
    
protocol BottomSheetDismissDelegate: AnyObject {
    func presentNextBottomSheet(screen: createAccountType, AccountReal: Bool, accounts: [AccountModel], index: Int)
}

struct SelectAccountType {
    var title = String()
    var name = String()
    var loginID = String()
    var balance = String()
    var detail = String()
}

class SelectAccountTypeVC: BottomSheetController {
    
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
    var getbalanceApi = TradeTypeCellVM()
    
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
    weak var newAccoutDelegate : CreateAccountUpdateProtocol?
    weak var dismissDelegate: BottomSheetDismissDelegate?
    
    var accountsPassword: [String: String] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.dismissDelegate = self
        
        self.btn_createAccount.titleTintColor = .systemYellow
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateAccountList), name: NSNotification.Name(rawValue: "dismissCreateAccountScreen"), object: nil)
        
    }
    
    @objc func updateAccountList(){
         
            self.getbalanceApi.getBalance(completion: { response in
                print("response of get balance: \(response)")
                if response == "Invalid Response" {
                    
                    return
                }
                
                GlobalVariable.instance.balanceUpdate = response //self.balance
                print("GlobalVariable.instance.balanceUpdate = \(GlobalVariable.instance.balanceUpdate)")
                NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
            })
            
            NotificationCenter.default.post(name: NSNotification.Name("accountCreate"), object: nil) // modify with abrar bhai
            NotificationCenter.default.post(name: NSNotification.Name("metaTraderLogin"), object: nil)
       
        registerCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
        passwordLoadFromUserDefaults()
        registerCell()
    }
    @IBAction func deleteAll(_ sender: Any) {
        firestoreObject.deleteAllUserAccounts(for: "CT9RjofmaSM5cPwHG5QmKk9tCMu1") { error in
            if let error = error {
                print("Failed to delete user accounts: \(error.localizedDescription)")
            } else {
                print("Successfully deleted all user accounts for the specified userID.")
            }
        }
        firestoreObject.fetchUserAccountsData(userId: "CT9RjofmaSM5cPwHG5QmKk9tCMu1")
    }
    
    private func registerCell() {
        if let savedList = UserDefaults.standard.dictionary(forKey: "userAccountsData") as? [String: [String: Any]] {
            print("user AccountsData create Account Screen is:\(savedList)")
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
       
        
        tableView.registerCells([
            SelectAccountTypeCell.self
        ])

        currentData = demoData
        sortCurrentData()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        updateButtonStyles(selectedButton: demoButton)
        if demoData.count == 0 {
            self.nodata_label.isHidden = false
        }else{
            self.nodata_label.isHidden = true
        }
    }
    
    func sortCurrentData() {
     
        currentData = currentData.sorted { first, second in
               // Extract "isDefault" and "accountNumber" values
               let firstValue = first.values.first as? [String: Any]
               let secondValue = second.values.first as? [String: Any]

               let isDefault1 = firstValue?["isDefault"] as? Int ?? 0
               let isDefault2 = secondValue?["isDefault"] as? Int ?? 0
               let accountNumber1 = firstValue?["accountNumber"] as? Int ?? 0
               let accountNumber2 = secondValue?["accountNumber"] as? Int ?? 0

               // Sort by "isDefault" first, then "accountNumber"
               if isDefault1 != isDefault2 {
                   return isDefault1 > isDefault2 // Higher "isDefault" (1) comes first
               }
               return accountNumber1 < accountNumber2 // Otherwise, sort by account number
           }
    }
    
    func passwordLoadFromUserDefaults() {
      
        if let savedPasswordAccounts = UserDefaults.standard.dictionary(forKey: "userPasswordData") as? [String: String] {
        
            accountsPassword = savedPasswordAccounts
            print("Accounts Password fetch from UserDefaults: \(accountsPassword)")
        } else {
            print("No saved accounts Password found")
        }
    }

    // Fetch password for a loginID
    func fetchPassword(for loginID: String) -> String? {
        return accountsPassword[loginID]
    }
    
    @IBAction func demoButtonTapped(_ sender: UIButton) {
        currentData = demoData
        if demoData.count == 0 {
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
        sortCurrentData()
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
            if demoData.count == 0 {
                self.btn_createAccount.setTitle("Create New Demo Account", for: .normal)
                
            }else{
                self.btn_createAccount.setTitle("Create Another Demo Account", for: .normal)
                
            }
            AccountReal = false
        }else{
            realButton.tintColor = .systemYellow
            demoButton.tintColor = .white
            real_undelineView.backgroundColor = .systemYellow
            demo_undelineView.backgroundColor = .lightGray
            self.lbl_accountDescription.text = "Trade with real money and withdraw any profit you make."
          
            if realData.count == 0 {
                self.btn_createAccount.setTitle("Create New Real Account", for: .normal)
            }else{
                self.btn_createAccount.setTitle("Create Another Real Account", for: .normal)
            }
            
            AccountReal = true
        }
        
    }
    
    @IBAction func createAccount(_ sender: Any) {
//        self.dismiss(animated: true)

//        dismissDelegate?.presentNextBottomSheet(screen: .selectAccountType, AccountReal: AccountReal, accounts: [], index: 0)
        
        let vc = Utilities.shared.getViewController(identifier: .createAccountSelectTradeType, storyboardType: .bottomSheetPopups) as! CreateAccountSelectTradeType
         if AccountReal {
                   vc.isRealAccount = true
               }else{
                   vc.isRealAccount = false
               }
//         vc.dismissDelegate = self
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
