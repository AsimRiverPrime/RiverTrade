//
//  ResultTopViewCell.swift
//  RiverPrime
//
//  Created by Macbook on 23/07/2024.
//

import UIKit

enum ResultTopButtonType{
    case summary
    case exnessBenefits
}

protocol ResultTopDelegate: AnyObject {
//    func resultTopTap(_ resultTopButtonType: ResultTopButtonType, index: Int, completion: @escaping (String) -> Void)
    func resultTopTap(_ resultTopButtonType: ResultTopButtonType, index: Int)
    
}

class ResultTopViewCell: UITableViewCell {

    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var secondTitle: UILabel!
//    @IBOutlet weak var labelAmmount: UILabel!
    @IBOutlet weak var labelStack: UIStackView!
//    @IBOutlet weak var viewOfAccount: UIStackView!
    @IBOutlet weak var viewOfBtnStack: UIView!
        
    @IBOutlet weak var heightOfAccountHeaderView: NSLayoutConstraint!
    @IBOutlet weak var widthOfMainStackView: NSLayoutConstraint!
    
    @IBOutlet weak var Btn_view: UIView!
    @IBOutlet weak var btn_funds: UIButton!
    @IBOutlet weak var btnFundsLineView: UIView!
    
    @IBOutlet weak var btn_Settings: UIButton!
    @IBOutlet weak var btnSettingsLineView: UIView!
    
    weak var delegate: ResultTopDelegate?
   
    var resultTopButtonType: ResultTopButtonType = .summary
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //MARK: - width constraint of main stack view.
        if UIDevice.isPhone {
//            viewOfAccount.spacing = 2
            widthOfMainStackView.constant = 0
        } else {
//            viewOfAccount.spacing = -300
            widthOfMainStackView.constant = -300
        }
        
        btn_funds.tag = 100
        btn_Settings.tag = 200
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setHeaderUI() {
        
        Btn_view.isHidden = false
        headerTitle.text = "Results"
        labelStack.isHidden = false
        viewOfBtnStack.isHidden = false
        secondTitle.text = "#0123456"
        
        changeResultTopButtonView(.summary)
        
    }
    
    func changeResultTopButtonView(_ resultTopButtonType: ResultTopButtonType) {
        
        switch resultTopButtonType {
        case .summary:
            btnFundsLineView.backgroundColor = .systemYellow
            btnSettingsLineView.backgroundColor = .lightGray
            break
        case .exnessBenefits:
            btnFundsLineView.backgroundColor = .lightGray
            btnSettingsLineView.backgroundColor = .systemYellow
            break
        }
        
    }
    
    func getResultTopButtonView(_ resultTopButtonType: ResultTopButtonType) -> String {
        
        switch resultTopButtonType {
        case .summary:
            return "summary"
        case .exnessBenefits:
            return "exnessBenefits"
        }
        
    }
    
    @IBAction func fundsBtnAction(_ sender: Any) {
        changeResultTopButtonView(.summary)
        delegate?.resultTopTap(.summary, index: (sender as AnyObject).tag)
    }
    @IBAction func settingsBtnAction(_ sender: Any) {
        changeResultTopButtonView(.exnessBenefits)
        delegate?.resultTopTap(.exnessBenefits, index: (sender as AnyObject).tag)
    }

}
