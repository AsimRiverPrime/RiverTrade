//
//  PasswordVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/01/2025.
//

import UIKit
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Firebase
import GoogleSignIn

class PasswordVC: BaseViewController {

    @IBOutlet weak var password_tf: UITextField!{
        didSet{
            password_tf.tintColor = UIColor.lightGray
            password_tf.setIcon(UIImage(imageLiteralResourceName: "passwordIcon"))
        }
    }
    @IBOutlet weak var btn_continue: CardViewButton!
    
    @IBOutlet weak var btn_passowrdIcon: UIButton!

    @IBOutlet weak var lbl_firstCondition: UILabel!
    @IBOutlet weak var lbl_secondCondition: UILabel!
    @IBOutlet weak var lbl_thirdCondition: UILabel!
    @IBOutlet weak var lbl_forthCondition: UILabel!
    
    var email: String?
    var fullName: String?
    var userId: String?
    
    let db = Firestore.firestore()
    var fireStoreInstance = FirestoreServices()
    var odoClientNew = OdooClientNew()
    
    let googleSignIn = GoogleSignIn()
    var googleUser = GIDGoogleUser()
    
    var isOpenAccount  = Bool()
    var isGoogleAccount =  Bool()
    var isAppleLogin = Bool()
    var account:  [AccountModel] = []
    let passwordManager = PasswordManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.password_tf.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
        
