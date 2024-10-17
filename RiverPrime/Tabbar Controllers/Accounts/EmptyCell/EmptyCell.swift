//
//  EmptyCell.swift
//  RiverPrime
//
//  Created by abrar ul haq on 18/10/2024.
//

import UIKit

class EmptyCell: UITableViewCell {

    @IBOutlet weak var emptyLabelMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
