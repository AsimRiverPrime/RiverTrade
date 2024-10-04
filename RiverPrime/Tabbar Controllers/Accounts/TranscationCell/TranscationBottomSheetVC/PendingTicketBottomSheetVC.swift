//
//  PendingTicketBottomSheetVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 04/10/2024.
//

import UIKit

class PendingTicketBottomSheetVC: UIViewController {

    @IBOutlet weak var lbl_ticketName: UILabel!
    @IBOutlet weak var lbl_positionNumber: UILabel!
    @IBOutlet weak var lbl_symbolName: UILabel!
    @IBOutlet weak var lbl_dateTime: UILabel!
    @IBOutlet weak var lbl_volumePrice: UILabel!
    
    @IBOutlet weak var tf_price: UITextField!
    @IBOutlet weak var tf_takeProfit: UITextField!
    @IBOutlet weak var tf_stopLoss: UITextField!
    
    var pendingData: PendingModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("pendingData = \(pendingData)")
    }
    
    @IBAction func priceMinus_actoin(_ sender: Any) {
    }
    
    @IBAction func pricePlus_action(_ sender: Any) {
    }
    
    @IBAction func tpMinus_action(_ sender: Any) {
    }
    
    @IBAction func tpPlus_action(_ sender: Any) {
    }
    
    @IBAction func takeProfitDropDown_action(_ sender: Any) {
    }
    
    @IBAction func stopLossMinus_action(_ sender: Any) {
    }
    
    @IBAction func stopLossPlus_action(_ sender: Any) {
    }
    
    @IBAction func stopLossDropdown_action(_ sender: Any) {
    }
    
    @IBAction func cancel_action(_ sender: Any) {
    }
    
    @IBAction func deleteOrder_action(_ sender: Any) {
    }
    
    @IBAction func save_action(_ sender: Any) {
    }
    
}
