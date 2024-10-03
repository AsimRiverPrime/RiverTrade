//
//  RefferalProgramTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 23/07/2024.
//

import UIKit

class RefferalProgramTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func referralBtnAction(_ sender: Any) {
        print("Refferal btn action")
       
        if let url = URL(string: "https://riverprime.com/en/Partnership-Broker") {
                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
               }
           
    }
    
}
