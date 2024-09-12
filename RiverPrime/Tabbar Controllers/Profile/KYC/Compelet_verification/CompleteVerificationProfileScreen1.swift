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
    
    var selectedObjective: [String: [String]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_tradeObj.text = "What is your trading objective?"
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
                switchControl.thumbTintColor = sender.isOn ? .systemYellow : .systemGray4
            } else {
                // Turn off all other switches
                switchControl.setOn(false, animated: true)
                switchControl.thumbTintColor = .systemGray4 // Ensure other switches have the off color
            }
        }

        // Debugging or further usage
        print(selectedObjective)
    }

    
    
    @IBAction func submitBtn_action(_ sender: Any) {
        UserDefaults.standard.set(selectedObjective, forKey: "SelectedTradeObjective")
        self.dismiss(animated: true)
        let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen2, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen2
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
       
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
    
    
    // Retrieve the saved dictionary from UserDefaults
//       if let savedObjective = UserDefaults.standard.dictionary(forKey: "SelectedObjective") as? [String: [String]] {
//           selectedObjective = savedObjective
//           
//           // Optionally, restore the UI based on the saved values
//           if let question = questionLabel.text {
//               if let selectedLabels = selectedObjective[question] {
//                   for (index, label) in labels.enumerated() {
//                       if selectedLabels.contains(label.text ?? "") {
//                           selectionSwitch[index].isOn = true
//                           selectionSwitch[index].thumbTintColor = .gray // Restore the on state color
//                       }
//                   }
//               }
//           }
//       } else {
//           selectedObjective = [:] // Initialize if no data exists
//       }
}

/*  @IBAction func switch_action(_ sender: UISwitch) {
 guard let question = lbl_tradeObj.text else { return }
    
    // Ensure the dictionary has the question key initialized with an empty array
    if selectedObjective[question] == nil {
        selectedObjective[question] = []
    }
//
    for (index, switchControl) in selectionSwitch.enumerated() {
        let labelValue = lbl_switchValue[index].text ?? ""
        
        if switchControl == sender {
            if sender.isOn {
                // Add the selected label if it's toggled on
                if !selectedObjective[question]!.contains(labelValue) {
                    selectedObjective[question]?.append(labelValue)
                }
            } else {
                // Remove the label if the switch is toggled off
                if let indexToRemove = selectedObjective[question]?.firstIndex(of: labelValue) {
                    selectedObjective[question]?.remove(at: indexToRemove)
                }
            }
            
            // Change the thumb color when the switch is turned on or off
            switchControl.thumbTintColor = sender.isOn ? .systemYellow : .systemGray4
            
        }
    }
 
    // Debugging or further usage
    print(selectedObjective)
}*/
