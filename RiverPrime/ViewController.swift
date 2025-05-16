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
        GlobalVariable.instance.guestAccount = false
        GlobalVariable.instance.realAccount = false
        if let nationalityVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "NationalityVC")
        {
   
            self.navigate(to: nationalityVC)
        }
    }
    
    @IBAction func signInBtn(_ sender: Any) {
        GlobalVariable.instance.guestAccount = false
        if let signInVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "SignInViewController"){
            self.navigate(to: signInVC)
        }
    }
    
    @IBAction func openRealAccountBtn(_ sender: Any) {
        GlobalVariable.instance.guestAccount = false
        GlobalVariable.instance.realAccount = true
        if let nationalityVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "NationalityVC")
        {
            self.navigate(to: nationalityVC)
        }
        
    }
    @IBAction func continueGuestBtn(_ sender: Any) {
        if let dashboardVC = self.instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "HomeTabbarViewController"){
            UserDefaults.standard.removeObject(forKey: "userData")
            UserDefaults.standard.removeObject(forKey:"defaultUserAccount")
            
            GlobalVariable.instance.realAccount = false
            GlobalVariable.instance.guestAccount = true
            self.navigate(to: dashboardVC)
        }
        
    }
    
    @IBAction func termsConditionAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TermsConditionsViewController") as! TermsConditionsViewController
    
        self.navigate(to: vc)
    }
    
    @IBAction func privacyPolicyAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PrivacyViewController") as! PrivacyViewController
    
        self.navigate(to: vc)
    }
    
    @IBAction func ExecutionAction(_ sender: Any) {
        
    }
    
    @IBAction func riskAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RiskViewController") as! RiskViewController
    
        self.navigate(to: vc)
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
    
        self.navigate(to: nationalityVC)
    }
    
    
    
    
}

extension ViewController:  CreateLeadOdooDelegate {
    func leadCreatSuccess(response: Any) {
        print("this is success response from create Lead and record ID is:\(response)")
        navigateToNationility()
       
    }
    
    func leadCreatFailure(error: any Error) {
        print("this is error response:\(error)")
        ActivityIndicator.shared.hide(from: self.view)
    }
}

