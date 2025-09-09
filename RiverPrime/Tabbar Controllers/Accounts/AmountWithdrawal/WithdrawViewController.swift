//
//  WithdrawViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit

class WithdrawViewController: BaseViewController {
    
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_balance: UILabel!
    @IBOutlet weak var lbl_accountInfo: UILabel!
    @IBOutlet weak var view_requiredField: UIView!
    
    @IBOutlet weak var lbl_first: UILabel!
    @IBOutlet weak var btn_paymentMethod: CardViewButton!
    @IBOutlet weak var btn_addNewMethod: UIButton!
    
    //MARK: - Required_field labels and views
    @IBOutlet weak var view_requirementFields: UIView!
    @IBOutlet weak var view_requirement_height: NSLayoutConstraint!
    @IBOutlet weak var btn_paymentType_subSelection: CardViewButton!
    @IBOutlet weak var btn_subSelectionHeight: NSLayoutConstraint!
    @IBOutlet weak var img_subSelection_downArrow: UIImageView!
    
    @IBOutlet weak var tf_typeFirstRequirment: UITextField!
    @IBOutlet weak var view_firstLine: UIView!
    @IBOutlet weak var lbl_typeFirstRequirment: UILabel!
    
    @IBOutlet weak var tf_typeSecondRequirment: UITextField!
    @IBOutlet weak var view_secondLine: UIView!
    @IBOutlet weak var lbl_typeSecondRequirment: UILabel!
    
    @IBOutlet weak var thridRequirment: UIStackView!
    @IBOutlet weak var tf_typethridRequirment: UITextField!
    @IBOutlet weak var view_thridLine: UIView!
    @IBOutlet weak var lbl_typethridRequirment: UILabel!
    
    //MARK: - Security labels
    @IBOutlet weak var securityStack: UIStackView!
    @IBOutlet weak var lbl_limits: UILabel!
    @IBOutlet weak var lbl_processingTime: UILabel!
    @IBOutlet weak var lbl_riskLevel: UILabel!
    @IBOutlet weak var lbl_verificationRequired: UILabel!
    
    var userEmail: String?
    let oddoService = OdooClientNew()
    var methodList : [String] = []
    var subSelectionOptions: [Option] = []
    var userPaymentMethods: [PaymentMethod] = []
    var allPaymentMethods: [PaymentType] = []
    private var shouldShowAllMethods = false
    
    var selectedPaymentType: PaymentType?
    var selectedDropdownOptionValue: String?
    var request_type = String()
    var walletBalance = String()
    var walletBalance_Name = String()
    
    var fieldData: [String: String] = [:]
    
