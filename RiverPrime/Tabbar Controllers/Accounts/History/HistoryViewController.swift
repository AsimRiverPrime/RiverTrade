//
//  HistoryViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var btn_fromDate: UIButton!
    @IBOutlet weak var btn_toDate: UIButton!
    @IBOutlet weak var lbl_noPosition: UILabel!
    @IBOutlet weak var lbl_totalProfit: UILabel!
    
    @IBOutlet weak var historyTableView: UITableView!
    
    @IBOutlet weak var view_noMatchData: UIView!
    
    var fromDate = String()
    var toDate = String()
    
    var fromTimestamp = 0
    var toTimestamp = 0
    
    var vm = HistoryVM()
    
    var closeData = [NewCloseModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyTableView.registerCells([
            HistoryTradeTVCell.self
        ])
        historyTableView.delegate = self
        historyTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        closeApiCalling()
        
    }
    
    @IBAction func fromDateBtn_action(_ sender: Any) {
        
        showDatePicker(sender as! UIButton)
        
    }
    
    @IBAction func toDateBtn_action(_ sender: Any) {
        
        showDatePicker(sender as! UIButton)
        
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return closeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(with: HistoryTradeTVCell.self, for: indexPath)
        
        cell.getCellData(close: closeData, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 355
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
                self.lbl_noPosition.text = "\(self.closeData.count)"
                print("historyClose data : \(self.closeData)")
                
                let totalProfitValue = self.closeData.reduce(0) { $0 + $1.totalProfit }
                self.lbl_totalProfit.text = "\(totalProfitValue) USD"
             
                if totalProfitValue < 0 {
                    self.lbl_totalProfit.textColor = .systemRed
                }else{
                    self.lbl_totalProfit.textColor = .systemGreen
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
        let alertController = UIAlertController(title: "Select Date", message: nil, preferredStyle: .actionSheet)
        
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
        
//        if fromDate != "" {
//            btn_fromDate.setTitle(date, for: .normal)
//            btn_fromDate.titleLabel?.text = date
//        } else if toDate != "" {
//            btn_toDate.setTitle(date, for: .normal)
//            btn_toDate.titleLabel?.text = date
//        }
        
//        let selectedDate = datePicker.date
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
