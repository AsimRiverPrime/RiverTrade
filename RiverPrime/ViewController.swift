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


class ViewController: BaseViewController {
    
    @IBOutlet weak var titlelbl: UILabel!
    @IBOutlet weak var companyTitlelbl: UILabel!
    @IBOutlet weak var registerNowBtn: UIButton!
    
    let vm = ViewControllerVM()
    let googleSignIn = GoogleSignIn()
    var odoClientNew = OdooClientNew()
    
//    var player: AVPlayer?
   
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
        if let residencyVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "NationalityVC")
        {
            self.navigate(to: residencyVC)
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
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nationalityVC = storyboard.instantiateViewController(withIdentifier: "NationalityVC") as! NationalityVC
            self?.navigate(to: nationalityVC)
            
//            self?.googleSignIn.odoClientNew.createLeadDelegate = self
//            self?.googleSignIn.authenticateWithFirebase(user: user1)
            
        }
    }
    
    @IBAction func tryDemo_btnAction(_ sender: Any) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
           let request = appleIDProvider.createRequest()
           request.requestedScopes = [.fullName, .email]  // Request necessary user info

           let authorizationController = ASAuthorizationController(authorizationRequests: [request])
           authorizationController.delegate = self
           authorizationController.presentationContextProvider = self
           authorizationController.performRequests()
        
    }
}

extension ViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email

            // Store userIdentifier securely in Keychain or your secure storage
            print("User ID: \(userIdentifier)")
            print("Full Name: \(String(describing: fullName))")
            print("Email: \(String(describing: email))")
            GlobalVariable.instance.userEmail = email ?? ""
            UserDefaults.standard.set(fullName, forKey: "FullName")
            // Proceed with user registration or login
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nationalityVC = storyboard.instantiateViewController(withIdentifier: "NationalityVC") as! NationalityVC
            self.navigate(to: nationalityVC)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple error: \(error.localizedDescription)")
    }
}

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
    
    func navigateToVerifiyScreen() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let verifyVC = storyboard.instantiateViewController(withIdentifier: "VerifyCodeViewController") as! VerifyCodeViewController
        //        verifyVC.userEmail = self.email_tf.text ?? ""
//        GlobalVariable.instance.userEmail = self.emailUser ?? ""
        verifyVC.isEmailVerification = true
        verifyVC.isPhoneVerification = false
        self.navigate(to: verifyVC)
    }
}

extension ViewController:  CreateLeadOdooDelegate {
    func leadCreatSuccess(response: Any) {
        print("this is success response from create Lead :\(response)")
         
        odoClientNew.sendOTP(type: "email", email: GlobalVariable.instance.userEmail, phone: "")
        
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

