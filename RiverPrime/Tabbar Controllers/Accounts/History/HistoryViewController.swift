//
//  HistoryViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit

enum HistoryType {
    case trade
    case transaction
}

class HistoryViewController: BaseViewController {
    
    @IBOutlet weak var btn_fromDate: UIButton!
    @IBOutlet weak var btn_toDate: UIButton!
    @IBOutlet weak var lbl_noPosition: UILabel!
    @IBOutlet weak var lbl_totalProfit: UILabel!
    
    @IBOutlet weak var lbl_total: UILabel!
    @IBOutlet weak var lbl_PositionCount: UILabel!
    
    @IBOutlet weak var historyTableView: UITableView!
    
    @IBOutlet weak var view_noMatchData: UIView!
    
    @IBOutlet weak var btn_trades: UIButton!
    @IBOutlet weak var btnTradeView: UIView!
    
    @IBOutlet weak var btn_transcation: UIButton!
    @IBOutlet weak var btnTranscationView: UIView!
    
    var fromDate = String()
    var toDate = String()
    
    var fromTimestamp = 0
    var toTimestamp = 0
    
    var vm = HistoryVM()
    
    var closeData = [NewCloseModel]()
    var transactionCloseData = [CloseModel]()
    
    var _getSelectedDate = String()
    var isFromOrToDate = ""
    
