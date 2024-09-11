//
//  CompleteVerificationProfileScreen1.swift
//  RiverPrime
//
//  Created by abrar ul haq on 08/09/2024.
//

import UIKit

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
    
    var selectedGender: String?
    let Firstname = UserDefaults.standard.string(forKey: "firstName")
    let LastName = UserDefaults.standard.string(forKey: "lastName")
    
    let dayPicker = UIPickerView()
    let monthPicker = UIPickerView()
    let yearPicker = UIPickerView()
    
//    let days = Array(1...31)
    let days = ["1","2","3","4","5"]
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
   
//    let years = Array((1900...2024).reversed())
//    let year = Calendar.current.component(.year, from: Date())
    
    func getYear() -> Array <String> {
        let _year = Calendar.current.component(.year, from: Date())
                let year = Array((1990..._year).reversed())
        print(year)
        let yearStrings = year.map { String($0) }
        return yearStrings
    }
    
    var selectedDay: Int?
    var selectedMonth: String?
    var selectedYear: Int?
    var activeButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up pickers
//        dayPicker.delegate = self
//        monthPicker.delegate = self
//        yearPicker.delegate = self
        
        self.tf_firstName.text = Firstname
        self.tf_lastName.text = LastName
        
        //MARK: - This commented code is use where we want to call this class.
        //MARK: - Asim bhai ye mene calling k lie kr dia he 1 class k lie, ap ne jahan bhi ye call krni hogi ye commented code use kr lain.
        /*
         let vc = Utilities.shared.getViewController(identifier: .completeVerificationProfileScreen1, storyboardType: .bottomSheetPopups) as! CompleteVerificationProfileScreen1
         PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
         */
        
        let tradeObjective = UserDefaults.standard.dictionary(forKey: "SelectedTradeObjective") as? [String: [String]]
        let tradeInstruments = UserDefaults.standard.dictionary(forKey: "SelectedTradeInstruments") as? [String: [String]]
        let tradeAnticipateMonthly = UserDefaults.standard.dictionary(forKey: "SelectedTradeAnticipateMonthly") as? [String: [String]]
        let tradeSourceIncome = UserDefaults.standard.dictionary(forKey: "SelectedTradeSourceIncome") as? [String: [String]]
        let tradeExprience = UserDefaults.standard.dictionary(forKey: "SelectedTradeExprience") as? [String: [String]]
        let tradePurpose = UserDefaults.standard.dictionary(forKey: "SelectedTradePurpose") as? [String: [String]]
        
        print("\n this is selected store data of: \(tradeObjective) \n \(tradeInstruments) \n \(tradeAnticipateMonthly) \n \(tradeSourceIncome) \n \(tradeExprience) \n \(tradePurpose) \n")
        
    }
    @IBAction func closeBtn_action(_ sender: UIButton) {
        
    }
    
    @IBAction func dayBtn_action(_ sender: UIButton) {
       // showPicker(for: sender, pickerView: dayPicker)
        dynamicDropDownButton(sender, list: days) { index , value in
            print("index: \(index) \t value: \(value)")
        }
        
    }
    
    @IBAction func monthBtn_action(_ sender: UIButton) {
//        showPicker(for: sender, pickerView: monthPicker)
        dynamicDropDownButton(sender, list: months) { index , value in
            print("index: \(index) \t value: \(value)")
        }
    }
    
    @IBAction func yearBtn_action(_ sender: UIButton) {
//        showPicker(for: sender, pickerView: yearPicker)
        dynamicDropDownButton(sender, list: getYear()) { index , value in
            print("index: \(index) \t value: \(value)")
        }
        print("\(getYear())")
    }
    
    @IBAction func maleBtn_action(_ sender: UIButton) {
        updateGenderButtons(for: "Male")
        storeGenderInUserDefaults(gender: "Male")
    }
    
    @IBAction func femaleBtn_action(_ sender: UIButton) {
        updateGenderButtons(for: "Female")
        storeGenderInUserDefaults(gender: "Female")
    }
    
    @IBAction func continueBtn_action(_ sender: UIButton) {
        
    }
    
    func updateGenderButtons(for gender: String) {
        if gender == "Male" {
            maleButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)  // Selected Male
            femaleButton.setImage(UIImage(systemName: "circle"), for: .normal)               // Unselected Female
        } else if gender == "Female" {
            femaleButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal) // Selected Female
            maleButton.setImage(UIImage(systemName: "circle"), for: .normal)                 // Unselected Male
        }
        selectedGender = gender
    }
    
    // Store the selected gender in UserDefaults
    func storeGenderInUserDefaults(gender: String) {
        UserDefaults.standard.set(gender, forKey: "selectedGender")
        print("Stored gender: \(gender)")  // Log the selected gender
    }
}

//extension CompleteVerificationProfileScreen7:  UIPickerViewDelegate, UIPickerViewDataSource {
//    
//    func showPicker(for button: UIButton, pickerView: UIPickerView) {
//        activeButton = button
//        
//        // Create and present an action sheet to hold the picker
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        
//        alert.view.addSubview(pickerView)
//        pickerView.frame = CGRect(x: 0, y: 40, width: alert.view.bounds.width - 20, height: 500)
//        
//        let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
//            self.updateButtonTitle(pickerView)
//            self.storeDateInUserDefaults()
//        }
//        
//        alert.addAction(doneAction)
//        present(alert, animated: true, completion: nil)
//    }
//    
//    @objc func dismissPicker() {
//        view.endEditing(true)
//    }
//    
//    // Update the button title based on the selected picker value
//    func updateButtonTitle(_ pickerView: UIPickerView) {
//        if let button = activeButton {
//            if pickerView == dayPicker {
//                let selectedDay = days[pickerView.selectedRow(inComponent: 0)]
//                button.setTitle("\(selectedDay)", for: .normal)
//                self.selectedDay = selectedDay // Store selected day
//            } else if pickerView == monthPicker {
//                let selectedMonth = months[pickerView.selectedRow(inComponent: 0)]
//                button.setTitle(selectedMonth, for: .normal)
//                self.selectedMonth = selectedMonth // Store selected month
//            } else if pickerView == yearPicker {
//                let years = getYear()
//                let selectedYear = years[pickerView.selectedRow(inComponent: 0)]
//                button.setTitle("\(selectedYear)", for: .normal)
//                self.selectedYear = selectedYear // Store selected year
//            }
//        }
//    }
//    
//    // MARK: - UIPickerViewDataSource and UIPickerViewDelegate
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if pickerView == dayPicker {
//            return days.count
//        } else if pickerView == monthPicker {
//            return months.count
//        } else if pickerView == yearPicker {
//            let years = getYear()
//            return years.count
//        }
//        return 0
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if pickerView == dayPicker {
//            return "\(days[row])"
//        } else if pickerView == monthPicker {
//            return months[row]
//        } else if pickerView == yearPicker {
//            let years = getYear()
//            return "\(years[row])"
//        }
//        return nil
//    }
//    
//    // MARK: - Store Date in UserDefaults
//    func storeDateInUserDefaults() {
//        if let day = selectedDay, let month = selectedMonth, let year = selectedYear {
//            let fullDate = "\(day) \(month) \(year)" // Combine selected values
//            UserDefaults.standard.set(fullDate, forKey: "DateOfBirth") // Store in UserDefaults
//            print("Stored date: \(fullDate)") // Log the stored date
//        }
//    }
//    
//}
