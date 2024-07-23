//
//  BenefitsTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 23/07/2024.
//

import UIKit

class BenefitsTableViewCell: UITableViewCell {

    @IBOutlet weak var negativeBtnAction: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func negativeBtnAction(_ sender: Any) {
        
    }
    @IBAction func virtualBtnAction(_ sender: Any) {
    }
    
    
}
