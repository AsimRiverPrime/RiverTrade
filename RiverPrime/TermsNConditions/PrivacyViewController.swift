//
//  PrivacyViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 09/07/2024.
//

import UIKit

class PrivacyViewController: BaseViewController {

    @IBOutlet weak var lbl_policyText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setGradientBackground()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: SignInViewController(), navController: self.navigationController, title: "Privacy Policy", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }

}