    var historyType: HistoryType? = .trade
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyTableView.registerCells([
            HistoryTradeTVCell.self, HistoryTransactionTVCell.self, HistoryTransactionTotalTVCell.self
        ])
        historyTableView.delegate = self
        historyTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        closeApiCalling()
        
    }
    
    @IBAction func btn_trades(_ sender: UIButton) {
        historyType = .trade
            btnTradeView.backgroundColor = .systemYellow
            btnTranscationView.backgroundColor = .lightGray
        self.lbl_totalProfit.isHidden = false
        self.lbl_noPosition.isHidden = false
        self.lbl_total.isHidden = false
        self.lbl_PositionCount.isHidden = false
        self.historyTableView.reloadData()
    }
    
    @IBAction func btn_transcation(_ sender: UIButton) {
        historyType = .transaction
        btnTradeView.backgroundColor = .lightGray
        btnTranscationView.backgroundColor = .systemYellow
        self.lbl_totalProfit.isHidden = true
        self.lbl_noPosition.isHidden = true
        self.lbl_total.isHidden = true
        self.lbl_PositionCount.isHidden = true
        self.historyTableView.reloadData()
    }
    
    @IBAction func fromDateBtn_action(_ sender: Any) {
        
        //        showDatePicker(sender as! UIButton)
        
        isFromOrToDate = "From"
        
        let vc = Utilities.shared.getViewController(identifier: .datePickerPopupBottomSheet, storyboardType: .bottomSheetPopups) as! DatePickerPopupBottomSheet
        
        vc.delegate = self
        vc.isSingleEntery = true
        
        //        PresentModalController.instance.presentBottomSheet((SCENE_DELEGATE.window?.rootViewController.self)!, sizeOfSheet: .medium, VC: vc)
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customMedium, VC: vc)
        
    }
    
    @IBAction func toDateBtn_action(_ sender: Any) {
        
        //        showDatePicker(sender as! UIButton)
        
        isFromOrToDate = "To"
        
        let vc = Utilities.shared.getViewController(identifier: .datePickerPopupBottomSheet, storyboardType: .bottomSheetPopups) as! DatePickerPopupBottomSheet
        
        vc.delegate = self
        vc.isSingleEntery = true
        //        vc.multipleSelection(isMultiple: false)
        //        vc.calendar.allowsMultipleSelection = false
        vc.singleDateSelection = true
        
        //        PresentModalController.instance.presentBottomSheet((SCENE_DELEGATE.window?.rootViewController.self)!, sizeOfSheet: .medium, VC: vc)
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customMedium, VC: vc)
    }
    
    @IBAction func searchBtn_action(_ sender: Any) {
        
        if btn_fromDate.titleLabel?.text != "from date" && btn_toDate.titleLabel?.text != "to date" {
            let from: Int = fromTimestamp
            let to: Int = toTimestamp
            
            print("from = \(from)")
            print("to = \(to)")
            
            closeApiCalling(fromDate: from, toDate: to)
            
        }else{
            Alert.showAlert(withMessage: "Please enter date", andTitle: "Message!", on: self )
        }
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        switch historyType {
        case .trade:
            return 1
        case .transaction:
            return 1
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch historyType {
        case .trade:
            return closeData.count
        case .transaction:
            print("Transaction count:", transactionCloseData.count)
            return transactionCloseData.count + 1 //  return transactionCloseData.count + (transactionCloseData.isEmpty ? 0 : 1) // +1 only if data exists
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch historyType {
        case .trade:
            
            let cell = tableView.dequeueReusableCell(with: HistoryTradeTVCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.getCellData(close: closeData, indexPath: indexPath)
            
            return cell
        case .transaction:
            if indexPath.row == 0 {
                // Calculate deposits and withdrawals
                let totalDeposit = transactionCloseData
                    .filter { $0.profit > 0 }
                    .reduce(0) { $0 + $1.profit }
                
                let totalWithdraw = transactionCloseData
                    .filter { $0.profit < 0 }
                    .reduce(0) { $0 + abs($1.profit) } // Convert to positive for display
                
                // Configure Total Deposit/Withdraw cell
                let cellTotal = tableView.dequeueReusableCell(with: HistoryTransactionTotalTVCell.self, for: indexPath)
                cellTotal.selectionStyle = .none
                cellTotal.lbl_totalDeposit.text = "$\(String.formatStringNumber(String(totalDeposit)))"
                cellTotal.lbl_totalwithdraw.text = "$\(String.formatStringNumber(String(totalWithdraw)))"
                
                return cellTotal
            } else {
                // Adjust index to account for the total cell at the top
                let cell = tableView.dequeueReusableCell(with: HistoryTransactionTVCell.self, for: indexPath)
                cell.selectionStyle = .none
                let historyClose = transactionCloseData[indexPath.row - 1] // Adjust index
                cell.configure(with: historyClose)
                return cell
            }
            
        case .none:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch historyType {
        case .trade:
            return 345
        case .transaction:
            return indexPath.row == transactionCloseData.count ? 70 : 60  // Last row has a different height
        case .none:
            return 0
        }
    }
}

extension HistoryViewController {
    
    private func closeApiCalling(fromDate: Int? = nil, toDate: Int? = nil) {
        
        vm.fetchPositions(fromDate: fromDate, toDate: toDate) { closeData, error in
            if error != nil {
                return
            }
            
            if closeData?.count == 0 {
                self.view_noMatchData.isHidden = false
                self.historyTableView.isHidden = true
            }else{
                self.view_noMatchData.isHidden = true
                self.historyTableView.isHidden = false
            }
            
            if let closeData1 = closeData {
                self.closeData = closeData1
                print("closeData all values : \(self.closeData)")
                
                //                self.transactionCloseData = closeData1.flatMap { $0.historyCloseData.filter { $0.action == 2 } }
                
                var uniqueDeals = Set<Int>()
                self.transactionCloseData = closeData1
                    .flatMap { $0.historyCloseData.filter { $0.action == 2 } }
                    .filter { uniqueDeals.insert($0.deal).inserted }
                
                self.lbl_noPosition.text = "\(self.closeData.count)"
                print("historyClose data : \(self.transactionCloseData)")
                
                let totalProfitValue = self.closeData.reduce(0) { $0 + $1.totalProfit }
                self.lbl_totalProfit.text = "$\(String(totalProfitValue).trimmedTrailingZeros())"
                
                if totalProfitValue < 0 {
                    self.lbl_totalProfit.textColor = UIColor(red: 217/255.0, green: 94/255.0, blue: 90/255.0, alpha: 1.0)//.systemRed
                    
                }else{
                    self.lbl_totalProfit.textColor = UIColor(red: 116/255.0, green: 202/255.0, blue: 143/255.0, alpha: 1.0) //.systemGreen
                }
                //   closeData.sort(by: { $0.LatestTime > $1.LatestTime })
                //                self.closeData.sort { $0.LatestTime > $1.LatestTime }
                self.historyTableView.reloadData()
            } else {
                return
            }
        }
        
    }
    
}

extension HistoryViewController {
    
    func showDatePicker(_ sender: UIButton) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        if sender == btn_fromDate {
            fromDate = "From"
            toDate = ""
        } else if sender == btn_toDate {
            toDate = "To"
            fromDate = ""
        }
        
        // Create an alert controller
        let alertController = UIAlertController(title: "Select Date", message: nil, preferredStyle: .alert)
        
        // Add the date picker to the alert
        alertController.view.addSubview(datePicker)
        
        // Set the height of the date picker
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalTo: alertController.view.widthAnchor),
            datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 50),
            datePicker.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -60)
        ])
        
        // Add a "Done" button
        let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
            let selectedDate = datePicker.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            
            print("Selected date: \(dateFormatter.string(from: selectedDate))")
        }
        
        alertController.addAction(doneAction)
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        // Optionally handle date changes in real-time if needed
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let date = dateFormatter.string(from: selectedDate)
        print("Current date: \(date)")
        
        let timestamp = selectedDate.timeIntervalSince1970
        print("Selected timestamp: \(timestamp)")
        
        if fromDate != "" {
            btn_fromDate.setTitle(date, for: .normal)
            btn_fromDate.titleLabel?.text = date
            fromTimestamp = Int(timestamp)
        } else if toDate != "" {
            btn_toDate.setTitle(date, for: .normal)
            btn_toDate.titleLabel?.text = date
            toTimestamp = Int(timestamp)
        }
        
    }
    
}

