//
//  TransactionCell.swift
//  RiverPrime
//
//  Created by Ahmad on 13/07/2024.
//

import UIKit

class TransactionCell: UITableViewCell {

    @IBOutlet weak var symbol_icon: UIImageView!
    @IBOutlet weak var lbl_symbolName: UILabel!
    @IBOutlet weak var lbl_profitValue: UILabel!
    @IBOutlet weak var lbl_currentPrice: UILabel!
    @IBOutlet weak var lbl_openPriceVolume: UILabel!
    
//    var opcDataList: OPCType?
    
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

extension TransactionCell {
    
    func getCellData(open: [OpenModel], indexPath: IndexPath) {
        
        let data = open[indexPath.row]
        
//        guard let _savedSymbol = vm.getSavedSymbols() else { return }
//
//        let savedSymbol = _savedSymbol[indexPath.row]
        
        // Get saved symbols as a dictionary
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
            let imageUrl = URL(string: symbolData.icon_url)
            symbol_icon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
//            vm.loadImage(imageUrl: imageUrl) { [weak self] image in
//                DispatchQueue.main.async {
//                    self?.symbol_icon.image = image
//                }
//            }
        }
        
        lbl_symbolName.text = data.symbol
        
        lbl_profitValue.text = "\(data.priceCurrent)"
     //  lbl_openPriceVolume =  data.action // apply check according to type and also volume value and open price value
        
        lbl_openPriceVolume.text = "Buy 1 Lots at " + "\(data.priceOpen)"
        
    }
    
}
