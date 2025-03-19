//
//  TicketVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 14/08/2024.
//

import UIKit
import Alamofire
import CryptoKit

class TicketVC: BottomSheetController {
    
    @IBOutlet weak var lbl_title: UILabel!
    //MARK: - volume Outlets
    @IBOutlet weak var tf_volume: UITextField!
    @IBOutlet weak var lbl_volumeDropdown: UILabel!
    @IBOutlet weak var lbl_volumeFees: UILabel!
    @IBOutlet weak var lbl_volumeMargin: UILabel!
    @IBOutlet weak var lbl_volumeLeverage: UILabel!
    @IBOutlet weak var btn_volumeDropdown: UIButton!
    //MARK: - price Outlets
    @IBOutlet weak var price_view: CardView!
    @IBOutlet weak var lbl_PriceDropdown: UILabel!
    @IBOutlet weak var tf_priceValue: UITextField!
    @IBOutlet weak var lbl_currentPriceValue: UILabel!
    @IBOutlet weak var btn_price: UIButton!
    @IBOutlet weak var priceValue_view: UIStackView!
    
    //MARK: - takeProfile Outlets
    
    @IBOutlet weak var takeProfit_switch: UISwitch!
    @IBOutlet weak var tf_takeProfit: UITextField!
    @IBOutlet weak var lbl_takeProfitDropDown: UILabel!
    //    @IBOutlet weak var takeProfit_view: UIStackView!
    @IBOutlet weak var takeProfit_view: CardView!
    
    @IBOutlet weak var liveValue_view: UIStackView!
    @IBOutlet weak var lbl_liveProfitLoss: UILabel!
//    @IBOutlet weak var lbl_profitLossPips: UILabel!
    @IBOutlet weak var lbl_profitLossPercentage: UILabel!
    @IBOutlet weak var takeProfit_height: NSLayoutConstraint!
    @IBOutlet weak var clearTakeProfit_btn: UIButton!
    @IBOutlet weak var btn_takeProfitDropdown: UIButton!
    
    //MARK: - stop Loss Outlets
    @IBOutlet weak var stopLoss_switch: UISwitch!
    @IBOutlet weak var tf_stopLoss: UITextField!
    @IBOutlet weak var lbl_stopLossDropDown: UILabel!
    //    @IBOutlet weak var stopLoss_view: UIStackView!
    @IBOutlet weak var stopLoss_view: CardView!
    
    @IBOutlet weak var stopLossLiveValue_view: UIStackView!
    @IBOutlet weak var lbl_liveStopLoss: UILabel!
    @IBOutlet weak var lbl_stopLossPips: UILabel!
    @IBOutlet weak var lbl_stopLossPercentage: UILabel!
    @IBOutlet weak var stopLoss_height: NSLayoutConstraint!
    @IBOutlet weak var clearStoploss_btn: UIButton!
    @IBOutlet weak var btn_stopLossDropDown: UIButton!
    
    @IBOutlet weak var lbl_totalBalance: UILabel!
    @IBOutlet weak var btn_confirm: UIButton!
    
    var getSymbolDetail = SymbolCompleteList()
    
    var titleString: String = ""
    var volumeList = ["Lots", "USD"]
    var priceList = ["Market", "Limit", "Stop"]
    var takeProfitList = ["Profit in %", "Profit in Pips","Profit in Price"]
    var stopLossList = ["Loss in %", "Loss in Pips","Loss in Price"]
    
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
    
    var selectedVolume: String?
    var volume: Double?
    var totalValueUSD: Int?
    var contractSize: Int?
    var volumeStep: Int?
    var volumeMax: Int?
    var incrementValue: Int?
    var digits: Int?
    var volumeMin: Int?
    var bidValue: Double?
    var selectedSymbol: String?
    
    
    var userLoginID: Int?
    var userPassword: String?
    var userEmail: String?
    var digits_currency: Int = 3
    var stopLoss: Double = 0.0
    var takeProfit: Double = 0.0
    var priceValue: Double?
    
    var type: Int?
    /* OP_BUY                   =0,     // buy order
     OP_SELL                  =1,     // sell order
     OP_BUY_LIMIT             =2,     // buy limit order
     OP_SELL_LIMIT            =3,     // sell limit order
     OP_BUY_STOP              =4,     // buy stop order
     OP_SELL_STOP             =5,     // sell stop order
     OP_BUY_STOP_LIMIT        =6,     // buy stop limit order
     OP_SELL_STOP_LIMIT       =7,     // sell stop limit order
     OP_CLOSE_BY              =8,     // close by*/
    
    var previousSelectedVolume: String?
    
    var decryptedPass: String?
    
    var getTF_Volume: Double?
    var previousStopLossType: String = "Loss in Price"
    var previousTakeProfitType: String = "Profit in Price"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_title.text = titleString + " Ticket"
        
        selectedVolume = "Lots"
        previousSelectedVolume = selectedVolume
        //        volume = 0.01
        
        btn_volumeDropdown.setTitle(selectedVolume, for: .normal)
        tf_volume.delegate = self
        
        stopLoss_switch.isOn = false
        takeProfit_switch.isOn = false
        self.takeProfit_view.isUserInteractionEnabled = false
        self.stopLoss_view.isUserInteractionEnabled = false
        self.btn_takeProfitDropdown.setTitle("Price", for: .normal)
        self.btn_stopLossDropDown.setTitle("Price", for: .normal)
        
        self.btn_price.setTitle(selectedPrice, for: .normal)
        
