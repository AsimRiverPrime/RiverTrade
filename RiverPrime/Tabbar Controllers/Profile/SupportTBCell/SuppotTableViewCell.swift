//
//  SuppotTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 23/07/2024.
//

import UIKit

class SuppotTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func helpCenterAction(_ sender: Any) {
        openLink("https://www.riverprime.com/en/contactUs")
    }
    @IBAction func liveChatAction(_ sender: Any) {
        openLink("https://portal.riverprime.com/en/live_signup?brd=1&is_ib=1")
    }
    @IBAction func legalDocumentAction(_ sender: Any) {
        openLink("https://riverprime.com/en/Regulations")
    }
    @IBAction func rateAppAction(_ sender: Any) {
    }
    
    func openLink(_ urlString: String) {
           if let url = URL(string: urlString) {
               UIApplication.shared.open(url, options: [:], completionHandler: nil)
           }
       }
    
}
