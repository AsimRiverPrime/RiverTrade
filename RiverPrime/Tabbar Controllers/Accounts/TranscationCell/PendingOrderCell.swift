//
//  PendingOrderCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 03/10/2024.
//

import UIKit
import SDWebImage

class PendingOrderCell: UITableViewCell {

    
    @IBOutlet weak var symbol_icon: UIImageView!
    @IBOutlet weak var lbl_symbolName: UILabel!
    @IBOutlet weak var lbl_profitValue: UILabel!
    @IBOutlet weak var lbl_currentPriceVolume: UILabel!
    
    var vm = TransactionCellVM()
    var ticketName: String?
    var getSymbol = ""
    var symbolDigit = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        lbl_currentPriceVolume.textColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension PendingOrderCell {
    
    func getCellData(pending: [PendingModel], indexPath: IndexPath) {
        
        let data = pending[indexPath.row]
        
        //        guard let _savedSymbol = vm.getSavedSymbols() else { return }
        //
        //        let savedSymbol = _savedSymbol[indexPath.row]
        
        // Get saved symbols as a dictionary
        guard let savedSymbolsDict = vm.getSavedSymbolsDictionary() else {
            return
        }
        
       
       if data.symbol.contains(".") {
            getSymbol = String(data.symbol.dropLast())
        } else {
            getSymbol = data.symbol
        }
        
        // Retrieve the symbol data using the name as the key
//        if let symbolData = savedSymbolsDict[getSymbol] {
//            // Return the icon_url if a match is found
//            if symbolData.name == "Platinum" {
//                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/silver.png")
//                symbol_icon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
//            }else {
//                let imageUrl = URL(string: symbolData.icon_url)
//                symbol_icon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
//            }
//            
//        }
        
        lbl_symbolName.text = data.symbol
        
        if data.type == 0 {
            ticketName = "Buy"
            
        }else if data.type == 1 {
            ticketName = "Sell"
            
        }else if data.type == 2 {
            ticketName = "Buy Limit"
            
        }else if data.type == 3 {
            ticketName = "Sell Limit"
            
        }else if data.type == 4 {
            ticketName = "Buy Stop"
            
        }else if data.type == 5 {
            ticketName = "Sell Stop"
        }
        
        if let symbolMatch = GlobalVariable.instance.symbolDataArray.firstIndex(where: {$0.name == getSymbol }) {
            let symbolData = GlobalVariable.instance.symbolDataArray[symbolMatch]
         
            let symbolDigits = Int(symbolData.digits) ?? 2
            self.symbolDigit = symbolDigits
        }
        
        let amount = String(format: "%.\(self.symbolDigit)f", data.price)
      
        
        let volume : Double = Double(data.volume) / Double(10000)
        lbl_currentPriceVolume.text = ticketName! + " \(volume)" + " Lots at " + "\(amount)"
      
    }
    
}
