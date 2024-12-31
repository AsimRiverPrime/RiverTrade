//
//  TimeFrameTVCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 31/10/2024.
//

import UIKit

class TimeFrameTVCell: UITableViewCell {

    @IBOutlet weak var lbl_timeValue: UILabel!
    @IBOutlet weak var img_checkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
