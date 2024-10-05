//
//  PendingTicketBottomSheetVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 04/10/2024.
//

import UIKit

class PendingTicketBottomSheetVC: BaseViewController {

    @IBOutlet weak var lbl_ticketName: UILabel!
    @IBOutlet weak var lbl_positionNumber: UILabel!
    @IBOutlet weak var lbl_symbolName: UILabel!
    @IBOutlet weak var lbl_dateTime: UILabel!
    @IBOutlet weak var lbl_volumePrice: UILabel!
    
    @IBOutlet weak var tf_price: UITextField!
    @IBOutlet weak var tf_takeProfit: UITextField!
    @IBOutlet weak var tf_stopLoss: UITextField!
    @IBOutlet weak var takeProfit_View: UIStackView!
    @IBOutlet weak var takeProfit_switch: UISwitch!
    @IBOutlet weak var stopLoss_switch: UISwitch!
    
    @IBOutlet weak var stopLoss_view: UIStackView!
    
    var pendingData: PendingModel?
    
    var takeProfitList = ["Profit in %", "Profit in USD", "Profit in Pips","Profit in Price"]
    var stopLossList = ["Loss in %", "Loss in USD", "Loss in Pips","Loss in Price"]
    
    var currentValue: Double = 0.0
    var currentValue1: Double = 0.0
    var currentValue2: Double = 0.0
    var currentValue3: Double = 0.0
    
    var ticketName: String?
    //    var openData: OPCNavigationType?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopLoss_switch.isOn = false
        takeProfit_switch.isOn = false
        self.takeProfit_View.isUserInteractionEnabled = false
        self.stopLoss_view.isUserInteractionEnabled = false
        

        self.lbl_symbolName.text = pendingData?.symbol
        self.lbl_positionNumber.text = "#\(pendingData?.position ?? 0)"
        
        //        if openData?.action == 0 {
        //            ticketName = "Buy Ticket"
        //        }else if openData?.action == 1 {
        //            ticketName = "Sell Ticket"
        //        }else if openData?.action == 2 {
        //            ticketName = "Sell Ticket"
        //        }else if openData?.action == 3 {
        //            ticketName = "Sell Ticket"
        //        }else if openData?.action == 4 {
        //            ticketName = "Sell Ticket"
        //        }else if openData?.action == 5 {
        //            ticketName = "Sell Ticket"
        //        }
        if pendingData?.action == 1 {
            ticketName = "Buy Ticket"
        }else {
            ticketName = "Sell Ticket"
        }
        self.lbl_ticketName.text = ticketName
        let time = timeConvert()
        self.lbl_dateTime.text = "Time: " + time
        self.lbl_volumePrice.text = "Buy Limit 0.04 Lot at " + "\(pendingData?.price ?? 0)"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    func timeConvert() -> String {
        
        let createDate = Date(timeIntervalSince1970: Double(pendingData!.time) / 1000.0)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.timeZone = .current
        
        let datee = dateFormatter.string(from: createDate)
        
        return datee
    }
    @objc func hideKeyboard() {
        view.endEditing(true)  // This will dismiss the keyboard for all text fields
    }
    
    
    @IBAction func priceMinus_actoin(_ sender: Any) {
        updateValue(for: tf_price, increment: false)
    }
    
    @IBAction func pricePlus_action(_ sender: Any) {
        updateValue(for: tf_price, increment: true)
    }
    
    @IBAction func tpMinus_action(_ sender: Any) {
        updateValue(for: tf_takeProfit, increment: false)
    }
    
    @IBAction func tpPlus_action(_ sender: Any) {
        updateValue(for: tf_takeProfit, increment: true)
    }
    
    @IBAction func takeProfitDropDown_action(_ sender: Any) {
        self.dynamicDropDownButtonForTakeProfit(sender as! UIButton, list: stopLossList) { index, item in
            print("drop down index = \(index)")
            print("drop down item = \(item)")
           
        }
    }
    
    @IBAction func takeProfit_switchAction(_ sender: UISwitch) {
        
        if sender.isOn {
            self.takeProfit_View.isUserInteractionEnabled = true
            self.tf_takeProfit.text = "\(pendingData?.takeProfit ?? 0)"
            self.currentValue2 = pendingData?.takeProfit ?? 0
           
        }else{
            self.takeProfit_View.isUserInteractionEnabled = false
            self.tf_takeProfit.text = ""
        }
    }
    
    @IBAction func stopLossMinus_action(_ sender: Any) {
        updateValue(for: tf_stopLoss, increment: false)
    }
    
    @IBAction func stopLossPlus_action(_ sender: Any) {
        updateValue(for: tf_stopLoss, increment: true)
    }
    
    @IBAction func stopLossDropdown_action(_ sender: Any) {
        self.dynamicDropDownButtonForTakeProfit(sender as! UIButton, list: stopLossList) { index, item in
            print("drop down index = \(index)")
            print("drop down item = \(item)")
           
        }
    }
    
    @IBAction func stopLoss_Switch(_ sender: UISwitch) {
        if sender.isOn {
            self.stopLoss_view.isUserInteractionEnabled = true
            self.tf_stopLoss.text = "\(pendingData?.stopLoss ?? 0)"
            self.currentValue3 = pendingData?.stopLoss ?? 0
           
        }else{
            self.stopLoss_view.isUserInteractionEnabled = false
            self.tf_stopLoss.text = ""
        }
    }
    
    @IBAction func cancel_action(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            print("Bottom sheet dismissed on cancel btn press")
        })
    }
    
    @IBAction func closePosition_action(_ sender: Any) {
    }
    
    @IBAction func save_action(_ sender: Any) {
    }
    
    func updateValue(for textField: UITextField, increment: Bool) {
        let step: Double = 0.01 // You can adjust the step value (e.g., 0.1 for increments in decimal)
        
        // Determine which text field is being updated and get its current value
        switch textField {
        case tf_price:
            currentValue = currentValue1
        case tf_takeProfit:
            currentValue = currentValue2
        case tf_stopLoss:
            currentValue = currentValue3
     
        default:
            return
        }
        // Update the value based on increment or decrement
        if increment {
            currentValue += step
            
        } else {
            if currentValue > 0 {
                currentValue -= step
            }
        }
        
        // Update the specific text field and save the new value
        textField.text = String(format: "%.3f", currentValue)
        
        // Save the updated current value back to the respective variable
        switch textField {
        case tf_price:
            currentValue1 = currentValue
        case tf_takeProfit:
            currentValue2 = currentValue
        case tf_stopLoss:
            currentValue3 = currentValue
      
        default:
            break
        }
    }
    
}
