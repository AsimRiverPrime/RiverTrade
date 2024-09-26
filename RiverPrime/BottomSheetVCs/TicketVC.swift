//
//  TicketVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 14/08/2024.
//

import UIKit

class TicketVC: BottomSheetController, UITextFieldDelegate {
    
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
    @IBOutlet weak var btn_price: UIButton!
    
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
    @IBOutlet weak var lbl_ConfrmBtnPrice: UILabel!
    
    @IBOutlet weak var btn_confirm: UIButton!
    
    var getSymbolDetail = SymbolCompleteList()
    
    var titleString: String = ""
    var volumeList = ["Lots", "USD"]
    var priceList = ["Market", "Limit", "Stop"]
    var takeProfitList = ["Profit in %", "Profit in USD", "Profit in Pips","Profit in Price"]
    var stopLossList = ["Loss in %", "Loss in USD", "Loss in Pips","Loss in Price"]
    
    var selectedPrice: String = "Market"
    var getPriceLiveValue: String?
    
    var currentValue: Double = 0.0
    var currentValue1: Double = 0.0
        var currentValue2: Double = 0.0
        var currentValue3: Double = 0.0
        var currentValue4: Double = 0.0
        
    
    var isFirstValueSet = false
    var isFirstValueStopLoss = false
    var isFirstValueTakeProfit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_title.text = titleString
       
        self.btn_price.setTitle(selectedPrice, for: .normal)
        
        updateUIBasedOnSelectedPrice()
      
