//
//  SignInViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//
import Foundation
import UIKit
import TPKeyboardAvoiding
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import SVProgressHUD

import AuthenticationServices
import KeychainSwift
import Firebase
import CryptoKit

class SignInViewController: BaseViewController {
    
    @IBOutlet var bfView: UIView!
    @IBOutlet weak var username_tf: UITextField!{
        didSet{
            username_tf.setIcon(UIImage(imageLiteralResourceName: "personIcon"))
            username_tf.tintColor = UIColor.lightGray
        }
    }
    
    @IBOutlet weak var password_tf: UITextField!{
        didSet{
            password_tf.tintColor = UIColor.lightGray
            password_tf.setIcon(UIImage(imageLiteralResourceName: "passwordIcon"))
        }
    }
    
    @IBOutlet weak var lbl_emailCheck: UILabel!
    @IBOutlet weak var lbl_passwordCheck: UILabel!
//    @IBOutlet weak var lbl_credientailCheck: UILabel!
    @IBOutlet weak var btn_rememberMe: UIButton!
   
    @IBOutlet weak var btn_submit: UIButton!
    
    @IBOutlet weak var hideShowPassBtn: UIButton!
    
    var firebaseInstance = FirestoreServices()
    var viewModel = SignViewModel()
//    var signUpVC = SignUpViewController()
//    var odooClientService = OdooClient()
    var odoClientNew = OdooClientNew()
    var googleSignIn = GoogleSignIn()
    var emailUser: String?
      
    var fromOpenAccount : Bool = false
    var isGoogleLogin : Bool = false
    var isAppleLogin : Bool = false
    
    let keychain = KeychainSwift()
    let db = Firestore.firestore()
    var _email : String?
    var _fullName : String?
    var _password: String?
    
    let passwordManager = PasswordManager()
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.username_tf.addTarget(self, action: #selector(emailTextChanged), for: .editingChanged)
        self.password_tf.addTarget(self, action: #selector(passwordTextChanged), for: .editingChanged)
    
//        enableLoginButton()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
        //MARK: - Show Navigation Bar
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: SignInViewController(), navController: self.navigationController, title: "", leftTitle: "", rightTitle: "", textColor: .white, barColor: .splashScreen)
     
    }
    
//    private func enableLoginButton() {
//        if self.viewModel.isLoginFieldsValid(email: self.username_tf.text!, password: self.password_tf.text!) && self.username_tf.state.isEmpty && self.password_tf.state.isEmpty {
//            self.btn_submit.isEnabled = true
//            self.btn_submit.setTitleColor(UIColor(named: "white"), for: .normal)
//        } else {
//            self.btn_submit.isEnabled = false
//            self.btn_submit.setTitleColor(UIColor(named: "lightGray"), for: .normal)
//        }
//        
//        guard let email = username_tf.text, !email.isEmpty, let password = password_tf.text, !password.isEmpty else {
//            self.btn_submit.isEnabled = false
//            self.btn_submit.setTitleColor(UIColor(named: "lightGray"), for: .normal)
//            return
//           }
//    }
    
    @objc func emailTextChanged(_ textField: UITextField) {
        if self.viewModel.isValidEmail(self.username_tf.text!) {
            self.lbl_emailCheck.isHidden = true
        } else {
            
            self.lbl_emailCheck.text = "email is not correct"
            self.lbl_emailCheck.isHidden = false
        }
//        enableLoginButton()
    }
    