        updateUIBasedOnSelectedPrice()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTradesUpdated(_:)), name: .tradesUpdated, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: NotificationObserver.Constants.BalanceUpdateConstant.key), object: nil)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        fetchSymbolDetail()
        
    }
    @objc func notificationPopup(_ notification: NSNotification) {
        
        if let ammount = notification.userInfo?[NotificationObserver.Constants.BalanceUpdateConstant.title] as? String {
            print("Received ammount in ticket vc : \(ammount)")
            self.lbl_totalBalance.text = "$\(ammount)"
        }
        
    }
    
    func fetchSymbolDetail() {
        
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let email = savedUserData["email"] as? String{
                self.userEmail = email
            }
        }
        
        if let defaultAccount = UserAccountManager.shared.getDefaultAccount() {
            self.userLoginID = defaultAccount.accountNumber
        }
        
        if let obj = GlobalVariable.instance.symbolDataArray.first(where: {$0.name == getSymbolDetail.tickMessage?.symbol}) {
            
            // print("\nsymbol Detail: \(obj) \n")
            selectedSymbol = obj.name
            contractSize = Int("\(obj.contractSize)")
            volumeStep = Int("\(obj.volumeStep)")
            volumeMax = Int("\(obj.volumeMax)")
            volumeMin = Int("\(obj.volumeMin)")
            digits = Int("\(obj.digits)")
            
            userPassword = UserDefaults.standard.string(forKey: "password")
            
            print("selectedSymbol: \(selectedSymbol)\n contractSize: \(String(describing: contractSize)) \t volumeStep: \(volumeStep ?? 0) \t volumeMax:\(volumeMax) \t volumeMin: \(volumeMin) \t digits: \(digits) \n password: \(userPassword) \t email: \(userEmail) \t loginID: \(userLoginID) ")
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)  // This will dismiss the keyboard for all text fields
    }
    
    @objc private func handleTradesUpdated(_ notification: Notification) {
        
        if let tradeDetail = notification.object as? TradeDetails {
            
            if tradeDetail.symbol == getSymbolDetail.tickMessage?.symbol {
                self.getPriceLiveValue = "\(tradeDetail.bid)"
                // priceValue = bidValue
                checkEnable(liveValue: getPriceLiveValue ?? "")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /*
    private func checkEnable(liveValue: String) {
        var price: (String,Double,Bool) = ("",0.0,false)
        var profit: (String,Double,Bool) = ("",0.0,false)
        var loss: (String,Double,Bool) = ("",0.0,false)
        
        //  self.lbl_ConfrmBtnPrice.text = liveValue
        
        
        //MARK: - START Price Logic
        if titleString == "SELL" { //TODO: SELL
            
            if self.selectedPrice == "Limit" {
                self.type = 3
                price.0 = "Limit"
                price.1 = Double(liveValue) ?? 0.0
                price.2 = true
            } else if self.selectedPrice == "Stop" {
                self.type = 5
                price.0 = "Stop"
                price.1 = Double(liveValue) ?? 0.0
                price.2 = true
            } else { //TODO: STOP Price.
                self.type = 1
                price.0 = ""
                price.1 = 0.0
                price.2 = false
                priceValue = bidValue
            }
            
        } else { //TODO: BUY
            if self.selectedPrice == "Limit" {
                self.type = 2
                price.0 = "Limit"
                price.1 = Double(liveValue) ?? 0.0
                price.2 = true
            } else if self.selectedPrice == "Stop" {
                self.type = 4
                price.0 = "Stop"
                price.1 = Double(liveValue) ?? 0.0
                price.2 = true
            } else { //TODO: STOP Price.
                self.type = 0
                price.0 = ""
                price.1 = 0.0
                price.2 = false
                priceValue = bidValue
            }
        }
        //MARK: - END Price Logic
        
        //MARK: - START profit Logic
        if takeProfit_switch.isOn {
            if self.selectedPrice == "Market" {
                profit.0 = "Profit"
                profit.1 = Double(liveValue) ?? 0.0
                profit.2 = true
            }else{
                profit.0 = "Profit"
                profit.1 = Double(tf_priceValue.text ?? "") ?? 0.0
                profit.2 = true
            }
        } else {
            profit.0 = ""
            profit.1 = 0.0
            profit.2 = false
        }
        //MARK: - END profit Logic
        
        //MARK: - START loss Logic
        if stopLoss_switch.isOn {
            if self.selectedPrice == "Market" {
                loss.0 = "Loss"
                loss.1 = Double(liveValue) ?? 0.0
                loss.2 = true
            }else{
                loss.0 = "Loss"
                loss.1 = Double(tf_priceValue.text ?? "") ?? 0.0
                loss.2 = true
            }
        } else {
            loss.0 = ""
            loss.1 = 0.0
            loss.2 = false
        }
        //MARK: - END loss Logic
        
        if selectedPrice != "Market" {
            //MARK: - START Main Logic
            if price.2 == true || profit.2 == true || loss.2 == true {
                
                var isConfirmEnable: [(String,Bool,String)] = [("",false,""), ("",false,""), ("",false,"")]
                
                if price.2 == true && price.0 == "Limit" {  //TODO: LIMIT ORDER TYPE
                    
                    if !isFirstValueSet {
                        bidValue = Double(liveValue)!
                        // Set the text field with the first value
                        tf_priceValue.text = String(liveValue)
                        currentValue2 = Double(liveValue)!
                        // Update the flag so the field is not updated again
                        isFirstValueSet = true
                    }
                    
                    if titleString == "SELL" { //TODO: SELL for LIMIT ORDER TYPE
                        
                        let myPriceValue: Double = Double(tf_priceValue.text ?? "0") ?? 0
                        
                        self.lbl_currentPriceValue.text = "Min. " + "\(liveValue)"  // According to logic later
                        //                        lbl_limit.text = "Limit"
                        
                        if price.1 < myPriceValue {
                            isConfirmEnable[0].1 = true
                            isConfirmEnable[0].0 = "on"
                            isConfirmEnable[0].2 = "SELL"
                        }else{
                            isConfirmEnable[0].1 = false
                            isConfirmEnable[0].0 = "on"
                            isConfirmEnable[0].2 = "SELL"
                        }
                        if profit.2 == true && profit.0 == "Profit" {
                            if !isFirstValueTakeProfit {
                                tf_takeProfit.text = String(liveValue)
                                currentValue3 = Double(liveValue)!
                                isFirstValueTakeProfit = true
                            }
                            let myTakeProfitValue: Double = Double(tf_takeProfit.text ?? "0") ?? 0
                            if profit.1 > myTakeProfitValue {
                                isConfirmEnable[1].1 = true
                                isConfirmEnable[1].0 = "on"
                                isConfirmEnable[1].2 = "Profit"
                            }else{
                                isConfirmEnable[1].1 = false
                                isConfirmEnable[1].0 = "on"
                                isConfirmEnable[1].2 = "Profit"
                            }
                        }
                        if loss.2 == true && loss.0 == "Loss" {
                            if !isFirstValueStopLoss {
                                tf_stopLoss.text = String(liveValue)
                                currentValue4 = Double(liveValue)!
                                isFirstValueStopLoss = true
                            }
                            let myStopLossValue: Double = Double(tf_stopLoss.text ?? "0") ?? 0
                            if loss.1 < myStopLossValue {
                                isConfirmEnable[2].1 = true
                                isConfirmEnable[2].0 = "on"
                                isConfirmEnable[2].2 = "Loss"
                            }else{
                                isConfirmEnable[2].1 = false
                                isConfirmEnable[2].0 = "on"
                                isConfirmEnable[2].2 = "Loss"
                            }
                        }
                        
                    } else { //TODO: BUY for LIMIT ORDER TYPE
                        
                        let myPriceValue: Double = Double(tf_priceValue.text ?? "0") ?? 0
                        
                        self.lbl_currentPriceValue.text = "Max. " + "\(liveValue)" // According to logic later
                        
                        if price.1 > myPriceValue {
                            isConfirmEnable[0].1 = true
                            isConfirmEnable[0].0 = "on"
                            isConfirmEnable[0].2 = "BUY"
                        }else{
                            isConfirmEnable[0].1 = false
                            isConfirmEnable[0].0 = "on"
                            isConfirmEnable[0].2 = "BUY"
                        }
                    }
                    if profit.2 == true && profit.0 == "Profit" {
                        if !isFirstValueTakeProfit {
                            tf_takeProfit.text = String(liveValue)
                            currentValue3 = Double(liveValue)!
                            isFirstValueTakeProfit = true
                        }
                        let myTakeProfitValue: Double = Double(tf_takeProfit.text ?? "0") ?? 0
                        if profit.1 < myTakeProfitValue {
                            isConfirmEnable[1].1 = true
                            isConfirmEnable[1].0 = "on"
                            isConfirmEnable[1].2 = "Profit"
                        }else{
                            isConfirmEnable[1].1 = false
                            isConfirmEnable[1].0 = "on"
                            isConfirmEnable[1].2 = "Profit"
                        }
                    }
                    if loss.2 == true && loss.0 == "Loss" {
                        if !isFirstValueStopLoss {
                            tf_stopLoss.text = String(liveValue)
                            currentValue4 = Double(liveValue)!
                            isFirstValueStopLoss = true
                        }
                        let myStopLossValue: Double = Double(tf_stopLoss.text ?? "0") ?? 0
                        if loss.1 > myStopLossValue {
                            isConfirmEnable[2].1 = true
                            isConfirmEnable[2].0 = "on"
                            isConfirmEnable[2].2 = "Loss"
                        }else{
                            isConfirmEnable[2].1 = false
                            isConfirmEnable[2].0 = "on"
                            isConfirmEnable[2].2 = "Loss"
                        }
                    }
                    
                } else if price.2 == true && price.0 == "Stop" { //TODO: STOP ORDER TYPE
                    if !isFirstValueSet {
                        bidValue = Double(liveValue)!
                        // Set the text field with the first value
                        tf_priceValue.text = String(liveValue)
                        currentValue2 = Double(liveValue)!
                        // Update the flag so the field is not updated again
                        isFirstValueSet = true
                    }
                    
                    if titleString == "SELL" {        //TODO: SELL FOR STOP order type
                        let myPriceValue: Double = Double(tf_priceValue.text ?? "0") ?? 0
                        self.lbl_currentPriceValue.text = "Max. " + "\(liveValue)"
                        //                        lbl_limit.text = "Stop"
                        
                        if price.1 > myPriceValue {
                            isConfirmEnable[0].1 = true
                            isConfirmEnable[0].0 = "on"
                            isConfirmEnable[0].2 = "SELL"
                        }else{
                            isConfirmEnable[0].1 = false
                            isConfirmEnable[0].0 = "on"
                            isConfirmEnable[0].2 = "SELL"
                        }
                        if profit.2 == true && profit.0 == "Profit" {
                            if !isFirstValueTakeProfit {
                                tf_takeProfit.text = String(liveValue)
                                currentValue3 = Double(liveValue)!
                                isFirstValueTakeProfit = true
                            }
                            let myTakeProfitValue: Double = Double(tf_takeProfit.text ?? "0") ?? 0
                            if profit.1 > myTakeProfitValue {
                                isConfirmEnable[1].1 = true
                                isConfirmEnable[1].0 = "on"
                                isConfirmEnable[1].2 = "Profit"
                            }else{
                                isConfirmEnable[1].1 = false
                                isConfirmEnable[1].0 = "on"
                                isConfirmEnable[1].2 = "Profit"
                            }
                        }
                        if loss.2 == true && loss.0 == "Loss" {
                            if !isFirstValueStopLoss {
                                tf_stopLoss.text = String(liveValue)
                                currentValue4 = Double(liveValue)!
                                isFirstValueStopLoss = true
                            }
                            let myStopLossValue: Double = Double(tf_stopLoss.text ?? "0") ?? 0
                            if loss.1 < myStopLossValue {
                                isConfirmEnable[2].1 = true
                                isConfirmEnable[2].0 = "on"
                                isConfirmEnable[2].2 = "Loss"
                            }else{
                                isConfirmEnable[2].1 = false
                                isConfirmEnable[2].0 = "on"
                                isConfirmEnable[2].2 = "Loss"
                            }
                        }
                    } else { //TODO: BUY FOR STOP order type
                        let myPriceValue: Double = Double(tf_priceValue.text ?? "0") ?? 0
                        self.lbl_currentPriceValue.text = "Min. " + "\(liveValue)"
                        if price.1 < myPriceValue {
                            isConfirmEnable[0].1 = true
                            isConfirmEnable[0].0 = "on"
                            isConfirmEnable[0].2 = "BUY"
                        }else{
                            isConfirmEnable[0].1 = false
                            isConfirmEnable[0].0 = "on"
                            isConfirmEnable[0].2 = "BUY"
                        }
                        if profit.2 == true && profit.0 == "Profit" {   //TODO: TakeProfit
                            if !isFirstValueTakeProfit {
                                tf_takeProfit.text = String(liveValue)
                                currentValue3 = Double(liveValue)!
                                isFirstValueTakeProfit = true
                            }
                            let myTakeProfitValue: Double = Double(tf_takeProfit.text ?? "0") ?? 0
                            if profit.1 < myTakeProfitValue {
                                isConfirmEnable[1].1 = true
                                isConfirmEnable[1].0 = "on"
                                isConfirmEnable[1].2 = "Profit"
                            }else{
                                isConfirmEnable[1].1 = false
                                isConfirmEnable[1].0 = "on"
                                isConfirmEnable[1].2 = "Profit"
                            } }
                        if loss.2 == true && loss.0 == "Loss" {     //TODO: STOP LOSS
                            if !isFirstValueStopLoss {
                                tf_stopLoss.text = String(liveValue)
                                currentValue4 = Double(liveValue)!
                                isFirstValueStopLoss = true
                            }
                            let myStopLossValue: Double = Double(tf_stopLoss.text ?? "0") ?? 0
                            if loss.1 > myStopLossValue {
                                isConfirmEnable[2].1 = true
                                isConfirmEnable[2].0 = "on"
                                isConfirmEnable[2].2 = "Loss"
                            }else{
                                isConfirmEnable[2].1 = false
                                isConfirmEnable[2].0 = "on"
                                isConfirmEnable[2].2 = "Loss"
                            } }
                    }
                }
                var checkEnable = false
                
                for isEnable in isConfirmEnable {
                    if isEnable.0 != "" {
                        if !isEnable.1 {
                            checkEnable = true
                            
                            if isEnable.2 == "SELL" {
                                self.btn_confirm.isEnabled = false
                                self.btn_confirm.layer.borderColor = UIColor.systemGray2.cgColor
                                self.btn_confirm.titleLabel?.textColor = UIColor.systemGray2
                                self.price_view.layer.borderWidth = 0.3
                                self.price_view.layer.borderColor = UIColor.red.cgColor
                                self.lbl_currentPriceValue.textColor = UIColor.red
                            } else if isEnable.2 == "BUY" {
                                self.btn_confirm.isEnabled = false
                                self.btn_confirm.layer.borderColor = UIColor.systemGray2.cgColor
                                self.btn_confirm.titleLabel?.textColor = UIColor.systemGray2
                                self.price_view.layer.borderWidth = 0.3
                                self.price_view.layer.borderColor = UIColor.red.cgColor
                                self.lbl_currentPriceValue.textColor = UIColor.red
                            } else if isEnable.2 == "Profit" {
                                self.btn_confirm.isEnabled = false
                                self.btn_confirm.layer.borderColor = UIColor.systemGray2.cgColor
                                self.btn_confirm.titleLabel?.textColor = UIColor.systemGray2
                                self.takeProfit_view.layer.borderWidth = 0.3
                                self.takeProfit_view.layer.borderColor = UIColor.red.cgColor
                                self.lbl_liveProfitLoss.isHidden = false
                                let value: Double = (Double(tf_priceValue.text ?? "0.0") ?? 0.0)// + 0.01
                                
                                //                            let plusValue = value.adjusted(by: "plus")
                                
                                if titleString == "SELL" {
                                    let plusValue = value.adjusted(by: "minus")
                                    self.lbl_liveProfitLoss.text = "Max. \(plusValue)"
                                } else {
                                    let plusValue = value.adjusted(by: "plus")
                                    self.lbl_liveProfitLoss.text = "Min. \(plusValue)"
                                }
                                
                                //                            self.lbl_liveProfitLoss.text = "Min. \(plusValue)"
                                self.lbl_liveProfitLoss.textColor = UIColor.red
                            } else if isEnable.2 == "Loss" {
                                self.btn_confirm.isEnabled = false
                                self.btn_confirm.layer.borderColor = UIColor.systemGray2.cgColor
                                self.btn_confirm.titleLabel?.textColor = UIColor.systemGray2
                                self.stopLoss_view.layer.borderWidth = 0.3
                                self.stopLoss_view.layer.borderColor = UIColor.red.cgColor
                                self.lbl_liveStopLoss.isHidden = false
                                let value: Double = (Double(tf_priceValue.text ?? "0.0") ?? 0.0)// - 0.01
                                
                                //                            let minusValue = value.adjusted(by: "minus")
                                
                                if titleString == "SELL" {
                                    let minusValue = value.adjusted(by: "plus")
                                    self.lbl_liveStopLoss.text = "Min. \(minusValue)"
                                } else {
                                    let minusValue = value.adjusted(by: "minus")
                                    self.lbl_liveStopLoss.text = "Max. \(minusValue)"
                                }
                                
                                //                            self.lbl_liveStopLoss.text = "Max. \(minusValue)"
                                self.lbl_liveStopLoss.textColor = UIColor.red
                            }
                        }
                    }
                }
                
                if !checkEnable {
                    self.btn_confirm.isEnabled = true
                    self.btn_confirm.tintColor = UIColor.systemYellow
                    self.btn_confirm.layer.borderColor = UIColor.systemYellow.cgColor
                    
                    self.stopLoss_view.layer.borderColor = UIColor.lightGray.cgColor
                    self.lbl_liveStopLoss.isHidden = true
                    
                    self.price_view.layer.borderColor = UIColor.darkGray.cgColor
                    self.lbl_currentPriceValue.textColor = UIColor.lightGray
                    
                    self.takeProfit_view.layer.borderColor = UIColor.darkGray.cgColor
                    self.lbl_liveProfitLoss.isHidden = true
                }
            }
        } else {
            if self.selectedPrice == "Market" { //MARK: - MARKET
                
                bidValue = Double(liveValue)!
                
                if takeProfit_switch.isOn {
                    if !isFirstValueTakeProfit {
                        tf_takeProfit.text = String(liveValue)
                        currentValue3 = Double(liveValue)!
                        isFirstValueTakeProfit = true
                    }
                    
                    if titleString == "SELL" {
                        if bidValue ?? 0.0 > Double(tf_takeProfit.text ?? "0.0") ?? 0.0 { // TP
                            self.btn_confirm.isEnabled = true
                            self.btn_confirm.tintColor = UIColor.systemYellow
                            self.btn_confirm.layer.borderColor = UIColor.systemYellow.cgColor
                            
                            self.stopLoss_view.layer.borderColor = UIColor.lightGray.cgColor
                            self.lbl_liveStopLoss.isHidden = true
                            
                            self.price_view.layer.borderColor = UIColor.darkGray.cgColor
                            self.lbl_currentPriceValue.textColor = UIColor.lightGray
                            
                            self.takeProfit_view.layer.borderColor = UIColor.darkGray.cgColor
                            self.lbl_liveProfitLoss.isHidden = true
                        } else {
                            self.btn_confirm.isEnabled = false
                            self.btn_confirm.layer.borderColor = UIColor.systemGray2.cgColor
                            self.btn_confirm.titleLabel?.textColor = UIColor.systemGray2
                            self.takeProfit_view.layer.borderWidth = 0.3
                            self.takeProfit_view.layer.borderColor = UIColor.red.cgColor
                            self.lbl_liveProfitLoss.isHidden = false
                            let value: Double = (Double(liveValue) ?? 0.0)// + 0.01
                            
                            //                            let plusValue = value.adjusted(by: "plus")
                            
                            if titleString == "SELL" {
                                let plusValue = value.adjusted(by: "minus")
                                self.lbl_liveProfitLoss.text = "Max. \(plusValue)"
                            } else {
                                let plusValue = value.adjusted(by: "plus")
                                self.lbl_liveProfitLoss.text = "Min. \(plusValue)"
                            }
                            
                            //                            self.lbl_liveProfitLoss.text = "Min. \(plusValue)"
                            self.lbl_liveProfitLoss.textColor = UIColor.red
                        }
                    } else {
                        if bidValue ?? 0.0 < Double(tf_takeProfit.text ?? "0.0") ?? 0.0 { // TP
                            self.btn_confirm.isEnabled = true
                            self.btn_confirm.tintColor = UIColor.systemYellow
                            self.btn_confirm.layer.borderColor = UIColor.systemYellow.cgColor
                            
                            self.stopLoss_view.layer.borderColor = UIColor.lightGray.cgColor
                            self.lbl_liveStopLoss.isHidden = true
                            
                            self.price_view.layer.borderColor = UIColor.darkGray.cgColor
                            self.lbl_currentPriceValue.textColor = UIColor.lightGray
                            
                            self.takeProfit_view.layer.borderColor = UIColor.darkGray.cgColor
                            self.lbl_liveProfitLoss.isHidden = true
                        } else {
                            self.btn_confirm.isEnabled = false
                            self.btn_confirm.layer.borderColor = UIColor.systemGray2.cgColor
                            self.btn_confirm.titleLabel?.textColor = UIColor.systemGray2
                            self.takeProfit_view.layer.borderWidth = 0.3
                            self.takeProfit_view.layer.borderColor = UIColor.red.cgColor
                            self.lbl_liveProfitLoss.isHidden = false
                            let value: Double = (Double(liveValue) ?? 0.0)// + 0.01
                            
                            //                            let plusValue = value.adjusted(by: "plus")
                            
                            if titleString == "SELL" {
                                let plusValue = value.adjusted(by: "minus")
                                self.lbl_liveProfitLoss.text = "Max. \(plusValue)"
                            } else {
                                let plusValue = value.adjusted(by: "plus")
                                self.lbl_liveProfitLoss.text = "Min. \(plusValue)"
                            }
                            
                            //                            self.lbl_liveProfitLoss.text = "Min. \(plusValue)"
                            self.lbl_liveProfitLoss.textColor = UIColor.red
                        }
                    }
                }
                if stopLoss_switch.isOn {
                    if !isFirstValueStopLoss {
                        tf_stopLoss.text = String(liveValue)
                        currentValue4 = Double(liveValue)!
                        isFirstValueStopLoss = true
                    }
                    
                    if titleString == "SELL" { //SELL
                        if bidValue ?? 0.0 < Double(tf_stopLoss.text ?? "0.0") ?? 0.0 { // SLOSS
                            self.btn_confirm.isEnabled = true
                            self.btn_confirm.tintColor = UIColor.systemYellow
                            self.btn_confirm.layer.borderColor = UIColor.systemYellow.cgColor
                            
                            self.stopLoss_view.layer.borderColor = UIColor.lightGray.cgColor
                            self.lbl_liveStopLoss.isHidden = true
                            
                            self.price_view.layer.borderColor = UIColor.darkGray.cgColor
                            self.lbl_currentPriceValue.textColor = UIColor.lightGray
                            
                            self.takeProfit_view.layer.borderColor = UIColor.darkGray.cgColor
                            self.lbl_liveProfitLoss.isHidden = true
                        } else {
                            self.btn_confirm.isEnabled = false
                            self.btn_confirm.layer.borderColor = UIColor.systemGray2.cgColor
                            self.btn_confirm.titleLabel?.textColor = UIColor.systemGray2
                            self.stopLoss_view.layer.borderWidth = 0.3
                            self.stopLoss_view.layer.borderColor = UIColor.red.cgColor
                            self.lbl_liveStopLoss.isHidden = false
                            let value: Double = (Double(liveValue) ?? 0.0)// - 0.01
                            
                            //                            let minusValue = value.adjusted(by: "minus")
                            
                            if titleString == "SELL" {
                                let minusValue = value.adjusted(by: "plus")
                                self.lbl_liveStopLoss.text = "Min. \(minusValue)"
                            } else {
                                let minusValue = value.adjusted(by: "minus")
                                self.lbl_liveStopLoss.text = "Max. \(minusValue)"
                            }
                            
                            //                            self.lbl_liveStopLoss.text = "Max. \(minusValue)"
                            self.lbl_liveStopLoss.textColor = UIColor.red
                        }
                    } else { // BUY
                        if bidValue ?? 0.0 > Double(tf_stopLoss.text ?? "0.0") ?? 0.0 { // SLOSS
                            self.btn_confirm.isEnabled = true
                            self.btn_confirm.tintColor = UIColor.systemYellow
                            self.btn_confirm.layer.borderColor = UIColor.systemYellow.cgColor
                            
                            self.stopLoss_view.layer.borderColor = UIColor.lightGray.cgColor
                            self.lbl_liveStopLoss.isHidden = true
                            
                            self.price_view.layer.borderColor = UIColor.darkGray.cgColor
                            self.lbl_currentPriceValue.textColor = UIColor.lightGray
                            
                            self.takeProfit_view.layer.borderColor = UIColor.darkGray.cgColor
                            self.lbl_liveProfitLoss.isHidden = true
                        } else {
                            self.btn_confirm.isEnabled = false
                            self.btn_confirm.layer.borderColor = UIColor.systemGray2.cgColor
                            self.btn_confirm.titleLabel?.textColor = UIColor.systemGray2
                            self.stopLoss_view.layer.borderWidth = 0.3
                            self.stopLoss_view.layer.borderColor = UIColor.red.cgColor
                            self.lbl_liveStopLoss.isHidden = false
                            let value: Double = (Double(liveValue) ?? 0.0)// - 0.01
                            
                            //                            let minusValue = value.adjusted(by: "minus")
                            
                            if titleString == "SELL" {
                                let minusValue = value.adjusted(by: "plus")
                                self.lbl_liveStopLoss.text = "Min. \(minusValue)"
                            } else {
                                let minusValue = value.adjusted(by: "minus")
                                self.lbl_liveStopLoss.text = "Max. \(minusValue)"
                            }
                            
                            //                            self.lbl_liveStopLoss.text = "Max. \(minusValue)"
                            self.lbl_liveStopLoss.textColor = UIColor.red
                        }
                        
                    }
                    
                }
                
                
//                if titleString == "SELL" { //SELL
//
//                } else { // BUY
//                    if bidValue < Double(tf_takeProfit.text ?? "0.0") ?? 0.0 {
//
//                    } else {
//
//                    }
//                }
            }
        }
        
        bidValue = Double(liveValue) ?? 0.0
    }
    */
    
    private func checkEnable(liveValue: String) {
        var price: (String,Double,Bool) = ("",0.0,false)
        var profit: (String,Double,Bool) = ("",0.0,false)
        var loss: (String,Double,Bool) = ("",0.0,false)
        
        //  self.lbl_ConfrmBtnPrice.text = liveValue
        
        
        //MARK: - START Price Logic
        if titleString == "SELL" { //TODO: SELL
            
            if self.selectedPrice == "Limit" {
                self.type = 3
                price.0 = "Limit"
                price.1 = Double(liveValue) ?? 0.0
                price.2 = true
            } else if self.selectedPrice == "Stop" {
                self.type = 5
                price.0 = "Stop"
                price.1 = Double(liveValue) ?? 0.0
                price.2 = true
            } else { //TODO: STOP Price.
                self.type = 1
                price.0 = ""
                price.1 = 0.0
                price.2 = false
                priceValue = bidValue
            }
            
        } else { //TODO: BUY
            if self.selectedPrice == "Limit" {
                self.type = 2
                price.0 = "Limit"
                price.1 = Double(liveValue) ?? 0.0
                price.2 = true
            } else if self.selectedPrice == "Stop" {
                self.type = 4
                price.0 = "Stop"
                price.1 = Double(liveValue) ?? 0.0
                price.2 = true
            } else { //TODO: STOP Price.
                self.type = 0
                price.0 = ""
                price.1 = 0.0
                price.2 = false
                priceValue = bidValue
            }
        }
        //MARK: - END Price Logic
        
        //MARK: - START profit Logic
        if takeProfit_switch.isOn {
            if self.selectedPrice == "Market" {
                profit.0 = "Profit"
                profit.1 = Double(liveValue) ?? 0.0
                profit.2 = true
            }else{
                profit.0 = "Profit"
                profit.1 = Double(tf_priceValue.text ?? "") ?? 0.0
                profit.2 = true
            }
        } else {
            profit.0 = ""
            profit.1 = 0.0
            profit.2 = false
        }
        //MARK: - END profit Logic
        
        //MARK: - START loss Logic
        if stopLoss_switch.isOn {
            if self.selectedPrice == "Market" {
                loss.0 = "Loss"
                loss.1 = Double(liveValue) ?? 0.0
                loss.2 = true
            }else{
                loss.0 = "Loss"
                loss.1 = Double(tf_priceValue.text ?? "") ?? 0.0
                loss.2 = true
            }
        } else {
            loss.0 = ""
            loss.1 = 0.0
            loss.2 = false
        }
        //MARK: - END loss Logic
        
        //MARK: - START Main Logic
        if price.2 == true || profit.2 == true || loss.2 == true {
            
            var isConfirmEnable: [(String,Bool,String)] = [("",false,""), ("",false,""), ("",false,"")]
            
            if price.2 == true && price.0 == "Limit" {  //TODO: LIMIT ORDER TYPE
                
                if !isFirstValueSet {
                    bidValue = Double(liveValue)!
                    // Set the text field with the first value
                    tf_priceValue.text = String(liveValue)
                    currentValue2 = Double(liveValue)!
                    // Update the flag so the field is not updated again
                    isFirstValueSet = true
                }
                
                let myPriceValue: Double = Double(tf_priceValue.text ?? "0") ?? 0
                
                if titleString == "SELL" { //TODO: SELL for LIMIT ORDER TYPE
                    
                    self.lbl_currentPriceValue.text = "Min. " + "\(liveValue)"  // According to logic later
                    //                        lbl_limit.text = "Limit"
                    
                    if price.1 < myPriceValue {
                        isConfirmEnable[0].1 = true
                        isConfirmEnable[0].0 = "on"
                        isConfirmEnable[0].2 = "SELL"
                    }else{
                        isConfirmEnable[0].1 = false
                        isConfirmEnable[0].0 = "on"
                        isConfirmEnable[0].2 = "SELL"
                    }
                    if profit.2 == true && profit.0 == "Profit" {
                        if !isFirstValueTakeProfit {
                            tf_takeProfit.text = String(liveValue)
                            currentValue3 = Double(liveValue)!
                            isFirstValueTakeProfit = true
                        }
                        let myTakeProfitValue: Double = Double(tf_takeProfit.text ?? "0") ?? 0
                        if myPriceValue > myTakeProfitValue {
                            isConfirmEnable[1].1 = true
                            isConfirmEnable[1].0 = "on"
                            isConfirmEnable[1].2 = "Profit"
                        }else{
                            isConfirmEnable[1].1 = false
                            isConfirmEnable[1].0 = "on"
                            isConfirmEnable[1].2 = "Profit"
                        }
                    }
                    if loss.2 == true && loss.0 == "Loss" {
                        if !isFirstValueStopLoss {
                            tf_stopLoss.text = String(liveValue)
                            currentValue4 = Double(liveValue)!
                            isFirstValueStopLoss = true
                        }
                        let myStopLossValue: Double = Double(tf_stopLoss.text ?? "0") ?? 0
                        if myPriceValue < myStopLossValue {
                            isConfirmEnable[2].1 = true
                            isConfirmEnable[2].0 = "on"
                            isConfirmEnable[2].2 = "Loss"
                        }else{
                            isConfirmEnable[2].1 = false
                            isConfirmEnable[2].0 = "on"
                            isConfirmEnable[2].2 = "Loss"
                        }
                    }
                    
                } else { //TODO: BUY for LIMIT ORDER TYPE
                    
//                    let myPriceValue: Double = Double(tf_priceValue.text ?? "0") ?? 0
                    
                    self.lbl_currentPriceValue.text = "Max. " + "\(liveValue)" // According to logic later
                    
                    if price.1 > myPriceValue {
                        isConfirmEnable[0].1 = true
                        isConfirmEnable[0].0 = "on"
                        isConfirmEnable[0].2 = "BUY"
                    }else{
                        isConfirmEnable[0].1 = false
                        isConfirmEnable[0].0 = "on"
                        isConfirmEnable[0].2 = "BUY"
                    }
                }
                if profit.2 == true && profit.0 == "Profit" {
                    if !isFirstValueTakeProfit {
                        tf_takeProfit.text = String(liveValue)
                        currentValue3 = Double(liveValue)!
                        isFirstValueTakeProfit = true
                    }
                    let myTakeProfitValue: Double = Double(tf_takeProfit.text ?? "0") ?? 0
                    
                    if titleString == "SELL" { //TODO: SELL for LIMIT ORDER TYPE
                        if myPriceValue > myTakeProfitValue {
                            isConfirmEnable[1].1 = true
                            isConfirmEnable[1].0 = "on"
                            isConfirmEnable[1].2 = "Profit"
                        }else{
                            isConfirmEnable[1].1 = false
                            isConfirmEnable[1].0 = "on"
                            isConfirmEnable[1].2 = "Profit"
                        }
                    } else { //TODO: BUY for LIMIT ORDER TYPE
                        if myPriceValue < myTakeProfitValue {
                            isConfirmEnable[1].1 = true
                            isConfirmEnable[1].0 = "on"
                            isConfirmEnable[1].2 = "Profit"
                        }else{
                            isConfirmEnable[1].1 = false
                            isConfirmEnable[1].0 = "on"
                            isConfirmEnable[1].2 = "Profit"
                        }
                    }
                  
                }
                if loss.2 == true && loss.0 == "Loss" {
                    if !isFirstValueStopLoss {
                        tf_stopLoss.text = String(liveValue)
                        currentValue4 = Double(liveValue)!
                        isFirstValueStopLoss = true
                    }
                    let myStopLossValue: Double = Double(tf_stopLoss.text ?? "0") ?? 0
                    
                    if titleString == "SELL" { //TODO: SELL for LIMIT ORDER TYPE
                        if myPriceValue < myStopLossValue {
                            isConfirmEnable[2].1 = true
                            isConfirmEnable[2].0 = "on"
                            isConfirmEnable[2].2 = "Loss"
                        }else{
                            isConfirmEnable[2].1 = false
                            isConfirmEnable[2].0 = "on"
                            isConfirmEnable[2].2 = "Loss"
                        }
                    } else { //TODO: BUY for LIMIT ORDER TYPE
                        if myPriceValue > myStopLossValue {
                            isConfirmEnable[2].1 = true
                            isConfirmEnable[2].0 = "on"
                            isConfirmEnable[2].2 = "Loss"
                        }else{
                            isConfirmEnable[2].1 = false
                            isConfirmEnable[2].0 = "on"
                            isConfirmEnable[2].2 = "Loss"
                        }
                    }
               
                }
                
            } else if price.2 == true && price.0 == "Stop" { //TODO: STOP ORDER TYPE
                if !isFirstValueSet {
                    bidValue = Double(liveValue)!
                    // Set the text field with the first value
                    tf_priceValue.text = String(liveValue)
                    currentValue2 = Double(liveValue)!
                    // Update the flag so the field is not updated again
                    isFirstValueSet = true
                }
                
                if titleString == "SELL" {        //TODO: SELL FOR STOP order type
                    let myPriceValue: Double = Double(tf_priceValue.text ?? "0") ?? 0
                    self.lbl_currentPriceValue.text = "Max. " + "\(liveValue)"
                    //                        lbl_limit.text = "Stop"
                    
                    if price.1 > myPriceValue {
                        isConfirmEnable[0].1 = true
                        isConfirmEnable[0].0 = "on"
                        isConfirmEnable[0].2 = "SELL"
                    }else{
                        isConfirmEnable[0].1 = false
                        isConfirmEnable[0].0 = "on"
                        isConfirmEnable[0].2 = "SELL"
                    }
                    if profit.2 == true && profit.0 == "Profit" {
                        if !isFirstValueTakeProfit {
                            tf_takeProfit.text = String(liveValue)
                            currentValue3 = Double(liveValue)!
                            isFirstValueTakeProfit = true
                        }
                        let myTakeProfitValue: Double = Double(tf_takeProfit.text ?? "0") ?? 0
                        if myPriceValue > myTakeProfitValue {
                            isConfirmEnable[1].1 = true
                            isConfirmEnable[1].0 = "on"
                            isConfirmEnable[1].2 = "Profit"
                        }else{
                            isConfirmEnable[1].1 = false
                            isConfirmEnable[1].0 = "on"
                            isConfirmEnable[1].2 = "Profit"
                        }
                    }
                    if loss.2 == true && loss.0 == "Loss" {
                        if !isFirstValueStopLoss {
                            tf_stopLoss.text = String(liveValue)
                            currentValue4 = Double(liveValue)!
                            isFirstValueStopLoss = true
                        }
                        let myStopLossValue: Double = Double(tf_stopLoss.text ?? "0") ?? 0
                        if myPriceValue < myStopLossValue {
                            isConfirmEnable[2].1 = true
                            isConfirmEnable[2].0 = "on"
                            isConfirmEnable[2].2 = "Loss"
                        }else{
                            isConfirmEnable[2].1 = false
                            isConfirmEnable[2].0 = "on"
                            isConfirmEnable[2].2 = "Loss"
                        }
                    }
                } else { //TODO: BUY FOR STOP order type
                    let myPriceValue: Double = Double(tf_priceValue.text ?? "0") ?? 0
                    self.lbl_currentPriceValue.text = "Min. " + "\(liveValue)"
                    if price.1 < myPriceValue {
                        isConfirmEnable[0].1 = true
                        isConfirmEnable[0].0 = "on"
                        isConfirmEnable[0].2 = "BUY"
                    }else{
                        isConfirmEnable[0].1 = false
                        isConfirmEnable[0].0 = "on"
                        isConfirmEnable[0].2 = "BUY"
                    }
                    if profit.2 == true && profit.0 == "Profit" {   //TODO: TakeProfit
                        if !isFirstValueTakeProfit {
                            tf_takeProfit.text = String(liveValue)
                            currentValue3 = Double(liveValue)!
                            isFirstValueTakeProfit = true
                        }
                        let myTakeProfitValue: Double = Double(tf_takeProfit.text ?? "0") ?? 0
                        if profit.1 < myTakeProfitValue {
                            isConfirmEnable[1].1 = true
                            isConfirmEnable[1].0 = "on"
                            isConfirmEnable[1].2 = "Profit"
                        }else{
                            isConfirmEnable[1].1 = false
                            isConfirmEnable[1].0 = "on"
                            isConfirmEnable[1].2 = "Profit"
                        } }
                    if loss.2 == true && loss.0 == "Loss" {     //TODO: STOP LOSS
                        if !isFirstValueStopLoss {
                            tf_stopLoss.text = String(liveValue)
                            currentValue4 = Double(liveValue)!
                            isFirstValueStopLoss = true
                        }
                        let myStopLossValue: Double = Double(tf_stopLoss.text ?? "0") ?? 0
                        if loss.1 > myStopLossValue {
                            isConfirmEnable[2].1 = true
                            isConfirmEnable[2].0 = "on"
                            isConfirmEnable[2].2 = "Loss"
                        }else{
                            isConfirmEnable[2].1 = false
                            isConfirmEnable[2].0 = "on"
                            isConfirmEnable[2].2 = "Loss"
                        } }
                }
            }
            var checkEnable = false
            
            for isEnable in isConfirmEnable {
                    if isEnable.0 != "" {
                        if !isEnable.1 {
                            checkEnable = true
                            
                            if isEnable.2 == "SELL" {
                                self.btn_confirm.isEnabled = false
                                self.btn_confirm.layer.borderColor = UIColor.systemGray2.cgColor
                                self.btn_confirm.titleLabel?.textColor = UIColor.systemGray2
                                self.price_view.layer.borderWidth = 0.3
                                self.price_view.layer.borderColor = UIColor.red.cgColor
                                self.lbl_currentPriceValue.textColor = UIColor.red
                            } else if isEnable.2 == "BUY" {
                                self.btn_confirm.isEnabled = false
                                self.btn_confirm.layer.borderColor = UIColor.systemGray2.cgColor
                                self.btn_confirm.titleLabel?.textColor = UIColor.systemGray2
                                self.price_view.layer.borderWidth = 0.3
                                self.price_view.layer.borderColor = UIColor.red.cgColor
                                self.lbl_currentPriceValue.textColor = UIColor.red
                            } else if isEnable.2 == "Profit" {
                                self.btn_confirm.isEnabled = false
                                self.btn_confirm.layer.borderColor = UIColor.systemGray2.cgColor
                                self.btn_confirm.titleLabel?.textColor = UIColor.systemGray2
                                self.takeProfit_view.layer.borderWidth = 0.3
                                self.takeProfit_view.layer.borderColor = UIColor.red.cgColor
                                self.lbl_liveProfitLoss.isHidden = false
                                let value: Double = (Double(tf_priceValue.text ?? "0.0") ?? 0.0)// + 0.01
                                
                                
                                if titleString == "SELL" { //TODO: SELL for LIMIT ORDER TYPE
                            
                                    let plusValue = value.adjusted(by: "minus")
                                    self.lbl_liveProfitLoss.text = "Max. \(plusValue)"
                                } else {
                                    let plusValue = value.adjusted(by: "plus")
                                    self.lbl_liveProfitLoss.text = "Min. \(plusValue)"
                                }
                                
                                self.lbl_liveProfitLoss.textColor = UIColor.red
                            } else if isEnable.2 == "Loss" {
                                self.btn_confirm.isEnabled = false
                                self.btn_confirm.layer.borderColor = UIColor.systemGray2.cgColor
                                self.btn_confirm.titleLabel?.textColor = UIColor.systemGray2
                                self.stopLoss_view.layer.borderWidth = 0.3
                                self.stopLoss_view.layer.borderColor = UIColor.red.cgColor
                                self.lbl_liveStopLoss.isHidden = false
                                let value: Double = (Double(tf_priceValue.text ?? "0.0") ?? 0.0)// - 0.01
                                                                
                                if titleString == "SELL" { //TODO: SELL for LIMIT ORDER TYPE
                        
                                    let minusValue = value.adjusted(by: "plus")
                                    self.lbl_liveStopLoss.text = "Min. \(minusValue)"
                                } else {
                                    let minusValue = value.adjusted(by: "minus")
                                    self.lbl_liveStopLoss.text = "Max. \(minusValue)"
                                }
                                
                                self.lbl_liveStopLoss.textColor = UIColor.red
                            }
                        }
                    }
                }
            
            if !checkEnable {
                self.btn_confirm.isEnabled = true
                self.btn_confirm.tintColor = UIColor.systemYellow
                self.btn_confirm.layer.borderColor = UIColor.systemYellow.cgColor
                
                self.stopLoss_view.layer.borderColor = UIColor.lightGray.cgColor
                self.lbl_liveStopLoss.isHidden = true
                
                self.price_view.layer.borderColor = UIColor.darkGray.cgColor
                self.lbl_currentPriceValue.textColor = UIColor.lightGray
                
                self.takeProfit_view.layer.borderColor = UIColor.darkGray.cgColor
                self.lbl_liveProfitLoss.isHidden = true
            }
        }
        
        bidValue = Double(liveValue) ?? 0.0
    }
    
    func updateVolumeValue() {
        
        //        // Check if the new selection is the same as the previous one
        if selectedVolume == previousSelectedVolume {
            // If the same, do nothing and return
            print("Selected volume is the same as the previous one, no update needed.")
            return
        }
        
        // Update the previous selected volume with the current one
        previousSelectedVolume = selectedVolume
        
        print("\n contractSize: \(contractSize) \t userInput: \(Double(self.tf_volume.text ?? "") ?? 0) \t bidValue: \(bidValue)")
        getTF_Volume = Double(self.tf_volume.text ?? "") ?? 0
        
        if selectedVolume == "Lots" {
            
            let total = (getTF_Volume ?? 0) / (bidValue ?? 0)
            let getTotal = String(format: "%.\(self.digits ?? 0)f", total)
            print("\n getTotal: \(getTotal)")
            
            self.volume = (Double(getTotal) ?? 0.0) / Double(contractSize ?? 0)
            
            let getTotalVolume = String(format: "%.\(self.digits ?? 0)f", Double(self.volume ?? 0.0))
            print("\n getTotalVolume: \(getTotalVolume)")
            
            let roundedValue = Double(round(1000 * (Double(getTotalVolume) ?? 0.0)) / 1000)
            print("\n rounded value : \(roundedValue)")
            self.tf_volume.text = "\(roundedValue)"
        }else{
            
            let total = (getTF_Volume ?? 0)  * Double(contractSize ?? 0) * Double(bidValue ?? 0)
            print("\n total: \(total)")
            
            let roundedValue = Double(round(1000 * total) / 1000)
            print("\n rounded value : \(roundedValue)")
            self.tf_volume.text = "\(roundedValue)"
        }
    }
    
    @IBAction func volumeMinus_action(_ sender: Any) {
        
        updateVolumeValue(increment: false)
    }
    @IBAction func volumePlus_action(_ sender: Any) {
        
        updateVolumeValue(increment: true)
    }
    @IBAction func volume_dropDownAction(_ sender: Any) {
        self.dynamicDropDownButton(sender as! UIButton, list: volumeList) { index, item in
            print("drop down index = \(index)")
            print("drop down item = \(item)")
            //            self.lbl_volumeDropdown.text = item
            self.selectedVolume = item
            self.updateVolumeValue()
        }
    }
    
    //MARK: - price actions
    @IBAction func price_dropDownAction(_ sender: Any) {
        self.dynamicDropDownButton(sender as! UIButton, list: priceList) { index, item in
            print("Order Type drop down index = \(index)")
            print("Order Type  drop down item = \(item)")
            // self.lbl_PriceDropdown.text = item
            self.selectedPrice = item
            
            self.updateUIBasedOnSelectedPrice()
        }
    }
    
    func updateUIBasedOnSelectedPrice() {
        if selectedPrice == "Market" {
            price_view.isHidden = true
            lbl_currentPriceValue.isHidden = true
            //            lbl_limit.isHidden = true
            priceValue = bidValue
            priceValue_view.layer.borderWidth = 0
            btn_confirm.isEnabled = true
        } else {
            price_view.isHidden = false
            lbl_currentPriceValue.isHidden = false
            //            lbl_limit.isHidden = false
            price_view.layer.borderWidth = 0.3
        }
    }
    
    @IBAction func priceMinus_action(_ sender: Any) {
        updateValue(for: tf_priceValue, increment: false)
    }
    @IBAction func pricePlus_action(_ sender: Any) {
        updateValue(for: tf_priceValue, increment: true)
    }
    
    func updateVolumeValue(increment: Bool) {
        //        var step: Double = 0 // incrementedValue
        var userCurrentValue: Double = 0.0
        
        if let volumeText = self.tf_volume.text {
            userCurrentValue = Double(volumeText) ?? 0
            // Successfully converted the text to a Double
            print("The current value is: \(userCurrentValue)")
        } else {
            print("Error: Invalid volume input")
        }
        
        var step: Double = 0.01
        currentValue =  userCurrentValue
        
        if increment {
            if selectedVolume == "Lots" {
                currentValue += step
            }else{
                step = bidValue ?? 0
                let maxValue = Double(volumeMax ?? 0) * Double(contractSize ?? 0) * Double(bidValue ?? 0)
                
                print("step = \(step) \t maxValue: \(maxValue)")
                
                if currentValue < maxValue {
                    currentValue = currentValue + step
                    print("\n currentValue = \(currentValue)")
                }
                
            }
        }else {
            if selectedVolume == "Lots" {
                if currentValue > 0.01 {
                    currentValue -= step
                }
            }else{
                // usd minus
                step = bidValue ?? 0
                let minValue = Double(volumeMin ?? 0)  * Double(bidValue ?? 0)
                print("\n step = \(step) \t minValue: \(minValue) \t currentValue: \(currentValue)")
                
                if currentValue > minValue {
                    currentValue = currentValue - step
                    if currentValue <  minValue  {
                        currentValue =  minValue // Ensure it doesn't go below minValue
                    }
                    print("\n currentValue after minus = \(currentValue)")
                }
            }
        }
        volume = currentValue
        self.tf_volume.text = String(format: "%.\(self.digits ?? 0)f", (currentValue))
        
    }
    
    func updateValue(for textField: UITextField, increment: Bool) {
        //        let step: Double = 0.01 self.digits  You can adjust the step value (e.g., 0.1 for increments in decimal)
        let step: Double = pow(10.0, -Double(self.digits ?? 0))
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
        textField.text = String(format: "%.\(self.digits ?? 0)f", currentValue)
        
        // Save the updated current value back to the respective variable
        switch textField {
        case tf_volume:
            currentValue1 = currentValue
        case tf_priceValue:
            currentValue2 = currentValue
            priceValue = currentValue
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
        
        if sender.isOn {
            self.takeProfit_view.isUserInteractionEnabled = true
            //            lbl_TP.isHidden = false
            takeProfit_switch.thumbTintColor = .systemYellow
            takeProfit_switch.onTintColor = .darkGray
        }else{
            self.takeProfit_view.isUserInteractionEnabled = false
            //            lbl_TP.isHidden = true
            self.takeProfit_view.layer.borderColor = UIColor.darkGray.cgColor
            self.lbl_liveProfitLoss.isHidden = true
            self.takeProfit = 0.0
            takeProfit_switch.thumbTintColor = .white
            takeProfit_switch.onTintColor = .darkGray
            self.btn_confirm.isEnabled = true
            self.btn_confirm.layer.borderColor = UIColor.systemYellow.cgColor
        }
    }
    
    @IBAction func takeProfit_dropDownAction(_ sender: Any) {
        self.dynamicDropDownButtonForTakeProfit(sender as! UIButton, list: takeProfitList) { index, item in
            print("TakeProfit drop down index = \(index)")
            print("Take Profit drop down item = \(item)")
            // Check if selected item is the same as previousType
            if self.previousTakeProfitType == item {
                print("Same type selected, no conversion needed.")
                return  // Exit without doing anything
            }
            
            let value = self.calculateProfitOrLoss(input: self.tf_takeProfit.text ?? "", selectedType: item, bidPrice: self.bidValue ?? 0.0, orderType: self.titleString, digits: self.digits ?? 0, previousType: self.previousTakeProfitType, isTakeProfit: true)
            print("new take profit converted value is = \(value)")
            self.currentValue3 = value
            self.tf_takeProfit.text = ("\(String(format: "%.\(self.digits ?? 0)f", value))")
            
            self.previousTakeProfitType = item
            
        }
    }
    
    @IBAction func takeProfitMinus_action(_ sender: Any) {
        updateValue(for: tf_takeProfit, increment: false)
    }
    
    @IBAction func takeProfitPlus_action(_ sender: Any) {
        updateValue(for: tf_takeProfit, increment: true)
    }
    
    @IBAction func profit_clearAction(_ sender: Any) {
        //        lbl_TP.isHidden = true
        liveValue_view.isHidden = true
        tf_takeProfit.text = ""
        tf_takeProfit.attributedPlaceholder = NSAttributedString(
            string: "not set",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white] // Change color here
        )
        
    }
    //MARK: - stop Loss actions
    
    @IBAction func stopLoss_switchAction(_ sender: UISwitch) {
        //       updateStopLossView()
        if sender.isOn {
            self.stopLoss_view.isUserInteractionEnabled = true
            //            lbl_SL.isHidden = false
            stopLoss_switch.thumbTintColor = .systemYellow
            stopLoss_switch.onTintColor = .darkGray
        }else{
            self.stopLoss_view.isUserInteractionEnabled = false
            //            lbl_SL.isHidden = true
            self.stopLoss_view.layer.borderColor = UIColor.darkGray.cgColor
            self.lbl_liveStopLoss.isHidden = true
            self.stopLoss = 0.0
            stopLoss_switch.thumbTintColor = .white
            stopLoss_switch.tintColor = .darkGray
            self.btn_confirm.isEnabled = true
            self.btn_confirm.layer.borderColor = UIColor.systemYellow.cgColor
        }
    }
    
    @IBAction func stopLoss_dropDownAction(_ sender: Any) {
        self.dynamicDropDownButtonForTakeProfit(sender as! UIButton, list: stopLossList) { index, item in
            print("StopLoss drop down index = \(index)")
            print("StopLoss drop down item = \(item)")
            // Check if selected item is the same as previousType
            if self.previousStopLossType == item {
                print("Same type selected, no conversion needed.")
                return  // Exit without doing anything
            }
            
            let value = self.calculateProfitOrLoss(input: self.tf_stopLoss.text ?? "", selectedType: item, bidPrice: self.bidValue ?? 0.0, orderType: self.titleString, digits: self.digits ?? 0, previousType: self.previousStopLossType, isTakeProfit: false)
            
            print("new stop loss converted value is = \(value)")
            self.currentValue4 = value
            
            self.tf_stopLoss.text =  ("\(String(format: "%.\(self.digits ?? 0)f", value))")
            self.previousStopLossType = item
        }
    }
    
    @IBAction func stopLossMinus_action(_ sender: Any) {
        updateValue(for: tf_stopLoss, increment: false)
    }
    
    @IBAction func stopLossPlus_action(_ sender: Any) {
        updateValue(for: tf_stopLoss, increment: true)
    }
    
    @IBAction func stopLoss_clearAction(_ sender: Any) {
        //        lbl_SL.isHidden = true
        stopLossLiveValue_view.isHidden = true
        tf_stopLoss.text = ""
        //        tf_stopLoss.placeholder = "not set"
        tf_stopLoss.attributedPlaceholder = NSAttributedString(
            string: "not set",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white] // Change color here
        )
    }
   
    func calculateProfitOrLoss(input: String, selectedType: String, bidPrice: Double, orderType: String, digits: Int, previousType: String? = nil, isTakeProfit: Bool = true) -> Double {
        var resultValue: Double = 0.0
        
        print("\n input: \(input) ,\t selectedType: \(selectedType), \t bidPrice: \(bidPrice), \t orderType: \(orderType), digits: \(digits), \t isTakeProfit: \(isTakeProfit) \n")
        
        // Adjusted pipValue based on the provided digits
        let pipValue = 1.0 / pow(10.0, Double(digits))
        
        // If the user switches from one type to another, convert the input accordingly
        if let previousType = previousType, previousType != selectedType, let inputValue = Double(input) {
            // Determine the list based on whether it's take profit or stop loss
            let actionList = isTakeProfit ? takeProfitList : stopLossList
            
            switch (previousType, selectedType) {
            case ("Profit in %", "Profit in Price"), ("Loss in %", "Loss in Price"):
                let amount = bidPrice * (inputValue / 100.0)
                resultValue = (orderType == "BUY") ? (bidPrice + (isTakeProfit ? amount : -amount)) : (bidPrice - (isTakeProfit ? amount : -amount))
                return resultValue
                
            case ("Profit in %", "Profit in Pips"), ("Loss in %", "Loss in Pips"):
                let amount = bidPrice * (inputValue / 100.0)
                let pips = amount / pipValue
                return pips
                
            case ("Profit in Pips", "Profit in Price"), ("Loss in Pips", "Loss in Price"):
                let amount = inputValue * pipValue
                resultValue = (orderType == "BUY") ? (bidPrice + (isTakeProfit ? amount : -amount)) : (bidPrice - (isTakeProfit ? amount : -amount))
                return resultValue
                
            case ("Profit in Pips", "Profit in %"), ("Loss in Pips", "Loss in %"):
                let amount = inputValue * pipValue
                let percentage = (amount / bidPrice) * 100.0
                return percentage
                
            case ("Profit in Price", "Profit in %"), ("Loss in Price", "Loss in %"):
                let percentage = ((inputValue - bidPrice) / bidPrice) * 100.0
                return percentage
                
            case ("Profit in Price", "Profit in Pips"), ("Loss in Price", "Loss in Pips"):
                let pips = (inputValue - bidPrice) / pipValue
                return pips
                
            default:
                break
            }
        }
        // Default to the original case (no type switch needed)
        if let inputValue = Double(input) {
            switch selectedType {
            case "Profit in %":
                let amount = bidPrice * (inputValue / 100.0)
                resultValue = (orderType == "BUY") ? (bidPrice + amount) : (bidPrice - amount)
            case "Profit in Pips":
                let amount = inputValue * pipValue
                resultValue = (orderType == "BUY") ? (bidPrice + amount) : (bidPrice - amount)
            case "Profit in Price":
                resultValue = (orderType == "BUY") ? (bidPrice + inputValue) : (bidPrice - inputValue)
                
            case "Loss in %":
                let amount = bidPrice * (inputValue / 100.0)
                resultValue = (orderType == "BUY") ? (bidPrice - amount) : (bidPrice + amount)
            case "Loss in Pips":
                let amount = inputValue * pipValue
                resultValue = (orderType == "BUY") ? (bidPrice - amount) : (bidPrice + amount)
            case "Loss in Price":
                resultValue = (orderType == "BUY") ? (bidPrice - inputValue) : (bidPrice + inputValue)
                
            default:
                break
            }
        }
        
        return resultValue
    }
    
    // Function to convert to takeProfit price before API call
    func convertToTPprice(input: String, bidPrice: Double, orderType: String, digits: Int) -> Double {
        
        if previousTakeProfitType == "Profit in Price" {
            return Double(input) ?? bidPrice
        }else{
            return calculateProfitOrLoss(input: input, selectedType: "Profit in Price", bidPrice: bidPrice, orderType: orderType, digits: digits, previousType: previousTakeProfitType)
            
        }
    }
    // Function to convert to StopLoss price before API call
    func convertToSLprice(input: String, bidPrice: Double, orderType: String, digits: Int) -> Double {
        
        if previousStopLossType == "Loss in Price" {
            return Double(input) ?? bidPrice
        }else{
            return calculateProfitOrLoss(input: input, selectedType: "Profit in Price", bidPrice: bidPrice, orderType: orderType, digits: digits, previousType: previousTakeProfitType)
        }
    }
    
    @IBAction func cancel_btnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            print("Bottom sheet dismissed on cancel btn press")
        })
    }
    
    @IBAction func submit_btnAction(_ sender: Any) {
        
        if selectedVolume == "Lots" {
            volume = Double(self.tf_volume.text ?? "")
        }else{
            let total = (Double(self.tf_volume.text ?? "") ?? 0) / (bidValue ?? 0)
            let y = total / Double(contractSize ?? 0)
            volume = y
        }
        
        priceValue =  Double(self.tf_priceValue.text ?? "")
        
        if priceValue == nil {
            priceValue = bidValue
        }
        stopLoss = Double(self.tf_stopLoss.text ?? "") ?? 0
        takeProfit = Double(self.tf_takeProfit.text ?? "") ?? 0
        
        if !selectedSymbol!.contains(".") {
            selectedSymbol! += "."
        }
        
//        print("\n symbol: \(selectedSymbol) \t contractSize: \(String(describing: contractSize)) \t volumeStep: \(volumeStep ?? 0) \t volumeMax:\(volumeMax) \t volumeMin: \(volumeMin) \t digits: \(digits) \n password: \(userPassword) \t email: \(userEmail) \t loginID: \(userLoginID) \t type: \(type) \t digit_currcny: \(digits_currency)  \t volume: \(volume) \t price: \(priceValue) \t stop_loss: \(stopLoss) \t take_profit: \(takeProfit)")
        
        createOrder(email: userEmail ?? "", loginID: userLoginID ?? 0, password: userPassword ?? "", symbol: selectedSymbol ?? "" , type: type ?? 0, volume: volume ?? 0, price: priceValue ?? 0, stop_loss: stopLoss, take_profit: takeProfit, digits: digits ?? 0, digits_currency: digits_currency, contract_size: contractSize ?? 0, comment: "comment testing")
    }
}

