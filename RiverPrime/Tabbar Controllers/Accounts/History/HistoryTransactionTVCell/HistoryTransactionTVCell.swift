//
//  HistoryTransactionTVCell.swift
//  RiverPrime
//
//  Created by abrar ul haq on 07/02/2025.
//

import UIKit

class HistoryTransactionTVCell: UITableViewCell {

    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    var closeData = NewCloseModel()
//    var transcationCloseData = CloseModel
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension HistoryTransactionTVCell {
 
    func configure(with model: RiverPrime.CloseModel) {
//        print("\n transcationData in history TV cell :\n \(model)")
        
        let createDate = Date(timeIntervalSince1970: Double(model.time))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.timeZone = .current
        
        let datee = dateFormatter.string(from: createDate)
            
        timeLbl.text = "\(datee)"
        
        if model.profit < 0 {
            priceLbl.textColor = UIColor(red: 217/255.0, green: 94/255.0, blue: 90/255.0, alpha: 1.0) // red
            priceLbl.text = "$\(String.formatStringNumber(String(model.profit)))"
        }else{
            priceLbl.textColor = UIColor(red: 116/255.0, green: 202/255.0, blue: 143/255.0, alpha: 1.0) //.systemGreen
            priceLbl.text = "$\(String.formatStringNumber(String(model.profit)))"
           
        }
        
      }
}
