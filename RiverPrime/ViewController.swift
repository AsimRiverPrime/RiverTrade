//
//  ViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//

import UIKit
import AVFoundation
import GoogleSignIn
import AuthenticationServices
import FirebaseFirestore
import KeychainSwift
import CryptoKit
import Firebase



class ViewController: BaseViewController {
    
    @IBOutlet weak var titlelbl: UILabel!
    @IBOutlet weak var companyTitlelbl: UILabel!
    @IBOutlet weak var registerNowBtn: UIButton!
    
    let vm = ViewControllerVM()
    let googleSignIn = GoogleSignIn()
    var odoClientNew = OdooClientNew()
    var firebaseInstance = FirestoreServices()
    var fromOpenAccount : Bool = false
    var isGoogleLogin : Bool = false
    var isAppleLogin : Bool = false
    
    let keychain = KeychainSwift()
    let db = Firestore.firestore()
    var _email : String?
    var _fullName : String?
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        odoClientNew.createLeadDelegate = self
        //        styling()
        //        playBackgroundVideo()
    }
    
    
    // for crash laytics
    //        let button = UIButton(type: .roundedRect)
    //           button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
    //           button.setTitle("Test Crash", for: [])
    //           button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
    //           view.addSubview(button)
    //       }
    //
    //       @IBAction func crashButtonTapped(_ sender: AnyObject) {
    //           let numbers = [0]
    //           let _ = numbers[1]
    //       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func registerBtn(_ sender: Any) {
        if let nationalityVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "NationalityVC")
        {
            
            self.isGoogleLogin = false
            self.isAppleLogin = false
            self.fromOpenAccount = true
            UserDefaults.standard.set(self.isGoogleLogin, forKey: "isGoogleLogin")
            UserDefaults.standard.set(self.fromOpenAccount, forKey: "fromOpenAccount")
            UserDefaults.standard.set(self.isAppleLogin, forKey: "isAppleLogin")
            
            self.navigate(to: nationalityVC)
        }
        
    }
    
    @IBAction func signInBtn(_ sender: Any) {
        if let signInVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "SignInViewController"){
            self.navigate(to: signInVC)
        }
    }
    
    @IBAction func continueGoogleBtn(_ sender: Any) {
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                print("Sign in failed: \(error.localizedDescription)")
                return
            }
            //            print("google login user result : \(result)")
            guard let user1 = result?.user else { return }
            let _email = result?.user.profile?.email ?? ""
            let _name = result?.user.profile?.name ?? ""
            
            print("_email : \(_email) and name is : \(_name)")
            UserDefaults.standard.set(_name, forKey: "FullName")
            GlobalVariable.instance.userEmail = _email
//            GlobalVariable.instance.userID = result?.user.userID ?? ""
            self?.isGoogleLogin = true
            
            self?.googleSignIn.odoClientNew.createLeadDelegate = self
            self?.googleSignIn.authenticateWithFirebase(user: user1)
            
        }
    }
    
    @IBAction func tryDemo_btnAction(_ sender: Any) {
        
//        let nonce = randomNonceString()
//        currentNonce = nonce
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//        request.nonce = sha256(nonce)
//        
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
//        
    }
    
    func saveToKeychain(userIdentifier: String) {
        
        keychain.set(userIdentifier, forKey: "appleUserIdentifier")
        print("User Identifier saved to Keychain")
    }
    func getUserIdentifierFromKeychain() -> String? {
        
        return keychain.get("appleUserIdentifier")
    }
}

