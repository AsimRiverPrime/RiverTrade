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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.password_tf.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
        
        odoClientNew.createLeadDelegate = self
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGesture)
        
        isOpenAccount =  UserDefaults.standard.bool(forKey: "fromOpenAccount")
        isGoogleAccount =  UserDefaults.standard.bool(forKey: "isGoogleLogin")
        isAppleLogin =  UserDefaults.standard.bool(forKey: "isAppleLogin")
        
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
        }else if isGoogleAccount{
            SignUpGoogle()
            
        }else if isAppleLogin {
            
            signUpApple()
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
                        
                        self?.userId =  UserDefaults.standard.string(forKey: "userID")
                        
                        self?.odoClientNew.createRecords(firebase_uid: user.uid, email: self?.email ?? "", name: self?.fullName ?? "")
                        
                        self?.fireStoreInstance.saveAdditionalUserData(userId: user.uid, kyc: "Not Started", address: "", dateOfBirth: "", profileStep: 0, name: self?.fullName ?? "", gender: "", phone: "", email: self?.email ?? "", emailVerified: false, phoneVerified: false, isLogin: false, pushedToCRM: false, nationality: GlobalVariable.instance.nationality, residence: GlobalVariable.instance.residence, registrationType: 1)
                        self?.odoClientNew.writeRecords(number: "", firebaseToken: GlobalVariable.instance.firebaseNotificationToken)
                    }
                }
            }
        }
    }
    
    func signUpApple() {
        updateUserPassword(self.password_tf.text ?? "")
    }
    
    func SignUpGoogle() {
      
//        self.googleSignIn.authenticateWithFirebase(user: googleUser)
        updateUserPassword(self.password_tf.text ?? "")
 
    }
    // Function to update the user's password in Firebase
    func updateUserPassword(_ password: String) {
        guard let user = Auth.auth().currentUser else { return }
        print("Current user is: \(user.email ?? "nothing to show")")
        
        user.updatePassword(to: password) { error in
            if let error = error {
                print("Failed to update password: \(error.localizedDescription)")
            } else {
                print("Password updated successfully.")
                self.navigateFaceID()
            }
        }
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
        self.odoClientNew.writeRecords(number: "", firebaseToken: GlobalVariable.instance.firebaseNotificationToken)
        
//        odoClientNew.sendOTP(type: "email", email: email ?? "", phone: "")
        
//        Alert.showAlertWithOKHandler(withHandler: "Check email inbox or spam for OTP", andTitle: "", OKButtonText: "OK", on: self) { _ in
//
//        }
        self.navigateFaceID()
    }
    
    func leadCreatFailure(error: any Error) {
        print("this is error response:\(error)")
        ActivityIndicator.shared.hide(from: self.view)
    }
}
