//
//  SelectAccountTypeCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 24/12/2024.
//

import UIKit

class SelectAccountTypeCell: UITableViewCell {

    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_group: UILabel!
    @IBOutlet weak var lbl_loginID: UILabel!
    @IBOutlet weak var lbl_balance: UILabel!
    @IBOutlet weak var btn_checkAccount: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
