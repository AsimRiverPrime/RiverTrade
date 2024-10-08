//
//  CloseTicketBottomSheetVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 04/10/2024.
//

import UIKit

class CloseTicketBottomSheetVC: UIViewController {

    @IBOutlet weak var lbl_ticketName: UILabel!
    @IBOutlet weak var lbl_positionNumber: UILabel!
    @IBOutlet weak var lbl_symbolName: UILabel!
    @IBOutlet weak var lbl_totalPrice: UILabel!
    
    @IBOutlet weak var closeValue_TableView: UITableView!
    
    var closeData: CloseModel?
    var ticketName : String?
     
    var totalValue: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        
        print("closeData = \(closeData)")
        
        self.lbl_symbolName.text = closeData?.symbol
        self.lbl_positionNumber.text = "#\(closeData?.order ?? 0)"
        
        if closeData?.action == 0 {
            ticketName = "Buy"
            self.lbl_ticketName.text = "Buy Ticket"
        }else if closeData?.action == 1 {
            ticketName = "Sell"
            self.lbl_ticketName.text = "Sell Ticket"
        }else if closeData?.action == 2 {
            ticketName = "Buy Limit"
            self.lbl_ticketName.text = "Buy Ticket"
        }else if closeData?.action == 3 {
            ticketName = "Sell Limit"
            self.lbl_ticketName.text = "Sell Ticket"
        }else if closeData?.action == 4 {
            ticketName = "Buy Stop"
            self.lbl_ticketName.text = "Buy Ticket"
        }else if closeData?.action == 5 {
            ticketName = "Sell Stop"
            self.lbl_ticketName.text = "Sell Ticket"
        }
        
    }
    
    private func registerCell() {
        closeValue_TableView.registerCells([
            CloseTicketSectionCell.self , CloseTicketTBCell.self
        ])
        closeValue_TableView.delegate = self
        closeValue_TableView.dataSource = self
        closeValue_TableView.reloadData()
    }
    

}

extension CloseTicketBottomSheetVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
            return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: CloseTicketSectionCell.self, for: indexPath)
           
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(with: CloseTicketTBCell.self, for: indexPath)
            
            if closeData?.entry == 0 {
                cell.lbl_type.text = "IN"
            }else{
                cell.lbl_type.text = "OUT"
            }
            let volumee = Double(closeData!.volume) / Double(10000)
            cell.lbl_volume.text = "\(volumee)"
            cell.lbl_price.text = "\(closeData!.price)"
            cell.lbl_profit.text = "\(closeData!.profit)"
            
//            self.totalValue = Double(closeData!.profit)
            self.lbl_totalPrice.text = "\(closeData!.profit)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 40
        }else{
            return 40
        }
    }
}

