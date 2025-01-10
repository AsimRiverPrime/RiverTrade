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
    var metaTraderType: MetaTraderType? = .None

//    var loginID = Int()
//    var createDemoAccount = String()
//    var realAccount = String()
//    var accountType = String()
//    var mt5 = String()
    var firestoreObject = FirestoreServices()
    
    var demoData: [[String: Any]] = []
    var realData: [[String: Any]] = []
    var currentData: [[String: Any]] = []
    
    var  AccountReal = Bool()
    weak var newAccoutDelegate : CreateAccountUpdateProtocol?
    weak var dismissDelegate: BottomSheetDismissDelegate?
    
    var accountsPassword: [String: [String: String]] = [:]
    let passwordManager = PasswordManager()
    
    var userID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.dismissDelegate = self
        self.btn_createAccount.titleTintColor = .systemYellow
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateAccountList), name: NSNotification.Name(rawValue: "updateSelectedAccountList"), object: nil)
        registerCell()
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
       
        self.dismiss(animated: true)
//        registerCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
        
        let allPasswords = passwordManager.getAllPasswords()
        print("All Saved Passwords on create Account: \(allPasswords)")
    }
    @IBAction func deleteAll(_ sender: Any) {
        firestoreObject.deleteAllUserAccounts(for: "wMmWmODl5cUTVYZFR4B6XBy981I2") { error in
            if let error = error {
                print("Failed to delete user accounts: \(error.localizedDescription)")
            } else {
                print("Successfully deleted all user accounts for the specified userID.")
            }
        }
        firestoreObject.fetchUserAccountsData(userId: "wMmWmODl5cUTVYZFR4B6XBy981I2", completion: {
            
        })
    }
    
    private func registerCell() {
        if let savedList = UserDefaults.standard.dictionary(forKey: "userAccountsData") as? [String: [String: Any]] {
            print("user AccountsData create Account Screen is:\(savedList)")
            // Clear the arrays to avoid duplicate data
           
            demoData.removeAll()
            realData.removeAll()
            for (_, account) in savedList {
                self.userID = account["userID"] as! String
                if let isReal = account["isReal"] as? Int {
                    if isReal == 0 {
                        demoData.append(account)
                    } else if isReal == 1 {
                        realData.append(account)
                    }
                }
            }
            
            demoData.sort { ($0["isDefault"] as? Int ?? 0) > ($1["isDefault"] as? Int ?? 0) }
            realData.sort { ($0["isDefault"] as? Int ?? 0) > ($1["isDefault"] as? Int ?? 0) }
               
            print("Demo Data: \(demoData)")
            print("Real Data: \(realData)")
        }
       
        tableView.registerCells([
            SelectAccountTypeCell.self
        ])

        currentData = demoData
//        sortCurrentData()
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
        // Convert accountNumber to a String (since dictionary keys are strings)
        let accountNumberKey = String(accountNumber)
        
        // Get the stored passwords dictionary
      
        let allPasswords = passwordManager.getAllPasswords()
        
        // Check if the accountNumber exists in the dictionary
        if let passwordEntry = allPasswords[accountNumberKey], let password = passwordEntry[accountNumberKey] {
            print("Account found with password: \(password)")
            
            // Call the login API directly
//            loginAPI(accountNumber: accountNumber, password: password)
            getbalanceApi.loginForPassword(loginID: accountNumber, pass: password, completion: { response in
                print("the login to meta Trader account response is: \(response)")
                self.firestoreObject.updateDefaultAccount(for: "\(accountNumber)", userId: self.userID){ [weak self] error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error updating default account: \(error.localizedDescription)")
                        return
                    }
                    print("\n updating isDefault account success: ")
                   
                    self.metaTraderType = .Balance
                    
                    NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.MetaTraderLoginConstant.key, dict: [NotificationObserver.Constants.MetaTraderLoginConstant.title: self.metaTraderType ?? MetaTraderType.None])
                    self.dismiss(animated: true, completion: nil)
                }
                
               
            })
        } else {
            print("Account not found. Navigating to login screen.")
            
            // Navigate to the LoginPopupVC screen
            if let mtLoginVC = UIStoryboard(name: "BottomSheetPopups", bundle: nil)
                .instantiateViewController(withIdentifier: "LoginPopupVC") as? LoginPopupVC {
                mtLoginVC.loginId = accountNumber
                mtLoginVC.modalPresentationStyle = .overFullScreen
                mtLoginVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                mtLoginVC.view.alpha = 0
                mtLoginVC.modalTransitionStyle = .crossDissolve
                mtLoginVC.metaTraderType = .Balance
                self.present(mtLoginVC, animated: true, completion: nil)
            }
        }
    }
}
