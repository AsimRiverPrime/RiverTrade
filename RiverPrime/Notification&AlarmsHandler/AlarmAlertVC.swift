//
//  AlarmAlertVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 07/02/2025.
//

import UIKit

class AlarmAlertVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: TradeViewController(), navController: self.navigationController, title: "Alerts", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    @IBAction func closeBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            print("Bottom sheet dismissed after cross btn click")
        })
    }

}
