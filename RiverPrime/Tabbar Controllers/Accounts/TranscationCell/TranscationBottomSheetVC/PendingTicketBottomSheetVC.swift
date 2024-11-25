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
//    @IBOutlet weak var lbl_symbolName: UILabel!
    @IBOutlet weak var image_SymbolIcon: UIImageView!
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
    var viewModel = TradeTypeCellVM()
    var vm = TransactionCellVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopLoss_switch.isOn = false
        takeProfit_switch.isOn = false
        self.takeProfit_View.isUserInteractionEnabled = false
        self.stopLoss_view.isUserInteractionEnabled = false
        
        
//        self.lbl_symbolName.text = pendingData?.symbol
        self.lbl_positionNumber.text = "#\(pendingData?.order ?? 0) |"
        
        if pendingData?.type == 0 {
            ticketName = "Buy"
            self.lbl_ticketName.text = "Buy Ticket"
        }else if pendingData?.type == 1 {
            ticketName = "Sell"
            self.lbl_ticketName.text = "Sell Ticket"
        }else if pendingData?.type == 2 {
            ticketName = "Buy Limit"
            self.lbl_ticketName.text = "Buy Ticket"
        }else if pendingData?.type == 3 {
            ticketName = "Sell Limit"
            self.lbl_ticketName.text = "Sell Ticket"
        }else if pendingData?.type == 4 {
            ticketName = "Buy Stop"
            self.lbl_ticketName.text = "Buy Ticket"
        }else if pendingData?.type == 5 {
            ticketName = "Sell Stop"
            self.lbl_ticketName.text = "Sell Ticket"
        }
        
        let volume: Double = Double(pendingData?.volume ?? 0) / Double(10000)
        
        let time = timeConvert()
        self.lbl_dateTime.text = time //"Time: " + time
        self.lbl_volumePrice.text = ticketName! + " \(volume) Lots at " + "\(pendingData?.price ?? 0)"
        tf_price.text = "\(pendingData?.price ?? 0)"
        tf_stopLoss.text = "\(pendingData?.stopLoss ?? 0)"
        tf_takeProfit.text = "\(pendingData?.takeProfit ?? 0)"
        
        getSymbolIcon()
        
        currentValue1 = Double(pendingData?.price ?? 0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    private func getSymbolIcon() {
        
        guard let data = pendingData else { return }
        
        // Get saved symbols as a dictionary
        guard let savedSymbolsDict = vm.getSavedSymbolsDictionary() else {
            return
        }
        
        var getSymbol = ""
        
        if data.symbol.contains("..") {
            getSymbol = String(data.symbol.dropLast())
            getSymbol = String(getSymbol.dropLast())
        } else if data.symbol.contains(".") {
            getSymbol = String(data.symbol.dropLast())
        } else {
            getSymbol = data.symbol
        }
        
        // Retrieve the symbol data using the name as the key
        if let symbolData = savedSymbolsDict[getSymbol] {
            // Return the icon_url if a match is found
            if symbolData.name == "Platinum" {
                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/silver.png")
                image_SymbolIcon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }else if symbolData.name == "NDX100" {
                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/ndx.png")
                image_SymbolIcon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }else if symbolData.name == "DJI30" {
                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/dj30.png")
                image_SymbolIcon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }else{
                let imageUrl = URL(string: symbolData.icon_url)
                image_SymbolIcon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }
        }
        
    }
    
    func timeConvert() -> String {
        
        let createDate = Date(timeIntervalSince1970: Double(pendingData!.timeSetup) / 1000.0 )
        
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
        self.dynamicDropDownButtonForTakeProfit(sender as! UIButton, list: takeProfitList) { index, item in
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
    
    @IBAction func deleteOrder_action(_ sender: Any) {
        //        delete_order(self, email, login, password, order_id)
        guard let order_id = pendingData?.order else { return }
        
        viewModel.deletePendingOrder(order_Id: order_id, completion: { response in
            
            self.showTimeAlert(str: response)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.dismiss(animated: true, completion: {
                    print("Bottom sheet dismissed on success.")
                    NotificationCenter.default.post(name: .OPCListDismissall, object: nil, userInfo: ["OPCType": "Pending"])
                })
            }
            
        })
    }
    
    @IBAction func save_action(_ sender: Any) {
        //        update_order(self, email, login, password, order_id, price, take_profit, stop_loss)
        guard let order_id = pendingData?.order else { return }
        
        viewModel.UpdatePendingOrder(order_Id: order_id, takeProfit: (Double(tf_takeProfit.text ?? "") ?? 0), stopLoss: (Double(tf_stopLoss.text ?? "") ?? 0), price: (Double(tf_price.text ?? "") ?? 0), completion: { response in
            
            self.showTimeAlert(str: response)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.dismiss(animated: true, completion: {
                    print("Bottom sheet dismissed on success.")
                    NotificationCenter.default.post(name: .OPCListDismissall, object: nil, userInfo: ["OPCType": "Pending"])
                })
                
            }
        })
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
