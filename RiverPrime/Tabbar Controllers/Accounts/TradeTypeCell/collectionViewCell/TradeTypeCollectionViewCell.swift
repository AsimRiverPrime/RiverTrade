//
//  TradeTypeCollectionViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 15/07/2024.
//

import UIKit

class TradeTypeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lbl_tradetype: UILabel!
    
    @IBOutlet weak var selectedColorView: UIView!
    @IBOutlet weak var sepratorView: UIView!
    @IBOutlet weak var refreshImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
//        return contentView.systemLayoutSizeFitting(CGSize(width: self.bounds.size.width, height: 1))
//    }

}
