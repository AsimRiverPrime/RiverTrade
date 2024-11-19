//
//  TradingSignalCollectionViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/07/2024.
//

import UIKit

class TradingSignalCollectionViewCell: UICollectionViewCell {
//    @IBOutlet weak var lbl_currencyPair2: UILabel!
    @IBOutlet weak var lbl_currencyPair: UILabel!
    @IBOutlet weak var lbl_days: UILabel!
    @IBOutlet weak var lbl_dateTime: UILabel!
    
//    @IBOutlet weak var lbl_currency2: UILabel!
    @IBOutlet weak var view_chart: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
