//
//  CompleteVerificationProfileScreen1.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/09/2024.
//

import UIKit

class CompleteVerificationProfileScreen1: BottomSheetController {
    
    @IBOutlet weak var lbl_tradeObj: UILabel!
    
    @IBOutlet var lbl_switchValue: [UILabel]!
    
    @IBOutlet var selectionSwitch: [UISwitch]!
    
    @IBOutlet weak var btn_submit: UIButton!
    @IBOutlet weak var btn_back: UIButton!
    
    var selectedObjective: [String: [String]] = [:]
    
    weak var delegateKYC: KYCVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_tradeObj.text = "What is your trading objective?"
        // Do any additional setup after loading the view.
        for switchControl in selectionSwitch {
            switchControl.isOn = false
            switchControl.thumbTintColor = .systemGray2 // Initial thumb color for off state
        }
        //        selectedObjective = [:]
        self.navigationController?.navigationBar.isHidden = true

        
    }
    @IBAction func switch_action(_ sender: UISwitch) {
        guard let question = lbl_tradeObj.text else { return }
        
        // Ensure the dictionary has the question key initialized with an empty array
        if selectedObjective[question] == nil {
            selectedObjective[question] = []
        }
        
        // Iterate through all switches
        for (index, switchControl) in selectionSwitch.enumerated() {
            let labelValue = lbl_switchValue[index].text ?? ""
            
            if switchControl == sender {
                // Handle the current switch that was toggled
                if sender.isOn {
                    // Add the label for the selected switch
                    selectedObjective[question] = [labelValue] // Only one label allowed at a time
                } else {
                    // Remove the label if the switch is turned off
                    selectedObjective[question]?.removeAll()
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
        print(selectedObjective)
    }
    
    
    
    @IBAction func submitBtn_action(_ sender: Any) {
        UserDefaults.standard.set(selectedObjective, forKey: "SelectedTradeObjective")
        self.dismiss(animated: true)
        delegateKYC?.navigateToCompeletProfile(kyc: .SecondScreen)
        
    }
    
    @IBAction func backBtn_action(_ sender: Any) {
        self.dismiss(animated: true)
        delegateKYC?.navigateToCompeletProfile(kyc: .ProfileScreen)
    }
    
    @IBAction func closeBtn_action(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
    
