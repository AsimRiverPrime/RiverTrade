//
//  withDrawTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit

class withDrawTableViewCell: UITableViewCell {

    @IBOutlet weak var cardBankIcon: UIImageView!
    @IBOutlet weak var lblBankTitle: UILabel!
    
    @IBOutlet weak var lblProcessTime: UILabel!
        
    @IBOutlet weak var lblFee: UILabel!
    @IBOutlet weak var lblLimits: UILabel!
    @IBOutlet weak var lockBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
