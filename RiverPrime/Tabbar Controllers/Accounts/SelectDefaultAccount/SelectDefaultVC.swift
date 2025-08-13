//
//  SelectDefaultVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 07/08/2025.
//

import UIKit

class SelectDefaultVC: BaseViewController {

    @IBOutlet weak var lbl_accountCount: UILabel!
    
    @IBOutlet weak var accounts_tableView: UITableView!
    
    var currentData: [[String: Any]] = []
    var AccountReal = Bool()
    var accountsPassword: [String: [String: String]] = [:]
    var userID = String()
   
    var loginId = Int()
    
    weak var accountDismisalProtocol: AccountDismisalProtocol?
    
    var metaTraderType: MetaTraderType? = .None
    let webSocketManager = WebSocketManager.shared
    
    let passwordManager = PasswordManager()
    var firestoreObject = FirestoreServices()
    let getbalanceApi = TradeTypeCellVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firestoreObject.fetchUserAccountsData(userId: userID) {
            self.registerCell()
        }
       
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: SignInViewController(), navController: self.navigationController, title: "Select Default Account", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    
    private func registerCell() {
        let allPasswords = passwordManager.getAllPasswords()
        print("All Saved Passwords on selectDefaultVC: \(allPasswords)")
        
        guard let savedList = UserDefaults.standard.dictionary(forKey: "userAccountsData") as? [String: [String: Any]] else {
            return
        }
        print("\nsavedList of accounts in SelectDefaultVC: \(savedList)\n")
        lbl_accountCount.text = "\(savedList.count) accounts available"
       
        currentData.removeAll()
        
        for (_, account) in savedList {
            currentData.append(account)
        }
      
        accounts_tableView.registerCells([
            SelectAccountTvCell.self
        ])
        accounts_tableView.layer.masksToBounds = true
        accounts_tableView.layer.borderWidth = 1
        accounts_tableView.layer.borderColor = UIColor.lightGray.cgColor
        accounts_tableView.layer.cornerRadius = 15
        accounts_tableView.delegate = self
        accounts_tableView.dataSource = self
        accounts_tableView.reloadData()
    }
    
    
    @IBAction func `continue`(_ sender: Any) {
       
        UserDefaults.standard.set(self.userID, forKey: "userID")
        updateSocket(isReal: AccountReal)
        firestoreObject.fetchUserAccountsData(userId: userID) {
          
            if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
                print("\n Default user Account get in signing process `continue` btn: \(defaultAccount)")
                
                self.navigateToFaceID()
            }else{
                self.ToastMessage("Select Any Account First.")
            }
        }
//        if UserAccountManager.shared.getDefaultAccount() == nil {
//           
//        }else{
//               self.navigateToFaceID()
//        }
    }
    
    func navigateToFaceID() {
       
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let verifyVC = storyboard.instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! PasscodeFaceIDVC
       self.navigate(to: verifyVC)
   }
}

extension SelectDefaultVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(with: SelectAccountTvCell.self, for: indexPath)
        cell.isUserInteractionEnabled = true
        cell.selectionStyle = .none
        
        let account = currentData[indexPath.row]
            cell.configureCell(account: account)
//                cell.delegate = self
        
      
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedAccount = currentData[indexPath.row]
        for i in 0...currentData.count - 1 {
            
            let indexPath = IndexPath(row: i, section: 0)

            if let cell = tableView.cellForRow(at: indexPath) as? SelectAccountTvCell {
//                cell.isUserInteractionEnabled = false
                cell.btn_checkAccount.tintColor = .lightGray
                cell.btn_checkAccount.setImage(UIImage(systemName: "circle"), for: .normal)
            }
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? SelectAccountTvCell {
//            cell.isUserInteractionEnabled = false
            cell.btn_checkAccount.tintColor = .systemYellow
            cell.btn_checkAccount.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }
        
        if let accountReal = selectedAccount["isReal"] as? Int {
            if accountReal == 0 {
                self.AccountReal = false
            }else{
                self.AccountReal = true
            }
        }
        
        if let accountUserID = selectedAccount["userID"] as? String {
            self.userID = accountUserID
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            if let accountNumber = selectedAccount["accountNumber"] as? Int {
                self?.didTapButton(accountNumber: accountNumber)
            }
        }
        
    }
}

