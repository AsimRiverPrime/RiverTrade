//
//  CompleteVerificationProfileScreen4.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/09/2024.
//

import UIKit

class CompleteVerificationProfileScreen4: BottomSheetController {
   
    @IBOutlet var lbl_switchValue: [UILabel]!
    @IBOutlet weak var lbl_tradeInstrument: UILabel!
    @IBOutlet var selectedSwitch: [UISwitch]!
    var selectedIncome: [String: [String]] = [:]

    weak var delegateKYC: KYCVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lbl_tradeInstrument.text = "Please select your source of income and wealth?"

        for switchControl in selectedSwitch {
               switchControl.isOn = false
               switchControl.thumbTintColor = .systemGray4 // Initial thumb color for off state
           }
        
    }
    
    @IBAction func switch_action(_ sender: UISwitch) {
     guard let question = lbl_tradeInstrument.text else { return }
        
        // Ensure the dictionary has the question key initialized with an empty array
        if selectedIncome[question] == nil {
            selectedIncome[question] = []
        }
    //
        for (index, switchControl) in selectedSwitch.enumerated() {
            let labelValue = lbl_switchValue[index].text ?? ""
            
            if switchControl == sender {
                if sender.isOn {
                    // Add the selected label if it's toggled on
                    if !selectedIncome[question]!.contains(labelValue) {
                        selectedIncome[question]?.append(labelValue)
                    }
                } else {
                    // Remove the label if the switch is toggled off
                    if let indexToRemove = selectedIncome[question]?.firstIndex(of: labelValue) {
                        selectedIncome[question]?.remove(at: indexToRemove)
                    }
                }
                
                // Change the thumb color when the switch is turned on or off
                switchControl.thumbTintColor = sender.isOn ? .systemYellow : .systemGray4
                
            }
        }
     
        // Debugging or further usage
        print(selectedIncome)
    }
    
    @IBAction func continueBtn_action(_ sender: Any) {
        UserDefaults.standard.set(selectedIncome, forKey: "SelectedTradeSourceIncome")
        
        self.dismiss(animated: true)
        delegateKYC?.navigateToCompeletProfile(kyc: .FifthScreen)
        
    }
    
    @IBAction func backBtn_action(_ sender: Any) {
        self.dismiss(animated: true)
        delegateKYC?.navigateToCompeletProfile(kyc: .ThirdScreen)
    }
    
    @IBAction func closeBtn_action(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
