//
//  TradeTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 12/07/2024.
//

import UIKit

class TradeTableViewCell: UITableViewCell {

    @IBOutlet weak var currencyICon: UIImageView!
    @IBOutlet weak var lblCurrencySymbl: UILabel!
    @IBOutlet weak var lblCurrencyName: UILabel!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblPercent: UILabel!
    @IBOutlet weak var profitIcon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