extension SelectDefaultVC: SelectAccountCellDelegate {
    func didTapButton(accountNumber: Int) {
        // Convert accountNumber to a String (since dictionary keys are strings)
        let accountNumberKey = String(accountNumber)
        
        // Get the stored passwords dictionary
        let allPasswords = passwordManager.getAllPasswords()
        
        // Check if the accountNumber exists in the dictionary
        if let password = allPasswords[accountNumberKey] {
            print("Account found with password: \(password)")
            if password != "" {
                getbalanceApi.loginForPassword(loginID: accountNumber, pass: password, isDemo: !self.AccountReal , completion: { response in
                    print("the login to meta Trader account response is: \(response)") // handle failure case
                    if response == "Login Failed" {
                        self.ToastMessage(response)
                        //self.lbl_wrongPassword.isHidden = false
                    }else{
                        self.firestoreObject.updateDefaultAccount(for: "\(accountNumber)", userId: self.userID){ [weak self] error in
                            guard let self = self else { return }
                            
                            if let error = error {
                                print("Error updating default account: \(error.localizedDescription)")
                                return
                            }
                            print("\n updating isDefault account success: ")
                            
                            self.metaTraderType = .Balance
                            
                            // MARK: - NEW LOGIC: Separate data based on server_id
                            GlobalVariable.instance.separateSymbolsByServerId(Session.instance.bothSymbols ?? [])
                            
//                            updateSocket(isReal: AccountReal) // Update the socket according to MT Account Type
                            
                            NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.MetaTraderLoginConstant.key, dict: [NotificationObserver.Constants.MetaTraderLoginConstant.title: self.metaTraderType ?? MetaTraderType.None])
                            
                            //                    self.dismiss(animated: true, completion: nil)
                            //                    self.accountDismisalProtocol?.accountDismisal()
                            
                        }
                        
                        self.ToastMessage(response)
                    }
                })
            }else {
                print("Account Password not found. Navigating to login popup screen.")
                self.loginId = accountNumber
                showPopup()
            }
            
        } else {
            print("Account Password not found. Navigating to login popup screen.")
            self.loginId = accountNumber
            showPopup()
        }
    }
    
    private func updateSocket(isReal: Bool) {
        //MARK: - Disconnect web socket.
        self.webSocketManager.DisconnectWebSocket()
        if isReal {
            //MARK: - //MARK: - Connect live web socket.
            print("Change websocket to Live.")
            self.webSocketManager.connectWebSocket(socketURLType:  .live)
        } else {
            //MARK: - //MARK: - Connect demo web socket.
            print("Change websocket to Demo.")
            self.webSocketManager.connectWebSocket(socketURLType:  .demo)
        }
    }
}

extension SelectDefaultVC {
    func showPopup() {
        let storyboard = UIStoryboard(name: "BottomSheetPopups", bundle: nil)
        if let popupVC = storyboard.instantiateViewController(withIdentifier: "LoginPopupVC") as? LoginPopupVC {
            // Set modal presentation style
            popupVC.loginId = self.loginId
            popupVC.userID = self.userID
           
            popupVC.isDemo = !self.AccountReal
            popupVC.modalPresentationStyle = .overFullScreen
            popupVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            popupVC.view.alpha = 0
            // Optional: Set modal transition style (this is for animation)
            popupVC.modalTransitionStyle = .crossDissolve
            popupVC.metaTraderType = .Balance
            
            // Present the popup
            SCENE_DELEGATE.window?.rootViewController?.present(popupVC, animated: true)
        }
    }
}
