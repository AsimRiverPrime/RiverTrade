//
//  TicketVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 14/08/2024.
//

import UIKit

class TicketVC: BottomSheetController {
    
    @IBOutlet weak var lbl_title: UILabel!
    //MARK: - volume Outlets
    @IBOutlet weak var tf_volume: UITextField!
    @IBOutlet weak var lbl_volumeDropdown: UILabel!
    @IBOutlet weak var lbl_volumeFees: UILabel!
    @IBOutlet weak var lbl_volumeMargin: UILabel!
    @IBOutlet weak var lbl_volumeLeverage: UILabel!
    //MARK: - price Outlets
    @IBOutlet weak var price_view: CardView!
    @IBOutlet weak var lbl_PriceDropdown: UILabel!
    @IBOutlet weak var tf_priceValue: UITextField!
    @IBOutlet weak var lbl_currentPriceValue: UILabel!
    //MARK: - takeProfile Outlets
    
    @IBOutlet weak var takeProfit_switch: UISwitch!
    @IBOutlet weak var tf_takeProfit: UITextField!
    @IBOutlet weak var lbl_takeProfitDropDown: UILabel!
    @IBOutlet weak var takeProfit_view: UIStackView!
    @IBOutlet weak var liveValue_view: UIStackView!
    @IBOutlet weak var lbl_liveProfitLoss: UILabel!
    @IBOutlet weak var lbl_profitLossPips: UILabel!
    @IBOutlet weak var lbl_profitLossPercentage: UILabel!
    @IBOutlet weak var takeProfit_height: NSLayoutConstraint!
    @IBOutlet weak var clearTakeProfit_btn: UIButton!
    
    //MARK: - stop Loss Outlets
    @IBOutlet weak var stopLoss_switch: UISwitch!
    @IBOutlet weak var tf_stopLoss: UITextField!
    @IBOutlet weak var lbl_stopLossDropDown: UILabel!
    @IBOutlet weak var stopLoss_view: UIStackView!
    @IBOutlet weak var stopLossLiveValue_view: UIStackView!
    @IBOutlet weak var lbl_liveStopLoss: UILabel!
    @IBOutlet weak var lbl_stopLossPips: UILabel!
    @IBOutlet weak var lbl_stopLossPercentage: UILabel!
    @IBOutlet weak var stopLoss_height: NSLayoutConstraint!
    @IBOutlet weak var clearStoploss_btn: UIButton!
    
    @IBOutlet weak var lbl_SL: UILabel!
    @IBOutlet weak var lbl_TP: UILabel!
    @IBOutlet weak var lbl_limit: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateStopLossView()
        updateProfitView()
        
    }
    //MARK: - volume actions
    @IBAction func volumeMinus_action(_ sender: Any) {
    }
    @IBAction func volumePlus_action(_ sender: Any) {
    }
    @IBAction func volume_dropDownAction(_ sender: Any) {
    }
    //MARK: - price actions
    @IBAction func price_dropDownAction(_ sender: Any) {
    }
    
    @IBAction func priceMinus_action(_ sender: Any) {
    }
    @IBAction func pricePlus_action(_ sender: Any) {
    }
    //MARK: - take Profit actions
    @IBAction func takeProfile_switchAction(_ sender: UISwitch) {
        updateProfitView()
      
    }
    
    @IBAction func takeProfit_dropDownAction(_ sender: Any) {
    }
    
    
    @IBAction func takeProfitMinus_action(_ sender: Any) {
    }
    
    @IBAction func takeProfitPlus_action(_ sender: Any) {
    }
    
    @IBAction func profit_clearAction(_ sender: Any) {
        lbl_TP.isHidden = true
        liveValue_view.isHidden = true
        tf_takeProfit.text = ""
        tf_takeProfit.placeholder = "not set"
        
    }
    //MARK: - stop Loss actions
    
    @IBAction func stopLoss_switchAction(_ sender: UISwitch) {
       updateStopLossView()
    }
    
    @IBAction func stopLoss_dropDownAction(_ sender: Any) {
        
    }
    
    @IBAction func stopLossMinus_action(_ sender: Any) {
        
    }
    
    @IBAction func stopLossPlus_action(_ sender: Any) {
        
    }
    
    @IBAction func cancel_btnAction(_ sender: Any) {
    }
    
    @IBAction func submit_btnAction(_ sender: Any) {
    }
    @IBAction func stopLoss_clearAction(_ sender: Any) {
        lbl_SL.isHidden = true
        stopLossLiveValue_view.isHidden = true
        tf_stopLoss.text = ""
        tf_stopLoss.placeholder = "not set"
    }
    
    private func updateProfitView() {
           if takeProfit_switch.isOn {
               lbl_TP.isHidden = false
               clearTakeProfit_btn.isHidden = false
               takeProfit_view.isHidden = false
               liveValue_view.isHidden = false
               takeProfit_height.constant = 110 // Original height
           } else {
               lbl_TP.isHidden = true
               clearTakeProfit_btn.isHidden = true
               takeProfit_view.isHidden = true
               liveValue_view.isHidden = true
               takeProfit_height.constant = 30
           }
//           UIView.animate(withDuration: 0.2) {
//               self.view.layoutIfNeeded()
//           }
       }
    private func updateStopLossView() {
           if stopLoss_switch.isOn {
               lbl_SL.isHidden = false
               clearStoploss_btn.isHidden = false
               stopLoss_view.isHidden = false
               stopLossLiveValue_view.isHidden = false
               stopLoss_height.constant = 110 // Original height
           } else {
               lbl_SL.isHidden = true
               clearStoploss_btn.isHidden = true
               stopLoss_view.isHidden = true
               stopLossLiveValue_view.isHidden = true
               stopLoss_height.constant = 30
           }
//           UIView.animate(withDuration: 0.3) {
//               self.view.layoutIfNeeded()
//           }
       }
}
