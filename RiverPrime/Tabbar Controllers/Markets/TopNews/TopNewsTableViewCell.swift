//
//  TopNewsTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 18/07/2024.
//

import UIKit

class TopNewsTableViewCell: UITableViewCell {

    @IBOutlet weak var viewAllButton: UIButton!
    
    var viewAllAction : () -> () = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       // self.viewAllButton.addTarget(self, action: #selector(viewAll_btnAction(_:)), for: .touchUpInside)

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func viewAll_btnAction(_ sender: UIButton) {
        viewAllAction()
    }
    
}
