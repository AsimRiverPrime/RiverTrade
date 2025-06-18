//
//  CompleteVerificationProfileScreen2.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/09/2024.
//

import UIKit

class CompleteVerificationProfileScreen2: BaseViewController {

    
    @IBOutlet var lbl_switchValues: [UILabel]!
 
    @IBOutlet weak var lbl_tradeInstrument: UILabel!
    @IBOutlet var selectedSwitch: [UISwitch]!
   
    
    @IBOutlet weak var btn_submit: UIButton!
    @IBOutlet weak var btn_back: UIButton!
    
    var selectedInstrument: [String: [String]] = [:]

    weak var delegateKYC: KYCVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lbl_tradeInstrument.text = "What trading instruments do you plan to use?"

        for switchControl in selectedSwitch {
               switchControl.isOn = false
               switchControl.thumbTintColor = .systemGray2 // Initial thumb color for off state
           }
  
//        self.navigationController?.navigationBar.isHidden = true

    }
    override func viewWillAppear(_ animated: Bool) {
        self.setNavBar(vc: self, isBackButton: true, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: CompleteVerificationProfileScreen1(), navController: self.navigationController, title: "Questionnaire", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    
    @IBAction func switch_action(_ sender: UISwitch) {
     guard let question = lbl_tradeInstrument.text else { return }
        
        // Ensure the dictionary has the question key initialized with an empty array
        if selectedInstrument[question] == nil {
            selectedInstrument[question] = []
        }
    //
        for (index, switchControl) in selectedSwitch.enumerated() {
            let labelValue = lbl_switchValues[index].text ?? ""
            
            if switchControl == sender {
                if sender.isOn {
                    // Add the selected label if it's toggled on
                    if !selectedInstrument[question]!.contains(labelValue) {
                        selectedInstrument[question]?.append(labelValue)
                    }
                } else {
                    // Remove the label if the switch is toggled off
                    if let indexToRemove = selectedInstrument[question]?.firstIndex(of: labelValue) {
                        selectedInstrument[question]?.remove(at: indexToRemove)
                    }
                }
                
                // Change the thumb color when the switch is turned on or off
                switchControl.thumbTintColor = sender.isOn ? .systemYellow : .systemGray2
                
            }
        }
     
        // Debugging or further usage
        print(selectedInstrument)
    }
    
    @IBAction func continueBtn_action(_ sender: Any) {
        UserDefaults.standard.set(selectedInstrument, forKey: "SelectedTradeInstruments")
//        self.dismiss(animated: true)
//        delegateKYC?.navigateToCompeletProfile(kyc: .ThirdScreen)
        
        
        if GlobalVariable.instance.realAccount {
            let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen3, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen3
    //        vc.delegateKYC = self
            self.navigate(to: vc)
        } else {
            self.dismiss(animated: true)
            delegateKYC?.navigateToCompeletProfile(kyc: .ThirdScreen)
        }
        
    }
    
    @IBAction func backBtn_action(_ sender: Any) {
//        self.dismiss(animated: true)
//        delegateKYC?.navigateToCompeletProfile(kyc: .FirstScreen)
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
