//
//  SignInViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//
import Foundation
import UIKit
import TPKeyboardAvoiding
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD

class SignInViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var username_tf: UITextField!{
        didSet{
            username_tf.setIcon(UIImage(imageLiteralResourceName: "emailIcon"))
            username_tf.tintColor = UIColor.lightGray
        }
    }
    
    @IBOutlet weak var lbl_emailCheck: UILabel!
    @IBOutlet weak var btn_submit: UIButton!
    
    @IBOutlet weak var otp_view: CardView!
    @IBOutlet weak var tf_firstNum: UITextField!
    @IBOutlet weak var tf_SecondNum: UITextField!
    @IBOutlet weak var tf_thirdNum: UITextField!
    @IBOutlet weak var tf_fourthNum: UITextField!
    @IBOutlet weak var tf_fivethNum: UITextField!
    @IBOutlet weak var tf_sixthNum: UITextField!
    
    
    @IBOutlet weak var resendCodeButton: UIButton!
    @IBOutlet weak var label_errorCode: UILabel!
    @IBOutlet weak var lbl_remainingTime: UILabel!
   
    var countdownTimer: Timer?
    var remainingSeconds = 59
    
    var firebaseInstance = FirestoreServices()
    var viewModel = SignViewModel()
//    var signUpVC = SignUpViewController()
//    var odooClientService = OdooClient()
    var odoClientNew = OdooClientNew()
    var emailUser: String?
      
    var fireBaseUserData = [String: Any]()
    
//    let keychain = KeychainSwift()
    let db = Firestore.firestore()
    
    var _userID : String?
    var _fullName : String?
    var _password: String?
    
//    let passwordManager = PasswordManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otp_view.isHidden = true
        self.username_tf.addTarget(self, action: #selector(emailTextChanged), for: .editingChanged)
    
        self.label_errorCode.isHidden = true
        
        odoClientNew.otpDelegate = self
        odoClientNew.verifyDelegate = self
        
        let textFields = [tf_firstNum, tf_SecondNum, tf_thirdNum, tf_fourthNum, tf_fivethNum, tf_sixthNum]
        
        for textField in textFields {
            textField?.delegate = self
            textField?.keyboardType = .numberPad
            textField?.textAlignment = .center
            textField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Show Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: SignInViewController(), navController: self.navigationController, title: "", leftTitle: "", rightTitle: "", textColor: .black, barColor: .clear)
     
    }
 
    @objc func emailTextChanged(_ textField: UITextField) {
        if self.viewModel.isValidEmail(self.username_tf.text!) {
            self.lbl_emailCheck.isHidden = true
        } else {
            
            self.lbl_emailCheck.text = "email is not correct"
            self.lbl_emailCheck.isHidden = false
        }

    }

    @IBAction func submitBtn(_ sender: Any) {
        SVProgressHUD.show()
        guard let email = username_tf.text, !email.isEmpty  else {
            lbl_emailCheck.text = "Please enter email."
            lbl_emailCheck.isHidden = false
            SVProgressHUD.dismiss()
            return
        }
        
        odoClientNew.SearchRecord(email: self.username_tf.text ?? "") { userFound, userData, error in
            
            if let error = error {
                print("Error checking user:", error)
                self.ToastMessage("No user found with this email.")
                return
            }

            if userFound {
                print("✅ User exists, sending OTP...")
                self.btn_submit.isHidden = true
                self.otp_view.isHidden = false
                
                self.fireBaseUserData = userData ?? [:]
//                print("\n ---->the crm user data is saved for firebaseUser: \(self.fireBaseUserData)--->\n")
               
                self.odoClientNew.sendOTP(type: "email", email: self.username_tf.text ?? "", phone: "")
            } else {
                print("❌ User does not exist")
                // Show alert or error to user
              
                self.ToastMessage("No user found with this email.")
            }
        }
    }
    
    @IBAction func verify_OTP(_ sender: Any) {
        callApi()
    }
    
    
    @IBAction func createAccountBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
     func navigateToFaceID() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let verifyVC = storyboard.instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! PasscodeFaceIDVC
      
        GlobalVariable.instance.userEmail = self.emailUser ?? ""
        
        self.navigate(to: verifyVC)
    }
    
    func navigateToSelectDefaultAccount() {
        print("\n navigateToSelectDefaultAccount \n")
        let storyboard = UIStoryboard(name: "BottomSheetPopups", bundle: nil)
        let selectDefaultVC = storyboard.instantiateViewController(withIdentifier: "SelectDefaultVC") as! SelectDefaultVC
        selectDefaultVC.userID = _userID ?? ""
        self.navigate(to: selectDefaultVC)
   }
    
}

