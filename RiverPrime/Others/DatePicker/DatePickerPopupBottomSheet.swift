//
//  DatePickerPopupBottomSheet.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/10/2024.
//

import Foundation
import UIKit
import FSCalendar

protocol didSelectBtnDelegate: AnyObject {
//    func NextButtonClick(_ sender: UIButton, calendar: FSCalendar)
//    func PreviousButtonClick(_ sender: UIButton, calendar: FSCalendar)
    func doneDatePickerButton(_ sender: UIButton)
    func cancelDatePickerButton(_ sender: UIButton)
    func getStartEndDate(startDate: String, endDate: String)
    func getDate(date: String)
    func showAlert(str: String)
}

class DatePickerPopupBottomSheet: UIViewController {

    @IBOutlet weak var doneDateButton: UIButton!
    @IBOutlet weak var cancelDateButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var NextButton: UIButton!
    @IBOutlet weak var PreviousButton: UIButton!
    
    var isSingleEntery: Bool? = nil
    
    public weak var delegate: didSelectBtnDelegate?
    
    var findCollegueDatePicker: Bool?
    var setFrequencyVC: Bool?
    var selectedDate: String?
    var singleDateSelection: Bool?
    
    // first date in the range
    public var firstDate: Date?
    // last date in the range
    public var lastDate: Date?
    
    public var datesRange: [Date]?
    
    public var currentPage: Date?

    public lazy var today: Date = {
        return Date()
    }()
    
    public var startDate = String()
    public var endDate = String()
    
    var onNextClick: (()->())?
    var onPreviousClick: (()->())?
    
    var datesWithEvent = [String]()
    var datesWithMultipleEvents = [String]()
    
    public lazy var dateFormatter2: DateFormatter = {
        //MARK: - deviceTimeZoneForPicker param in DateTimeHandling._DateTimeHandling.setDateFormat(deviceTimeZoneForPicker: true) is for pick the date according to the device timezone, if we remove deviceTimeZoneForPicker param in the function then building selected timezone will be working.
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideNavBar()
        customizeCalendar()
        showDatePicker()
        
    }
    
