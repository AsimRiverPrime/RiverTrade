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
  
    @IBOutlet weak var chooseDateBtn: CardViewButton!
//    @IBOutlet weak var btn_fromDate: UIButton!
//    @IBOutlet weak var btn_toDate: UIButton!
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
    
    var historyViewModel = HistoryVM()
    
    var closeData = [NewCloseModel]()
    var transactionCloseData = [CloseModel]()
    
    var _getSelectedDate = String()
    var isFromOrToDate = ""
    
    var historyType: HistoryType? = .trade
    var dateList = ["1 Day","1 Week", "15 Days", "1 Month", "6 Months", "Custom Date"]
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.chooseDateBtn.setTitle(dateList[0], for: .normal)
        self.setChooseDate(dateItem: dateList[0])
        
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: AccountsViewController(), navController: self.navigationController, title: "History", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    
    @IBAction func btn_trades(_ sender: UIButton) {
        self.chooseDateBtn.setTitle(dateList[0], for: .normal)
        self.setChooseDate(dateItem: dateList[0])
        
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
        self.chooseDateBtn.setTitle(dateList[0], for: .normal)
        self.setChooseDate(dateItem: dateList[0])
        
        historyType = .transaction
        btnTradeView.backgroundColor = .lightGray
        btnTranscationView.backgroundColor = .systemYellow
        self.lbl_totalProfit.isHidden = true
        self.lbl_noPosition.isHidden = true
        self.lbl_total.isHidden = true
        self.lbl_PositionCount.isHidden = true
        
        self.historyTableView.reloadData()
    }
    
    
    @IBAction func chooseDateBtn(_ sender: CardViewButton){
        print("Choose date button click.")
        self.dynamicDropDownButton(sender, list: dateList) { index, item in
            print("drop down index = \(index)")
            print("drop down item = \(item)")
            sender.setTitle(item, for: .normal)
            
            sender.titleLabel?.text = item
            
            if item == "Custom Date" {
            
                let popupVC = DateRangePickerViewController()
                popupVC.modalPresentationStyle = .overCurrentContext
                popupVC.modalTransitionStyle = .crossDissolve
                popupVC.onApply = { from, to in
                    print("Selected From: \(from)")
                    print("Selected To: \(to)")
                    sender.setTitle("\(from) - \(to)", for: .normal)
                    
                    // Create a date formatter
                    let dateFormatter = DateFormatter()
                    
                    dateFormatter.dateFormat = "MMM dd, yyyy"
                    
                    // Convert the selected date string to a Date object
                    guard let myfromDate = dateFormatter.date(from: from) else {
                        print("ERROR: Date conversion failed due to mismatched format myfromDate (Custom Date).")
                        return
                    }
                    
                    // Convert the selected date string to a Date object
                    guard let mytoDate = dateFormatter.date(from: to) else {
                        print("ERROR: Date conversion failed due to mismatched format mytoDate Custom Date.")
                        return
                    }
                    
                    dateFormatter.dateFormat = "dd-MM-yyyy"
                    
                    //                    print("From:", formatter.string(from: fromDatePicker.date))
                    //                    print("To:", formatter.string(from: toDatePicker.date))
                    let _fromDate = dateFormatter.string(from: myfromDate)
                    let _toDate = dateFormatter.string(from: mytoDate)
                    
                    // Convert the selected date string to a Date object
                    guard let fromDate = dateFormatter.date(from: _fromDate) else {
                        print("ERROR: Date conversion failed due to mismatched format myfromDate (Custom Date).")
                        return
                    }
                    
                    // Convert the selected date string to a Date object
                    guard let toDate = dateFormatter.date(from: _toDate) else {
                        print("ERROR: Date conversion failed due to mismatched format myToDate (Custom Date).")
                        return
                    }
                    
                    //TODO: START From:
                    var fromDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: fromDate)
                    // Add specific time (e.g., 23:59:59) to the date
                    fromDateComponents.hour = 23
                    fromDateComponents.minute = 59
                    fromDateComponents.second = 59
//
                    guard let updatedFromDate = Calendar.current.date(from: fromDateComponents) else {
                        print("ERROR: Failed to create updated date with time.")
                        return
                    }
                    
                    // Format the updated date with time back into a string
                    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    let _datefrom = dateFormatter.string(from: updatedFromDate)
                    print("previous date with time: \(_datefrom)")
                    
                    // Get the timestamp for the updated date
                    let from_timestamp = updatedFromDate.timeIntervalSince1970
                    print("Selected from_timestamp: \(from_timestamp)")
                    
                    self.fromTimestamp = Int(from_timestamp)
                    //TODO: END From:
                    
                    //TODO: START To:
                    var toDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: toDate)
                    // Add specific time (e.g., 23:59:59) to the date
                    toDateComponents.hour = 23
                    toDateComponents.minute = 59
                    toDateComponents.second = 59
                    
                    guard let updatedToDate = Calendar.current.date(from: toDateComponents) else {
                        print("ERROR: Failed to create updated date with time.")
                        return
                    }
                    
                    // Format the updated date with time back into a string
                    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    let _dateto = dateFormatter.string(from: updatedToDate)
                    print("Current date with time: \(_dateto)")
                    
                    // Get the timestamp for the updated date
                    let to_timestamp = updatedToDate.timeIntervalSince1970
                    print("Selected to_timestamp: \(to_timestamp)")
                    
                    self.toTimestamp = Int(to_timestamp)
               
                }
                
                self.present(popupVC, animated: true, completion: nil)
            } else {
                self.setChooseDate(dateItem: item)
            }

        }
    }
    
    private func setChooseDate(dateItem: String) {
        
        var from = ""
        var to = ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy" // Set the desired format
        let currentDate = formatter.string(from: Date()) // Get the current date as a string

        print("Current Date: \(currentDate)")
        
        if dateItem == "1 Day" {
            
            to = currentDate
            let previousWeekEndDate = getPreviousPeriodEndDate(forPeriod: "1 Day")
            
            let end = formatter.string(from: previousWeekEndDate)
            
            from = end
            
        } else if dateItem == "1 Week" {
            
            to = currentDate
  
            let previousWeekEndDate = getPreviousPeriodEndDate(forPeriod: "week")
            
            let end = formatter.string(from: previousWeekEndDate)
            
            from = end
            
        } else if dateItem == "15 Days" {
            
            to = currentDate
            
            let previous15DaysEndDate = getPreviousPeriodEndDate(forPeriod: "15days")
            
            let end = formatter.string(from: previous15DaysEndDate)
            
            from = end
            
        } else if dateItem == "1 Month" {
            
            to = currentDate
            
            let previousMonthEndDate = getPreviousPeriodEndDate(forPeriod: "month")
            
            let end = formatter.string(from: previousMonthEndDate)
            
            from = end
            
        } else if dateItem == "6 Months" {
            
            to = currentDate
            
            let previous6MonthsEndDate = getPreviousPeriodEndDate(forPeriod: "6months")
            
            let end = formatter.string(from: previous6MonthsEndDate)
            
            from = end
            
        }
        
        // Create a date formatter
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        // Convert the selected date string to a Date object
        guard let myfromDate = dateFormatter.date(from: from) else {
            print("ERROR: Date conversion failed due to mismatched format (6 Months).")
            return
        }
        
        // Convert the selected date string to a Date object
        guard let mytoDate = dateFormatter.date(from: to) else {
            print("ERROR: Date conversion failed due to mismatched format (6 Months).")
            return
        }
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
 
        let _fromDate = dateFormatter.string(from: myfromDate)
        let _toDate = dateFormatter.string(from: mytoDate)
        
        // Convert the selected date string to a Date object
        guard let fromDate = dateFormatter.date(from: _fromDate) else {
            print("ERROR: Date conversion failed due to mismatched format.")
            return
        }
        
        // Convert the selected date string to a Date object
        guard let toDate = dateFormatter.date(from: _toDate) else {
            print("ERROR: Date conversion failed due to mismatched format.")
            return
        }
        
        //TODO: START From:
        var fromDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: fromDate)
        // Add specific time (e.g., 23:59:59) to the date
        fromDateComponents.hour = 23
        fromDateComponents.minute = 59
        fromDateComponents.second = 59
        
        guard let updatedFromDate = Calendar.current.date(from: fromDateComponents) else {
            print("ERROR: Failed to create updated date with time.")
            return
        }
        
        // Format the updated date with time back into a string
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let _datefrom = dateFormatter.string(from: updatedFromDate)
        print("previous date with time: \(_datefrom)")
        
        // Get the timestamp for the updated date
        let from_timestamp = updatedFromDate.timeIntervalSince1970
        print("Selected from_timestamp: \(from_timestamp)")
        
        self.fromTimestamp = Int(from_timestamp)
        //TODO: END From:
        
        //TODO: START To:
