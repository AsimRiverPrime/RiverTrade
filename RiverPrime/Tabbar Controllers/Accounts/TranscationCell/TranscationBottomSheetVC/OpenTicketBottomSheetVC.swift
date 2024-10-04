//
//  OpenTicketBottomSheetVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 04/10/2024.
//

import UIKit

class OpenTicketBottomSheetVC: UIViewController {

    @IBOutlet weak var lbl_ticketName: UILabel!
    @IBOutlet weak var lbl_positionNumber: UILabel!
    @IBOutlet weak var lbl_symbolName: UILabel!
    @IBOutlet weak var lbl_dateTime: UILabel!
    
    @IBOutlet weak var lbl_partialCloseValue: UILabel!
    @IBOutlet weak var partialClose_View: UIStackView!
    @IBOutlet weak var partialCose_switch: UISwitch!
    
    @IBOutlet weak var tf_takeProfit: UITextField!
    @IBOutlet weak var takeProfit_View: UIStackView!
    @IBOutlet weak var stopLoss_view: UIStackView!
    
    @IBOutlet weak var tf_stopLoss: UITextField!
    @IBOutlet weak var btn_closePosition: UIButton!
    @IBOutlet weak var takeProfit_switch: UISwitch!
    @IBOutlet weak var stopLoss_switch: UISwitch!
    
//    var openData: OPCNavigationType?
    var openData: OpenModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("openData = \(openData)")
    }
    
    @IBAction func partialSwitch_action(_ sender: Any) {
    }
    
    @IBAction func partialMinus_actoin(_ sender: Any) {
    }
    
    @IBAction func partialPlus_action(_ sender: Any) {
    }
    
    @IBAction func tpMinus_action(_ sender: Any) {
    }
    
    @IBAction func tpPlus_action(_ sender: Any) {
    }
    
    @IBAction func takeProfitDropDown_action(_ sender: Any) {
    }
    
    @IBAction func takeProfit_switchAction(_ sender: Any) {
    }
    
    @IBAction func stopLossMinus_action(_ sender: Any) {
    }
    
    @IBAction func stopLossPlus_action(_ sender: Any) {
    }
    
    @IBAction func stopLossDropdown_action(_ sender: Any) {
    }
    
    @IBAction func stopLoss_Switch(_ sender: Any) {
    }
    
    @IBAction func cancel_action(_ sender: Any) {
    }
    
    @IBAction func closePosition_action(_ sender: Any) {
    }
    
    @IBAction func save_action(_ sender: Any) {
    }
    
}