extension SignInViewController{
    func callApi(){
        if ((getVerificationCode()?.isEmpty) == nil) {
            print("please enter code")
            label_errorCode.isHidden = false
            return
        }else{
            label_errorCode.isHidden = true
            odoClientNew.verifyOTP(type: "email", email: username_tf.text ?? "", phone: "", otp: getVerificationCode() ?? "" )
        }
    }
    
    @IBAction func resendCodeBtn(_ sender: Any) {
        callMethodAfterDelay()
//        resendCodeButton.isEnabled = false
        
        
        //        resendCodeButton.setTitle("Resend in \(remainingSeconds) seconds", for: .disabled)
        
        // Start the countdown timer
        startCountdown()
        
        // Call your method after 60 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 59) {
            self.callMethodAfterDelay()
        }
    }
    
    func startCountdown() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateButtonTitle), userInfo: nil, repeats: true)
    }
    
    // Method to update the button title each second
    @objc func updateButtonTitle() {
        remainingSeconds -= 1
        if remainingSeconds >= 0 {
            //            resendCodeButton.setTitle("Resend code in \(remainingSeconds) seconds", for: .disabled)
            self.lbl_remainingTime.text = "00:\(remainingSeconds)"
//            resendCodeButton.isEnabled = false
            resendCodeButton.isUserInteractionEnabled = false
        } else {
        
            countdownTimer?.invalidate()
            countdownTimer = nil
//            resendCodeButton.isEnabled = true
            resendCodeButton.isUserInteractionEnabled = true
            remainingSeconds = 59 // Reset the countdown time
        }
    }
    
    // Method to be called after the delay
    func callMethodAfterDelay() {
        // Add your method logic here
        print("Method called after 25 Second")
        
        odoClientNew.sendOTP(type: "email", email: username_tf.text ?? "", phone: "")
            
        }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, text.count == 1 else { return }
        
        switch textField {
        case tf_firstNum:
            tf_SecondNum.becomeFirstResponder()
        case tf_SecondNum:
            tf_thirdNum.becomeFirstResponder()
        case tf_thirdNum:
            tf_fourthNum.becomeFirstResponder()
        case tf_fourthNum:
            tf_fivethNum.becomeFirstResponder()
        case tf_fivethNum:
            tf_sixthNum.becomeFirstResponder()
        case tf_sixthNum:
            tf_sixthNum.resignFirstResponder()
            dismissKeyboard()
            // Optionally, get the combined string when the user finishes input
            
            let verificationCode = getVerificationCode()
            print("Verification Code is: \(verificationCode ?? "")")
//            callApi()
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        
        self.tf_firstNum.backgroundColor = .white
        self.tf_SecondNum.backgroundColor = .white
        self.tf_thirdNum.backgroundColor = .white
        self.tf_fourthNum.backgroundColor = .white
        self.tf_fivethNum.backgroundColor = .white
        self.tf_sixthNum.backgroundColor = .white
        
        if string.isEmpty { // Check for backspace
            if text.isEmpty {
                switch textField {
                case tf_firstNum:
                    tf_firstNum.becomeFirstResponder()
                case tf_SecondNum:
                    tf_firstNum.becomeFirstResponder()
                case tf_thirdNum:
                    tf_SecondNum.becomeFirstResponder()
                case tf_fourthNum:
                    tf_thirdNum.becomeFirstResponder()
                case tf_fivethNum:
                    tf_fourthNum.becomeFirstResponder()
                case tf_sixthNum:
                    tf_fivethNum.becomeFirstResponder()
                    
                default:
                    break
                }
            }
            return true
        }
        
        let newLength = text.count + string.count - range.length
        return newLength <= 1
    }
    
    // Method to get the combined string from all text fields
    func getVerificationCode() -> String? {
        
        guard
            let code1 = tf_firstNum.text, !code1.isEmpty,
            let code2 = tf_SecondNum.text, !code2.isEmpty,
            let code3 = tf_thirdNum.text, !code3.isEmpty,
            let code4 = tf_fourthNum.text, !code4.isEmpty,
            let code5 = tf_fivethNum.text, !code5.isEmpty,
            let code6 = tf_sixthNum.text, !code6.isEmpty
        else {
            print("Please fill in all fields.")
            self.ToastMessage("Please fill in all fields.")
            return nil
        }
        
        let code = code1 + code2 + code3 + code4 + code5 + code6
        return code
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
}

