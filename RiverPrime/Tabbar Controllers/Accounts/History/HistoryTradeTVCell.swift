//
//  HistoryTradeTVCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/10/2024.
//

import UIKit
import SDWebImage

class HistoryTradeTVCell: UITableViewCell {

    @IBOutlet weak var lbl_positionID: UILabel!
    @IBOutlet weak var image_SymbolIcon: UIImageView!
    @IBOutlet weak var lbl_symbolName: UILabel!
    @IBOutlet weak var lbl_typeVolume: UILabel!
    @IBOutlet weak var lbl_dateTime: UILabel!
    @IBOutlet weak var lbl_price: UILabel!
    @IBOutlet weak var image_TotatPrice: UIImageView!
    
    @IBOutlet weak var orders_tableView: UITableView!
    @IBOutlet weak var lbl_totalPrice: UILabel!
    
    
    var closeData = NewCloseModel()
    var vm = TransactionCellVM()
    
    var ticketName = String()
     
    var totalValue: Double?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        registerCell()
        
        print("\n closeData in history TV cell :\n \(closeData)")
        
     
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


extension HistoryTradeTVCell {
    func getCellData(close: [NewCloseModel], indexPath: IndexPath) {
        
//        let data = close[indexPath.row]
        closeData = close[indexPath.row]
        
        guard let savedSymbolsDict = vm.getSavedSymbolsDictionary() else {
            return
        }
        
        self.lbl_positionID.text = "#\(closeData.position)"
        
        if closeData.action == 0 {
            ticketName = "BUY"
         
        }else if closeData.action == 1 {
            ticketName = "SELL"
         
        }else if closeData.action == 2 {
            ticketName = "BUY Limit"
        
        }else if closeData.action == 3 {
            ticketName = "SELL Limit"
      
        }else if closeData.action == 4 {
            ticketName = "BUY Stop"
        
        }else if closeData.action == 5 {
            ticketName = "SELL Stop"
        
        }
        
        
        let createDate = Date(timeIntervalSince1970: Double(closeData.LatestTime))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.timeZone = .current
        
        let datee = dateFormatter.string(from: createDate)
        
        self.lbl_dateTime.text = datee
            
        
        // for image only
        var getSymbol = ""
        if closeData.symbol.contains("..") {
            getSymbol = String(closeData.symbol.dropLast())
            getSymbol = String(getSymbol.dropLast())
        } else if closeData.symbol.contains(".") {
            getSymbol = String(closeData.symbol.dropLast())
        } else {
            getSymbol = closeData.symbol
        }
        // Retrieve the symbol data using the name as the key
        if let symbolData = savedSymbolsDict[getSymbol] {
            if symbolData.name == "Platinum" {
                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/silver.png")
                image_SymbolIcon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }else {
                let imageUrl = URL(string: symbolData.icon_url)
                image_SymbolIcon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }
        }
        
        lbl_symbolName.text = closeData.symbol
        
        if closeData.totalProfit < 0 {
            lbl_totalPrice.textColor = .systemRed
            self.lbl_price.textColor = .systemRed
            self.image_TotatPrice.image = UIImage(systemName: "chart.line.downtrend.xyaxis")

        }else{
            lbl_totalPrice.textColor = .systemGreen
            self.lbl_price.textColor = .systemGreen
            self.image_TotatPrice.image = UIImage(systemName: "chart.line.uptrend.xyaxis")
        }
        self.lbl_price.text = "\(closeData.totalProfit) USD"
        lbl_totalPrice.text = "\(closeData.totalProfit) USD"
        
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
            return closeData.repeatedFilteredArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: CloseTicketSectionCell.self, for: indexPath)
           
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(with: CloseTicketTBCell.self, for: indexPath)
            
            let data = closeData.repeatedFilteredArray[indexPath.row]
            let volumee = Double(data.volume ) / Double(10000)
            
            if data.entry == 0 {
                cell.lbl_type.text = "IN"
                self.lbl_typeVolume.text = ticketName + " \(volumee) " + "Lot"
            }else{
                cell.lbl_type.text = "OUT"
            }
          
            cell.lbl_volume.text = "\(volumee)"
            cell.lbl_price.text = "\(data.price )"
            cell.lbl_profit.text = "\(data.profit)"
            
            let profit = data.profit
            
            if profit < 0 {
                cell.lbl_profit.textColor = .systemRed
            }else if profit > 0 {
                cell.lbl_profit.textColor = .systemGreen
            }else{
                cell.lbl_profit.textColor = .darkGray
            }
                        
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

