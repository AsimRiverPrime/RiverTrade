//
//  EconomicCalendarSection.swift
//  RiverPrime
//
//  Created by Ross Rostane on 12/12/2024.
//

import UIKit

class EconomicCalendarSection: UITableViewCell {

    @IBOutlet weak var btn_viewAll: UIButton!
    
    var viewAllAction : () -> () = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func viewAll_btnAction(_ sender: UIButton) {
        self.viewAllAction()
    }
    
}