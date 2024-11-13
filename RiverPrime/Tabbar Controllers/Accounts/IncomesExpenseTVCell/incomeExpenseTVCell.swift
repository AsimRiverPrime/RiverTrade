//
//  incomeExpenseTVCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 13/11/2024.
//

import UIKit

class incomeExpenseTVCell: UITableViewCell {

    @IBOutlet weak var lbl_incomePrice: UILabel!
    @IBOutlet weak var lbl_income: UILabel!
    @IBOutlet weak var incomeChart: UIView!
    
    @IBOutlet weak var lbl_expensePrice: UILabel!
    @IBOutlet weak var lbl_Expense: UILabel!
    @IBOutlet weak var expenseChart: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
