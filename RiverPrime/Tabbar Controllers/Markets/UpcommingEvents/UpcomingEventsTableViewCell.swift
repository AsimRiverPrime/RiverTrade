//
//  UpcomingEventsTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 18/07/2024.
//

import UIKit

class UpcomingEventsTableViewCell: UITableViewCell {

    @IBOutlet weak var countryIcon: UIImageView!
    @IBOutlet weak var lbl_event: UILabel!
    @IBOutlet weak var firstIcon: UIImageView!
    @IBOutlet weak var secondIcon: UIImageView!
    @IBOutlet weak var thridIcon: UIImageView!
    @IBOutlet weak var lbl_date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
