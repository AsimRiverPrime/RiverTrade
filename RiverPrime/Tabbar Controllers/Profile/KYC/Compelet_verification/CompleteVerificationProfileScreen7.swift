//
//  CompleteVerificationProfileScreen1.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/09/2024.
//

import UIKit
import Firebase
import FirebaseFirestore


class CompleteVerificationProfileScreen7: BottomSheetController {
        
    @IBOutlet weak var lbl_addProfileinfo: UILabel!
    @IBOutlet weak var tf_firstName: UITextField!
    @IBOutlet weak var tf_lastName: UITextField!
    @IBOutlet weak var tf_address: UITextField!
    
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var btn_continue: UIButton!
    
    let fireStoreInstance = FirestoreServices()
    
    var selectedGender: String?
   
    let days = Array(1...31).map { String($0) }
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
   
    var selectedDay: String?
    var selectedMonth: String?
    var selectedYear: String?
    var dob: String?
    
    let tradeObjective = UserDefaults.standard.dictionary(forKey: "SelectedTradeObjective") as? [String: [String]]
    let tradeInstruments = UserDefaults.standard.dictionary(forKey: "SelectedTradeInstruments") as? [String: [String]]
    let tradeAnticipateMonthly = UserDefaults.standard.dictionary(forKey: "SelectedTradeAnticipateMonthly") as? [String: [String]]
    let tradeSourceIncome = UserDefaults.standard.dictionary(forKey: "SelectedTradeSourceIncome") as? [String: [String]]
    let tradeExprience = UserDefaults.standard.dictionary(forKey: "SelectedTradeExprience") as? [String: [String]]
    let tradePurpose = UserDefaults.standard.dictionary(forKey: "SelectedTradePurpose") as? [String: [String]]
    let userId =  UserDefaults.standard.string(forKey: "userID")
    let Firstname = UserDefaults.standard.string(forKey: "firstName")
    let LastName = UserDefaults.standard.string(forKey: "lastName")
  
    var profileStep = UserDefaults.standard.integer(forKey: "profileStepCompeleted")
    let overAllStatus = UserDefaults.standard.string(forKey: "OverAllStatus")
    let sid = UserDefaults.standard.string(forKey: "SID")
    
    weak var delegateKYC: KYCVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.tf_firstName.text = Firstname
        self.tf_lastName.text = LastName
        
        monthButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        dayButton.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        yearButton.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        
        print("the profileStep value is: \(profileStep)")
        
        btn_continue.buttonStyle()
        btn_continue.layer.cornerRadius = 15.0
            
    }
    
    func getYear() -> Array <String> {
        let _year = Calendar.current.component(.year, from: Date())
        let year = Array((1960..._year).reversed())
        print(year)
        let yearStrings = year.map { String($0) }
        return yearStrings
    }
   
    
    @IBAction func closeBtn_action(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func dayBtn_action(_ sender: UIButton) {
       
        dynamicDropDownButton(sender, list: days) { index , value in
            self.selectedDay = value
        }
        
    }
    
    @IBAction func monthBtn_action(_ sender: UIButton) {

        dynamicDropDownButton(sender, list: months) { index , value in
            self.selectedMonth = value
        }
    }
    
    @IBAction func yearBtn_action(_ sender: UIButton) {

        dynamicDropDownButton(sender, list: getYear()) { index , value in
            self.selectedYear = value
        }
    }
    
    @IBAction func maleBtn_action(_ sender: UIButton) {
        updateGenderButtons(for: "Male")
//        storeGenderInUserDefaults(gender: "Male")
    }
    
    @IBAction func femaleBtn_action(_ sender: UIButton) {
        updateGenderButtons(for: "Female")
//        storeGenderInUserDefaults(gender: "Female")
    }
    
    @IBAction func continueBtn_action(_ sender: UIButton) {
        profileStep = UserDefaults.standard.integer(forKey: "profileStepCompeleted")
        print("profileStepCompeleted is : \(profileStep)")
        
        updateUser()
//        AddUserAccountDetail()
        
    }
    @IBAction func backBtn_action(_ sender: Any) {
        self.dismiss(animated: true)
        delegateKYC?.navigateToCompeletProfile(kyc: .FifthScreen)
    }
    
    func updateGenderButtons(for gender: String) {
        storeDateInUserDefaults()
        
         UserDefaults.standard.set(1, forKey: "profileStepCompeleted")
      
        if gender == "Male" {
            maleButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)  // Selected Male
            femaleButton.setImage(UIImage(systemName: "circle"), for: .normal)               // Unselected Female
        } else if gender == "Female" {
            femaleButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal) // Selected Female
            maleButton.setImage(UIImage(systemName: "circle"), for: .normal)                 // Unselected Male
        }
        selectedGender = gender
    }

    
    // MARK: - Store Date in UserDefaults
       func storeDateInUserDefaults(){
           if let day = selectedDay, let month = selectedMonth, let year = selectedYear {
               let fullDate = "\(day) \(month) \(year)" // Combine selected values
               UserDefaults.standard.set(fullDate, forKey: "DateOfBirth") // Store in UserDefaults
               print("Stored date: \(fullDate)") // Log the stored date
                dob = fullDate
           }
          
       }
    
    func AddUserAccountDetail() {
        // Merge all dictionaries into one dictionary
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
               "uid": userId!,
               "sId": sid!,
               "step": profileStep,
               "profileStep": profileStep,
               "overAllStatus": overAllStatus! ,
               "questionAnswer": questionAnswer
           ]
        
        fireStoreInstance.addUserAccountData(uid: userId!, data: userData) { result in
            switch result {
            case .success:
                print("Document USER_ACCOUNT detail ADD successfully!")
             
                Alert.showAlertWithOKHandler(withHandler: "Thank you for providing your details. A Customer Support representative will reach out to you shortly with further instructions and to complete your account activation.", andTitle: "Completed", OKButtonText: "Return to Dashboard", on: self) { ok in
                    self.navigateToDashboard()
                }
               
                
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
        delegateKYC?.navigateToCompeletProfile(kyc: .ReturnDashboard)
    }
    
    func updateUser() {
        guard let userId = userId else{
            return
        }
        var fieldsToUpdate: [String: Any] = [
                "KYC": true,
                "address" : self.tf_address.text ?? "",
                "dob" : self.dob! ,
                "gender": self.selectedGender! ,
                "profileStep": profileStep,
             ]
        
        fireStoreInstance.updateUserFields(userID: userId, fields: fieldsToUpdate) { error in
            if let error = error {
                print("Error updating user fields: \(error.localizedDescription)")
                return
            } else {
                print("\n User data save successfully in the fireBase")
            }
        }
    }
    
    
}
