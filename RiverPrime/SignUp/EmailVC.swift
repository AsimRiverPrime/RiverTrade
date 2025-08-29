//
//  EmailVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/01/2025.
//

import UIKit
import GoogleSignIn
import AuthenticationServices
import FirebaseFirestore
import KeychainSwift
import Firebase
import CryptoKit
import SVProgressHUD

class EmailVC: BaseViewController {
   
    @IBOutlet weak var tf_email: UITextField!{
        didSet{
            tf_email.setIcon(UIImage(imageLiteralResourceName: "emailIcon").withTintColor(.black))
            tf_email.tintColor = UIColor.black
        }
    }
    @IBOutlet weak var tf_fullName: UITextField!{
        didSet{
            tf_fullName.setIcon(UIImage(imageLiteralResourceName: "personIcon").withTintColor(.black))
            tf_fullName.tintColor = UIColor.black
        }
    }
    
    @IBOutlet weak var lbl_emailError: UILabel!

    var viewModel = SignViewModel()
    let googleSignIn = GoogleSignIn()
    var odoClientNew = OdooClientNew()
    var firebaseInstance = FirestoreServices()
    
    var isAppleLogin : Bool = false
    
    let keychain = KeychainSwift()
    let db = Firestore.firestore()
    var _email : String?
    var _fullName : String?
    var _password: String?
    var encryptedPassword = String()
    let passwordManager = PasswordManager()
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        odoClientNew.createLeadDelegate = self
        odoClientNew.createUserAcctDelegate = self
        
        self.tf_email.addTarget(self, action: #selector(emailTextChanged), for: .editingChanged)
      
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGesture)
        
        self._password = passwordManager.generateRandomPassword(length: 8)
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: ResidencVC(), navController: self.navigationController, title: "SignUP", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func emailTextChanged(_ textField: UITextField) {
        if let email = self.tf_email.text, !email.isEmpty {
            if self.viewModel.isValidEmail(email) {
                self.lbl_emailError.isHidden = true
                self.tf_email.layer.borderColor = UIColor.black.cgColor
            } else {
                self.lbl_emailError.textColor = .systemRed
                self.lbl_emailError.text = "Email is not correct"
                self.lbl_emailError.isHidden = false
                self.tf_email.layer.borderColor = UIColor.red.cgColor
            }
        } else {
            self.lbl_emailError.textColor = .systemRed
            self.lbl_emailError.text = "Email field cannot be empty"
            self.lbl_emailError.isHidden = false
            self.tf_email.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    @IBAction func continue_action(_ sender: Any) {

        guard let email = tf_email.text, !email.isEmpty else {
            self.lbl_emailError.isHidden = false
            self.lbl_emailError.text = "This field cannot be empty"
            self.tf_email.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        if let passwordVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "PasswordVC") as? PasswordVC {
            passwordVC.email = tf_email.text
            passwordVC.fullName = tf_fullName.text
            
            self.navigate(to: passwordVC)
        }
    }
    
    @IBAction func signInBtn(_ sender: Any) {
        if let signInVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "SignInViewController"){
            self.navigate(to: signInVC)
        }
    }
    
    @IBAction func signInGoogle(_ sender: Any) {
        SVProgressHUD.show()
        self.isAppleLogin = false
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                print("Sign in failed: \(error.localizedDescription)")
                SVProgressHUD.dismiss()
                return
            }
            //            print("google login user result : \(result)")
            guard let user1 = result?.user else { return }
            self?._email = result?.user.profile?.email ?? ""
            self?._fullName = result?.user.profile?.name ?? ""
         
            print("_email : \(self?._email ?? "") and name is : \(self?._fullName ?? "")")
            UserDefaults.standard.set(self?._fullName, forKey: "FullName")
            GlobalVariable.instance.userEmail = self?._email ?? ""
            
            self?.authenticateWithFirebase(user: user1)
        }
    }
    
    @IBAction func appleSignIN_btnAction(_ sender: Any) {
        SVProgressHUD.show()
        self.isAppleLogin = true
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
    
}

