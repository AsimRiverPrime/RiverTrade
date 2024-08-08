//
//  ViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//

import UIKit


class ViewController: BaseViewController {

    @IBOutlet weak var titlelbl: UILabel!
    @IBOutlet weak var companyTitlelbl: UILabel!
    @IBOutlet weak var registerNowBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styling()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
    }
    
    @IBAction func registerBtn(_ sender: Any) {
//        if let signUp = instantiateViewController(fromStoryboard: "Main", withIdentifier: "SignUpViewController"){
//            self.navigate(to: signUp)
//        }
        if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DashboardVC"){
            self.navigate(to: vc)
        }
    }
}

extension ViewController {
    
    private func styling() {
        //MARK: - Fonts
        titlelbl.font = FontController.Fonts.Inter_Regular.font
        companyTitlelbl.font = FontController.Fonts.Inter_Medium.font
        registerNowBtn.titleLabel?.font = FontController.Fonts.Inter_SemiBold.font
        
        //MARK: - Labels
        titlelbl.text = LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.WelcomeScreen.Title.localized)
        companyTitlelbl.text = LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.WelcomeScreen.CompanyNameLabel.localized)
        registerNowBtn.setTitle(LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.WelcomeScreen.RegisterNowButton.localized), for: .normal)
    }
    
}
