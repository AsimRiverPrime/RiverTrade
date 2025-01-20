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
    
    func configure(with payload: PayloadItem) {
        
        self.lbl_title.text = payload.title
      
        if let date = DateHelper.convertToDate(from: payload.date) {
            self.lbl_date.text = DateHelper.timeAgo1(from: date)
        } else {
            print("Failed to convert date string to Date")
        }
      
        switch payload.importance{
        case 1:
            firstIcon.image = UIImage(named: "fireIconSelect")
            secondIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
            thridIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
        case 2:
            firstIcon.image = UIImage(named: "fireIconSelect")
            secondIcon.image = UIImage(named: "fireIconSelect")
            thridIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
        case 3:
            firstIcon.image = UIImage(named: "fireIconSelect")
            secondIcon.image = UIImage(named: "fireIconSelect")
            thridIcon.image = UIImage(named: "fireIconSelect")
        default:
            firstIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
            secondIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
            thridIcon.image = UIImage(named: "fireIconSelect")?.tint(with: .lightGray)
        }
        
      }
    
//    @IBAction func favirateBtn_action(_ sender: Any) {
//        self.btn_favirate.isSelected = !self.btn_favirate.isSelected
//        self.btn_favirate.setImage(!self.btn_favirate.isSelected ? UIImage(systemName: "star") : UIImage(systemName: "star.fill"), for: .normal)
//        self.btn_favirate.tintColor = self.btn_favirate.isSelected ? .systemYellow : .lightGray
//    }
    
}
