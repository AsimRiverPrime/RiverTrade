//
//  CloseOrderCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 03/10/2024.
//

import UIKit

class CloseOrderCell: UITableViewCell {

    
    @IBOutlet weak var symbol_icon: UIImageView!
    @IBOutlet weak var lbl_symbolName: UILabel!
    @IBOutlet weak var lbl_profitValue: UILabel!
    @IBOutlet weak var lbl_timeValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
