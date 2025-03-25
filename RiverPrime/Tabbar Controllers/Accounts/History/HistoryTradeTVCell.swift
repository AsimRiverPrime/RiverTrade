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
//    @IBOutlet weak var image_SymbolIcon: UIImageView!
    @IBOutlet weak var lbl_symbolName: UILabel!
//    @IBOutlet weak var lbl_typeVolume: UILabel!
    @IBOutlet weak var lbl_dateTime: UILabel!
    @IBOutlet weak var lbl_price: UILabel!
//    @IBOutlet weak var image_TotatPrice: UIImageView!
    
    @IBOutlet weak var orders_tableView: UITableView!
    @IBOutlet weak var lbl_totalPrice: UILabel!
    
    var closeData = NewCloseModel()
    var vm = TransactionCellVM()
    
    var ticketName = String()
    var totalValue: Double?
    var datee = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        registerCell()
        
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
//        orders_tableView.reloadData()
    }
    
}


extension HistoryTradeTVCell {
    func getCellData(close: [NewCloseModel], indexPath: IndexPath) {
        
//        let data = close[indexPath.row]
        closeData = close[indexPath.row]
//        print("\n closeData in history TV cell :\n \(closeData)")
        
        guard let savedSymbolsDict = vm.getSavedSymbolsDictionary() else {
            return
        }
        
        self.lbl_positionID.text = "#\(closeData.position)"
   
        // for image only
        var getSymbol = ""
       
        if closeData.symbol.contains(".") {
            getSymbol = String(closeData.symbol.dropLast())
        } else {
            getSymbol = closeData.symbol
        }
        // Retrieve the symbol data using the name as the key
//        if let symbolData = savedSymbolsDict[getSymbol] {
//            if symbolData.name == "Platinum" {
//                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/silver.png")
//                image_SymbolIcon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
//            }else {
//                let imageUrl = URL(string: symbolData.icon_url)
//                image_SymbolIcon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
//            }
//        }
        
        lbl_symbolName.text = closeData.symbol
        
        if closeData.totalProfit < 0 {
//            lbl_totalPrice.textColor = UIColor(red: 217/255.0, green: 94/255.0, blue: 90/255.0, alpha: 1.0) //.systemRed
            self.lbl_price.textColor = UIColor(red: 217/255.0, green: 94/255.0, blue: 90/255.0, alpha: 1.0)//.systemRed
//            self.image_TotatPrice.image = UIImage(systemName: "arrow.down")
//            self.image_TotatPrice.tintColor = UIColor(red: 217/255.0, green: 94/255.0, blue: 90/255.0, alpha: 1.0)
        }else{
//            lbl_totalPrice.textColor = UIColor(red: 116/255.0, green: 202/255.0, blue: 143/255.0, alpha: 1.0) //.systemGreen
            self.lbl_price.textColor = UIColor(red: 116/255.0, green: 202/255.0, blue: 143/255.0, alpha: 1.0) //.systemGreen
//            self.image_TotatPrice.image = UIImage(systemName: "arrow.up")
//            self.image_TotatPrice.tintColor = UIColor(red: 116/255.0, green: 202/255.0, blue: 143/255.0, alpha: 1.0)
        }
//        self.lbl_price.text = "$\(closeData.totalProfit)"
        if closeData.totalProfit < 0 {
            self.lbl_price.text = "-$\(abs(closeData.totalProfit))"
        } else {
            self.lbl_price.text = "$\(closeData.totalProfit)"
        }
        
//        lbl_totalPrice.text = "$\(closeData.totalProfit)"
        
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
            return closeData.repeatedFilteredArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: CloseTicketSectionCell.self, for: indexPath)
            cell.selectionStyle = .none
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(with: CloseTicketTBCell.self, for: indexPath)
            cell.selectionStyle = .none
            let data = closeData.repeatedFilteredArray[indexPath.row]
            let volumee = Double(data.volume ) / Double(10000)
            
            switch data.action {
            case 0:
                ticketName = "B"
            case 1:
                ticketName = "S"
            case 2:
                ticketName = "BL"
            case 3:
                ticketName = "SL"
            case 4:
                ticketName = "BS"
            case 5:
                ticketName = "SS"
            default:
                print("No data found.")
            }

            let directionText = data.direction == 0 ? "IN" : "OUT"
           
            let createDate = Date(timeIntervalSince1970: Double(data.time))
            let calendar = Calendar.current
            if let updatedDate = calendar.date(byAdding: .hour, value: -3, to: createDate) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yy HH:mm:ss"
                dateFormatter.timeZone = .current
                
                cell.lbl_profit.text = dateFormatter.string(from: updatedDate)
            }
            
//            let dateString = String(DateHelper.convertDateToGMT(from: Double(data.time)) ?? "0")
//            cell.lbl_profit.text = dateString
            
            cell.lbl_type.text = "\(ticketName)/\(directionText)"
            cell.lbl_volume.text = "\(volumee)"

            let amount = String.formatStringNumber("\(data.price)")
            cell.lbl_price.text = amount
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 30
        }else{
            return 27
        }
    }
}

