//
//  ForgotViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//

import UIKit

class ForgotViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    @IBAction func continue_btn(_ sender: Any) {
        if let verifyVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "VerifyCodeViewController"){
            self.navigate(to: verifyVC)
        }
    }
    
    @IBAction func backLoginBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true) 
    }
    
}
