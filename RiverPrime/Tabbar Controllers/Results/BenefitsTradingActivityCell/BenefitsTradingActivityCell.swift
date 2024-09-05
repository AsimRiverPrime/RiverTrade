//
//  BenefitsTradingActivityCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 31/07/2024.
//

import UIKit

class BenefitsTradingActivityCell: UITableViewCell {

    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var seperator: UIView!
    @IBOutlet weak var warningImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var SelectLabel: UILabel!
    @IBOutlet weak var TradeButton: UIButton!
    
    var onStartTradingButtonClick: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        styling()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func TradeButton(_ sender: UIButton) {
        self.onStartTradingButtonClick?()
    }
    
}

extension BenefitsTradingActivityCell {
    
    private func styling() {
        //MARK: - Fonts
        mainTitleLabel.font = FontController.Fonts.Inter_Regular.font
        titleLabel.font = FontController.Fonts.Inter_Medium.font
        SelectLabel.font = FontController.Fonts.Inter_Regular.font
        TradeButton.titleLabel?.font = FontController.Fonts.Inter_Medium.font
        
        //MARK: - Labels
        mainTitleLabel.text = LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.BenefitsTradingActivityCell.mainTitle.localized)
        titleLabel.text = LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.BenefitsTradingActivityCell.title.localized)
        SelectLabel.text = LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.BenefitsTradingActivityCell.selectedText.localized)
        TradeButton.setTitle(LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.BenefitsTradingActivityCell.tradeButton.localized), for: .normal)
    }
    
}
