//
//  CloseOrderCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 03/10/2024.
//

import UIKit
import SDWebImage

class CloseOrderCell: UITableViewCell {

    
    @IBOutlet weak var symbol_icon: UIImageView!
    @IBOutlet weak var lbl_symbolName: UILabel!
    @IBOutlet weak var lbl_profitValue: UILabel!
    @IBOutlet weak var lbl_timeValue: UILabel!
    
    var vm = TransactionCellVM()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension CloseOrderCell {
    func getCellData(close: [NewCloseModel], indexPath: IndexPath) {
        
        let data = close[indexPath.row]
        
        guard let savedSymbolsDict = vm.getSavedSymbolsDictionary() else {
            return
        }
        
        var getSymbol = ""
        
        if data.symbol.contains("..") {
            getSymbol = String(data.symbol.dropLast())
            getSymbol = String(getSymbol.dropLast())
        } else if data.symbol.contains(".") {
            getSymbol = String(data.symbol.dropLast())
        } else {
            getSymbol = data.symbol
        }
        
        // Retrieve the symbol data using the name as the key
        if let symbolData = savedSymbolsDict[getSymbol] {
            // Return the icon_url if a match is found
            if symbolData.name == "Platinum" {
                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/silver.png")
                symbol_icon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }else {
                let imageUrl = URL(string: symbolData.icon_url)
                symbol_icon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }
            
        }
        
        lbl_symbolName.text = data.symbol
        
        let createDate = Date(timeIntervalSince1970: Double(data.LatestTime))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.timeZone = .current
        
        let datee = dateFormatter.string(from: createDate)
        
        lbl_timeValue.text = datee
        
        if data.totalProfit < 0 {
            lbl_profitValue.textColor = .systemRed
        }else{
            lbl_profitValue.textColor = .systemGreen
        }
        
        lbl_profitValue.text = "$\(data.totalProfit)".trimmedTrailingZeros()
        
        
    }
    
}
