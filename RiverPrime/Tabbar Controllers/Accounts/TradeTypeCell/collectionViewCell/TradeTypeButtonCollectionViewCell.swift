//
//  TradeTypeButtonCollectionViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/08/2024.
//

import UIKit

class TradeTypeButtonCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var refreshImageButton: UIButton!
    var onRefreshImageButtonClick: ((UIButton)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        refreshImageButton.setTitle("", for: .normal)
    }
    
    @IBAction func refreshImageButton(_ sender: UIButton) {
        self.onRefreshImageButtonClick?(sender)
    }
    
}