        odoClientNew.createLeadDelegate = self
        odoClientNew.createUserAcctDelegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGesture)
        
        isOpenAccount =  UserDefaults.standard.bool(forKey: "fromOpenAccount")
        isGoogleAccount =  UserDefaults.standard.bool(forKey: "isGoogleLogin")
        isAppleLogin =  UserDefaults.standard.bool(forKey: "isAppleLogin")
      
        self.userId = UserDefaults.standard.string(forKey: "userID")
        self.fullName = UserDefaults.standard.string(forKey: "FullName")
        
        let randomPassword = passwordManager.generateRandomPassword(length: 8) // Adjust the length as needed
        print("Generated Password: \(randomPassword)")
        password_tf.text = randomPassword
        passwordDidChange(password_tf)
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func passwordDidChange(_ textField: UITextField) {

        validatePassword(password: textField.text ?? "")
    }
    
    func validatePassword(password: String) {
        // Condition 1: Length between 8 and 15 characters
        if password.count >= 8 && password.count <= 15 {
            lbl_firstCondition.textColor = .green
        } else {
            lbl_firstCondition.textColor = .red
        }
        
        // Condition 2: At least one uppercase and one lowercase letter
        let uppercaseLetter = CharacterSet.uppercaseLetters
        let lowercaseLetter = CharacterSet.lowercaseLetters
        let hasUppercase = password.rangeOfCharacter(from: uppercaseLetter) != nil
        let hasLowercase = password.rangeOfCharacter(from: lowercaseLetter) != nil
        
        if hasUppercase && hasLowercase {
            lbl_secondCondition.textColor = .green
        } else {
            lbl_secondCondition.textColor = .red
            
        }
        
        // Condition 3: At least one number and one special character
        let numbers = CharacterSet.decimalDigits
        let specialCharacters = CharacterSet.punctuationCharacters.union(.symbols)
        let hasNumber = password.rangeOfCharacter(from: numbers) != nil
        let hasSpecial = password.rangeOfCharacter(from: specialCharacters) != nil
        
        if hasNumber {
            lbl_thirdCondition.textColor = .green
        } else {
            lbl_thirdCondition.textColor = .red
        }
        
        if hasSpecial {
            lbl_forthCondition.textColor = .green
        } else {
            lbl_forthCondition.textColor = .red
            
        }
    }
    
    @IBAction func passwordIconAction(_ sender: Any) {
        self.password_tf.isSecureTextEntry = !self.password_tf.isSecureTextEntry
        self.btn_passowrdIcon.setImage(!self.password_tf.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash"), for: .normal)
    }

    @IBAction func continueAction(_ sender: Any) {
        guard let password = password_tf.text, !password.isEmpty else {
            return
        }
        
        if isOpenAccount {
            openAccountSignUp()
            print("userID on email : \(userId ?? "")")
        }else if isGoogleAccount{
//            userId =  GlobalVariable.instance.userID
            print("userID on google : \(userId ?? "")")
//            SignUpGoogle()
            
        }else if isAppleLogin {
            print("userID on Apple : \(userId ?? "")")
//            signUpApple()
        }
       
    }
    
    private func openAccountSignUp() {
        db.collection("users").whereField("email", isEqualTo: email!).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error checking for existing user: \(error.localizedDescription)")
            }
            
            if let snapshot = querySnapshot, !snapshot.isEmpty {
                print("User with this email already exists.")
                Alert.showAlert(withMessage: "User with this email already exists.", andTitle: "", OKButtonText: "Ok", on: self)
                return
            } else {
                UserDefaults.standard.set((self.password_tf.text ?? ""), forKey: "password")
                //if user is not exist then Use Firebase Authentication to create a new user
                Auth.auth().createUser(withEmail: self.email ?? "", password: self.password_tf.text ?? "") { [weak self] authResult, error in
                    if let error = error as NSError? {
                        if let authError = AuthErrorCode.Code(rawValue: error.code){
                            switch authError {
                            case .emailAlreadyInUse:
                                Alert.showAlert(withMessage: "User with this email already exists.", andTitle: "", OKButtonText: "Ok", on: self)
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
                        
                        self?.userId = UserDefaults.standard.string(forKey: "userID")
                        
                        self?.odoClientNew.createRecords(firebase_uid: user.uid, email: self?.email ?? "", name: self?.fullName ?? "")
                        
                        self?.fireStoreInstance.saveAdditionalUserData(userId: user.uid, kyc: "Not Started", address: "", dateOfBirth: "", profileStep: 0, name: self?.fullName ?? "", gender: "", phone: "", email: self?.email ?? "", emailVerified: false, phoneVerified: false, isLogin: false, pushedToCRM: false, nationality: GlobalVariable.instance.nationality, residence: GlobalVariable.instance.residence, password: self?.password_tf.text ?? "", registrationType: 1)
//                        self?.odoClientNew.writeRecords(number: "", firebaseToken: GlobalVariable.instance.firebaseNotificationToken)
                    }
                }
            }
        }
    }
    
//    func signUpApple() {
        
//        updateUserPassword(self.password_tf.text ?? "")
//    }
    
//    func SignUpGoogle() {
      
//        self.googleSignIn.authenticateWithFirebase(user: googleUser)
//        updateUserPassword(self.password_tf.text ?? "")
 
//    }
    // Function to update the user's password in Firebase
//    func updateUserPassword(_ password: String) {
//        guard let user = Auth.auth().currentUser else { return }
//        print("Current user is: \(user.email ?? "nothing to show")")
//        
//        user.updatePassword(to: password) { error in
//            if let error = error {
//                print("Failed to update password: \(error.localizedDescription)")
//            } else {
//                print("Password updated successfully.")
//                UserDefaults.standard.set((self.password_tf.text ?? ""), forKey: "password")
//                
//                if self.isAppleLogin {
//                    self.fireStoreInstance.saveAdditionalUserData(userId: user.uid, kyc: "Not Started", address: "", dateOfBirth: "", profileStep: 0, name: self.fullName ?? "", gender: "", phone: "", email: user.email ?? "", emailVerified: true, phoneVerified: false, isLogin: false, pushedToCRM: false, nationality: GlobalVariable.instance.nationality, residence: GlobalVariable.instance.residence, password: self.password_tf.text ?? "", registrationType: 3)
//                }else{
//                    self.fireStoreInstance.saveAdditionalUserData(userId: user.uid, kyc: "Not Started", address: "", dateOfBirth: "", profileStep: 0, name: self.fullName ?? "", gender: "", phone: "", email: user.email ?? "", emailVerified: true, phoneVerified: false, isLogin: false, pushedToCRM: false, nationality: GlobalVariable.instance.nationality, residence: GlobalVariable.instance.residence, password: self.password_tf.text ?? "", registrationType: 2)
//                }
//                
//                self.odoClientNew.createAccount(phone: "", group: "demo\\RP\\PRO", email: user.email ?? "", currency: "USD", leverage: 400, first_name: self.fullName ?? "", last_name: "", password: (self.password_tf.text ?? ""), is_demo: true)
//                
//               }
//        }
//    }

       func updateUserAccount(){
           
           var fieldsToUpdate: [String:Any] = [
               "KycStatus": "Not Started",
               "name" : self.fullName ?? "",
               "currency": "USD",
               "userID" : userId ?? "",
               "groupID": "RWHwgycWkAqi5OPvv1oX",
               "isDefault" : true,
               "isReal": false,
               "groupName" : "PRO",
               "accountNumber" : GlobalVariable.instance.loginID // loginID in createAccount response
           ]
          
           print("updating user Accounts fields are: \(fieldsToUpdate)")
          
           fireStoreInstance.updateUserAccountsFields(fields: fieldsToUpdate, completion: { error in
                      if let error = error {
                          print("Error updating UserAccounts fields: \(error.localizedDescription)")
                          return
                      } else {
                          print("(byDefault) User Accounts fields updated successfully!")
                          self.fireStoreInstance.updateDefaultAccount(for: "\(GlobalVariable.instance.loginID)", userId: self.userId ?? ""){ [weak self] error in
                              guard let self = self else { return }
                              
                              if let error = error {
                                  print("Error updating default account: \(error.localizedDescription)")
                                  return
                              }
                              print("\n updating isDefault account success: ")
   //                           self.fireStoreInstance.fetchUserAccountsData(userId: self.userId)
                              
                              let passwordManager = PasswordManager()
                              if passwordManager.savePassword(for: String(GlobalVariable.instance.loginID), password: password_tf.text ?? "") {
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
    
    func navigateFaceID(){
        let faceIdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PasscodeFaceIDVC") as! PasscodeFaceIDVC
        faceIdVC.afterLoginNavigation = false
        self.navigate(to: faceIdVC)
    }
  
}

extension PasswordVC:  CreateLeadOdooDelegate {
    func leadCreatSuccess(response: Any) {
        print("this is success response from create Lead :\(response)")
        self.odoClientNew.writeFirebaseToken(firebaseToken: GlobalVariable.instance.firebaseNotificationToken)
       
        odoClientNew.createAccount(phone: "", group: "demo\\RP\\PRO", email: email ?? "", currency: "USD", leverage: 400, first_name: fullName ?? "", last_name: "", password: (self.password_tf.text ?? ""), is_demo: true)
        
        
    }
    
    func leadCreatFailure(error: any Error) {
        print("this is error response:\(error)")
        ActivityIndicator.shared.hide(from: self.view)
    }
  
   }


extension PasswordVC : CreateUserAccountTypeDelegate {
       func createAccountSuccess(response: Any) {
           print("\nthis is create user success response from Password Screen: \(response)")
           // get loginId from the response
           updateUserAccount()
   
       }
       
       func createAccountFailure(error: any Error) {
           print("\n this is create user error response: \(error)")
           showTimeAlert(str: "Account Create Failed.")
       }
   }