    //MARK: - Calendar Styling.
    func customizeCalendar() {
        // Change the color of the day numbers
        calendar.appearance.titleDefaultColor = .white // Set to desired color
        
        // Customize other appearance properties as needed
        calendar.appearance.weekdayTextColor = .systemYellow // Weekday text (Sun, Mon, etc.)
        calendar.appearance.selectionColor = .systemYellow // Selected day color
        calendar.appearance.todayColor = .lightText // Today’s date color
        calendar.appearance.todaySelectionColor = .systemYellow // Today’s selection color
        calendar.appearance.headerTitleColor = .systemYellow // Month name color
        
        // Optionally, you can change the font for the day numbers as well
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 14)
    }
    
    // MARK: - to show events.
    private func showEvents() {
        
        let date = Date()
        
        let result = dateFormatter2.string(from: date)
        print("Current Date is = \(result)")
        
        guard let date = dateFormatter2.date(from: result) else {
            return
        }

        // MARK: Way 1

        let components = date.get(.day, .month, .year)
        if let day = components.day, let month = components.month, let year = components.year {
            print("day: \(day), month: \(month), year: \(year)")
        }

        // MARK: Way 2

        print("day: \(date.get(.day)), month: \(date.get(.month)), year: \(date.get(.year))")
        
        datesWithEvent.removeAll()
        datesWithMultipleEvents.removeAll()
        
        let monthDate = String(format: "%02d", components.month!)
        
        datesWithEvent.append("\(monthDate)/03/\(date.get(.year))")
        datesWithEvent.append("\(monthDate)/06/\(date.get(.year))")
        datesWithEvent.append("\(monthDate)/12/\(date.get(.year))")
        datesWithEvent.append("\(monthDate)/25/\(date.get(.year))")
        
        datesWithMultipleEvents.append("\(monthDate)/08/\(date.get(.year))")
        datesWithMultipleEvents.append("\(monthDate)/16/\(date.get(.year))")
        datesWithMultipleEvents.append("\(monthDate)/20/\(date.get(.year))")
        datesWithMultipleEvents.append("\(monthDate)/28/\(date.get(.year))")
        
        
        print("datesWithEvent = \(datesWithEvent)")
        print("datesWithMultipleEvents = \(datesWithMultipleEvents)")
        
    }
    // MARK: - to show events.
    private func showDatePicker() {
        
        calendar.dataSource = self
        calendar.delegate = self
        
        multipleSelection(isMultiple: false)
        
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        NextButton.setTitle("", for: .normal)
        PreviousButton.setTitle("", for: .normal)
        
        ifAlreadySelected()
        
    }
    
    private func ifAlreadySelected() {
        
        if startDate != "" && endDate != "" {
            
            print("startDate = \(startDate)")
            print("endDate = \(endDate)")
            
            guard let startDate = dateFormatter2.date(from: startDate) else {
                return
            }
            
            guard let endDate = dateFormatter2.date(from: endDate) else {
                return
            }
            
            firstDate = startDate
            lastDate = endDate
            
            let range = datesRange(from: startDate, to: endDate)
            
            lastDate = range.last
            
            for d in range {
                calendar.select(d)
            }
            
            datesRange = range
            
            print("datesRange contains: \(datesRange!)")
            
            let date = dateFormatter2.string(from: (datesRange?[0])!)
            print("date[0] = \(date)")
            
            let date1 = dateFormatter2.string(from: (datesRange?[datesRange!.count-1])!)
            print("date[count-1] = \(date1)")
            
        }
        
    }
    
    func dismissTopView() {
        self.titleLabel.isHidden = true
        self.cancelDateButton.isHidden = true
        self.doneDateButton.isHidden = true
        self.isSingleEntery = nil
    }
    
    func multipleSelection(isMultiple: Bool) {
        calendar.allowsMultipleSelection = isMultiple
    }
    
    //MARK: - Button Actions
    
    @IBAction func NextButton(_ sender: UIButton) {
        calendar.setCurrentPage(getNextMonth(date: calendar.currentPage), animated: true)

    }
    
    @IBAction func PreviousButton(_ sender: UIButton) {
        calendar.setCurrentPage(getPreviousMonth(date: calendar.currentPage), animated: true)

    }
    
    private func getNextMonth(date:Date)->Date {
        return  Calendar.current.date(byAdding: .month, value: 1, to:date)!
    }

    private func getPreviousMonth(date:Date)->Date {
        return  Calendar.current.date(byAdding: .month, value: -1, to:date)!
    }
    
    private func moveCurrentPage(moveUp: Bool) {
            
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = moveUp ? 1 : -1
        
        currentPage = calendar.date(byAdding: dateComponents, to: currentPage ?? today)
        self.calendar.setCurrentPage(currentPage!, animated: true)
    }
    
    //MARK: - Done and Cancel Button Actions.
    
    @IBAction func doneDateButton(_ sender: UIButton) {
        
        self.delegate?.getStartEndDate(startDate: startDate, endDate: endDate)
        self.delegate?.doneDatePickerButton(sender)
        
//        if calendar.allowsMultipleSelection == true {
//            if startDate != "" && endDate == "" {
//                guard let _startDate = dateFormatter2.date(from: startDate) else {
//                    print("ERROR: Date conversion failed due to mismatched format.")
//                    return
//                }
//                
//                print("DateTimeHandling._DateTimeHandling.SetCurrentDate() = \(SetCurrentDate())")
//                print("startDate = \(startDate)")
//                
//                if startDate == SetCurrentDate() {
//                    let date: String = SetCurrentDate()
//                    startDate = date
//                    endDate = date
//                    print("startDate = \(startDate)")
//                    print("endDate = \(endDate)")
//                    self.delegate?.getStartEndDate(startDate: startDate, endDate: endDate)
//                } else {
//                    if _startDate < setCurrentDate() {
//                        
//                        if isSingleEntery == true {
//                            endDate = startDate
//                            print("startDate = \(startDate)")
//                            print("endDate = \(endDate)")
//                            self.delegate?.getStartEndDate(startDate: startDate, endDate: endDate)
//                        } else {
//                            self.delegate?.showAlert(str: "Start and End Date cannot be less than today.")
//                        }
//                        
//                    } else {
//                        endDate = startDate
//                        print("startDate = \(startDate)")
//                        print("endDate = \(endDate)")
//                        self.delegate?.getStartEndDate(startDate: startDate, endDate: endDate)
//                    }
//                }
//                
//            } else {
//                setCurrentDateIfDoneNothing()
//            }
//        } else {
//            //MARK: - for Single
//            if startDate == "" {
//                return
//            }
//        }
//        self.isSingleEntery = nil
//        self.delegate?.doneDatePickerButton(sender)
    }
    
    @IBAction func cancelDateButton(_ sender: UIButton) {
        self.delegate?.cancelDatePickerButton(sender)
//        PresentModalController.instance.dismisBottomSheet(self)
    }
    
    //MARK: - If Date is not selected and user click on the done button then Current Date will be selected AutoMatically.
    private func setCurrentDateIfDoneNothing() {
        
        if startDate != "" && endDate != "" {
            if let dateRange = datesRange {
                if dateRange.count == 0 {
                    let date: String = SetCurrentDate()
                    startDate = date
                    endDate = date
                    print("startDate = \(startDate)")
                    print("endDate = \(endDate)")
                    self.delegate?.getStartEndDate(startDate: startDate, endDate: endDate)
                } else if dateRange.count == 1 { // MARK: - if user select only one date then start and end date should be the same which user select.
                    guard let _startDate = dateFormatter2.date(from: startDate) else {
                        print("ERROR: Date conversion failed due to mismatched format.")
                        return
                    }
                    if _startDate < setCurrentDate() {
                        
                        if isSingleEntery == true {
                            endDate = startDate
                            print("startDate = \(startDate)")
                            print("endDate = \(endDate)")
                            self.delegate?.getStartEndDate(startDate: startDate, endDate: endDate)
                        } else {
                            self.delegate?.showAlert(str: "Start and End Date cannot be less than today.")
                        }
                        
                    } else {
                        endDate = startDate
                        print("startDate = \(startDate)")
                        print("endDate = \(endDate)")
                        self.delegate?.getStartEndDate(startDate: startDate, endDate: endDate)
                    }
                    
                }
            }
        } else {
            let date: String = SetCurrentDate()
            startDate = date
            endDate = date
            print("startDate = \(startDate)")
            print("endDate = \(endDate)")
            self.delegate?.getStartEndDate(startDate: startDate, endDate: endDate)
        }
        
    }
    
    func showNavBar() {
        
        // Hide Navigation Back Button on this View Controller
        self.navigationItem.setHidesBackButton(false, animated:true);

        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }
    
    func hideNavBar() {
        
        // Hide Navigation Back Button on this View Controller
        self.navigationItem.setHidesBackButton(true, animated:true);

        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)

    }
    
}

