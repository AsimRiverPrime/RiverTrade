//
//  HistoryTransactionTotalTVCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 10/02/2025.
//

import UIKit

class HistoryTransactionTotalTVCell: UITableViewCell {

    @IBOutlet weak var lbl_totalDeposit: UILabel!
    @IBOutlet weak var lbl_totalwithdraw: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
