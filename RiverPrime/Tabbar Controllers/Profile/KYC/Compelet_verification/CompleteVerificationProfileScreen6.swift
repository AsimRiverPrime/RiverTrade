//
//  CompleteVerificationProfileScreen6.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/09/2024.
//

import UIKit

class CompleteVerificationProfileScreen6: BaseViewController {
    
    @IBOutlet weak var lbl_tradeObj: UILabel!
    
    @IBOutlet var lbl_switchValue: [UILabel]!
    
    @IBOutlet var selectionSwitch: [UISwitch]!
    
    
    @IBOutlet weak var btn_submit: UIButton!
    @IBOutlet weak var btn_back: UIButton!
    var selectedPurpose: [String: [String]] = [:]
    
    let fireStoreInstance = FirestoreServices()
//    weak var delegateKYC: KYCVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_tradeObj.text = "What is the purpose of opening your account?"
        // Do any additional setup after loading the view.
        for switchControl in selectionSwitch {
            switchControl.isOn = false
            switchControl.thumbTintColor = .systemGray2 // Initial thumb color for off state
        }
       

//        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNavBar(vc: self, isBackButton: true, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: CompleteVerificationProfileScreen5(), navController: self.navigationController, title: "Questionnaire", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
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
    }
    
    @IBAction func backBtn_action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateUser() {
//        let userId =  UserDefaults.standard.string(forKey: "userID")
        let profileStep = UserDefaults.standard.integer(forKey: "profileStepCompeleted")
       
        guard let userId =  UserDefaults.standard.string(forKey: "userID") else {
                    print("userId is nil in completeVerfication6_Screen")
                    return
                }
        
        let fieldsToUpdate: [String: Any] = [
                "profileStep": profileStep
             ]
        
        fireStoreInstance.updateUserFields(userID: userId, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                print("\n User data save successfully in the fireBase")
                self.fireStoreInstance.fetchUserData(userId: userId)
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
                 
                print("Document Added to USER_ACCOUNTs collection Successfully!")
                self.updateUser()
                self.navigateToNextKYC()

            case .failure(let error):
                print("Error adding/updating document: \(error)")
                self.ToastMessage("\(error)")
            }
        }
    }
    
    func navigateToNextKYC() {
      
                    let vc = Utilities.shared.getViewController(identifier: .kycViewController, storyboardType: .dashboard) as! KYCViewController
                    self.navigate(to: vc)
            }
    
}