//MARK: - Calendar delegate methods
extension DatePickerPopupBottomSheet: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        if calendar.allowsMultipleSelection == true {
            
            let date = dateFormatter2.string(from: date)
            guard let date = dateFormatter2.date(from: date) else {
                return
            }
            
            // nothing selected:
            if firstDate == nil {
                firstDate = date
                datesRange = [firstDate!]
                
                print("datesRange contains: \(datesRange!)")
                
                let date = dateFormatter2.string(from: (datesRange?[0])!)
                print("date[0] = \(date)")
                startDate = date
                
                return
            }

            // only first date is selected:
            if firstDate != nil && lastDate == nil {
                // handle the case of if the last date is less than the first date:
                if date <= firstDate! {
                    calendar.deselect(firstDate!)
                    firstDate = date
                    datesRange = [firstDate!]
                    
                    print("datesRange contains: \(datesRange!)")
                    
                    return
                }
                
                let range = datesRange(from: firstDate!, to: date)
                
                lastDate = range.last
                
                for d in range {
                    calendar.select(d)
                }
                
                datesRange = range
                
                print("datesRange contains: \(datesRange!)")
                
                let date = dateFormatter2.string(from: (datesRange?[0])!)
                print("date[0] = \(date)")
                startDate = date
                
                let date1 = dateFormatter2.string(from: (datesRange?[datesRange!.count-1])!)
                print("date[count-1] = \(date1)")
                
                endDate = date1
                
                if !isDateValid(startDate: startDate, endDate: endDate, isSingle: false) {
                    return
                }
                
                self.delegate?.getStartEndDate(startDate: startDate, endDate: endDate)
                
                return
            }