    @objc func passwordTextChanged(_ textField: UITextField) {
    
        if self.viewModel.isValidatePassword(password: self.password_tf.text!)  {
            self.lbl_passwordCheck.isHidden = true
        }else{
            self.lbl_passwordCheck.isHidden = false
            self.lbl_passwordCheck.text = "Password should be atleast 8 characters with one capital & one Special letter & one number."
        }
//        enableLoginButton()
    }
    @IBAction func rememberMeBtn(_ sender: Any) {
        self.btn_rememberMe.isSelected = !self.btn_rememberMe.isSelected
        self.btn_rememberMe.setImage(!self.btn_rememberMe.isSelected ? UIImage(systemName: "circle") : UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        self.btn_rememberMe.tintColor = self.btn_rememberMe.isSelected ? .systemYellow : .white
    }
    
    @IBAction func passwordIconAction(_ sender: Any) {
        self.password_tf.isSecureTextEntry = !self.password_tf.isSecureTextEntry
        self.hideShowPassBtn.setImage(!self.password_tf.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }
    
    @IBAction func submitBtn(_ sender: Any) {
        login()
        
//        if let dashboardVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "HomeTabbarViewController"){
//            self.navigate(to: dashboardVC)
//        }
    }
    
    @IBAction func signINGoogle_action(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                print("Sign in failed: \(error.localizedDescription)")
                return
            }
//            print("result user: \(result)")
            guard let user1 = result?.user else { return }
            SVProgressHUD.show()
        
            self?.authenticateWithFirebase(user: user1)
        }
    }
    
    @IBAction func appleSignIN_btnAction(_ sender: Any) {
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
    }
    @IBAction func forgotBtn(_ sender: Any) {
        if let forgotVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "ForgotViewController"){
            self.navigate(to: forgotVC)
        }
    }
    
    @IBAction func createAccountBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func login() {
        // Check if all text fields are filled
        guard
            let email = username_tf.text, !email.isEmpty
        else {
            lbl_emailCheck.text = "Please enter email."
            lbl_emailCheck.isHidden = false
            return
        }
        guard
            let password = password_tf.text, !password.isEmpty
        else {
            lbl_passwordCheck.text = "Please enter password."
            lbl_passwordCheck.isHidden = false
            return
        }
        
        // Use Firebase Authentication to sign in
        Auth.auth().signIn(withEmail: username_tf.text!, password: password_tf.text!) { [weak self] authResult, error in
            
            let authres = authResult?.user.email
            
            if let error = error as NSError? {
                if let authError = AuthErrorCode.Code(rawValue: error.code) {
                    print("Error code: \(authError)")
                    switch authError {
                        
                    case .invalidEmail:
                        self?.lbl_emailCheck.text = "Please enter correct email."
                        self?.lbl_emailCheck.isHidden = false
                    case .wrongPassword:
                        self?.lbl_passwordCheck.text = "Please enter correct password."
                        self?.lbl_passwordCheck.isHidden = false
                    case .userNotFound:
                        self?.lbl_emailCheck.text = "No account found for this email."
                        self?.lbl_emailCheck.isHidden = false
                    default:
                        self?.lbl_passwordCheck.text = "Please enter correct crediential."
                        self?.lbl_passwordCheck.isHidden = false
                        print("Error signing in: \(error.localizedDescription)")
                        return
                    }
                }
            }else{
                self?.lbl_emailCheck.isHidden = true
                self?.lbl_passwordCheck.isHidden = true
//                self?.lbl_credientailCheck.isHidden = true
                print(" signing in successfully: \(authres ?? " no data")")
                
                if let userId = authResult?.user.uid {
                    self?.firebaseInstance.fetchUserData(userId: userId)
                    self?.firebaseInstance.fetchUserAccountsData(userId: userId, completion: {
                        
                    })
                }
                
                let timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { _ in
                    print("Timer fired!")
                    self?.firebaseInstance.handleUserData()
                }
            }
        }
    }
    
     func navigateToFaceID() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let verifyVC = storyboard.instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! PasscodeFaceIDVC
      
        GlobalVariable.instance.userEmail = self.emailUser ?? ""
        
        self.navigate(to: verifyVC)
    }
    
}

