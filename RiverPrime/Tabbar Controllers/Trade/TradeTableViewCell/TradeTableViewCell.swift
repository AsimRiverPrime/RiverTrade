//
//  TradeTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 12/07/2024.
//

import UIKit
//import SDWebImage
//import SDWebImageSVGKitPlugin

class TradeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var currencyICon: UIImageView!
    @IBOutlet weak var lblCurrencySymbl: UILabel!
    @IBOutlet weak var lblCurrencyName: UILabel!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var lbl_bidAmount: UILabel!
    @IBOutlet weak var lblPercent: UILabel!
    @IBOutlet weak var profitIcon: UIImageView!
    @IBOutlet weak var lbl_askAmount: UILabel!
    @IBOutlet weak var lbl_pipsValues: UILabel!
    @IBOutlet weak var lbl_datetime: UILabel!
    @IBOutlet weak var lbl_pointsDiff: UILabel!
    @IBOutlet weak var openPosSymbolColorView: UIView!
    @IBOutlet weak var lbl_bid_low: UILabel!
    @IBOutlet weak var lbl_ask_high: UILabel!
    
    //    private var chart: LightweightCharts? // Chart reference to keep it persistent
    //    private var series: AreaSeries? // The chart's area series
    private var isChartCreated = false // Flag to ensure chart is created only once
    private var darkBackground: UIView? // To keep the background dark while chart loads
    //    var options = AreaSeriesOptions()
    
    var close = Double()
    var previousValue: Double?
    var previousValueAsk: Double?
    var digits: Int?
    var lastClosedValue: Double?
    
    var onLabelSymbolTapped: (() -> Void)?
    var onLabelAskTapped: (() -> Void)?
    var onLabelBidTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Add gesture recognizers
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(labelSymbolTapped))
        lblCurrencySymbl.isUserInteractionEnabled = true
        lblCurrencySymbl.addGestureRecognizer(tapGesture1)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(labelBidTapped))
        lbl_bidAmount.isUserInteractionEnabled = true
        lbl_bidAmount.addGestureRecognizer(tapGesture2)
        
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(labelAskTapped))
        lbl_askAmount.isUserInteractionEnabled = true
        lbl_askAmount.addGestureRecognizer(tapGesture3)
        
        openPosSymbolColorView.layer.cornerRadius = 2.5
        
    }
    
    // Gesture recognizer actions
    @objc private func labelSymbolTapped() {
        onLabelSymbolTapped?()
    }
    
    @objc private func labelAskTapped() {
        onLabelAskTapped?()
    }
    
    @objc private func labelBidTapped() {
        onLabelBidTapped?()
    }
    
    func setStyledLabel(value: Double, digit: Int, label: UILabel) {
        let boldColor: UIColor
        boldColor = .white
      
        // Format the value to the specified number of digits
        let format = "%.\(digit)f"
        let valueString = String(format: format, value).trimmingCharacters(in: .whitespaces)
        
        // Split the value into integer and decimal parts
        let parts = valueString.split(separator: ".")
        let integerPart = String(parts[0]) + "."
        var decimalPart = parts.count > 1 ? String(parts[1]) : ""
        
        // Attributes for normal, bold, and superscript text
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.white
        ]
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 25),
            .foregroundColor: boldColor
        ]
        let superscriptAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: boldColor,
            .baselineOffset: 8 // Raise the last digit slightly
        ]
        
        let attributedText = NSMutableAttributedString(string: integerPart, attributes: normalAttributes)
        
        // Apply logic for decimal part styling
        if decimalPart.isEmpty {
            decimalPart = "0"
            attributedText.append(NSAttributedString(string: decimalPart, attributes: boldAttributes))
        } else if decimalPart.count == 1 {
            attributedText.append(NSAttributedString(string: decimalPart, attributes: boldAttributes))
        } else if decimalPart.count == 2 {
            attributedText.append(NSAttributedString(string: decimalPart, attributes: boldAttributes))
        } else if decimalPart.count == 3 {
            let firstTwoDigits = String(decimalPart.prefix(2))
            let lastDigit = String(decimalPart.suffix(1))
            
            attributedText.append(NSAttributedString(string: firstTwoDigits, attributes: boldAttributes))
            attributedText.append(NSAttributedString(string: lastDigit, attributes: superscriptAttributes))
        } else if decimalPart.count == 4 {
            let firstDigit = String(decimalPart.prefix(1))
            let middleDigits = String(decimalPart.dropFirst(1).prefix(2))
            let lastDigit = String(decimalPart.suffix(1))
            
            attributedText.append(NSAttributedString(string: firstDigit, attributes: normalAttributes))
            attributedText.append(NSAttributedString(string: middleDigits, attributes: boldAttributes))
            attributedText.append(NSAttributedString(string: lastDigit, attributes: superscriptAttributes))
        } else if decimalPart.count >= 5 {
            let firstTwoDigits = String(decimalPart.prefix(2))
            let middleDigits = String(decimalPart.dropFirst(2).dropLast())
            let lastDigit = String(decimalPart.suffix(1))
            
            attributedText.append(NSAttributedString(string: firstTwoDigits, attributes: normalAttributes))
            if !middleDigits.isEmpty {
                attributedText.append(NSAttributedString(string: middleDigits, attributes: boldAttributes))
            }
            attributedText.append(NSAttributedString(string: lastDigit, attributes: superscriptAttributes))
        }
        
        // Set the styled text to the label
        label.attributedText = attributedText
    }
    
    func calculatePips(ask: Double, bid: Double, digits: Int) -> Int {
        // Calculate the difference
        let difference = ask - bid
        
        // Convert the difference into pips using the number of digits
        let pips = difference * pow(10.0, Double(digits))
        
        // Convert to an integer (round or truncate as required)
        return Int(round(pips))
    }
    
    func calculatePointDifferencePips(currentBid: Double, lastCloseBid: Double, decimalPrecision: Int) -> Int {
        // Points are usually 10x smaller than pips
        let newDigits = decimalPrecision >= 3 ? decimalPrecision - 1 : decimalPrecision
        
//        print("\n decimalPrecision/Digits::: ---> \(decimalPrecision) for symbol is: \(self.lblCurrencySymbl.text) \t new digits is: \(newDigits) \n")
       
        let pointMultiplier = Int(pow(10.0, Double(decimalPrecision)))
       
//         let result = Int(round(abs(currentBid - lastCloseBid) * Double(newDigits) * Double(pointMultiplier)))
        // Calculate the point difference
        let result = Int(round(abs(currentBid - lastCloseBid) * Double(pointMultiplier)))
        
        return result
    }
    
    // This function is used to configure the cell based on trades and symbol data.
    class func cellForTableView(_ tableView: UITableView, atIndexPath indexPath: IndexPath, trades: [TradeDetails]) -> TradeTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TradeTableViewCell", for: indexPath) as? TradeTableViewCell else {
            return UITableViewCell() as! TradeTableViewCell
        }
        
        let trade = trades[indexPath.row]
        var symbolDataObj: SymbolData?
        
        if let obj = GlobalVariable.instance.symbolDataArray.first(where: { $0.name == trade.symbol }) {
            symbolDataObj = obj
        }
        
        cell.configure(with: trade, symbolDataObj: symbolDataObj, indexPath: indexPath)
        
        return cell
    }
    
    // Function to configure the cell's UI and chart based on trade data.
    func configure(with trade: TradeDetails, symbolDataObj: SymbolData? = nil, indexPath: IndexPath) {
          
        lblCurrencySymbl.text = trade.symbol
       
        let createDate = Date(timeIntervalSince1970: Double(trade.datetime))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = .current
        
        let datee = dateFormatter.string(from: createDate)
        
        self.lbl_datetime.text = datee
        
        setStyledLabel(value: trade.bid, digit: self.digits ?? 0, label: lbl_bidAmount)
        setStyledLabel(value: trade.ask, digit: self.digits ?? 0, label: lbl_askAmount)
        
        if let symbol = symbolDataObj{
            lblCurrencyName.text = symbol.description
            self.digits = Int(symbol.digits)
            self.lastClosedValue = Double(symbol.yesterday_close)
            print("symbol name: \(symbol.name) \t symbol description: \(symbol.description) \t symbol digits \(digits) \t symbol lastClosedValue: \(lastClosedValue)")
        }else{
            print("symbol data not fount:---------------------")
        }
       
        
        //MARK: - Check if Open position have data then match it with our trade list and show color to our View.
        if GlobalVariable.instance.openSymbolList.contains(trade.symbol) {
            openPosSymbolColorView.backgroundColor = UIColor.systemGreen // Match found at the same index
        } else {
            openPosSymbolColorView.backgroundColor = UIColor.clear // Default color
        }
        
        let pointsValues = calculatePointDifferencePips(currentBid: trade.bid, lastCloseBid: self.lastClosedValue ?? 0.0, decimalPrecision: self.digits ?? 0)
        self.lbl_pointsDiff.text = "\(pointsValues)"
        
        let pipsValues = calculatePips(ask: trade.ask, bid: trade.bid, digits: self.digits ?? 0)
        self.lbl_pipsValues.text = "\(pipsValues)"
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension String {
    func trimmedTrailingZeros() -> String {
        if let doubleValue = Double(self) {
            return String(format: "%.2f", doubleValue)
        }
        return self
    }
    
   static func formatStringNumber(_ numberString: String) -> String {
        if let number = Double(numberString) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: number)) ?? numberString
        }
        return numberString  // Return original if conversion fails
    }
    
    static func formatStringNumberTF(_ numberString: String) -> String {
          let cleaned = numberString.replacingOccurrences(of: ",", with: "")
          if let number = Double(cleaned) {
              let formatter = NumberFormatter()
              formatter.numberStyle = .decimal
              formatter.maximumFractionDigits = 0 // no decimals
              return formatter.string(from: NSNumber(value: number)) ?? numberString
          }
          return numberString
      }
}
