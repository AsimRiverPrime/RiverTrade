//
//  TopNewsTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 18/07/2024.
//

import UIKit

class TopNewsTableViewCell: UITableViewCell {


    @IBOutlet weak var firstIcon: UIImageView!
    @IBOutlet weak var secondIcon: UIImageView!
    @IBOutlet weak var thridIcon: UIImageView!
    //    @IBOutlet weak var btn_favirate: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    @IBAction func favirateBtn_action(_ sender: Any) {
//        self.btn_favirate.isSelected = !self.btn_favirate.isSelected
//        self.btn_favirate.setImage(!self.btn_favirate.isSelected ? UIImage(systemName: "star") : UIImage(systemName: "star.fill"), for: .normal)
//        self.btn_favirate.tintColor = self.btn_favirate.isSelected ? .systemYellow : .lightGray
//    }
    
}
