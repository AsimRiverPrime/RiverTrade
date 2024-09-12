//
//  CompleteVerificationProfileScreen1.swift
//  RiverPrime
//
//  Created by abrar ul haq on 08/09/2024.
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
    
    let fireStoreInstance = FirestoreServices()
    
    var selectedGender: String?
    
//    let days = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.tf_firstName.text = Firstname
        self.tf_lastName.text = LastName
        
        monthButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        dayButton.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        yearButton.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        
        print("the profileStep value is: \(profileStep)")
    }
    
    func getYear() -> Array <String> {
        let _year = Calendar.current.component(.year, from: Date())
        let year = Array((1990..._year).reversed())
        print(year)
        let yearStrings = year.map { String($0) }
        return yearStrings
    }
    
    // Function to calculate days in a month based on the month selected
//    func daysInMonth(month: String, year: Int) -> [String] {
//        switch month {
//        case "February":
//            // Check for leap year (29 days in February if leap year, otherwise 28)
//            return isLeapYear(year) ? Array(1...29).map { String($0) } : Array(1...28).map { String($0) }
//        case "April", "June", "September", "November":
//            // These months have 30 days
//            return Array(1...30).map { String($0) }
//        default:
//            // All other months have 31 days
//            return Array(1...31).map { String($0) }
//        }
//    }
//    // Function to check if a year is a leap year
//    func isLeapYear(_ year: Int) -> Bool {
//        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
//    }
//    // Month button action to select the month and update the day options
//    @IBAction func monthBtn_action(_ sender: UIButton) {
//        dynamicDropDownButton(sender, list: months) { index, value in
//            self.selectedMonth = value
//            let currentYear = 2024  // Assume the current year
//            let availableDays = self.daysInMonth(month: value, year: currentYear)
//
//            // When a month is selected, update the available days for the selected month
//            print("Selected month: \(value)")
//            print("Available days: \(availableDays)")
//        }
//    }
//
//    // Day button action to select the day based on the updated month
//    @IBAction func dayBtn_action(_ sender: UIButton) {
//        let currentYear = 2024  // Assume the current year
//        let availableDays = daysInMonth(month: selectedMonth, year: currentYear)  // Dynamically get days based on the selected month
//        
//        dynamicDropDownButton(sender, list: availableDays) { index, value in
//            self.selectedDay = value
//            print("Selected day: \(value)")
//        }
//    }
    
    
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
        AddUserAccountDetail()
    }
    
    func updateGenderButtons(for gender: String) {
        storeDateInUserDefaults()
        
         UserDefaults.standard.set(3, forKey: "profileStepCompeleted")
      
        if gender == "Male" {
            maleButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)  // Selected Male
            femaleButton.setImage(UIImage(systemName: "circle"), for: .normal)               // Unselected Female
        } else if gender == "Female" {
            femaleButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal) // Selected Female
            maleButton.setImage(UIImage(systemName: "circle"), for: .normal)                 // Unselected Male
        }
        selectedGender = gender
    }
    
    // Store the selected gender in UserDefaults
//    func storeGenderInUserDefaults(gender: String) {
//        UserDefaults.standard.set(gender, forKey: "selectedGender")
//        print("Stored gender: \(gender)")  // Log the selected gender
//    }
    
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
                self.ToastMessage("User detail add successfully!")
                self.navigateToDashboard()
            case .failure(let error):
                print("Error adding/updating document: \(error)")
                self.ToastMessage("\(error)")
            }
        }
    }
    
    func navigateToDashboard() {
        self.dismiss(animated: true)
        if let dashboardVC = instantiateViewController(fromStoryboard: "Dashboard", withIdentifier: "ProfileVC"){
                   self.navigate(to: dashboardVC)
               }
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
