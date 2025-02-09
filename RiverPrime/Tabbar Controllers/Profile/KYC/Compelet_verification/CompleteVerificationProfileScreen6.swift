//
//  CompleteVerificationProfileScreen6.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/09/2024.
//

import UIKit

class CompleteVerificationProfileScreen6: BottomSheetController {
    
    @IBOutlet weak var lbl_tradeObj: UILabel!
    
    @IBOutlet var lbl_switchValue: [UILabel]!
    
    @IBOutlet var selectionSwitch: [UISwitch]!
    
    
    @IBOutlet weak var btn_submit: UIButton!
    @IBOutlet weak var btn_back: UIButton!
    var selectedPurpose: [String: [String]] = [:]
    
    let fireStoreInstance = FirestoreServices()
    weak var delegateKYC: KYCVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_tradeObj.text = "What is the purpose of opening your account?"
        // Do any additional setup after loading the view.
        for switchControl in selectionSwitch {
            switchControl.isOn = false
            switchControl.thumbTintColor = .systemGray2 // Initial thumb color for off state
        }
       

        self.navigationController?.navigationBar.isHidden = true

        
    }
    @IBAction func switch_action(_ sender: UISwitch) {
        guard let question = lbl_tradeObj.text else { return }
        
        // Ensure the dictionary has the question key initialized with an empty array
        if selectedPurpose[question] == nil {
            selectedPurpose[question] = []
        }
        
        // Iterate through all switches
        for (index, switchControl) in selectionSwitch.enumerated() {
            let labelValue = lbl_switchValue[index].text ?? ""
            
            if switchControl == sender {
                // Handle the current switch that was toggled
                if sender.isOn {
                    // Add the label for the selected switch
                    selectedPurpose[question] = [labelValue] // Only one label allowed at a time
                } else {
                    // Remove the label if the switch is turned off
                    selectedPurpose[question]?.removeAll()
                }
                // Update the thumb color for the current switch
                switchControl.thumbTintColor = sender.isOn ? .systemYellow : .systemGray2
            } else {
                // Turn off all other switches
                switchControl.setOn(false, animated: true)
                switchControl.thumbTintColor = .systemGray2 // Ensure other switches have the off color
            }
        }
        print(selectedPurpose)
    }
    
    
    
    @IBAction func submitBtn_action(_ sender: Any) {
       
        UserDefaults.standard.set(1, forKey: "profileStepCompeleted")
        UserDefaults.standard.set(selectedPurpose, forKey: "SelectedTradePurpose")
        
        AddUserAccountDetail()
        // self.dismiss(animated: true)
    }
    
    @IBAction func backBtn_action(_ sender: Any) {
        self.dismiss(animated: true)
        delegateKYC?.navigateToCompeletProfile(kyc: .FifthScreen)
    }
    
    @IBAction func closeBtn_action(_ sender: Any) {
        self.dismiss(animated: true)
    }
   
    
    func updateUser() {
        let userId =  UserDefaults.standard.string(forKey: "userID")
        let profileStep = UserDefaults.standard.integer(forKey: "profileStepCompeleted")
        
        var fieldsToUpdate: [String: Any] = [
                "profileStep": profileStep
             ]
        
        fireStoreInstance.updateUserFields(userID: userId!, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                print("\n User data save successfully in the fireBase")
            }
        }
    }
    
    func AddUserAccountDetail() {
        UserDefaults.standard.set(1, forKey: "profileStepCompeleted")
        
        let tradeObjective = UserDefaults.standard.dictionary(forKey: "SelectedTradeObjective") as? [String: [String]]
        let tradeInstruments = UserDefaults.standard.dictionary(forKey: "SelectedTradeInstruments") as? [String: [String]]
        let tradeAnticipateMonthly = UserDefaults.standard.dictionary(forKey: "SelectedTradeAnticipateMonthly") as? [String: [String]]
        let tradeSourceIncome = UserDefaults.standard.dictionary(forKey: "SelectedTradeSourceIncome") as? [String: [String]]
        let tradeExprience = UserDefaults.standard.dictionary(forKey: "SelectedTradeExprience") as? [String: [String]]
        let tradePurpose = UserDefaults.standard.dictionary(forKey: "SelectedTradePurpose") as? [String: [String]]
        
        let userId =  UserDefaults.standard.string(forKey: "userID")
        let profileStep = UserDefaults.standard.integer(forKey: "profileStepCompeleted")
        let overAllStatus = UserDefaults.standard.string(forKey: "OverAllStatus")
        let sid = UserDefaults.standard.string(forKey: "SID")
        
        var questionAnswer: [String: [String]] = [:]
        
        // Merge all individual dictionaries into questionAnswer
        questionAnswer.merge(tradeObjective!) { (current, _) in current }
        questionAnswer.merge(tradeInstruments!) { (current, _) in current }
        questionAnswer.merge(tradeAnticipateMonthly!) { (current, _) in current }
        questionAnswer.merge(tradeSourceIncome!) { (current, _) in current }
        questionAnswer.merge(tradeExprience!) { (current, _) in current }
        questionAnswer.merge(tradePurpose!) { (current, _) in current }
   //  print("\(questionAnswer)")
        
        let userData: [String: Any] = [
               "uid": userId ?? "",
               "userId": userId ?? "",
               "step": profileStep,
               "profileStep": profileStep,
               
               "questionAnswer": questionAnswer
           ]
       
        fireStoreInstance.addUserAccountData(uid: userId!, data: userData) {  [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                print("Document USER_ACCOUNT detail ADD successfully!")
                self.updateUser()
                self.navigateToDashboard()
//                Alert.showAlertWithOKHandler(withHandler: "Thank you for providing your details. A Customer Support representative will reach out to you shortly with further instructions and to complete your account activation.", andTitle: "Completed", OKButtonText: "Return to Dashboard", on: self) { ok in
//
//                }
               
                
            case .failure(let error):
                print("Error adding/updating document: \(error)")
                self.ToastMessage("\(error)")
            }
        }
    }
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
               
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    
    func navigateToDashboard() {
        self.dismiss(animated: true)
        delegateKYC?.navigateToCompeletProfile(kyc: .KycScreen)
    }
    
       
}
