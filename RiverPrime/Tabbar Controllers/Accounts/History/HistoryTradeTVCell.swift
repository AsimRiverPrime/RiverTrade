//
//  HistoryTradeTVCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/10/2024.
//

import UIKit

class HistoryTradeTVCell: UITableViewCell {

    @IBOutlet weak var lbl_positionID: UILabel!
    @IBOutlet weak var image_SymbolIcon: UIImageView!
    @IBOutlet weak var lbl_symbolName: UILabel!
    @IBOutlet weak var lbl_typeVolume: UILabel!
    @IBOutlet weak var lbl_dateTime: UILabel!
    @IBOutlet weak var lbl_price: UILabel!
    
    @IBOutlet weak var orders_tableView: UITableView!
    @IBOutlet weak var lbl_totalPrice: UILabel!
    
    
    var closeData: NewCloseModel?
    var ticketName : String?
     
    var totalValue: Double?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        registerCell()
        
//        print("closeData = \(closeData)")
        
        self.lbl_symbolName.text = closeData?.symbol
        self.lbl_positionID.text = "#\(closeData?.position ?? 0)"
        
        if closeData?.action == 0 {
            ticketName = "Buy"
         
        }else if closeData?.action == 1 {
            ticketName = "Sell"
         
        }else if closeData?.action == 2 {
            ticketName = "Buy Limit"
        
        }else if closeData?.action == 3 {
            ticketName = "Sell Limit"
      
        }else if closeData?.action == 4 {
            ticketName = "Buy Stop"
        
        }else if closeData?.action == 5 {
            ticketName = "Sell Stop"
        
        }
        
        self.lbl_typeVolume.text = ticketName ?? "" + "  " + "Lot"
        self.lbl_price.text = "\(closeData?.totalPrice ?? 0)"
        
        let createDate = Date(timeIntervalSince1970: Double(closeData?.LatestTime ?? 0))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.timeZone = .current
        
        let datee = dateFormatter.string(from: createDate)
        
        self.lbl_dateTime.text = datee
        
        self.lbl_totalPrice.text = "\(closeData?.totalPrice ?? 0)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func registerCell() {
        orders_tableView.registerCells([
            CloseTicketSectionCell.self , CloseTicketTBCell.self
        ])
        orders_tableView.delegate = self
        orders_tableView.dataSource = self
        orders_tableView.reloadData()
    }
    
}


extension HistoryTradeTVCell: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
            return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }else{
            return closeData?.repeatedFilteredArray.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: CloseTicketSectionCell.self, for: indexPath)
           
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(with: CloseTicketTBCell.self, for: indexPath)
            
            let data = closeData?.repeatedFilteredArray[indexPath.row]
            
            if data?.entry == 0 {
                cell.lbl_type.text = "IN"
            }else{
                cell.lbl_type.text = "OUT"
            }
            let volumee = Double(data?.volume ?? 0) / Double(10000)
            cell.lbl_volume.text = "\(volumee)"
            cell.lbl_price.text = "\(data?.price ?? 0.0)"
            cell.lbl_profit.text = "\(data?.profit ?? 0.0)"
            
//            self.totalValue = Double(closeData!.profit)
            let Tprofit = closeData!.totalProfit
            let profit = data!.profit
            
            if Tprofit < 0  {
                self.lbl_totalPrice.textColor = .systemRed
               
            }else {
                self.lbl_totalPrice.textColor = .darkGray
                
            }
            
            if profit < 0 {
                cell.lbl_profit.textColor = .systemRed
            }else{
                cell.lbl_profit.textColor = .darkGray
            }
            
            self.lbl_totalPrice.text = "\(Tprofit) USD"
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 40
        }else{
            return 70
        }
    }
}