//        var toDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: toDate)
        // Add specific time (e.g., 23:59:59) to the date
//        toDateComponents.hour = 23
//        toDateComponents.minute = 59
//        toDateComponents.second = 59
        
//        guard let updatedToDate = Calendar.current.date(from: toDateComponents) else {
//            print("ERROR: Failed to create updated date with time.")
//            return
//        }
        // Format the updated date with time back into a string
//        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
//        let _dateto = dateFormatter.string(from: updatedToDate)
//        print("Current date with time: \(_dateto)")
        
        // Get the current day timestamp for the to date
        let to_timestamp = Date().timeIntervalSince1970 //updatedToDate.timeIntervalSince1970
        print("Selected to_timestamp: \(to_timestamp)")
        
        self.toTimestamp = Int(to_timestamp)
        //TODO: END To:
        
    }
    
    func getPreviousPeriodEndDate(forPeriod period: String) -> Date {
        let calendar = Calendar.current
        
        // Get today's date
        let currentDate = Date()
        
        // Start of today (removes the time portion, setting it to midnight)
        let startOfToday = calendar.startOfDay(for: currentDate)
        
        var previousPeriodStart: Date
        var previousPeriodEnd: Date
        
        switch period {
        case "1 Day":
            previousPeriodStart = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
            return previousPeriodStart
        case "week":
            // Calculate the start of the previous week (7 days back)
            previousPeriodStart = calendar.date(byAdding: .day, value: -7, to: startOfToday)!

            return previousPeriodStart
        case "15days":
            // Calculate the start of the previous 15 days (15 days back)
            previousPeriodStart = calendar.date(byAdding: .day, value: -15, to: startOfToday)!
            
            return previousPeriodStart
        case "month":
            // Calculate the start of the previous month (1 month back)
            previousPeriodStart = calendar.date(byAdding: .month, value: -1, to: startOfToday)!
            // Calculate the end of the previous month (last day of the previous month)
            previousPeriodEnd = calendar.date(byAdding: .month, value: -1, to: startOfToday)!
            previousPeriodEnd = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: previousPeriodEnd))!
            
        case "6months":
            // Calculate the start of the previous 6 months (6 months back)
            previousPeriodStart = calendar.date(byAdding: .month, value: -6, to: startOfToday)!
            // Calculate the end of the previous 6 months (last day of the 6th month)
            previousPeriodEnd = calendar.date(byAdding: .month, value: -6, to: startOfToday)!
            previousPeriodEnd = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: previousPeriodEnd))!
            
        default:
            fatalError("Invalid period")
        }
        
        return previousPeriodEnd
    }

    
    @IBAction func searchBtn_action(_ sender: Any) {
        if chooseDateBtn.titleLabel?.text == "Custom Date" || chooseDateBtn.titleLabel?.text == "Select Date" {
            Alert.showAlert(withMessage: "Please select date", andTitle: "Message!", on: self )
        }else{
            let from: Int = fromTimestamp
            let to: Int = toTimestamp
            
            print("from = \(from)")
            print("to = \(to)")
            
            closeApiCalling(fromDate: from, toDate: to)
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
            print("closeData count:", closeData.count)
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
            return 160
        case .transaction:
            return indexPath.row == 0 ? 70 : 60
        case .none:
            return 0
        }
    }
}