extension SignInViewController: SendOTPDelegate {
    func otpSuccess(response: Any) {
        print("this is the email send otp response: \(response)")
           
        self.ToastMessage("Check your email inbox or spam for OTP")
        startCountdown()
    }
    
    func otpFailure(error: Error) {
        print("this is the error  otp response: \(error)")
       
    }
}

extension SignInViewController:  VerifyOTPDelegate {
    func otpVerifySuccess(response: Any) {
        print("\nthis is the verify Email otp response: \(response)\n")
        
     
            self.ToastMessage("OTP Verify.")
            ActivityIndicator.shared.hide(from: self.view)
          
        [self.tf_firstNum, self.tf_SecondNum, self.tf_thirdNum, self.tf_fourthNum, self.tf_fivethNum, self.tf_sixthNum].forEach {
            $0?.backgroundColor = .systemGreen
        }

        guard let email = self.username_tf.text, !email.isEmpty else {
            print("❌ Email is empty, aborting Firebase check")
            return
        }
        
         checkUserExists(email: email)
           
    }
    
    //   navigateToPhoneVerifiyScreen()
    func otpVerifyFailure(error: Error) {
        
        print("this is the error from verify otp response: \(error)")
        self.label_errorCode.isHidden = false
        
        self.ToastMessage("OTP Verification Failed.")
        
        [self.tf_firstNum, self.tf_SecondNum, self.tf_thirdNum, self.tf_fourthNum, self.tf_fivethNum, self.tf_sixthNum].forEach {
            $0?.backgroundColor = .systemRed
        }
    }
 
   
    func checkUserExists(email: String) {
        let tempPassword = UUID().uuidString
        
        Auth.auth().createUser(withEmail: email, password: tempPassword) { result, error in
           
            if let error = error as NSError? {
                if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    print("✅ User exists in Firebase Auth")
                    // User exists in Auth, now check if they exist in Firestore
                    self.checkExistingUserInFirestore(email: email)
                } else {
                    print("⚠️ Error in checkUserExists in auth: \(error.localizedDescription)")
                }
            } else {
                // User was created successfully - they didn't exist before
                print("✅ New user created in Auth")
                
                guard let user = result?.user else { return }
                
                // Add new user to Firestore
                self.addUserToFirestore(email: email, user: user)
            }
        }
    }

    func checkExistingUserInFirestore(email: String) {
    
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
//                .whereField("uid", isEqualTo: userId)
            if let error = error {
                print("⚠️ Firestore query error: \(error)")
                self.ToastMessage("❌ user premission denied")
                return
            }
            
            if let docs = snapshot?.documents, !docs.isEmpty {
                print("✅ User exists in Firestore")
                let userID = docs[0].documentID
               
                self.proceedToFetchUserAccount(userID: userID)
            } else {
                print("❌ User exists in Auth but not in Firestore")
                // Get the current authenticated user and add them to Firestore
                if let currentUser = Auth.auth().currentUser {
                    self.addUserToFirestore(email: email, user: currentUser)
                } else {
                    print("❌ No current user found")
                    self.ToastMessage("❌ No current user found")
                }
            }
        }
    }

    func addUserToFirestore(email: String, user: User) {
        print("⚠️ Add new user to Firestore with fields: \(fireBaseUserData)")
        guard let kycStatus = fireBaseUserData["kyc_status"] as? String else {
            return
        }
        guard let address = fireBaseUserData["contact_address"] as? String else {
            return
        }
//        guard let phone = fireBaseUserData["phone"] as? String else {
//            return
//        }
        guard let residence = fireBaseUserData["country_of_residance"] as? Bool else {
            return
        }
        guard let isKyc = fireBaseUserData["is_kyc"] as? Bool else {
            return
        }
        guard let questionnaire_done = fireBaseUserData["questionnaire_done"] as? Bool else {
            return
        }
        
        var phone: String?

        if let phoneString = fireBaseUserData["phone"] as? String {
            phone = phoneString
        } else if let phoneBool = fireBaseUserData["phone"] as? Bool {
            phone = String(phoneBool) // or "Yes"/"No" if you prefer
        }
        
        var profileStep : Int = 0
        if questionnaire_done == true {
            profileStep = 1
        }else if isKyc == true {
            profileStep = 2
        }else{
            profileStep = 0
        }
       
        print("⚠️ Add fields to new user")
        db.collection("users").document(user.uid).setData([
        
            "KycStatus":kycStatus,
            "address":address,
            "dateOfBirth": "",
            "email": email,
            "emailVerified": true,
            "fullName": user.displayName ?? "",
            "gender": "",
            "uid": user.uid,
            
            "isLogin": true,
            "nationality": residence,
            "phone": phone,
            "phoneVerified": false,
            "profileStep":profileStep,
            "pushedToCRM": true,
            "registrationType" : 0,
            "residence": residence,
            "created_at": Timestamp(date: Date())
            
        ]) { err in
            if let err = err {
                print("❌ Error adding Firestore doc: \(err)")
            } else {
                print("✅ User added to Firestore")
                self.proceedToFetchUserAccount(userID: user.uid)
            }
        }
    }

    func proceedToFetchUserAccount(userID: String) {
        self._userID = userID
        UserDefaults.standard.set(userID, forKey: "userID")
        
        print("🎉 Proceeding to Fetch user Account")
        guard let accountIds = fireBaseUserData["account_ids"] as? [Int] else {
            print("No account IDs found")
            return
        }

        print("Account IDs to fetch: \(accountIds)")
        
        odoClientNew.SearchUserMtAccounts(accountIds: accountIds) { isExists, userAccounts, error in
            if let error = error {
                print("Error checking user:", error)
                return
            }

            if isExists {
                print("✅ User Accounts exists, sending or checking to Firebase mtAccountsData...")
                
//                print("\n ---->the MT user account data is saved for firebaseUser: \(userAccounts)--->\n")
                self.processMTAccountsForFirebase(mtAccountsData: userAccounts, userID: userID)
            } else {
                print("❌ User accounts does not exist")
                // Show alert or error to user
              
                self.ToastMessage("No user accounts found with this email.")
            }
        }
    }
    
    func processMTAccountsForFirebase(mtAccountsData: [[String: Any]]?, userID: String) {
       
        firebaseInstance.userNotFound = {
            print("\n ---***---No user account found and create MT user in firbase---***----\n")
            self.firebaseInstance.fetchUserData(userId: userID)
            self.createMTAccounts(mtAccountsData: mtAccountsData, userID: userID)
            return
        }
        
        firebaseInstance.fetchUserAccountsData(userId: userID) {
            
            self.firebaseInstance.fetchUserData(userId: userID)
            if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
                print("\n Default user Account get in signing process : \(defaultAccount)")
              
                self.navigateToFaceID()
            }else{
//                self.navigateToSelectDefaultAccount()
            }
          
        }
        
    }

    private func createMTAccounts(mtAccountsData: [[String: Any]]?, userID: String) {
        // Group ID mapping
        let groupIDMapping: [String: String] = [
            "Prime": "RWHwgycWkAqi5OPvv1oX",
            "Pro": "J4DE6ojeCiIt8uWDWUBT",
            "Premium": "hejJt530sHou5bEuMk48"
        ]
        
        let userAccountsCollection = db.collection("userAccounts")
        
        // Handle Optional array
        guard let accountsArray = mtAccountsData else {
            print("❌ No MT accounts data found")
            return
        }
        
        print("🚀 Processing \(accountsArray.count) MT accounts...")
        
        for (index, account) in accountsArray.enumerated() {
            print("Processing account \(index + 1)")
            
            // Extract data from MT account response
            guard let login = account["login"] as? Int,
                  let groupIdArray = account["group_id"] as? [Any],
                  let serverIdArray = account["server_id"] as? [Any],
                  let createDateString = account["create_date"] as? String,
                  let writeDateString = account["write_date"] as? String else {
                print("⚠️ Failed to extract required data from account")
                continue
            }
            
            // Extract group name from group_id array (second element)
            let fullGroupName = groupIdArray.count > 1 ? String(describing: groupIdArray[1]) : ""
            let groupName = self.extractGroupName(from: fullGroupName)
            
            // Extract server ID (first element)
            let serverID = serverIdArray.count > 0 ? serverIdArray[0] as? Int ?? 1 : 1
            
            // Map server_id to isReal (1 = demo/false, 2 = real/true)
            let isReal = serverID == 2
            
            // Create account name
            let accountType = isReal ? "Real" : "Demo"
            let name = "\(groupName) \(accountType) Account"
            
            // Get group ID from mapping
            let groupID = groupIDMapping[groupName] ?? ""
            
            // Convert date strings to timestamps
            let createDate = DateHelper.convertToDate(from: createDateString)
            let updateDate = DateHelper.convertToDate(from: writeDateString)
            
            // Handle password - can be string, number 0, or false/null
            var password = ""
            if let passwordString = account["password"] as? String {
                password = passwordString
            } else if let passwordNumber = account["password"] as? Int, passwordNumber != 0 {
                password = String(passwordNumber)
            }
            
            print("🏦 Account \(login): Group=\(groupName), IsReal=\(isReal)")
            
            // Prepare Firebase document data
            let firebaseAccountData: [String: Any] = [
                "accountNumber": login,
                "createdAt": createDate,
                "groupID": groupID,
                "groupName": groupName,
                "isDefault": false,
                "isReal": isReal,
                "name": name,
                "password": password,
                "updatedAt": updateDate,
                "userID": userID
            ]
            
            // Create a unique document for each account using userID + login
            let documentID = "\(userID)_\(login)"
            
            // Add to Firebase
            userAccountsCollection.document(documentID).setData(firebaseAccountData) { error in
                if let error = error {
                    print("❌ Error adding account \(login): \(error)")
                } else {
                    print("✅ Successfully added account \(login) to Firebase")
                   
                }
            }
        }
        self.navigateToSelectDefaultAccount()
    }

    // Helper function to extract group name from full group path
    func extractGroupName(from fullGroupName: String) -> String {
        print("Extracting group name from: '\(fullGroupName)'")
        
        // Handle both single and double backslashes
        // Extract from patterns like "demo\RP\PRO", "RP\PRIME\6C-0R-20SO", "RP\PRO\0C-0R-20SO"
        let components = fullGroupName.components(separatedBy: "\\")
        
        for component in components {
            let upperComponent = component.uppercased().trimmingCharacters(in: .whitespaces)
            print("Checking component: '\(upperComponent)'")
            
            if upperComponent.contains("PRIME") {
                print("Found PRIME group")
                return "Prime"
            } else if upperComponent.contains("PRO") {
                print("Found PRO group")
                return "Pro"
            } else if upperComponent.contains("PREMIUM") {
                print("Found PREMIUM group")
                return "Premium"
            }
        }
        
        print("No specific group found, using default: Pro")
        return "Pro" // Default fallback
    }
    
}
