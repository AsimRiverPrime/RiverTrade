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
    }
    
    @IBAction func toDateBtn_action(_ sender: Any) {
    }
    
    
    @IBAction func searchBtn_action(_ sender: Any) {
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
    
    private func closeApiCalling() {
        
        vm.fetchPositions { closeData, error in
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