extension HistoryViewController {
    
    private func closeApiCalling(fromDate: Int? = nil, toDate: Int? = nil) {
       
        historyViewModel.fetchPositions(fromDate: fromDate, toDate: toDate, isHistory: true) { closeData, error in
            if error != nil {
                return
            }
            print("fetchPositions closeData count is = \(closeData?.count ?? 0)")
            
            if closeData?.count == 0 {
                self.view_noMatchData.isHidden = false
                self.historyTableView.isHidden = true
            }else{
                self.view_noMatchData.isHidden = true
                self.historyTableView.isHidden = false
            }
            
            if let closeData1 = closeData {

                let updatedModels = [NewCloseModel]()

                if let firstResult = closeData1.first,
                   closeData1.allSatisfy({ $0.action == firstResult.action && $0.position == firstResult.position }) {
                    
                    var updatedModels = [NewCloseModel]()
                    
                    for i in 0...closeData1.count-1 {
                        for j in 0...closeData1[i].repeatedFilteredArray.count-1 {
                            if closeData1[i].repeatedFilteredArray[j].action == 1 {
                                updatedModels.append(closeData1[i])
                            }
                        }
                    }
                    self.closeData = updatedModels
                    
                } else {
                    self.closeData = closeData1
                }
                print("updatedModels closeData1 = \(updatedModels)")
               
//                self.closeData = updatedModels
        
                var uniqueDeals = Set<Int>()
                self.transactionCloseData = closeData1
                    .flatMap { $0.historyCloseData.filter { $0.action == 2 || $0.action == 5 } }
                    .filter { uniqueDeals.insert($0.deal).inserted }
                
                self.lbl_noPosition.text = "\(self.closeData.count)"
                print("historyClose data : \(self.transactionCloseData)")
                
                let totalProfitValue = self.closeData.reduce(0) { $0 + $1.totalProfit }
               
                
                if totalProfitValue < 0 {
                    self.lbl_totalProfit.textColor = UIColor(red: 217/255.0, green: 94/255.0, blue: 90/255.0, alpha: 1.0)//.systemRed
                    let abc = "\(String(totalProfitValue).trimmedTrailingZeros())"
                    self.lbl_totalProfit.text =  "-$\(abs(Double(abc) ?? 0))"
                }else{
                    self.lbl_totalProfit.textColor = UIColor(red: 116/255.0, green: 202/255.0, blue: 143/255.0, alpha: 1.0) //.systemGreen
                    let abc = "\(String(totalProfitValue).trimmedTrailingZeros())"
                    self.lbl_totalProfit.text =  "$" + abc
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