extension TicketVC {
    
    func createOrder(email: String, loginID: Int, password: String, symbol: String, type: Int, volume: Double, price: Double, stop_loss: Double, take_profit: Double, digits: Int, digits_currency: Int, contract_size: Int, comment: String) {
        ActivityIndicator.shared.show(in: self.view, style: .large)
        
        var odooClient = OdooClientNew()
        
        let url = "https://mbe.riverprime.com/jsonrpc" //"http://18.116.153.208:8069/jsonrpc" //
        
        let parameters1: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 3000,
            "params": [
                "method": "execute_kw",
                "service": "object",
                "args": [
                    odooClient.dataBaseName,
                    odooClient.uid,
                    odooClient.dbPassword,
                    "mt.middleware",
                    "create_order",
                    [
                        [],
                        email,
                        loginID,
                        password,
                        symbol,
                        type,
                        volume,
                        price,
                        stop_loss,
                        take_profit,
                        digits,
                        digits_currency,
                        contract_size,
                        comment
                    ]
                ]
            ]
        ]
        print("\n parameters for create order : \(parameters1)")
        
        AF.request(url,
                   method: .post,
                   parameters: parameters1,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type": "application/json"])
        .validate()
        .responseJSON { (response: AFDataResponse<Any>) in
            switch response.result {
            case .success(let value):
                print("values of create order is: \(value)")
                ActivityIndicator.shared.hide(from: self.view)
                
                if let json = value as? [String: Any], let result = json["result"] as? [String: Any], let status = result["success"] as? Bool{
                    if status {
                        print("order place success")
                        DispatchQueue.main.async {
                            self.showTimeAlert(str: "Order placed successfully")
                        }
                        
                        let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                            self.dismiss(animated: true)
                        }
                        
                    }else {
                        if let result = json["result"] as? [String: Any], let error = result["Error"] as? String {
                            
                            print("Error response: \(error)")
                            DispatchQueue.main.async {
                                self.showTimeAlert(str: "\(error)")
                            }
                        }
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        self.showTimeAlert(str: "Order not placed")
                    }
                    
                    let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                        self.dismiss(animated: true)
                    }
                }
            case .failure(let error):
                // Handle the error
                ActivityIndicator.shared.hide(from: self.view)
                print("Request failed with error: \(error)")
            }
            
        }
        
    }
}
extension TicketVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tf_volume {
            let getTF_Volume = tf_volume.text
            self.getTF_Volume = Double(getTF_Volume ?? "0.0") ?? 0.0
        }
    }
    
}

extension Double {
    // Function to detect decimal places, including trailing zeros
    func decimalPlaces() -> Int {
        let stringValue = String(self)
        
        // Check if the value contains a decimal point
        if let decimalRange = stringValue.range(of: ".") {
            return stringValue[decimalRange.upperBound...].count
        }
        return 0
    }
    
    // Function to add/subtract based on detected decimal places
    func adjusted(by operation: String) -> Double {
        let places = self.decimalPlaces()
        let adjustment = pow(10.0, Double(-places))
        
        switch operation {
        case "plus":
            return (self + adjustment).rounded(toPlaces: places)
        case "minus":
            return (self - adjustment).rounded(toPlaces: places)
        default:
            return self
        }
    }
    
    // Function to round to a given decimal place, preserving precision
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
