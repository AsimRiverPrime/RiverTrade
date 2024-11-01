//
//  CompleteVerificationProfileScreen2.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/09/2024.
//

import UIKit

class CompleteVerificationProfileScreen2: BottomSheetController {

    
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
               switchControl.thumbTintColor = .systemGray4 // Initial thumb color for off state
           }
        btn_back.buttonStyle()
        btn_back.layer.cornerRadius = 15.0
        btn_submit.buttonStyle()
        btn_submit.layer.cornerRadius = 15.0
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
                switchControl.thumbTintColor = sender.isOn ? .systemYellow : .systemGray4
                
            }
        }
     
        // Debugging or further usage
        print(selectedInstrument)
    }
    
    @IBAction func continueBtn_action(_ sender: Any) {
        UserDefaults.standard.set(selectedInstrument, forKey: "SelectedTradeInstruments")
        self.dismiss(animated: true)
        delegateKYC?.navigateToCompeletProfile(kyc: .ThirdScreen)
        
    }
    
    @IBAction func backBtn_action(_ sender: Any) {
        self.dismiss(animated: true)
        delegateKYC?.navigateToCompeletProfile(kyc: .FirstScreen)
    }
    
    @IBAction func closeBtn_action(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
