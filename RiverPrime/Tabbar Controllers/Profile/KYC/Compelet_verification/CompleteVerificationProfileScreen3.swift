//
//  CompleteVerificationProfileScreen3.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/09/2024.
//

import UIKit

class CompleteVerificationProfileScreen3: BaseViewController {
    
    @IBOutlet weak var lbl_tradeObj: UILabel!
    
    @IBOutlet var lbl_switchValue: [UILabel]!
    
    @IBOutlet var selectionSwitch: [UISwitch]!
    
    
    @IBOutlet weak var btn_submit: UIButton!
    @IBOutlet weak var btn_back: UIButton!
    
    var selectedAnticipated: [String: [String]] = [:]
    weak var delegateKYC: KYCVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_tradeObj.text = "What is your anticipated monthly income are you plan to invest?"
        // Do any additional setup after loading the view.
        for switchControl in selectionSwitch {
            switchControl.isOn = false
            switchControl.thumbTintColor = .systemGray2 // Initial thumb color for off state
        }
       
//        self.navigationController?.navigationBar.isHidden = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNavBar(vc: self, isBackButton: true, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: CompleteVerificationProfileScreen2(), navController: self.navigationController, title: "Questionnaire", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    
    @IBAction func switch_action(_ sender: UISwitch) {
        guard let question = lbl_tradeObj.text else { return }
        
        // Ensure the dictionary has the question key initialized with an empty array
        if selectedAnticipated[question] == nil {
            selectedAnticipated[question] = []
        }
        
        // Iterate through all switches
        for (index, switchControl) in selectionSwitch.enumerated() {
            let labelValue = lbl_switchValue[index].text ?? ""
            
            if switchControl == sender {
                // Handle the current switch that was toggled
                if sender.isOn {
                    // Add the label for the selected switch
                    selectedAnticipated[question] = [labelValue] // Only one label allowed at a time
                } else {
                    // Remove the label if the switch is turned off
                    selectedAnticipated[question]?.removeAll()
                }
                // Update the thumb color for the current switch
                switchControl.thumbTintColor = sender.isOn ? .systemYellow : .systemGray2
            } else {
                // Turn off all other switches
                switchControl.setOn(false, animated: true)
                switchControl.thumbTintColor = .systemGray2 // Ensure other switches have the off color
            }
        }
        
        // Debugging or further usage
        print(selectedAnticipated)
    }
    
    
    
    @IBAction func submitBtn_action(_ sender: Any) {
        UserDefaults.standard.set(selectedAnticipated, forKey: "SelectedTradeAnticipateMonthly")
        
//        self.dismiss(animated: true)
////       delegateKYC?.navigateToCompeletProfile(kyc: .FourthScreen)
//        let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen4, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen4
////        vc.delegateKYC = self
//        self.navigate(to: vc)
        
        if GlobalVariable.instance.realAccount {
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen4, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen4
    //        vc.delegateKYC = self
            self.navigate(to: vc)
        } else {
            self.dismiss(animated: true)
            delegateKYC?.navigateToCompeletProfile(kyc: .FourthScreen)
        }
        
    }
    
    @IBAction func backBtn_action(_ sender: Any) {
//        self.dismiss(animated: true)
//        delegateKYC?.navigateToCompeletProfile(kyc: .SecondScreen)
        self.navigationController?.popViewController(animated: true)

    }
    
    @IBAction func closeBtn_action(_ sender: Any) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "HomeTabbarViewController") as! UITabBarController
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }
}