extension ViewController {
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
//extension ViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
//    
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return view.window!
//    }
//    
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            
//            guard let nonce = currentNonce else {
//                fatalError("Invalid state: A login callback was received, but no login request was sent.")
//            }
//            guard let appleIDToken = appleIDCredential.identityToken else {
//                print("Unable to fetch identity token")
//                return
//            }
//            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
//                return
//            }
//            
//            if let email = appleIDCredential.email {
//                print("user Email set: \(email)")
//                keychain.set(email, forKey: "appleEmail")
//                _email = email
//            } else {
//                print("Email not provided")
//                _email = keychain.get("appleEmail")
//                print("User Email get : \(_email)")
//            }
//            
//            if let fullName = appleIDCredential.fullName {
//                let formattedName = [fullName.givenName, fullName.familyName]
//                    .compactMap { $0 } // Remove nil values
//                    .joined(separator: " ") // Combine non-nil values
//                
//                if !formattedName.isEmpty {
//                    print("Full Name: \(formattedName)")
//                    keychain.set(formattedName, forKey: "appleName")
//                    _fullName = formattedName
//                } else {
//                    print("Full Name not provided (empty)")
//                    _fullName = keychain.get("appleName") ?? "Not available"
//                    print("Full Name get from Keychain: \(_fullName ?? "Not available")")
//                }
//            } else {
//                print("Full Name object not provided")
//                _fullName = keychain.get("appleName") ?? "Not available"
//                print("Full Name from Keychain: \(_fullName ?? "Not available")")
//            }
//            UserDefaults.standard.set(_fullName, forKey: "FullName")
//            // Initialize a Firebase credential, including the user's full name.
//            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
//                                                           rawNonce: nonce,
//                                                           fullName: appleIDCredential.fullName)
//            // Sign in with Firebase.
//            Auth.auth().signIn(with: credential) { authResult, error in
//                if let error = error {
//                    print("Firebase authentication failed: \(error.localizedDescription)")
//                    return
//                }
//                // User is signed in with Firebase successfuly
//                if let user = authResult?.user {
//                    
//                        UserDefaults.standard.set(user.uid, forKey: "userID")
//                    //                 self.emailUser = user.email ?? ""
//                    //                 GlobalVariable.instance.userEmail = self.emailUser!
//                    
//                    self.db.collection("users").whereField("email", isEqualTo: user.email ?? "").getDocuments { (querySnapshot, error) in
//                        if let error = error {
//                            print("Error checking for existing user: \(error.localizedDescription)")
//                        }
//                        
//                        if let snapshot = querySnapshot, !snapshot.isEmpty {
//                            print("User with this email already exists.")
//                            
//                            self.firebaseInstance.fetchUserData(userId: user.uid)
//                            self.firebaseInstance.fetchUserAccountsData(userId: user.uid, completion: {
//                            })
//                            
//                            let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
//                                print("Timer fired!")
//                                
//                                self.firebaseInstance.handleUserData()
//                            }
//                            
//                        } else {
//                            self.odoClientNew.createRecords(firebase_uid: user.uid, email: self._email ?? "", name: self._fullName ?? "")
//                            self.firebaseInstance.saveAdditionalUserData(userId: user.uid, kyc: "Not Started", address: "", dateOfBirth: "", profileStep: 0, name: self._fullName ?? "", gender: "", phone: "", email: user.email ?? "", emailVerified: false, phoneVerified: false, isLogin: false, pushedToCRM: false, nationality: "", residence: "", registrationType: 3)
//                            
//                        }
//                    }
//                }
//            }
//        }
//    }
//  
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        print("Sign in with Apple error: \(error.localizedDescription)")
//    }
//}

extension ViewController {
    
    private func styling() {
        //MARK: - Fonts
        //        titlelbl.font = FontController.Fonts.Inter_Regular.font
        //        companyTitlelbl.font = FontController.Fonts.Inter_Medium.font
        //        registerNowBtn.titleLabel?.font = FontController.Fonts.Inter_SemiBold.font
        
        //        MARK: - Labels
        //        titlelbl.text = LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.WelcomeScreen.Title.localized)
        //        companyTitlelbl.text = LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.WelcomeScreen.CompanyNameLabel.localized)
        //        registerNowBtn.setTitle(LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.WelcomeScreen.RegisterNowButton.localized), for: .normal)
        titlelbl.text = NSLocalizedString("welcome_screen_title", comment: "")
        companyTitlelbl.text = NSLocalizedString("welcome_screen_company_name", comment: "Welcome message on the main screen")
        registerNowBtn.setTitle(NSLocalizedString("welcome_screen_register_button", comment: "Register button title"), for: .normal)
        
    }
    
    func navigateToNationility(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nationalityVC = storyboard.instantiateViewController(withIdentifier: "NationalityVC") as! NationalityVC
        
        if isGoogleLogin {
            self.isGoogleLogin = true
            self.isAppleLogin = false
            self.fromOpenAccount = false
            UserDefaults.standard.set(self.isGoogleLogin, forKey: "isGoogleLogin")
            UserDefaults.standard.set(self.fromOpenAccount, forKey: "fromOpenAccount")
            UserDefaults.standard.set(self.isAppleLogin, forKey: "isAppleLogin")
        }else{
            self.isGoogleLogin = false
            self.isAppleLogin = true
            self.fromOpenAccount = false
            UserDefaults.standard.set(self.isGoogleLogin, forKey: "isGoogleLogin")
            UserDefaults.standard.set(self.fromOpenAccount, forKey: "fromOpenAccount")
            UserDefaults.standard.set(self.isAppleLogin, forKey: "isAppleLogin")
        }
        self.navigate(to: nationalityVC)
    }
    
}

extension ViewController:  CreateLeadOdooDelegate {
    func leadCreatSuccess(response: Any) {
        print("this is success response from create Lead and record ID is:\(response)")
        odoClientNew.writeFirebaseToken(firebaseToken: GlobalVariable.instance.firebaseNotificationToken)
        navigateToNationility()
        //        odoClientNew.sendOTP(type: "email", email: GlobalVariable.instance.userEmail, phone: "")
        
        //        Alert.showAlertWithOKHandler(withHandler: "Check email inbox or spam for OTP", andTitle: "", OKButtonText: "OK", on: self) { _ in
        //
        //        }
        //        self.navigateToVerifiyScreen()
        //        ActivityIndicator.shared.hide(from: self.view)
    }
    
    func leadCreatFailure(error: any Error) {
        print("this is error response:\(error)")
        ActivityIndicator.shared.hide(from: self.view)
    }
}

