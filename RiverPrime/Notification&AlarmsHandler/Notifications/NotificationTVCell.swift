//
//  NotificationTVCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 15/01/2025.
//

import UIKit

class NotificationTVCell: UITableViewCell {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_status: UILabel!
    @IBOutlet weak var lbl_date: UILabel!
    
    @IBOutlet weak var view_Unseen: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
