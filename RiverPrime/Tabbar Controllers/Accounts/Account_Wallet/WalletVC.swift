//
//  WalletVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 18/08/2025.
//

import UIKit

class WalletVC: BaseViewController {
    
    
    @IBOutlet weak var view_name_balance: CardView!
    @IBOutlet weak var lbl_walletName: UILabel!
    @IBOutlet weak var lbl_balance: UILabel!
    
    @IBOutlet weak var lbl_transcationCount: UILabel!
    @IBOutlet weak var btn_deposit: CardViewButton!
    @IBOutlet weak var btn_withdraw: CardViewButton!
    @IBOutlet weak var btn_transfer: CardViewButton!
    
    @IBOutlet weak var tv_transcation: UITableView!
    
    @IBOutlet weak var view_noTranscations: UIStackView!
    
    var odooClient = OdooClientNew()
    let getbalanceApi = TradeTypeCellVM()

    var userEmail = String()
    var wallet_type = String()
    var getUserBalance = Double()
    var profileStep = Int()
    
    var records: [TransactionRecord] = [] // transcation data source
    var combinedRecords: [CombinedTransactionRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view_noTranscations.isHidden = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWalletTransferNotification(_:)),
            name: Notification.Name("WalletToMTTransferCompleted"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: AccountsViewController(), navController: self.navigationController, title: "My Wallet", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
        
        
        setupTableView()
        userAccountData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.getbalanceApi.getUserBalance(completion: { response in
            print("response of get balance: \(response)")
            switch response{
        case .success(let responseModel):
    
            UserManager.shared.currentUser = responseModel.result.user
            
            GlobalVariable.instance.balanceUpdate = "\(responseModel.result.user.balance)"
                
            print("\n GlobalVariable.instance.balanceUpdate in walletVC = \(GlobalVariable.instance.balanceUpdate)")
            NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
         
            case .failure(let error):
                print("Failed to fetch balance: \(error.localizedDescription)")
            }
        })
    }
    @objc private func handleWalletTransferNotification(_ notification: Notification) {
        
        // Update UI or refresh data here
        userAccountData()
    }
    func setupTableView() {
  
        tv_transcation.registerCells([ WalletVC_TVCell.self ])
        tv_transcation.layer.cornerRadius = 10
        tv_transcation.layer.borderWidth = 1
        tv_transcation.layer.borderColor = UIColor.lightGray.cgColor
        tv_transcation.layer.masksToBounds = true
        tv_transcation.delegate = self
        tv_transcation.dataSource = self
    }
    
    func userAccountData() {
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            print("\n Default user Account in wallet VC: \(defaultAccount)")
            let type = defaultAccount.isReal == true ? "real" : "demo"
            self.wallet_type = type
        }
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            print("\n get user data in wallet VC: \(savedUserData)")
            if let _email = savedUserData["email"] as? String, let _profileStep = savedUserData["profileStep"] as? Int {
                self.userEmail = _email
                self.profileStep = _profileStep
            }
        }
        
        btn_withdraw.isHidden = (self.wallet_type == "demo")
        loadCombinedTransactionData()
    }
  
    @IBAction func deposit_btn_Action(_ sender: Any) {
        
        if wallet_type == "demo" {
            if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DemoDepositVC") as? DemoDepositVC {
                self.navigate(to: vc)
            }
        }else{
            if profileStep == 2 {
                let vc = Utilities.shared.getViewController(identifier: .demoWithdrawalVC, storyboardType: .dashboard) as! DemoWithdrawalVC
                vc.walletBalance = self.lbl_balance.text ?? ""
                //            vc.walletBalance_Name = self.lbl_walletName.text ?? ""
                vc.request_type = "Deposit"
                vc.wallet_Name = self.lbl_walletName.text ?? ""
                self.navigate(to: vc)
            }else{
                self.ToastMessage("Please do KYC first, then try to deposit.")
            }
        }
    }
    
    @IBAction func withdraw_btn_Action(_ sender: Any) {
        
        if self.getUserBalance == 0.0 {
            self.ToastMessage("Insufficient balance to withdraw. Please deposit first.")
        }else{
            let vc = Utilities.shared.getViewController(identifier: .withdrawViewController, storyboardType: .dashboard) as! WithdrawViewController
            vc.walletBalance = self.lbl_balance.text ?? ""
            vc.walletBalance_Name = self.lbl_walletName.text ?? ""
            vc.request_type = "Withdrawal"
            self.navigate(to: vc)
        }
    }
    
    @IBAction func transfer_btn_Action(_ sender: Any) {
        let vc = Utilities.shared.getViewController(identifier: .transferViewController, storyboardType: .dashboard) as! TransferViewController
        //        vc.newAccoutDelegate = self
        //        vc.dismissDelegate = self
        //        vc.accountDismisalProtocol = self
        vc.userEmail = self.userEmail
        vc.walletBalance_Name = self.lbl_walletName.text ?? ""
        vc.walletBalance = self.lbl_balance.text ?? ""
        
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        
    }
}

