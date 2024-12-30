//
//  SignUpViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//
import Foundation
import UIKit
import TPKeyboardAvoiding
import GoogleSignIn
import FirebaseFirestore
import FirebaseAuth
import Firebase

class SignUpViewController: BaseViewController {
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var lbl_emailValid: UILabel!
    @IBOutlet weak var lbl_passValid: UILabel!
    @IBOutlet weak var lbl_reTypePassValid: UILabel!
    
    @IBOutlet weak var lbl_fullName: UITextField! {
        didSet{
            lbl_fullName.setIcon(UIImage(imageLiteralResourceName: "personIcon"))
            lbl_fullName.tintColor = UIColor.lightGray
        }
    }
    @IBOutlet weak var lbl_userName: UITextField! {
        didSet{
            lbl_userName.setIcon(UIImage(imageLiteralResourceName: "personIcon"))
            lbl_userName.tintColor = UIColor.lightGray
        }
    }
    
    @IBOutlet weak var reTypePassword_tf: UITextField! {
        didSet{
            reTypePassword_tf.setIcon(UIImage(imageLiteralResourceName: "passwordIcon"))
            reTypePassword_tf.tintColor = UIColor.lightGray
        }
    }
    
    @IBOutlet weak var email_tf: UITextField!{
        didSet{
            email_tf.setIcon(UIImage(imageLiteralResourceName: "emailIcon"))
            email_tf.tintColor = UIColor.lightGray
        }
    }
    
    @IBOutlet weak var password_tf: UITextField!{
        didSet{
            password_tf.tintColor = UIColor.lightGray
            password_tf.setIcon(UIImage(imageLiteralResourceName: "passwordIcon"))
        }
    }
    
    //    @IBOutlet weak var signinbutton: UIButton!
    @IBOutlet weak var btn_termsCondition: UIButton!
    @IBOutlet weak var termsCondition_lbl: UILabel!
    @IBOutlet weak var btn_passowrdIcon: UIButton!
    @IBOutlet weak var btn_reTpyePassowrdIcon: UIButton!
    @IBOutlet weak var btn_contiune: UIButton!
    
    var viewModel = SignViewModel()
    //    var odooClientService = OdooClient()
    var odoClientNew = OdooClientNew()
    var googleSignIn = GoogleSignIn()
    let db = Firestore.firestore()
    let fireBaseService =  FirestoreServices()
    
    var emailUser: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("odoo client auth call")
        
