//
//  RiskViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 15/05/2025.
//

import UIKit

class RiskViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: SignInViewController(), navController: self.navigationController, title: "Risk Disclosure", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    
}
