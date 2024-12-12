//
//  TopNewsDetailVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/12/2024.
//

import UIKit

class TopNewsDetailVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: MarketsViewController(), navController: self.navigationController, title: "", leftTitle: "", rightTitle: "", textColor: .darkGray, barColor: .clear)
    }
   

}