extension EmailVC {
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
extension EmailVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
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
                print("User Email get from Keychain: \(_email ?? "")")
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
                    print("User is signed in with Firebase successfuly: \(user.uid)")
                    UserDefaults.standard.set(user.uid, forKey: "userID")
                    //self.emailUser = user.email ?? ""
//                    GlobalVariable.instance.userEmail = self.emailUser!
                    
                    self.db.collection("users").whereField("email", isEqualTo: self._email ?? "").getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Error checking for existing user: \(error.localizedDescription)")
                        }
                        print("User is in with Firebase users collection : \(self._email ?? "")")
                        if let snapshot = querySnapshot, !snapshot.isEmpty {
                            print("User with this email already exists.")
                            SVProgressHUD.dismiss()
                            self.ToastMessage("User with this email already exists.\nPlease Sign In")
                            
                        } else {
                            self.odoClientNew.SearchRecord(email: self._email ?? "") { userFound, userData, error in
                                
                                if let error = error {
                                    print("Error checking user:", error)
                                    self.ToastMessage("No user found.Server error.")
                                    SVProgressHUD.dismiss()
                                    return
                                }

                                if userFound {
                                    print("✅ User exists in CRM")
                                    self.ToastMessage("User with this email already exists.\nPlease Sign In")
                                    SVProgressHUD.dismiss()
                                    return
                                } else {
                                    print("❌ User does not exist")
                                    self.odoClientNew.createRecords(firebase_uid: user.uid, email: self._email ?? "", name: self._fullName ?? "")
                                    self.firebaseInstance.saveAdditionalUserData(userId: user.uid, kyc: "Not Started", address: "", dateOfBirth: "", profileStep: 0, name: self._fullName ?? "", gender: "", phone: "", email: self._email ?? "", emailVerified: false, phoneVerified: false, isLogin: false, pushedToCRM: false, nationality: "", residence: "",registrationType: 3)
                                  
                                }
                            }
                           
                        }
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple error: \(error.localizedDescription)")
        SVProgressHUD.dismiss()
    }
    
    func navigateFaceID(){
        SVProgressHUD.dismiss()
        let faceIdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! PasscodeFaceIDVC
        faceIdVC.afterLoginNavigation = false
       
        self.navigate(to: faceIdVC)
    }
    
    func createMTAccount() {
        let id =  UserDefaults.standard.string(forKey: "userID")
        
        let plainPassword = self._password ?? ""
        encryptedPassword = PasswordEncryption.encryptPassword(plainPassword)
        print("\n✅ encryptedPassword is: \(encryptedPassword)\n")
        let decryptedPassword = PasswordEncryption.decryptPassword(encryptedPassword)
        print("\n decryptedPassword is: \(decryptedPassword)\n")
        UserDefaults.standard.set((self.encryptedPassword), forKey: "password")
        
          if self.isAppleLogin {
              
              self.firebaseInstance.saveAdditionalUserData(userId: id ?? "", kyc: "Not Started", address: "", dateOfBirth: "", profileStep: 0, name: self._fullName ?? "", gender: "", phone: "", email: self._email ?? "", emailVerified: true, phoneVerified: false, isLogin: false, pushedToCRM: false, nationality: GlobalVariable.instance.nationality, residence: GlobalVariable.instance.residence, registrationType: 3)
          }else{
              self.firebaseInstance.saveAdditionalUserData(userId: id ?? "", kyc: "Not Started", address: "", dateOfBirth: "", profileStep: 0, name: self._fullName ?? "", gender: "", phone: "", email: self._email ?? "", emailVerified: true, phoneVerified: false, isLogin: false, pushedToCRM: false, nationality: GlobalVariable.instance.nationality, residence: GlobalVariable.instance.residence,  registrationType: 2)
          }
 
          self.odoClientNew.createAccount(phone: "", group: "PRO", email: _email ?? "", currency: "USD", leverage: 400, first_name: self._fullName ?? "", last_name: "", password: encryptedPassword, is_demo: true)
    }
    
       func updateUserMTAccount(){
           let id =  UserDefaults.standard.string(forKey: "userID")
           
           var fieldsToUpdate: [String:Any] = [
               "KycStatus": "Not Started",
               "name" : self._fullName ?? "",
               "currency": "USD",
               "userID" : id ?? "",
               "groupID": "RWHwgycWkAqi5OPvv1oX",
               "isDefault" : true,
               "isReal": false,
               "password": encryptedPassword,
               "groupName" : "PRO",
               "accountNumber" : GlobalVariable.instance.loginID // loginID in createAccount response
           ]
          
           print("updating user Accounts fields are: \(fieldsToUpdate)")
          
           firebaseInstance.updateUserAccountsFields(fields: fieldsToUpdate, completion: { error in
                      if let error = error {
                          print("Error updating UserAccounts fields: \(error.localizedDescription)")
                          return
                      } else {
                          print("(byDefault) User Accounts fields updated successfully!")
                          self.firebaseInstance.updateDefaultAccount(for: "\(GlobalVariable.instance.loginID)", userId: id ?? ""){ [weak self] error in
                              guard let self = self else { return }
                              
                              if let error = error {
                                  print("Error updating default account: \(error.localizedDescription)")
                                  return
                              }
                              print("\n updating isDefault account success: ")
   //                           self.fireStoreInstance.fetchUserAccountsData(userId: self.userId)
                              
                              
                              if passwordManager.savePassword(for: String(GlobalVariable.instance.loginID), password: encryptedPassword /*self._password ?? ""*/) {
                                  print("Password successfully saved.")
                              } else {
                                  print("ID already exists. Cannot save password.")
                              }
                              
                              let allPasswords = passwordManager.getAllPasswords()
                              print("All Saved Passwords on create Account: \(allPasswords)")
                               
                            NotificationCenter.default.post(name: NSNotification.Name("dismissCreateAccountScreen"), object: nil)
                                  self.dismiss(animated: true)
//                              }
                          }
                          
                      }
               self.navigateFaceID()
           })
       }

}