            // both are selected:
            if firstDate != nil && lastDate != nil {
                for d in calendar.selectedDates {
                    calendar.deselect(d)
                }
                
                lastDate = nil
                firstDate = nil
                
                datesRange = []
                
                print("datesRange contains: \(datesRange!)")
            }
            
        } else {
            let date = dateFormatter2.string(from: date)
            startDate = date
            
            if !isDateValid(startDate: startDate, endDate: endDate, isSingle: true) {
                return
            }
            
            self.delegate?.getDate(date: date)
            print("selected date = \(date)")
           
            
           
            
        }
        
    }
    
    private func isDateValid(startDate: String, endDate: String, isSingle: Bool) -> Bool {
        if isSingleEntery == true {
            return true
        }
        
        guard let _startDate = dateFormatter2.date(from: startDate) else {
            print("ERROR: Date conversion failed due to mismatched format.")
            return false
        }
        
        if isSingle == false {
            guard let _endDate = dateFormatter2.date(from: endDate) else {
                print("ERROR: Date conversion failed due to mismatched format.")
                return false
            }
            
            if startDate == SetCurrentDate() && _endDate > setCurrentDate() {
                return true
            }
            
            if _startDate < setCurrentDate() && _endDate < setCurrentDate() {
                //                    let str = "Please select date properly."
                self.delegate?.showAlert(str: "Start and End Date cannot be less than today.")
                return false
            } else if _startDate < setCurrentDate() {
                self.delegate?.showAlert(str: "Start Date cannot be less than today.")
                return false
            } else if _endDate < setCurrentDate() {
                self.delegate?.showAlert(str: "End Date cannot be less than today.")
                return false
            } else if _endDate < _startDate {
                self.delegate?.showAlert(str: "Please select date properly.")
                return false
            }
        } else {
            if _startDate < setCurrentDate() {
                self.delegate?.showAlert(str: "Start Date cannot be less than today.")
                return false
            }
        }
        
        return true
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // both are selected:

        // NOTE: the is a REDUANDENT CODE:
        if firstDate != nil && lastDate != nil {
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }

            lastDate = nil
            firstDate = nil

            datesRange = []
            print("datesRange contains: \(datesRange!)")
        }
    }
    
    func datesRange(from: Date, to: Date) -> [Date] {
        // in case of the "from" date is more than "to" date,
        // it should returns an empty array:
        if from > to { return [Date]() }

        var tempDate = from
        var array = [tempDate]

        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }

        return array
    }
    
}

extension DatePickerPopupBottomSheet: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {

        let dateString = self.dateFormatter2.string(from: date)
        print("dateString = \(dateString)")
        
        if self.datesWithEvent.contains(dateString) {
            return 1
        }

        if self.datesWithMultipleEvents.contains(dateString) {
            return 3
        }

        return 0
    }
    
}
extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension DatePickerPopupBottomSheet {
    
    //set Current Date
    public func SetCurrentDate()->String {
        let date = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        let result = formatter.string(from: date)
        print("Current Date is = \(result)")
        
        return result
        
    }
    
    //set Current Date
    public func setCurrentDate() -> Date {
        let date = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        let result = formatter.string(from: date)
        print("Current Date is = \(result)")
        
        guard let dateConvert = formatter.date(from: result) else {
//            fatalError("ERROR: Date conversion failed due to mismatched format.")
            print("ERROR: Date conversion failed due to mismatched format.")
            return date
        }
        
        return dateConvert
        
    }
    
}