        odoClientNew.authenticate()
        //        odooClientService.createLeadDelegate = self
        odoClientNew.createLeadDelegate = self
        // Do any additional setup after loading the view.
        self.email_tf.addTarget(self, action: #selector(emailTextChanged), for: .editingChanged)
        self.password_tf.addTarget(self, action: #selector(passwordTextChanged), for: .editingChanged)
        self.reTypePassword_tf.addTarget(self, action: #selector(reTypePasswordTextChange), for: .editingChanged)
        //        self.signinbutton.setTitle("", for: .normal)
        enableLoginButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.navigationController?.setNavigationBarHidden(true, animated: true)
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
        
        let fullText = "By clicking Create Account, you agree to Terms and Service and Privacy policy"
       
        let clickableWords = ["Terms and Service", "Privacy policy"]
        // Generate the attributed string with clickable words
        let attributedWithTextColor = fullText.attributedStringWithColor(
            ["Terms and Service", "Privacy policy"],
            color: UIColor.systemYellow,
            clickableWords: clickableWords
        )
       
        // Assign the attributed text to the UILabel
        termsCondition_lbl.attributedText = attributedWithTextColor
        
        // Enable interaction on the label
        termsCondition_lbl.isUserInteractionEnabled = true
        
        // Add a tap gesture recognizer to detect taps
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
        termsCondition_lbl.addGestureRecognizer(tapGesture)
        
        
        if GlobalVariable.instance.isIphone() {
            heightConstraint.constant = 35
        } else {
            heightConstraint.constant = 65
        }
        
    }
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        
        // Get the position of the tap
        let location = sender.location(in: label)
        
        // Get the attributed string from the label
        let attributedText = label.attributedText!
        
        // Create a layout manager to determine where the tap occurred in the text
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Adjust text container properties
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.size = label.bounds.size
        
        // Get the glyph index at the tapped location
        let glyphIndex = layoutManager.glyphIndex(for: location, in: textContainer)
        
        // Define the clickable words and actions (same as in the method)
        let clickableWords: [String: String] = [
            "Terms and Service": "action://termsService",
            "Privacy policy": "action://privacyPolicy"
        ]
        
        // Check if the tapped location is within the range of a clickable word
        for (word, action) in clickableWords {
            let range = (attributedText.string as NSString).range(of: word)
            if NSLocationInRange(glyphIndex, range) {
                print("You tapped on: \(word) with action: \(action)")
                handleAction(action)
                break
            }
        }
    }
    
    func handleAction(_ action: String) {
        // Handle the action based on the URL or custom string (e.g., show alert, navigate, etc.)
        if action == "action://termsService" {
            print("Navigate to Terms and Service page")
            
            if let termConditionVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "TermsConditionsViewController") {
                self.navigate(to: termConditionVC)
            }
            
            // Perform your action (e.g., show Terms and Service page)
        } else if action == "action://privacyPolicy" {
            print("Navigate to Privacy Policy page")
            // Perform your action (e.g., show Privacy Policy page)
            
            if let privcyVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "PrivacyViewController") {
                self.navigate(to: privcyVC)
            }
            
        }
    }
    
    @objc func emailTextChanged(_ textField: UITextField) {
        if self.viewModel.isValidEmail(self.email_tf.text!)  {
            self.lbl_emailValid.isHidden = true
            emailUser = self.email_tf.text!
        } else {
            self.lbl_emailValid.textColor = .red
            self.lbl_emailValid.text = "email is not correct"
            self.lbl_emailValid.isHidden = false
        }
        
    }
    
    @objc func passwordTextChanged(_ textField: UITextField) {
        
        if self.viewModel.isValidatePassword(password: self.password_tf.text!) {
            self.lbl_passValid.isHidden = true
        }else{
            self.lbl_passValid.isHidden = false
            self.lbl_passValid.text = "Password is atleast 8 character with 1 capital & 1 Special & 1 number"
            self.lbl_passValid.textColor = .red
        }
        
    }
    @objc func reTypePasswordTextChange(_ textField: UITextField) {
        if self.password_tf.text == self.reTypePassword_tf.text {
            self.lbl_reTypePassValid.isHidden = true
            enableLoginButton()
        } else {
            self.lbl_reTypePassValid.isHidden = false
            self.btn_contiune.isUserInteractionEnabled = false
//            self.btn_contiune.setTitleColor(UIColor.lightGray, for: .normal)
            self.btn_contiune.layer.borderColor =  CGColor.init(red: 107/255, green: 107/255, blue: 107/255, alpha: 1.0)
            self.btn_contiune.tintColor = .systemGray
        }
    }
    
    private func enableLoginButton() {
        if self.viewModel.isLoginFieldsValid(email: self.email_tf.text!, password: self.reTypePassword_tf.text!) //, self.btn_termsCondition.isSelected == true
        {
            self.btn_contiune.isUserInteractionEnabled = true
//            self.btn_contiune.setTitleColor(UIColor.systemYellow, for: .normal)
            self.btn_contiune.layer.borderColor = CGColor.init(red: 255/255, green: 202/255, blue: 35/255, alpha: 1.0)
            self.btn_contiune.tintColor = .systemYellow
        } else {
            self.btn_contiune.isUserInteractionEnabled = false
            self.btn_contiune.layer.borderColor =  CGColor.init(red: 107/255, green: 107/255, blue: 107/255, alpha: 1.0)
//            self.btn_contiune.setTitleColor(UIColor.lightGray, for: .normal)
            self.btn_contiune.tintColor = .systemGray
        }
        
        guard let email = email_tf.text, !email.isEmpty, let password = password_tf.text, !password.isEmpty else {
            self.btn_contiune.isUserInteractionEnabled = false
//            self.btn_contiune.setTitleColor(UIColor.lightGray, for: .normal)
            self.btn_contiune.layer.borderColor = CGColor.init(red: 107/255, green: 107/255, blue: 107/255, alpha: 1.0)
            self.btn_contiune.tintColor = .systemGray
            return
        }
    }
    
    
    @IBAction func signInBtn(_ sender: Any) {
        if let signInVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "SignInViewController"){
            self.navigate(to: signInVC)
        }
    }
  
    
    @IBAction func continueBtn(_ sender: Any) {
        signUp()
        //        if let dashboardVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DashboardVC"){
        //            self.navigate(to: dashboardVC)
        //        }
        
        //        let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen2, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen2
        //        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
    }
    
    @IBAction func passwordIconAction(_ sender: Any) {
        self.password_tf.isSecureTextEntry = !self.password_tf.isSecureTextEntry
        self.btn_passowrdIcon.setImage(!self.password_tf.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }
    
    @IBAction func reTypePasswordIconAction(_ sender: Any) {
        self.reTypePassword_tf.isSecureTextEntry = !self.reTypePassword_tf.isSecureTextEntry
        self.btn_reTpyePassowrdIcon.setImage(!self.reTypePassword_tf.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }
    
    @IBAction func continueGoogleBtn(_ sender: Any) {
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                print("Sign in failed: \(error.localizedDescription)")
                return
            }
            print("result user: \(result)")
            guard let user1 = result?.user else { return }
//            self?.odoClientNew.createLeadDelegate = self
            self?.googleSignIn.authenticateWithFirebase(user: user1)
            
        }
    }
    