    var selectedPaymentMethodId = Int()
    var selectedPaymentTypeName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationAmount(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
      
        self.lbl_balance.text = "\(walletBalance_Name)"
       
        if request_type == "Withdrawal" {
            self.lbl_title.text = "Withdrawal from your wallet"
        }else{
            self.lbl_title.text = "Deposit to your wallet"
        }
        loadUserPaymentMethods()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view_requirementFields.isHidden = true
        self.view_requirement_height.constant = 0
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: WalletVC(), navController: self.navigationController, title: "Select Payment Method", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
        
        tf_typeFirstRequirment.addDoneButton(target: self, selector: #selector(dismissKeyboard))
        tf_typeSecondRequirment.addDoneButton(target: self, selector: #selector(dismissKeyboard))
        tf_typethridRequirment.addDoneButton(target: self, selector: #selector(dismissKeyboard))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if view.frame.origin.y == 0 {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardHeight = keyboardFrame.cgRectValue.height
                view.frame.origin.y -= keyboardHeight / 2  // Adjust this value if needed
            } }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    
    func loadUserPaymentMethods() {
        oddoService.checkUser_withdrawMethod(email: userEmail ?? "") { [weak self] result in
            switch result {
            case .success(let methods):
                if methods.isEmpty {
                    self?.btn_addNewMethod.isEnabled = false
                    self?.lbl_first.text = "Select New \(self?.request_type ?? "") Method"
                    
                    self?.loadAllPaymentTypes()
                } else {
                    self?.btn_addNewMethod.isEnabled = true
                    self?.lbl_first.text = "Select \(self?.request_type ?? "") Method"
                    
                    self?.userPaymentMethods = methods
                    self?.methodList = self?.userPaymentMethods.map { $0.displayName } ?? []
                    // Set default title for the button (optional)
                    if let first = self?.methodList.first {
                        self?.btn_paymentMethod.setTitle(first, for: .normal)
                        self?.selectedPaymentMethodId = self?.userPaymentMethods.first?.id ?? 0
                        self?.selectedPaymentTypeName =  self?.userPaymentMethods.first?.name ?? ""
                        print("\n byDefault, selected payment Method Id: \(self?.selectedPaymentMethodId ?? 0)")
                    }
                    self?.view_requirementFields.isHidden = true
                    self?.view_requirement_height.constant = 0
                }
                
            case .failure(let error):
                print("Failed to fetch user payment types: \(error)")
                self?.loadAllPaymentTypes()
            }
        }
    }
    
    func loadAllPaymentTypes() {
        oddoService.checkAll_withdrawMethod { [weak self] result in
            switch result {
            case .success(let types):
                self?.allPaymentMethods = types
                self?.methodList = self?.allPaymentMethods.map { $0.name } ?? []
                self?.btn_paymentMethod.setTitle("Select payment method", for: .normal)
                self?.shouldShowAllMethods = true
            case .failure(let error):
                print("Failed to fetch all payment types: \(error)")
            }
        }
    }
    
    @IBAction func selectPaymentType(_ sender: CardViewButton) {
        print("Choose method button click.")
        shouldShowAllMethods = false
        showPaymentDropdown(from: sender)
    }
    
    @IBAction func addMethod(_ sender: UIButton) {
        loadAllPaymentTypes()
        shouldShowAllMethods = true
        
        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            print("Choose method loadAllPaymentTypes button click.")
            self.showPaymentDropdown(from: self.btn_paymentMethod)
        }
    }
    
    @IBAction func btn_paymentType_subSelectionAction(_ sender: UIButton) {
        guard !subSelectionOptions.isEmpty else { return }
        
        let labels = subSelectionOptions.map { $0.label }

           self.dynamicDropDownButton(sender, list: labels) { [weak self] index, selectedItem in
               guard let self = self else { return }

               self.btn_paymentType_subSelection.setTitle(selectedItem, for: .normal)
               self.selectedDropdownOptionValue = self.subSelectionOptions.first(where: { $0.label == selectedItem })?.value
           }
    }
    
    func showPaymentDropdown(from button: UIButton) {
        
        if userPaymentMethods.isEmpty {
            shouldShowAllMethods = true
        }
        // Decide which list to show
        methodList = shouldShowAllMethods
            ? allPaymentMethods.map { $0.name }
            : userPaymentMethods.map { method in
                let detail = method.details // non-optional String
                
                if let providerLine = detail
                    .components(separatedBy: .newlines)
                    .first(where: { $0.contains("Provider:") }) {
                    
                    let providerName = providerLine
                        .replacingOccurrences(of: "Provider:", with: "")
                        .trimmingCharacters(in: .whitespaces)
                    
                    if !providerName.isEmpty {
                        return providerName
                    }
                }
                
                return method.displayName // fallback
            }
        
        self.dynamicDropDownButton(button, list: methodList) { [weak self] index, item in
            guard let self = self else { return }
            
            print("drop down index = \(index)")
            print("drop down item = \(item)")
     
            button.setTitle(item, for: .normal)
            // ✅ Show requirement view only when "all methods type" are being shown
            if shouldShowAllMethods {
                
                self.view_requirementFields.isHidden = false
                self.view_requirement_height.constant = 340
                
                let selectedMethod = self.allPaymentMethods[index]
                selectedPaymentMethodId = selectedMethod.id
                
            } else {
                self.view_requirementFields.isHidden = true
                self.view_requirement_height.constant = 0
                
                let selectedMethod = self.userPaymentMethods[index]
                selectedPaymentMethodId = selectedMethod.id
                selectedPaymentTypeName = item
            }
            print("selected payment type name and its id for: \(selectedPaymentTypeName) = \(selectedPaymentMethodId)")
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            // 🔁 Handle required fields & security labels
            if let selectedType = self.allPaymentMethods.first(where: { $0.name == item }) {
                self.selectedPaymentType = selectedType // ✅ Track selected
                self.configureRequiredFields(for: selectedType)
                self.configureSecurityLabels(for: selectedType)
            }
        }
    }
    
    func configureRequiredFields(for method: PaymentType) {
        let requiredFields = method.requiredFields
        
        // Reset all fields and hide by default
        tf_typeFirstRequirment.text = ""
        tf_typeFirstRequirment.placeholder = ""
        tf_typeFirstRequirment.isHidden = true
        lbl_typeFirstRequirment.text = ""
        view_firstLine.isHidden = true
        lbl_typeFirstRequirment.isHidden = true
        
        tf_typeSecondRequirment.text = ""
        tf_typeSecondRequirment.placeholder = ""
        tf_typeSecondRequirment.isHidden = true
        lbl_typeSecondRequirment.text = ""
        lbl_typeSecondRequirment.isHidden = true
        view_secondLine.isHidden = true
        
        tf_typethridRequirment.text = ""
        tf_typethridRequirment.placeholder = ""
        tf_typethridRequirment.isHidden = true
        lbl_typethridRequirment.text = ""
        lbl_typethridRequirment.isHidden = true
        view_thridLine.isHidden = true
        
        btn_paymentType_subSelection.setTitle("", for: .normal)
        btn_paymentType_subSelection.isHidden = true
        btn_subSelectionHeight.constant = 0
        img_subSelection_downArrow.isHidden = true
        thridRequirment.isHidden = true
                
        for (index, field) in requiredFields.prefix(3).enumerated() {
            switch index {
            case 0:
                if field.type == "selection" {
                    let options = field.options ?? []
                    subSelectionOptions = options // ⬅️ Store for button action use
                    let optionLabels = options.map { $0.label }
                    btn_paymentType_subSelection.setTitle("Select", for: .normal)
                    
                    btn_paymentType_subSelection.isHidden = false
                    btn_subSelectionHeight.constant = 35
                    img_subSelection_downArrow.isHidden = false
                    tf_typeFirstRequirment.isHidden = true
                    view_firstLine.isHidden = true
                    lbl_typeFirstRequirment.isHidden = false
            
                }
                else {
                    lbl_typeFirstRequirment.text = field.help
                    lbl_typeFirstRequirment.isHidden = false
                    
//                    tf_typeFirstRequirment.placeholder = field.string
                    tf_typeFirstRequirment.attributedPlaceholder = NSAttributedString(string: field.string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                    view_firstLine.isHidden = false
                    tf_typeFirstRequirment.isHidden = false
                }
            case 1:
                lbl_typeSecondRequirment.text = field.help
                lbl_typeSecondRequirment.isHidden = false
                view_secondLine.isHidden = false
//                tf_typeSecondRequirment.placeholder = field.string
                tf_typeSecondRequirment.attributedPlaceholder = NSAttributedString(string: field.string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                tf_typeSecondRequirment.isHidden = false
            case 2:
                lbl_typethridRequirment.text = field.help
                lbl_typethridRequirment.isHidden = false
//                tf_typethridRequirment.placeholder = field.string
                tf_typethridRequirment.attributedPlaceholder = NSAttributedString(string: field.string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                tf_typethridRequirment.isHidden = false
                thridRequirment.isHidden = false
                view_thridLine.isHidden = false
            default:
                break
            }
        }
    }
    
    func configureSecurityLabels(for method: PaymentType) {
        lbl_limits.text = "Limits: $\(method.defaults.minAmount) - $\(method.defaults.maxAmount )"
        lbl_processingTime.text = "ProcessingTime: \(method.defaults.processingTime)"
//        lbl_riskLevel.text = "Risk Level: \(method.security?.riskLevel.capitalized ?? "")"
//        lbl_verificationRequired.text = "Verification Required: \(method.security?.verificationRequired.joined(separator: ", ") ?? "")"
//        
        securityStack.isHidden = false
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        
        if shouldShowAllMethods{
           
            guard let method = selectedPaymentType else {
                self.ToastMessage("Select any Payment Method")
                return
            }

                var fieldData: [String: String] = [:]
                
                for (index, field) in method.requiredFields.prefix(3).enumerated() {
                    switch index {
                    case 0:
                        if field.type == "selection" {
                            let selectedValue = selectedDropdownOptionValue ?? ""
                            if !selectedValue.isEmpty {
                                fieldData[field.name] = selectedValue
                            }else{
                                self.ToastMessage("Select any Payment Method")
                                return
                            }
                             
                        } else {
                            let value = tf_typeFirstRequirment.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                            if !value.isEmpty {
                                fieldData[field.name] = value
                                lbl_typeFirstRequirment.textColor = .lightGray
                            }else{
                                lbl_typeFirstRequirment.textColor = .systemRed
                                return
                            }
                        }
                    case 1:
                        let value = tf_typeSecondRequirment.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        if !value.isEmpty {
                            fieldData[field.name] = value
                            lbl_typeSecondRequirment.textColor = .lightGray
                        }else{
                            lbl_typeSecondRequirment.textColor = .systemRed
                            return
                        }
                    case 2:
                        let value = tf_typethridRequirment.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        if !value.isEmpty {
                            fieldData[field.name] = value
                            lbl_typethridRequirment.textColor = .lightGray
                        }else{
                            lbl_typethridRequirment.textColor = .systemRed
                            return
                        }
                    default:
                        break
                    }
                }
            
            oddoService.create_New_withdrawPaymentMethod(email: userEmail ?? "", methodCode: method.code, methodName: method.name, fieldData: fieldData) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("✅ Add Payment method created successfully")
                        self.loadUserPaymentMethods()
                    case .failure(let error):
                        print("❌ Failed to create new payment method: \(error)")
                        // Handle error
                        self.ToastMessage("new payment method not created")
                    }
                }
            }
        } else{
            print("move to get amount screen")
            if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DemoWithdrawalVC") as? DemoWithdrawalVC {
                vc.selectedPaymentTypeId = self.selectedPaymentMethodId
                vc.selectedPaymentTypeName = self.selectedPaymentTypeName
                vc.walletBalance = walletBalance
                vc.wallet_Name = walletBalance_Name
                vc.request_type = request_type
                self.navigate(to: vc)
            }
        }
        
    }
}

extension WithdrawViewController {
    func getUserInfo(){
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            let accountGroup = defaultAccount.groupName
            let accountType = defaultAccount.isReal == true ? "Real" : "Demo"
            let AccountNumber = defaultAccount.accountNumber
            self.lbl_accountInfo.text = "\(accountType) - \(accountGroup) #\(AccountNumber)"
        }
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let email = savedUserData["email"] as? String {
                self.userEmail = email
            }
        }
    }
    
}
