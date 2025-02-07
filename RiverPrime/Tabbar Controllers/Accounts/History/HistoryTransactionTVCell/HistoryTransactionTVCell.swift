//
//  HistoryTransactionTVCell.swift
//  RiverPrime
//
//  Created by abrar ul haq on 07/02/2025.
//

import UIKit

class HistoryTransactionTVCell: UITableViewCell {

    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    var closeData = NewCloseModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension HistoryTransactionTVCell {
    
    func getCellData(close: [NewCloseModel], indexPath: IndexPath) {
        
//        closeData = close[indexPath.row]
        print("\n closeData in history TV cell :\n \(closeData)")
//      if closeData.action == 2 {
//            commentLbl.text = closeData.repeatedFilteredArray[indexPath.row].comment
//            priceLbl.text = "\(closeData.repeatedFilteredArray[indexPath.row].price)"
//            timeLbl.text = "\(closeData.repeatedFilteredArray[indexPath.row].time)"
//        }
        commentLbl.text = "Deposit"
        priceLbl.text = "1000$"
        timeLbl.text = "12/2/2023 5:54:34" 
    }
    
}
