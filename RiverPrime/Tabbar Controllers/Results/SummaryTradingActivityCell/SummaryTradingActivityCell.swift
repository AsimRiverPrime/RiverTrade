//
//  SummaryTradingActivityCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 31/07/2024.
//

import UIKit

class SummaryTradingActivityCell: UITableViewCell {

    @IBOutlet weak var warningImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var SelectLabel: UILabel!
    @IBOutlet weak var TradeButton: UIButton!
    
    var onTradeButtonClick: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        styling()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func TradeButton(_ sender: UIButton) {
        self.onTradeButtonClick?()
    }
    
}

extension SummaryTradingActivityCell {
    
    private func styling() {
        //MARK: - Fonts
        titleLabel.font = FontController.Fonts.Inter_Medium.font
        SelectLabel.font = FontController.Fonts.Inter_Regular.font
        TradeButton.titleLabel?.font = FontController.Fonts.Inter_Medium.font
        
        //MARK: - Labels
        titleLabel.text = LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.SummaryTradingActivityCellScreen.title.localized)
        SelectLabel.text = LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.SummaryTradingActivityCellScreen.selectedText.localized)
        TradeButton.setTitle(LabelTranslation.labelTranslation.getLocalizedString(value: LabelTranslation.SummaryTradingActivityCellScreen.tradeButton.localized), for: .normal)
    }
    
}