extension SignInViewController {
    func authenticateWithFirebase(user: GIDGoogleUser) {
        
        let idToken = user.idToken?.tokenString
        let accessToken = user.accessToken.tokenString
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken ?? "", accessToken: accessToken)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Firebase authentication failed: \(error.localizedDescription)")
                return
            }
            
            // User is signed in with Firebase successfuly
            if let user = authResult?.user {
                
                UserDefaults.standard.set(user.uid, forKey: "userID")
                self.emailUser = user.email ?? ""
                GlobalVariable.instance.userEmail = self.emailUser!
                
                self.db.collection("users").whereField("email", isEqualTo: self.emailUser ?? "").getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error checking for existing user: \(error.localizedDescription)")
                    }
                    
                    if let snapshot = querySnapshot, !snapshot.isEmpty {
                        print("User with this email already exists.")
                        
                        self.firebaseInstance.fetchUserData(userId: user.uid)
                        self.firebaseInstance.fetchUserAccountsData(userId: user.uid, completion: {
                        })
                        
                        let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                            print("Timer fired!")
                            SVProgressHUD.dismiss()
                            self.navigateToFaceID()
                        }
                    } else {
                        SVProgressHUD.dismiss()
                        Alert.showAlertWithOKHandler(withHandler: "This user not exist, please open an Account", andTitle: "Error!", OKButtonText: "OK", on: self, andCompletionHandler: { action in
                            self.navigationController?.popViewController(animated: true)
                        })
                       
                    }
                }
            }
        }
    }
}


extension SignInViewController {
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
}

extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            if let email = appleIDCredential.email {
                print("user Email set: \(email)")
                keychain.set(email, forKey: "appleEmail")
                _email = email
            } else {
                print("Email not provided")
                _email = keychain.get("appleEmail")
                print("User Email get: \(_email)")
            }
            
            if let fullName = appleIDCredential.fullName {
                let formattedName = [fullName.givenName, fullName.familyName]
                    .compactMap { $0 } // Remove nil values
                    .joined(separator: " ") // Combine non-nil values
                
                if !formattedName.isEmpty {
                    print("Full Name: \(formattedName)")
                    keychain.set(formattedName, forKey: "appleName")
                    _fullName = formattedName
                } else {
                    print("Full Name not provided (empty)")
                    _fullName = keychain.get("appleName") ?? "Not available"
                    print("Full Name get from Keychain: \(_fullName ?? "Not available")")
                }
            } else {
                print("Full Name object not provided")
                _fullName = keychain.get("appleName") ?? "Not available"
                print("Full Name from Keychain: \(_fullName ?? "Not available")")
            }
            UserDefaults.standard.set(_fullName, forKey: "FullName")
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase authentication failed: \(error.localizedDescription)")
                    return
                }
                // User is signed in with Firebase successfuly
                if let user = authResult?.user {
                    
                    UserDefaults.standard.set(user.uid, forKey: "userID")
                    //self.emailUser = user.email ?? ""
                    //                    GlobalVariable.instance.userEmail = self.emailUser!
                    
                    self.db.collection("users").whereField("email", isEqualTo: user.email ?? "").getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Error checking for existing user: \(error.localizedDescription)")
                        }
                        
                        if let snapshot = querySnapshot, !snapshot.isEmpty {
                            print("User with this email already exists.")
                            
                            self.firebaseInstance.fetchUserData(userId: user.uid)
                            self.firebaseInstance.fetchUserAccountsData(userId: user.uid, completion: {
                            })
                            
                            let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                                print("Timer fired!")
                                
//                                self.firebaseInstance.handleFaceID()
                                self.navigateToFaceID()
                            }
                            
                        }else{
//                            self.ToastMessage("This user not exist, please open an Account")
                            Alert.showAlertWithOKHandler(withHandler: "This user not exist, please open an Account", andTitle: "Error!", OKButtonText: "OK", on: self, andCompletionHandler: { action in
                                self.navigationController?.popViewController(animated: true)
                            })
                            
                        }
                    }
                }
            }
        }
    }
}
    
