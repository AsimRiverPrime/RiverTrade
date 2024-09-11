//
//  CompleteVerificationProfileScreen5.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/09/2024.
//

import UIKit

class CompleteVerificationProfileScreen5: BottomSheetController {
    
    @IBOutlet weak var lbl_tradeObj: UILabel!
    
    @IBOutlet var lbl_switchValue: [UILabel]!
    
    @IBOutlet var selectionSwitch: [UISwitch]!
    
    var selectedExperience: [String: [String]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_tradeObj.text = "What is your trading experience with a real money?"
        // Do any additional setup after loading the view.
        for switchControl in selectionSwitch {
            switchControl.isOn = false
            switchControl.thumbTintColor = .systemGray4 // Initial thumb color for off state
        }
        //        selectedObjective = [:]
    }
    @IBAction func switch_action(_ sender: UISwitch) {
        guard let question = lbl_tradeObj.text else { return }
        
        // Ensure the dictionary has the question key initialized with an empty array
        if selectedExperience[question] == nil {
            selectedExperience[question] = []
        }
        
        // Iterate through all switches
        for (index, switchControl) in selectionSwitch.enumerated() {
            let labelValue = lbl_switchValue[index].text ?? ""
            
            if switchControl == sender {
                // Handle the current switch that was toggled
                if sender.isOn {
                    // Add the label for the selected switch
                    selectedExperience[question] = [labelValue] // Only one label allowed at a time
                } else {
                    // Remove the label if the switch is turned off
                    selectedExperience[question]?.removeAll()
                }
                // Update the thumb color for the current switch
                switchControl.thumbTintColor = sender.isOn ? .systemYellow : .systemGray4
            } else {
                // Turn off all other switches
                switchControl.setOn(false, animated: true)
                switchControl.thumbTintColor = .systemGray4 // Ensure other switches have the off color
            }
        }
        
        // Debugging or further usage
        print(selectedExperience)
    }
    
    
    
    @IBAction func submitBtn_action(_ sender: Any) {
        UserDefaults.standard.set(selectedExperience, forKey: "SelectedTradeExprience")
        
        let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen6, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen6
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        // self.dismiss(animated: true)
    }
    
    @IBAction func backBtn_action(_ sender: Any) {
        
        //        if let profileVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "ProfileVC"){
        //        self.navigate(to: profileVC)
        //        }
        self.dismiss(animated: true)
    }
    
    @IBAction func closeBtn_action(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
