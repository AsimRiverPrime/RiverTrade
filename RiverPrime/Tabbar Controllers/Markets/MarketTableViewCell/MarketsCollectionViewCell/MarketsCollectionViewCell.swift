//
//  MarketsCollectionViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/07/2024.
//

import UIKit

class MarketsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var img_currency: UIImageView!
    @IBOutlet weak var lbl_currencyPair: UILabel!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var lbl_price: UILabel!
    @IBOutlet weak var img_profitLossIcon: UIImageView!
    @IBOutlet weak var lbl_profitLossPercentage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
