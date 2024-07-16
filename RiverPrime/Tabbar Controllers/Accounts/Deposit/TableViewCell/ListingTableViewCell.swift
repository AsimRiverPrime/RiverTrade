//
//  ListingTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit

class ListingTableViewCell: UITableViewCell {

        @IBOutlet weak var lblTitle: UILabel!
        @IBOutlet weak var lblprocess: UILabel!
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
//        
//        func config(obj : ListEntity) {
//            lblTitle.text = obj.name
//            lblDetail.text = obj.country
//        }
    }
