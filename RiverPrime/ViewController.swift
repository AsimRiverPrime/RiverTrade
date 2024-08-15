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
    
    @IBAction func registerBtn(_ sender: Any) {
        if let signUp = instantiateViewController(fromStoryboard: "Main", withIdentifier: "SignUpViewController"){
            self.navigate(to: signUp)
        }
//        if let vc = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "DashboardVC"){
//            self.navigate(to: vc)
//        }
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