        NotificationCenter.default.addObserver(self, selector: #selector(handleTradesUpdated(_:)), name: .tradesUpdated, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
   
    @objc func hideKeyboard() {
        view.endEditing(true)  // This will dismiss the keyboard for all text fields
    }
    
    @objc private func handleTradesUpdated(_ notification: Notification) {
        
        if let tradeDetail = notification.object as? TradeDetails {
            
            if tradeDetail.symbol == getSymbolDetail.tickMessage?.symbol {
                self.getPriceLiveValue = "\(tradeDetail.bid)"
                
                checkValues(liveValue: getPriceLiveValue!)
                CheckSLTPValue(liveValue: getPriceLiveValue!)
            }
        }
    }
    
    func checkValues(liveValue: String) {
        //        print("\t \t the live value is: \(liveValue)")
        self.lbl_ConfrmBtnPrice.text = tf_priceValue.text
        
        if !isFirstValueSet {
            // Set the text field with the first value
            tf_priceValue.text = String(liveValue)
            currentValue = Double(liveValue)!
            // Update the flag so the field is not updated again
            isFirstValueSet = true
        }
        
        if titleString == "SELL" {
            if self.selectedPrice == "Limit" {
                self.lbl_currentPriceValue.text = "Min. " + "\(liveValue)"
                
                if liveValue < tf_priceValue.text ?? "000" {
                    self.btn_confirm.isEnabled = true
                    self.btn_confirm.backgroundColor = UIColor.systemYellow
                    self.price_view.layer.borderColor = UIColor.lightGray.cgColor
                }else{
                    self.btn_confirm.isEnabled = false
                    self.btn_confirm.backgroundColor = UIColor.systemGray4
                    self.price_view.layer.borderColor = UIColor.red.cgColor
                }
                
            }else if self.selectedPrice == "Stop" {
                self.lbl_currentPriceValue.text = "Max. " + "\(liveValue)"
                
                if liveValue > tf_priceValue.text ?? "000" {
                    self.btn_confirm.isEnabled = true
                    self.btn_confirm.backgroundColor = UIColor.systemYellow
                    self.price_view.layer.borderColor = UIColor.lightGray.cgColor
                }else{
                    self.btn_confirm.isEnabled = false
                    self.btn_confirm.backgroundColor = UIColor.systemGray4
                    self.price_view.layer.borderColor = UIColor.red.cgColor
                }
            }
            
        }else{
            if self.selectedPrice == "Limit" {
                self.lbl_currentPriceValue.text = "Max. " + "\(liveValue)"
                
                if liveValue > tf_priceValue.text ?? "000" {
                    self.btn_confirm.isEnabled = true
                    self.btn_confirm.backgroundColor = UIColor.systemYellow
                    self.price_view.layer.borderColor = UIColor.lightGray.cgColor
                }else{
                    self.btn_confirm.isEnabled = false
                    self.btn_confirm.backgroundColor = UIColor.lightGray
                    self.price_view.borderColor = UIColor.red
                }
                
            }else if self.selectedPrice == "Stop" {
                self.lbl_currentPriceValue.text = "Min. " + "\(liveValue)"
                
                if liveValue < tf_priceValue.text ?? "000" {
                    self.btn_confirm.isEnabled = true
                    self.btn_confirm.backgroundColor = UIColor.systemYellow
                    self.price_view.layer.borderColor = UIColor.lightGray.cgColor
                }else{
                    self.btn_confirm.isEnabled = false
                    self.btn_confirm.backgroundColor = UIColor.lightGray
                    self.price_view.borderColor = UIColor.red
                }
                
            }
        }
    }
    
    func CheckSLTPValue(liveValue: String){
      
        if takeProfit_switch.isOn {
            
            if !isFirstValueTakeProfit {
                tf_takeProfit.text = String(liveValue)
                currentValue3 = Double(liveValue)!
                isFirstValueTakeProfit = true
            }
            
            if liveValue > tf_takeProfit.text ?? "000" {
                self.btn_confirm.isEnabled = true
                self.btn_confirm.backgroundColor = UIColor.systemYellow
                self.takeProfit_view.layer.borderColor = UIColor.lightGray.cgColor
            }else{
                self.btn_confirm.isEnabled = false
                self.btn_confirm.backgroundColor = UIColor.lightGray
                self.takeProfit_view.layer.borderColor = UIColor.red.cgColor
            }
            
        }
            
        if stopLoss_switch.isOn {
            
            if !isFirstValueStopLoss {
                tf_stopLoss.text = String(liveValue)
                currentValue4 = Double(liveValue)!
                
                isFirstValueStopLoss = true
            }
           
            
            if liveValue < tf_stopLoss.text ?? "000" {
                self.btn_confirm.isEnabled = true
                self.btn_confirm.backgroundColor = UIColor.systemYellow
                self.stopLoss_view.layer.borderColor = UIColor.lightGray.cgColor
                
            }else{
                self.btn_confirm.isEnabled = false
                self.btn_confirm.backgroundColor = UIColor.lightGray
                self.stopLoss_view.layer.borderColor = UIColor.red.cgColor
            }
        }
        
        
    }
    //MARK: - volume actions
    @IBAction func volumeMinus_action(_ sender: Any) {
        updateValue(for: tf_volume, increment: false)
        
    }
    @IBAction func volumePlus_action(_ sender: Any) {
        updateValue(for: tf_volume, increment: true)
    }
    @IBAction func volume_dropDownAction(_ sender: Any) {
        self.dynamicDropDownButton(sender as! UIButton, list: volumeList) { index, item in
            print("drop down index = \(index)")
            print("drop down item = \(item)")
            self.lbl_volumeDropdown.text = item
            //            sender.buttonOulate Name = ""
        }
    }
    //MARK: - price actions
    @IBAction func price_dropDownAction(_ sender: Any) {
        self.dynamicDropDownButton(sender as! UIButton, list: priceList) { index, item in
            print("drop down index = \(index)")
            print("drop down item = \(item)")
            // self.lbl_PriceDropdown.text = item
            self.selectedPrice = item
            
            self.updateUIBasedOnSelectedPrice()
        }
    }
    
    func updateUIBasedOnSelectedPrice() {
        if selectedPrice == "Market" {
            price_view.isHidden = true
            lbl_currentPriceValue.isHidden = true
            lbl_limit.isHidden = true
        } else {
            price_view.isHidden = false
            lbl_currentPriceValue.isHidden = false
            lbl_limit.isHidden = false
        }
    }
    
    @IBAction func priceMinus_action(_ sender: Any) {
        updateValue(for: tf_priceValue, increment: false)
    }
    @IBAction func pricePlus_action(_ sender: Any) {
        updateValue(for: tf_priceValue, increment: true)
    }
    
    func updateValue(for textField: UITextField, increment: Bool) {
           let step: Double = 0.01 // You can adjust the step value (e.g., 0.1 for increments in decimal)
        
        // Determine which text field is being updated and get its current value
               switch textField {
               case tf_volume:
                   currentValue = currentValue1
               case tf_priceValue:
                   currentValue = currentValue2
               case tf_takeProfit:
                   currentValue = currentValue3
               case tf_stopLoss:
                   currentValue = currentValue4
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
               textField.text = String(format: "%.2f", currentValue)
               
               // Save the updated current value back to the respective variable
               switch textField {
               case tf_volume:
                   currentValue1 = currentValue
               case tf_priceValue:
                   currentValue2 = currentValue
               case tf_takeProfit:
                   currentValue3 = currentValue
               case tf_stopLoss:
                   currentValue4 = currentValue
               default:
                   break
               }
           }
    
    //MARK: - take Profit actions
    @IBAction func takeProfile_switchAction(_ sender: UISwitch) {
        //        updateProfitView()
        if sender.isOn {
            self.takeProfit_view.isUserInteractionEnabled = true
            lbl_TP.isHidden = false
        }else{
            self.takeProfit_view.isUserInteractionEnabled = false
            lbl_TP.isHidden = true
        }
    }
    
    @IBAction func takeProfit_dropDownAction(_ sender: Any) {
        self.dynamicDropDownButton(sender as! UIButton, list: takeProfitList) { index, item in
            print("drop down index = \(index)")
            print("drop down item = \(item)")
            //            self.lbl_takeProfitDropDown.text = item
        }
    }
    
    
    @IBAction func takeProfitMinus_action(_ sender: Any) {
        updateValue(for: tf_takeProfit, increment: false)
    }
    
    @IBAction func takeProfitPlus_action(_ sender: Any) {
        updateValue(for: tf_takeProfit, increment: true)
    }
    
    @IBAction func profit_clearAction(_ sender: Any) {
        lbl_TP.isHidden = true
        liveValue_view.isHidden = true
        tf_takeProfit.text = ""
        tf_takeProfit.placeholder = "not set"
        
    }
    //MARK: - stop Loss actions
    
    @IBAction func stopLoss_switchAction(_ sender: UISwitch) {
        //       updateStopLossView()
        if sender.isOn {
            self.stopLoss_view.isUserInteractionEnabled = true
            lbl_SL.isHidden = false
           
        }else{
            self.stopLoss_view.isUserInteractionEnabled = false
            lbl_SL.isHidden = true
        }
    }
    
    @IBAction func stopLoss_dropDownAction(_ sender: Any) {
        self.dynamicDropDownButton(sender as! UIButton, list: stopLossList) { index, item in
            print("drop down index = \(index)")
            print("drop down item = \(item)")
            //            self.lbl_stopLossDropDown.text = item
        }
        
    }
    
    @IBAction func stopLossMinus_action(_ sender: Any) {
        updateValue(for: tf_stopLoss, increment: false)
    }
    
    @IBAction func stopLossPlus_action(_ sender: Any) {
        updateValue(for: tf_stopLoss, increment: true)
    }
    
    @IBAction func cancel_btnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            print("Bottom sheet dismissed on cancel btn press")
        })
    }
    
    @IBAction func submit_btnAction(_ sender: Any) {
        
        
    }
    
    
    @IBAction func stopLoss_clearAction(_ sender: Any) {
        lbl_SL.isHidden = true
        stopLossLiveValue_view.isHidden = true
        tf_stopLoss.text = ""
        tf_stopLoss.placeholder = "not set"
    }

}
