//
//  ResultsFilterViewCell.swift
//  RiverPrime
//
//  Created by Macbook on 23/07/2024.
//

import UIKit

enum ResultFilterButtonType{
    case summaryAccountFilter
    case summaryDaysFilter
    case benefitsAccountFilter
}

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
            
            self.changeResultTopButtonView(.benefitsAccountFilter)
        } else { //summary
            SummaryAccountsFilterView.isHidden = false
            SummaryDaysFilterView.isHidden = false
            BenefitsAccountsFilterView.isHidden = true
            
            self.changeResultTopButtonView(.summaryAccountFilter)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func AllRealAccountsFilterButton(_ sender: UIButton) {
        self.changeResultTopButtonView(.summaryAccountFilter)
        self.onAllRealAccountsFilterButtonClick?()
    }
    
    @IBAction func DaysFilterButton(_ sender: UIButton) {
        self.changeResultTopButtonView(.summaryDaysFilter)
        self.onDaysFilterButton?()
    }
    
    @IBAction func BenefitsAllRealAccountsFilterButton(_ sender: UIButton) {
        self.changeResultTopButtonView(.benefitsAccountFilter)
        self.onBenefitsAllRealAccountsFilterButtonClick?()
    }
    
    func changeResultTopButtonView(_ resultFilterButtonType: ResultFilterButtonType) {
        
        switch resultFilterButtonType {
        case .summaryAccountFilter:
            SummaryAccountsFilterView.backgroundColor = .systemYellow
            SummaryDaysFilterView.backgroundColor = .lightGray
            BenefitsAccountsFilterView.backgroundColor = .lightGray
            break
        case .summaryDaysFilter:
            SummaryAccountsFilterView.backgroundColor = .lightGray
            SummaryDaysFilterView.backgroundColor = .systemYellow
            BenefitsAccountsFilterView.backgroundColor = .lightGray
            break
        case .benefitsAccountFilter:
            SummaryDaysFilterView.backgroundColor = .lightGray
            SummaryAccountsFilterView.backgroundColor = .lightGray
            BenefitsAccountsFilterView.backgroundColor = .systemYellow
            break
        }
        
    }
    
}