extension EmailVC:  CreateLeadOdooDelegate {
func leadCreatSuccess(response: Any) {
    print("this is success response from create Lead is:\(response)")
    
    if GlobalVariable.instance.realAccount {
        self.navigateFaceID()
       
    }else{
        createMTAccount()

    }
   
}

func leadCreatFailure(error: any Error) {
    print("this is error response:\(error)")
    ActivityIndicator.shared.hide(from: self.view)
}
}

extension EmailVC : CreateUserAccountTypeDelegate {
       func createAccountSuccess(response: Any) {
           print("\n this is create user success response from Email Screen: \(response)")
           // get loginId from the response
           updateUserMTAccount()
   
       }
       
       func createAccountFailure(error: any Error) {
           print("\n this is create user error response: \(error)")
           self.ToastMessage("Account Create Failed.")
           SVProgressHUD.dismiss()
       }
   }

extension EmailVC {
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
                self._email = user.email ?? ""
                GlobalVariable.instance.userEmail = self._email!
                
                self.db.collection("users").whereField("email", isEqualTo: self._email ?? "").getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error checking for existing user: \(error.localizedDescription)")
                    }
                    print("User is in with Firebase users collection : \(self._email ?? "")")
                    if let snapshot = querySnapshot, !snapshot.isEmpty {
                        print("User with this email already exists.")
                        SVProgressHUD.dismiss()
                        self.ToastMessage("User with this email already exists.\nPlease Sign In")
                        
                    } else {
                        self.odoClientNew.SearchRecord(email: self._email ?? "") { userFound, userData, error in
                            
                            if let error = error {
                                print("Error checking user:", error)
                                self.ToastMessage("Server error:\(error)")
                                SVProgressHUD.dismiss()
                                return
                            }
                            
                            if userFound {
                                print("✅ User exists in CRM")
                                self.ToastMessage("User with this email already exists.\nPlease Sign In")
                                SVProgressHUD.dismiss()
                                return
                            } else {
                                print("❌ User does not exist")
                                self.odoClientNew.createRecords(firebase_uid: user.uid, email: user.email ?? "", name: user.displayName ?? "anyName")
                                
                                self.firebaseInstance.saveAdditionalUserData(userId: user.uid, kyc: "Not Started", address: "", dateOfBirth: "", profileStep: 0, name: user.displayName ?? "", gender: "", phone: "", email: user.email ?? "", emailVerified: false, phoneVerified: false, isLogin: false, pushedToCRM: false, nationality: "", residence: "",  registrationType: 2)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
