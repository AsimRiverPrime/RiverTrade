//
//  ResultsFilterViewCell.swift
//  RiverPrime
//
//  Created by Macbook on 23/07/2024.
//

import UIKit

class ResultsFilterViewCell: UITableViewCell {

    @IBOutlet weak var AllRealAccountsFilterButton: UIButton!
    @IBOutlet weak var DaysFilterButton: UIButton!
    
    var onAllRealAccountsFilterButtonClick: (()->Void)?
    var onDaysFilterButton: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func AllRealAccountsFilterButton(_ sender: UIButton) {
        self.onAllRealAccountsFilterButtonClick?()
    }
    
    @IBAction func DaysFilterButton(_ sender: UIButton) {
        self.onDaysFilterButton?()
    }
    
}
