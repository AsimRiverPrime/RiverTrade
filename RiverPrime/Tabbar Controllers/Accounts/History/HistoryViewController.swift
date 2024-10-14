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
            
            if let closeData = closeData {
                self.closeData = closeData
                self.lbl_noPosition.text = "\(closeData.count)"
                print("historyClose data : \(closeData)")
                
//                for (models) in closeData {
//                
////                    let totalPrice = models.map { $0.price }.reduce(0, +)
//                }
                
                self.historyTableView.reloadData()
            } else {
                return
            }
        }
        
    }
    
}