//MARK: - Date picker delegate
extension HistoryViewController: didSelectBtnDelegate {
    
    func showAlert(str: String) {
        
        if var topController = SCENE_DELEGATE.window?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
                topController.view.makeToast(str)
            }
        }
        
    }
    
    func getDate(date: String) {
        print("this is date: \(date)")
    }
    
    func getStartEndDate(startDate: String, endDate: String) {
        if startDate == "" /*|| endDate == ""*/ {
            //            self..text = ""
            //            SCENE_DELEGATE.window?.rootViewController?.navigationController?.view.makeToast("Please select date properly.")
            self.showTimeAlert(str: "Please select date properly.")
        } else {
            
            //            self.tfDate.text =
            //            print("this is selected date : \(startDate) to \(endDate)")
            //            _getSelectedDate = "\(startDate) to \(endDate)"
            print("this is selected date : \(startDate)")
            _getSelectedDate = "\(startDate)"
        }
    }
    func doneDatePickerButton(_ sender: UIButton) {
        print("done")
        print("_getSelectedDate = \(_getSelectedDate)")
        
        // Create a date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        // Convert the selected date string to a Date object
        guard let date = dateFormatter.date(from: _getSelectedDate) else {
            print("ERROR: Date conversion failed due to mismatched format.")
            return
        }
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        if isFromOrToDate == "To" {
            // Add specific time (e.g., 23:59:59) to the date
            dateComponents.hour = 23
            dateComponents.minute = 59
            dateComponents.second = 59
        }
        
        guard let updatedDate = Calendar.current.date(from: dateComponents) else {
            print("ERROR: Failed to create updated date with time.")
            return
        }
        
        // Format the updated date with time back into a string
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let _date = dateFormatter.string(from: updatedDate)
        print("Current date with time: \(_date)")
        
        // Get the timestamp for the updated date
        let timestamp = updatedDate.timeIntervalSince1970
        print("Selected timestamp: \(timestamp)")
        
        // Handle "From" and "To" date selection
        if isFromOrToDate == "From" {
            btn_fromDate.setTitle(_getSelectedDate, for: .normal)
            btn_fromDate.titleLabel?.text = _getSelectedDate
            fromTimestamp = Int(timestamp)
        } else if isFromOrToDate == "To" {
            // Check if "From" date exists
            if fromTimestamp != 0 {
                let fromDate = Date(timeIntervalSince1970: TimeInterval(fromTimestamp))
                
                // Calculate the difference in months
                let monthsDifference = Calendar.current.dateComponents([.month], from: fromDate, to: updatedDate).month ?? 0
                if monthsDifference > 2 {
                    print("ERROR: The difference between From and To dates cannot exceed 2 months.")
                    self.showTimeAlert(str: "The difference between From and To dates cannot exceed 2 months.")
                    // Optionally, show an alert to the user
                    return
                }
            }
            
            btn_toDate.setTitle(_getSelectedDate, for: .normal)
            btn_toDate.titleLabel?.text = _getSelectedDate
            toTimestamp = Int(timestamp)
        }
        isFromOrToDate = ""
        
        // Dismiss the bottom sheet
        PresentModalController.instance.dismisBottomSheet(self)
    }
    
    func cancelDatePickerButton(_ sender: UIButton) {
        print("cancel")
        //        datePickerPopup.dismissView()
        //        PresentModalController.instance.dismisBottomSheet((SCENE_DELEGATE.window?.rootViewController.self)!)
        PresentModalController.instance.dismisBottomSheet(self)
    }
    
}