//    @IBAction func termConditionBtn(_ sender: Any) {
//        if let termConditionVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "TermsConditionsViewController") {
//            self.navigate(to: termConditionVC)
//        }
//        
//    }
//    @IBAction func privacyPolicyBtn(_ sender: Any) {
//        if let privcyVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "PrivacyViewController") {
//            self.navigate(to: privcyVC)
//        }
//    }
    
    
    private func signUp() {
        guard
            let fullName = lbl_fullName.text, !fullName.isEmpty,
            let userName = lbl_userName.text, !userName.isEmpty,
            let reTypePass = reTypePassword_tf.text, !reTypePass.isEmpty,
            let email = email_tf.text, !email.isEmpty,
            let password = password_tf.text, !password.isEmpty
                
        else {
            print("Please fill in all fields.")
            self.lbl_emailValid.isHidden = false
            self.lbl_emailValid.text = "Please fill in all fields."
            return
        }
        //        UserDefaults.standard.set(lbl_firstName.text, forKey: "firstName")
        //        UserDefaults.standard.set(lbl_lastName.text, forKey: "lastName")
        // Check if user already exists in Firestore
        
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error checking for existing user: \(error.localizedDescription)")
                
            }
            
            if let snapshot = querySnapshot, !snapshot.isEmpty {
                print("User with this email already exists.")
                self.lbl_emailValid.isHidden = false
                self.lbl_emailValid.text = "The email address is already Exist"
                return
            } else {
                //if user is not exist then Use Firebase Authentication to create a new user
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                    if let error = error as NSError? {
                        if let authError = AuthErrorCode.Code(rawValue: error.code){
                            switch authError {
                            case .emailAlreadyInUse:
                                self?.lbl_emailValid.isHidden = false
                                self?.lbl_emailValid.text = "The email address is already in use by another account"
                                print("The email address is already in use by another account.")
                                return
                            default:
                                print("Error creating user: \(error.localizedDescription)")
                            }
                        }
                        return
                    }
                    // Successfully add user to firebase
                    if let user = authResult?.user {
                        UserDefaults.standard.set(user.uid, forKey: "userID")
                        
//                        ActivityIndicator.shared.show(in: self!.view)
                        
                        //                        let name = firstName + " " + lastName
                        self?.odoClientNew.createRecords(firebase_uid: user.uid, email: email, name: fullName)
                        
                        self?.fireBaseService.saveAdditionalUserData(userId: user.uid, kyc: "Not Started", address: "", dateOfBirth: "", profileStep: 0, name: fullName, gender: "", phone: "", email: email, emailVerified: false, phoneVerified: false, isLogin: false, pushedToCRM: false, nationality: "", residence: "", registrationType: 1)
                        
//                        self?.fireBaseService.saveAdditionalUserData(userId: user.uid, kyc: false, profileStep: 0, name: fullName, userName: userName, phone: "", email: email, emailVerified: false, phoneVerified: false, loginId: 0, login: false, pushedToCRM: false, demoAccountGroup: "", realAccountCreated: false, demoAccountCreated: false, registrationType: 1)
                        // Navigate to the main screen or any other action
                        
                        
                    }
                }
            }
        }
        
    }
    
    func navigateToVerifiyScreen() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let verifyVC = storyboard.instantiateViewController(withIdentifier: "VerifyCodeViewController") as! VerifyCodeViewController
        //        verifyVC.userEmail = self.email_tf.text ?? ""
        GlobalVariable.instance.userEmail = self.emailUser ?? ""
        verifyVC.isEmailVerification = true
        verifyVC.isPhoneVerification = false
        self.navigate(to: verifyVC)
    }
    
}

extension SignUpViewController:  CreateLeadOdooDelegate {
    func leadCreatSuccess(response: Any) {
        print("this is success response from create Lead :\(response)")
        odoClientNew.sendOTP(type: "email", email: emailUser ?? "", phone: "")
        GlobalVariable.instance.userEmail = emailUser ?? ""
//        Alert.showAlertWithOKHandler(withHandler: "Check email inbox or spam for OTP", andTitle: "", OKButtonText: "OK", on: self) { _ in
//          
//        }
        self.navigateToVerifiyScreen()
//        ActivityIndicator.shared.hide(from: self.view)
    }
    
    func leadCreatFailure(error: any Error) {
        print("this is error response:\(error)")
        ActivityIndicator.shared.hide(from: self.view)
    }
}