extension WalletVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return combinedRecords.count
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(with: WalletVC_TVCell.self, for: indexPath)
          cell.backgroundColor = .clear
          cell.selectionStyle = .none
          
          let combinedRecord = combinedRecords[indexPath.row]
          cell.configure(with: combinedRecord)
          
          return cell
      }
      
      func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return 90
      }
}
    
extension WalletVC {
    
    func combineTransactionData(transactions: [Transaction], records: [TransactionRecord]) -> [CombinedTransactionRecord] {
        var combinedRecords: [CombinedTransactionRecord] = []
        
        // Create lookup dictionary from transactions (first API)
        var transactionDict: [String: Transaction] = [:]
        for transaction in transactions {
            let key = "\(transaction.transactionType)_\(transaction.amount)_\(transaction.createdDate.prefix(10))"
// let key = "\(transaction.amount)_\(transaction.createdDate.prefix(10))" // amount_date as key
            transactionDict[key] = transaction
        }
        
        // Track which transactions have been matched
        var matchedTransactionKeys: Set<String> = []
        
        // Combine with records (second API)
        for record in records {
            var combined = CombinedTransactionRecord()
            
            // Fill from TransactionRecord (Second API)
            combined.recordId = record.id
            combined.displayName = record.displayName
            combined.recordType = record.type
            combined.state = record.state
            combined.recordAmount = record.amount
            combined.balanceBefore = record.balanceBefore
            combined.balanceAfter = record.balanceAfter
            combined.createDate = record.createDate
            combined.processedDate = record.processedDate
            combined.reference = record.reference
            combined.description = record.description
            combined.currencySymbol = record.currencySymbol
            
            // Try to match with Transaction (First API)
            if !record.createDate.isEmpty {  // ✅ allow both deposits (+) and withdrawals (-)
                let key = "\(record.type)_\(record.amount)_\(record.createDate.prefix(10))"
// let key = "\(record.amount)_\(record.createDate.prefix(10))"
                
                if let transaction = transactionDict[key] {
                    // Fill from Transaction (First API)
                    combined.transactionId = transaction.id
                    combined.requestNumber = transaction.requestNumber
                    combined.transactionType = transaction.transactionType
                    combined.transactionAmount = transaction.amount
                    combined.currency = transaction.currency
                    combined.status = transaction.status
                    combined.statusDisplay = transaction.statusDisplay
                    combined.priority = transaction.priority
                    combined.walletType = transaction.walletType
                    combined.createdDate = transaction.createdDate
                    combined.submissionDate = transaction.submissionDate
                    combined.completionDate = transaction.completionDate
                    combined.expectedCompletionDate = transaction.expectedCompletionDate
                    combined.daysPending = transaction.daysPending
                    combined.processingDays = transaction.processingDays
                    combined.isOverdue = transaction.isOverdue
                    
                    // Mark this transaction as matched
                    matchedTransactionKeys.insert(key)
                }
            }
            
            combinedRecords.append(combined)
        }
        
        // Add unmatched transactions from first API (like withdrawals not in second API)
        for transaction in transactions {
//            let key = "\(transaction.amount)_\(transaction.createdDate.prefix(10))"
            let key = "\(transaction.transactionType)_\(transaction.amount)_\(transaction.createdDate.prefix(10))"

            // If this transaction wasn't matched with any record, add it
            if !matchedTransactionKeys.contains(key) {
                var combined = CombinedTransactionRecord()
                
                // Fill from Transaction (First API only)
                combined.transactionId = transaction.id
                combined.requestNumber = transaction.requestNumber
                combined.transactionType = transaction.transactionType
                combined.transactionAmount = transaction.amount
                combined.currency = transaction.currency
                combined.status = transaction.status
                combined.statusDisplay = transaction.statusDisplay
                combined.priority = transaction.priority
                combined.walletType = transaction.walletType
                combined.createdDate = transaction.createdDate
                combined.submissionDate = transaction.submissionDate
                combined.completionDate = transaction.completionDate
                combined.expectedCompletionDate = transaction.expectedCompletionDate
                combined.daysPending = transaction.daysPending
                combined.processingDays = transaction.processingDays
                combined.isOverdue = transaction.isOverdue
                
                // ✅ Always set display name fallback if missing
                if combined.displayName == nil || combined.displayName?.isEmpty == true {
                    let typeCapitalized = transaction.transactionType.capitalized
                    let statusText = transaction.statusDisplay ?? transaction.status
                    let currencyText = transaction.currency ?? "$"
                    combined.displayName = "\(typeCapitalized) - \(transaction.amount) \(currencyText) (\(statusText))"
                }
                
                combinedRecords.append(combined)
                print("➕ Added unmatched transaction: ID=\(transaction.id ?? 0), Type=\(transaction.transactionType), Amount=\(transaction.amount)")
            }
        }
        
        return combinedRecords
    }


    
    func loadCombinedTransactionData() {
        odooClient.check_userWallet(email: self.userEmail, wallet_type: self.wallet_type) { wallet in
            guard let walletId = wallet["id"] as? Int else {
                print("❌ Wallet not found or invalid")
                return
            }
            
            DispatchQueue.main.async {
                let displayName = wallet["display_name"] as? String ?? "N/A"
                let cleanName = displayName.components(separatedBy: " (").first ?? displayName
                self.lbl_walletName.text = cleanName
                
                if let balanceValue = wallet["balance"] {
                    self.getUserBalance = balanceValue as! Double
                    self.lbl_balance.text = "$" + String.formatStringNumber("\(balanceValue)")
                } else {
                    self.lbl_balance.text = "$0.00"
                    self.getUserBalance = 0.0
                }
            }
            
            // First API: user transactions
            self.odooClient.get_User_transcations(email: self.userEmail, wallet_type: self.wallet_type) { transactionsResponse in
//                print("\n---------->>>*****----->>>>> get user transcation data in walletVC:\(transactionsResponse)\n\n")
                
                // Second API: search read
                self.odooClient.get_transcations_search_read(email: self.userEmail, walletId: walletId) { recordsResponse in
//                    print("\n -------->>>>get search_read transcation data in walletVC:----->>>\(recordsResponse)---**********---------->>>>\n")
                    
                    // Debug: Check the response structure
                    if let responseDict = recordsResponse as? [String: Any],
                       let result = responseDict["result"] as? [String: Any],
                       let records = result["records"] as? [[String: Any]] {
                        print("🔍 Records array count: \(records.count)")
                        print("🔍 Records content: \(records)")
                        
                        if let totalCount = result["total_count"] as? Int {
                            print("🔍 Total count from API: \(totalCount)")
                        }
                    }
                    
                    // Decode both responses
                    var transactions: [Transaction] = []
                    var records: [TransactionRecord] = []
                    
                    // Decode first API response
                    if let transactionResponse = TransactionResponse.decode(from: transactionsResponse) {
                        transactions = transactionResponse.result.transactions
                        print("✅ Decoded \(transactions.count) transactions from first API")
                        
                        // Debug: Print first few transactions
                        for (index, transaction) in transactions.prefix(3).enumerated() {
                            print("📋 Transaction \(index): ID=\(transaction.id ?? 0), Amount=\(transaction.amount), Type=\(transaction.transactionType)")
                        }
                    } else {
                        print("❌ Failed to decode first API response")
                    }
                    
                    // Decode second API response
                    if let recordsResponse = RecordsResponse.decode(from: recordsResponse) {
                        records = recordsResponse.result.records
                        print("✅ Decoded \(records.count) records from second API")
                        
                        // Debug: Print first few records
                        for (index, record) in records.prefix(3).enumerated() {
                            print("📋 Record \(index): ID=\(record.id ?? 0), Amount=\(record.amount), Type=\(record.type)")
                        }
                    } else {
                        print("❌ Failed to decode second API response")
                    }
                    
                    // Combine the data
                    if transactions.isEmpty && records.isEmpty {
                        print("⚠️ Both APIs returned empty data")
                        self.combinedRecords = []
                    } else if records.isEmpty {
                        print("⚠️ Second API returned no records, creating combined records from first API only")
                        // Create combined records from first API only
                        self.combinedRecords = transactions.map { transaction in
                            var combined = CombinedTransactionRecord()
                            combined.transactionId = transaction.id
                            combined.requestNumber = transaction.requestNumber
                            combined.transactionType = transaction.transactionType
                            combined.transactionAmount = transaction.amount
                            combined.currency = transaction.currency
                            combined.status = transaction.status
                            combined.statusDisplay = transaction.statusDisplay
                            combined.priority = transaction.priority
                            combined.walletType = transaction.walletType
                            combined.createdDate = transaction.createdDate
                            combined.submissionDate = transaction.submissionDate
                            combined.completionDate = transaction.completionDate
                            combined.expectedCompletionDate = transaction.expectedCompletionDate
                            combined.daysPending = transaction.daysPending
                            combined.processingDays = transaction.processingDays
                            combined.isOverdue = transaction.isOverdue
                            return combined
                        }
                    } else {
                        print("✅ Combining data from both APIs")
                        self.combinedRecords = self.combineTransactionData(transactions: transactions, records: records)
                    }
                    
                    print("🎯 Final combined records count: \(self.combinedRecords.count)")
                    for (index, record) in self.combinedRecords.enumerated() {
                        print("📦 Combined \(index): transactionId=\(record.transactionId ?? -1), type=\(record.transactionType ?? record.recordType ?? "N/A"), amount=\(record.transactionAmount ?? record.recordAmount), displayName=\(record.displayName ?? "nil")")
                    }
                    // Update UI on main thread
                    DispatchQueue.main.async {
                        self.lbl_transcationCount.text = "\(self.combinedRecords.count) Transactions"
                        
                        let hasTransactions = !self.combinedRecords.isEmpty
                        self.view_noTranscations.isHidden = hasTransactions
                        self.tv_transcation.isHidden = !hasTransactions
                        
                        if hasTransactions {
                            print("🔄 Reloading table view with \(self.combinedRecords.count) records")
                        } else {
                            print("📭 No transactions to display")
                        }
                        
                        self.tv_transcation.reloadData()
                    }
                }
            }
        }
    }
}
