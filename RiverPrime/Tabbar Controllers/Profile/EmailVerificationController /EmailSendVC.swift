//
//  EmailSendVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 13/01/2025.
//

import UIKit

class EmailSendVC: UIViewController {

    @IBOutlet weak var lbl_emailSend: UILabel!
    
    var UserEmail: String?
    var odoClientNew = OdooClientNew()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lbl_emailSend.text = "We will send you verification code to your email " + (UserEmail ?? "")
        GlobalVariable.instance.userEmail = UserEmail ?? ""
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func sendCode_action(_ sender: Any) {
        odoClientNew.sendOTP(type: "email", email: UserEmail ?? "", phone: "")
       
//        Alert.showAlertWithOKHandler(withHandler: "Check email inbox or spam for OTP", andTitle: "", OKButtonText: "OK", on: self) { _ in
//
//        }
        
        self.navigateToVerifiyScreen()
    }
    
    func navigateToVerifiyScreen() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let verifyVC = storyboard.instantiateViewController(withIdentifier: "VerifyCodeViewController") as! VerifyCodeViewController
        
        verifyVC.isEmailVerification = true
        verifyVC.isPhoneVerification = false
        self.navigate(to: verifyVC)
    }
    
    @IBAction func close_action(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
