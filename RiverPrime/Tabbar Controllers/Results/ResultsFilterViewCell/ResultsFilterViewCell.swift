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
    
    @IBOutlet weak var SummaryAccountsFilterView: CardView!
    @IBOutlet weak var SummaryDaysFilterView: CardView!
    @IBOutlet weak var BenefitsAccountsFilterView: CardView!
    
//    weak var delegate: ResultTopDelegate?
//    var resultTopButtonType = String()
    
    var onAllRealAccountsFilterButtonClick: (()->Void)?
    var onDaysFilterButton: (()->Void)?
    var onBenefitsAllRealAccountsFilterButtonClick: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        print("resultTopButtonType = \(resultTopButtonType)")
        print("GlobalVariable.instance.resultTopButtonType = \(GlobalVariable.instance.resultTopButtonType)")
        
        if GlobalVariable.instance.resultTopButtonType == "exnessBenefits" { //exnessBenefits
            SummaryAccountsFilterView.isHidden = true
            SummaryDaysFilterView.isHidden = true
            BenefitsAccountsFilterView.isHidden = false
        } else { //summary
            SummaryAccountsFilterView.isHidden = false
            SummaryDaysFilterView.isHidden = false
            BenefitsAccountsFilterView.isHidden = true
        }
        
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
    
    @IBAction func BenefitsAllRealAccountsFilterButton(_ sender: UIButton) {
        self.onBenefitsAllRealAccountsFilterButtonClick?()
    }
    
}
