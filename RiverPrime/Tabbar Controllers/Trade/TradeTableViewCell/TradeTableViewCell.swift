//
//  TradeTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 12/07/2024.
//

import UIKit
import SDWebImage
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
    
    private var chart: LightweightCharts? // Chart reference to keep it persistent
    private var series: AreaSeries? // The chart's area series
    private var isChartCreated = false // Flag to ensure chart is created only once
    private var darkBackground: UIView? // To keep the background dark while chart loads
    var close = Double()
    var options = AreaSeriesOptions()
    
    var previousValue: Double?
    var previousValueAsk: Double?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.graphView.isHidden = true
        self.graphView.isUserInteractionEnabled = false
        graphView.backgroundColor = .clear
        
        // Set a dark background view behind the chart to avoid flickering
        darkBackground = UIView()
        darkBackground?.backgroundColor = UIColor.black // Dark background
        darkBackground?.frame = graphView.bounds
        darkBackground?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        graphView.addSubview(darkBackground!)
        graphView.sendSubviewToBack(darkBackground!) // Send the dark background to back
        
        // Initially hide the chart
        graphView.isHidden = true
    }
    
    func setStyledLabelAsk(value: Double, label: UILabel) {
      
        let boldColor: UIColor
        
          if let previous = previousValueAsk {
              if value < previous {
                  boldColor = .systemRed // Less than previous value
              } else if value > previous {
                  boldColor = .systemGreen // Greater than previous value
              } else {
                  boldColor = .white // Equal to previous value
              }
          } else {
              boldColor = .white // Default color for the first value
          }
          
          // Update the previousValue for future comparisons
        previousValueAsk = value
          
        
        // Convert the value to a string with up to 5 decimal places
        let valueString = String(format: "%.5f", value).trimmingCharacters(in: .whitespaces)
        
        // Split the value into integer and decimal parts
        let parts = valueString.split(separator: ".")
        
        let integerPart = String(parts[0]) + "."
        var decimalPart = String(parts[1])
      
        // Remove trailing zeros from the decimal part
        while decimalPart.last == "0" {
            decimalPart.removeLast()
        }
        
        if decimalPart.isEmpty {
            decimalPart = "0"
        }
        // Attributes for normal and bold text
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor.white
        ]
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 26),
            .foregroundColor: boldColor
        ]
        
        let attributedText = NSMutableAttributedString(string: integerPart, attributes: normalAttributes)
        
        if decimalPart.count == 0 {
            decimalPart = "0"
            attributedText.append(NSAttributedString(string: decimalPart, attributes: boldAttributes))
        }else if decimalPart.count == 1 {
            attributedText.append(NSAttributedString(string: decimalPart, attributes: boldAttributes))
        }else if decimalPart.count == 2 {
            // For 2 digits, make the entire decimal part bold
            attributedText.append(NSAttributedString(string: decimalPart, attributes: boldAttributes))
        } else if decimalPart.count == 3 {
            // For 3 digits: First 2 normal, last one normal
            let firstTwoDigits = String(decimalPart.prefix(2))
            let lastDigit = String(decimalPart.suffix(1))
            
            attributedText.append(NSAttributedString(string: firstTwoDigits, attributes: boldAttributes))
            attributedText.append(NSAttributedString(string: lastDigit, attributes: normalAttributes))
        } else if decimalPart.count == 4 {
            // For 4 digits: First 1 normal, middle 2 bold, last 1 normal
            let firstDigit = String(decimalPart.prefix(1))
            let middleDigits = String(decimalPart.dropFirst(1).prefix(2)) // Middle 2 digits
            let lastDigit = String(decimalPart.suffix(1))
            
            // Add the first digit as normal
            attributedText.append(NSAttributedString(string: firstDigit, attributes: normalAttributes))
            
            // Add the middle 2 digits as bold
            attributedText.append(NSAttributedString(string: middleDigits, attributes: boldAttributes))
            
            // Add the last digit as normal
            attributedText.append(NSAttributedString(string: lastDigit, attributes: normalAttributes))
        } else if decimalPart.count >= 5 {
            // For 5 or more digits: First 2 normal, middle bold, last normal
            let firstTwoDigits = String(decimalPart.prefix(2))
            let middleDigits = String(decimalPart.dropFirst(2).dropLast())
            let lastDigit = String(decimalPart.suffix(1))
            
            // Add the first two digits as normal
            attributedText.append(NSAttributedString(string: firstTwoDigits, attributes: normalAttributes))
            
            // Add the middle digits as bold
            if !middleDigits.isEmpty {
                attributedText.append(NSAttributedString(string: middleDigits, attributes: boldAttributes))
            }
            
            // Add the last digit as normal
            attributedText.append(NSAttributedString(string: lastDigit, attributes: normalAttributes))
        }
            // Set to label
            label.attributedText = attributedText
        
    }
    
    func setStyledLabel(value: Double, label: UILabel) {
      
        
        let boldColor: UIColor
        
          if let previous = previousValue {
              if value < previous {
                  boldColor = .systemRed // Less than previous value
              } else if value > previous {
                  boldColor = .systemGreen // Greater than previous value
              } else {
                  boldColor = .white // Equal to previous value
              }
          } else {
              boldColor = .white // Default color for the first value
          }
          
          // Update the previousValue for future comparisons
          previousValue = value
          
        
        // Convert the value to a string with up to 5 decimal places
        let valueString = String(format: "%.5f", value).trimmingCharacters(in: .whitespaces)
        
        // Split the value into integer and decimal parts
        let parts = valueString.split(separator: ".")
        
        let integerPart = String(parts[0]) + "."
        var decimalPart = String(parts[1])
      
        // Remove trailing zeros from the decimal part
        while decimalPart.last == "0" {
            decimalPart.removeLast()
        }
        
        if decimalPart.isEmpty {
            decimalPart = "0"  
        }
        // Attributes for normal and bold text
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor.white
        ]
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 26),
            .foregroundColor: boldColor
        ]
        
        let attributedText = NSMutableAttributedString(string: integerPart, attributes: normalAttributes)
        
        if decimalPart.count == 0 {
            decimalPart = "0"
            attributedText.append(NSAttributedString(string: decimalPart, attributes: boldAttributes))
        }else if decimalPart.count == 1 {
            attributedText.append(NSAttributedString(string: decimalPart, attributes: boldAttributes))
        }else if decimalPart.count == 2 {
            // For 2 digits, make the entire decimal part bold
            attributedText.append(NSAttributedString(string: decimalPart, attributes: boldAttributes))
        } else if decimalPart.count == 3 {
            // For 3 digits: First 2 normal, last one normal
            let firstTwoDigits = String(decimalPart.prefix(2))
            let lastDigit = String(decimalPart.suffix(1))
            
            attributedText.append(NSAttributedString(string: firstTwoDigits, attributes: boldAttributes))
            attributedText.append(NSAttributedString(string: lastDigit, attributes: normalAttributes))
        } else if decimalPart.count == 4 {
            // For 4 digits: First 1 normal, middle 2 bold, last 1 normal
            let firstDigit = String(decimalPart.prefix(1))
            let middleDigits = String(decimalPart.dropFirst(1).prefix(2)) // Middle 2 digits
            let lastDigit = String(decimalPart.suffix(1))
            
            // Add the first digit as normal
            attributedText.append(NSAttributedString(string: firstDigit, attributes: normalAttributes))
            
            // Add the middle 2 digits as bold
            attributedText.append(NSAttributedString(string: middleDigits, attributes: boldAttributes))
            
            // Add the last digit as normal
            attributedText.append(NSAttributedString(string: lastDigit, attributes: normalAttributes))
        } else if decimalPart.count >= 5 {
            // For 5 or more digits: First 2 normal, middle bold, last normal
            let firstTwoDigits = String(decimalPart.prefix(2))
            let middleDigits = String(decimalPart.dropFirst(2).dropLast())
            let lastDigit = String(decimalPart.suffix(1))
            
            // Add the first two digits as normal
            attributedText.append(NSAttributedString(string: firstTwoDigits, attributes: normalAttributes))
            
            // Add the middle digits as bold
            if !middleDigits.isEmpty {
                attributedText.append(NSAttributedString(string: middleDigits, attributes: boldAttributes))
            }
            
            // Add the last digit as normal
            attributedText.append(NSAttributedString(string: lastDigit, attributes: normalAttributes))
        }
            // Set to label
            label.attributedText = attributedText
        
    }
    
    func calculatePips(ask: Double, bid: Double) -> Int {
        // Determine the precision based on the number of decimal places in ask and bid
        let askDecimalPlaces = countDecimalPlaces(for: ask)
        let bidDecimalPlaces = countDecimalPlaces(for: bid)
        
        // Use the maximum precision of ask and bid
        let precision = max(askDecimalPlaces, bidDecimalPlaces)
        
        // Calculate the factor based on precision
        let factor = pow(10.0, Double(precision))
        
        // Calculate pips
        let pipsValue = (ask - bid) * factor
        return Int(round(pipsValue))
    }

    // Helper function to count decimal places in a number
    func countDecimalPlaces(for number: Double) -> Int {
        let numberString = String(format: "%.2f", number) // Max 10 decimal places
        let components = numberString.split(separator: ".")
        return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces).count : 0
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
        
        cell.configure(with: trade, symbolDataObj: symbolDataObj)
        
        return cell
    }
    
    // Function to configure the cell's UI and chart based on trade data.
    func configure(with trade: TradeDetails, symbolDataObj: SymbolData? = nil) {
        lblCurrencySymbl.text = trade.symbol
//        lblAmount.text = String(trade.bid).trimmedTrailingZeros()
        let pipsValues = calculatePips(ask: trade.ask, bid: trade.bid)
        self.lbl_pipsValues.text = "\(pipsValues)"
        
//        self.lbl_datetime.text = "\(Int64(trade.datetime))"
        let createDate = Date(timeIntervalSince1970: Double(trade.datetime))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.timeZone = .current
        
        let datee = dateFormatter.string(from: createDate)
        
        self.lbl_datetime.text = datee
        
        setStyledLabel(value: trade.bid, label: lbl_bidAmount)
        setStyledLabel(value: trade.ask, label: lbl_askAmount)
        
        if let symbol = symbolDataObj, let imageUrl = URL(string: symbol.icon_url) {
            lblCurrencyName.text = symbol.description
            
            // Setting different icons based on symbol name
            let defaultImageURL: String
            switch symbol.name {
            case "Platinum":
                defaultImageURL = "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/silver.png"
            case "NDX100":
                defaultImageURL = "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/ndx.png"
            case "DJI30":
                defaultImageURL = "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/dj30.png"
            default:
                defaultImageURL = symbol.icon_url
            }
            currencyICon.sd_setImage(with: URL(string: defaultImageURL), placeholderImage: UIImage(named: "photo.circle"))
        } else {
            print("Invalid URL for symbol: \(symbolDataObj?.description ?? "unknown symbol")")
        }
    }
    
    // Setting up the chart only once for a specific symbol
    private func setupChart(for symbol: String, with chartData: [ChartData]) {
        if !isChartCreated {  // Check if the chart hasn't been created yet
            // Create chart and apply options only once
            chart = LightweightCharts()
            chart?.backgroundColor = UIColor.clear // Set chart background color to black
            graphView.backgroundColor = UIColor.clear
            
            // Initially hide the chart while it's being setup
            chart?.isHidden = true
            graphView.addSubview(chart!)
            chart?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                chart!.leadingAnchor.constraint(equalTo: graphView.leadingAnchor),
                chart!.trailingAnchor.constraint(equalTo: graphView.trailingAnchor),
                chart!.topAnchor.constraint(equalTo: graphView.topAnchor),
                chart!.bottomAnchor.constraint(equalTo: graphView.bottomAnchor)
            ])
            
            // Chart options (e.g., hiding axis, gridlines, etc.)
            let chartOptions = ChartOptions(
                layout: LayoutOptions(background: SurfaceColor.solid(color: ChartColor.init(UIColor(red: 22/255.0, green: 25/255.0, blue: 36/255.0, alpha: 1.0)))),
                rightPriceScale: VisiblePriceScaleOptions(visible: false),
                timeScale: TimeScaleOptions(visible: false),
                grid: GridOptions(
                    verticalLines: GridLineOptions(visible: false),
                    horizontalLines: GridLineOptions(visible: false)
                )
            )
            chart?.applyOptions(options: chartOptions)

            series = chart?.addAreaSeries(options: options)
            
            isChartCreated = true // Mark chart as created to prevent re-initialization
        }
        
        // Update chart data after initialization
        updateChart(with: chartData)
    }
    
    // Function to update the chart with new data.
    func updateChart(with chartData: [ChartData]) {
        guard let areaSeries = series else { return }
        
        var areaData = [AreaData]()
        for data in chartData {
            self.close = data.close
            let area = AreaData(time: .utc(timestamp: Double(data.datetime)), value: data.close)
            areaData.append(area)
        }
        
        // Update chart data in one go
        areaSeries.setData(data: areaData)
        
//        // After updating the chart data, reveal the chart view (no flicker)
//        graphView.isHidden = false
//        chart?.isHidden = false
        
        // Start a timer to delay showing the chart by 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // After 2 seconds, reveal the chart and graph view
                    self.graphView.isHidden = false
                    self.chart?.isHidden = false
                }
    }
    
    // Use this function to configure the chart when data is available for the symbol.
    func configureChart(getSymbolData: SymbolChartData) {
        setupChart(for: getSymbolData.symbol, with: getSymbolData.chartData)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}






//class TradeTableViewCell: UITableViewCell {
//
//    @IBOutlet weak var currencyICon: UIImageView!
//    @IBOutlet weak var lblCurrencySymbl: UILabel!
//    @IBOutlet weak var lblCurrencyName: UILabel!
//    @IBOutlet weak var graphView: UIView!
//    @IBOutlet weak var lblAmount: UILabel!
//    @IBOutlet weak var lblPercent: UILabel!
//    @IBOutlet weak var profitIcon: UIImageView!
//
//
//    private var chart: LightweightCharts!
//    private var series: AreaSeries!
//    var close = Double()
//    // Track created charts for symbols
//    var createdCharts = [String: Bool]()
//    // Store chart data for each symbol
//    var storedChartData = [String: SymbolChartData]()
//
//    var getSymbolData = SymbolCompleteList()
//
//    var options = AreaSeriesOptions()
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.graphView.isUserInteractionEnabled = false
//       setupChart(for: getSymbolData.historyMessage?.symbol ?? "", with: getSymbolData.historyMessage?.chartData ?? [])
//        graphView.backgroundColor = .clear
//    }
//
//    //let cell = tableView.dequeueReusableCell(with: TradeTableViewCell.self, for: indexPath)
//    class func cellForTableView(_ tableView: UITableView,  atIndexPath indexPath: IndexPath, trades: [TradeDetails]) -> TradeTableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell", for: indexPath) as? TradeTableViewCell else {
//            return UITableViewCell() as! TradeTableViewCell
//        }
//
//        let trade = trades[indexPath.row] //vm.trade(at: indexPath)
//
//        var symbolDataObj: SymbolData?
//
//        if let obj = GlobalVariable.instance.symbolDataArray.first(where: {$0.name == trade.symbol}) {
//            symbolDataObj = obj
//            //   print("\(obj.icon_url)")
//        }
//
//        cell.configure(with: trade , symbolDataObj: symbolDataObj)
//
//        return cell
//    }
//
//
//    private func setupChart(for symbol: String, with chartData: [ChartData]) {
//        guard createdCharts[symbol] == nil else { return }
//            createdCharts[symbol] = true
//
//        chart = LightweightCharts()
//        chart.backgroundColor = UIColor(red: 22/255.0, green: 25/255.0, blue: 36/255.0, alpha: 1.0)
//        graphView.backgroundColor = UIColor(red: 22/255.0, green: 25/255.0, blue: 36/255.0, alpha: 1.0)
//
//        graphView.addSubview(chart)
//        chart.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            chart.leadingAnchor.constraint(equalTo: graphView.leadingAnchor),
//            chart.trailingAnchor.constraint(equalTo: graphView.trailingAnchor),
//            chart.topAnchor.constraint(equalTo: graphView.topAnchor),
//            chart.bottomAnchor.constraint(equalTo: graphView.bottomAnchor)
//        ])
//        // Options to hide the x-axis and y-axis
//           let chartOptions = ChartOptions(
//            layout: LayoutOptions(background: SurfaceColor.solid(color: ChartColor.init(UIColor(red: 22/255.0, green: 25/255.0, blue: 36/255.0, alpha: 1.0))) /*SurfaceColor.color(UIColor.black)*/ /*.none*/ ),
//               rightPriceScale: VisiblePriceScaleOptions(visible: false),
//               timeScale: TimeScaleOptions(visible: false),
//            grid: GridOptions(
//                verticalLines: GridLineOptions(visible: false),
//                horizontalLines: GridLineOptions(visible: false)
//            )
//           )
//           chart.applyOptions(options: chartOptions)
//
//        var options = AreaSeriesOptions()
//
//        options = self.options
//
////        //MARK: - Update options to hide the line and values -> Green
////        options = AreaSeriesOptions(
////                   priceLineVisible: false,
////                   topColor: "rgba(76, 175, 80, 0.5)",
////                   bottomColor: "rgba(76, 175, 80, 0)",
////                   lineColor: "rgba(76, 175, 80, 1)",
////                   lineWidth: .one
////               )
////
////        //MARK: - Update options to hide the line and values -> Red
////        options = AreaSeriesOptions(
////                   priceLineVisible: false,
////                   topColor: "rgba(255, 0, 0, 0.5)",
////                   bottomColor: "rgba(255, 0, 0, 0)",
////                   lineColor: "rgba(255, 0, 0, 1)",
////                   lineWidth: .one
////               )
//
////        let options2 = AreaSeriesOptions(
////            priceLineVisible: false,
////            topColor: "rgba(255, 59, 48, 0.5)",
////            bottomColor: "rgba(255, 59, 48, 0.0)",
////            lineColor: "rgba(255, 59, 48, 1.0)",
////            lineWidth: .one
////        )
//
//        let areaSeries = chart.addAreaSeries(options: options)
//
//        updateChart(with: chartData, areaSeries: areaSeries)
//    }
//
//    func updateChart(with chartData: [ChartData], areaSeries: AreaSeries) {
//        var areaData = [AreaData]()
//
//        for data in chartData {
//            print("/n Datetime1: \(data.datetime), Close: \(data.close)")
//            self.close = data.close
//            let _areaData = AreaData(time: .utc(timestamp: Double(data.datetime)), value: data.close)
//            areaData.append(_areaData)
//        }
//
//        areaSeries.setData(data: areaData)
//    }
//
//    func configure(with trade: TradeDetails, symbolDataObj: SymbolData? = nil) {
//        lblCurrencySymbl.text = trade.symbol
//
//        lblAmount.text = String(trade.bid).trimmedTrailingZeros()
//
//        if let symbol = symbolDataObj, let imageUrl = URL(string: symbol.icon_url) {
//
//            lblCurrencyName.text = symbol.description
//
//            print("\n Image Symbol: \(symbol.name) \t  Symbol: \(trade.symbol) \n Image URL: \(symbol.icon_url)")
//
//            if symbol.name == "Platinum" {
//                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/silver.png")
//                currencyICon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
//            }else if symbol.name == "NDX100" {
//                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/ndx.png")
//                currencyICon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
//            }else if symbol.name == "DJI30" {
//                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/dj30.png")
//                currencyICon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
//            }else{
//                let imageUrl = URL(string: symbol.icon_url)
//                currencyICon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
//            }
//
//        } else {
//            print("Invalid URL for symbol: \(symbolDataObj?.description ?? "unknown symbol")")
//        }
//    }
//
//    func configureChart(getSymbolData: SymbolChartData) {
//        setupChart(for: getSymbolData.symbol, with: getSymbolData.chartData)
//    }
//
////    func configureChart(getSymbolData: SymbolCompleteList) {
////
////        setupChart(for: getSymbolData.historyMessage?.symbol ?? "", with: getSymbolData.historyMessage?.chartData ?? [])
////    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//}


extension String {
    func trimmedTrailingZeros() -> String {
        if let doubleValue = Double(self) {
            return String(format: "%.2f", doubleValue)
        }
        return self
    }
}













































////
////  TradeTableViewCell.swift
////  RiverPrime
////
////  Created by Ross Rostane on 12/07/2024.
////
//
//import UIKit
//import SDWebImage
////import SDWebImageSVGKitPlugin
//
//class TradeTableViewCell: UITableViewCell {
//    
//    @IBOutlet weak var currencyICon: UIImageView!
//    @IBOutlet weak var lblCurrencySymbl: UILabel!
//    @IBOutlet weak var lblCurrencyName: UILabel!
//    @IBOutlet weak var graphView: UIView!
//    @IBOutlet weak var lblAmount: UILabel!
//    @IBOutlet weak var lblPercent: UILabel!
//    @IBOutlet weak var profitIcon: UIImageView!
//    
//
//    private var chart = LightweightCharts()
//    private var series: AreaSeries!
//    var close = Double()
//    // Track created charts for symbols
//    var createdCharts = [String: Bool]()
//    // Store chart data for each symbol
//    var storedChartData = [String: SymbolChartData]()
//    
//    var getSymbolData = SymbolCompleteList()
//    
//    var options = AreaSeriesOptions()
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.graphView.isUserInteractionEnabled = false
//        self.chart.layer.backgroundColor = .none
//        self.chart.backgroundColor = .clear
//        self.chart.layer.backgroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0)
//        graphView.backgroundColor = .clear
//        
//       setupChart(for: getSymbolData.historyMessage?.symbol ?? "", with: getSymbolData.historyMessage?.chartData ?? [])
//       
//    }
//   
//    //let cell = tableView.dequeueReusableCell(with: TradeTableViewCell.self, for: indexPath)
//    class func cellForTableView(_ tableView: UITableView,  atIndexPath indexPath: IndexPath, trades: [TradeDetails]) -> TradeTableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell", for: indexPath) as? TradeTableViewCell else {
//            return UITableViewCell() as! TradeTableViewCell
//        }
//        
//        let trade = trades[indexPath.row] //vm.trade(at: indexPath)
//        
//        var symbolDataObj: SymbolData?
//        
//        if let obj = GlobalVariable.instance.symbolDataArray.first(where: {$0.name == trade.symbol}) {
//            symbolDataObj = obj
//            //   print("\(obj.icon_url)")
//        }
//        
//        cell.configure(with: trade , symbolDataObj: symbolDataObj)
//        
//        return cell
//    }
//    
//   
//    private func setupChart(for symbol: String, with chartData: [ChartData]) {
//        guard createdCharts[symbol] == nil else { return }
//            createdCharts[symbol] = true
//
//        chart = LightweightCharts()
//        chart.backgroundColor = UIColor(red: 22/255.0, green: 25/255.0, blue: 36/255.0, alpha: 1.0)
//        graphView.backgroundColor = UIColor(red: 22/255.0, green: 25/255.0, blue: 36/255.0, alpha: 1.0)
//        
//        graphView.addSubview(chart)
//        chart.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            chart.leadingAnchor.constraint(equalTo: graphView.leadingAnchor),
//            chart.trailingAnchor.constraint(equalTo: graphView.trailingAnchor),
//            chart.topAnchor.constraint(equalTo: graphView.topAnchor),
//            chart.bottomAnchor.constraint(equalTo: graphView.bottomAnchor)
//        ])
//        // Options to hide the x-axis and y-axis
//           let chartOptions = ChartOptions(
//            layout: LayoutOptions(background: SurfaceColor.solid(color: ChartColor.init(UIColor(red: 22/255.0, green: 25/255.0, blue: 36/255.0, alpha: 1.0))) /*SurfaceColor.color(UIColor.black)*/ /*.none*/ ),
//               rightPriceScale: VisiblePriceScaleOptions(visible: false),
//               timeScale: TimeScaleOptions(visible: false),
//            grid: GridOptions(
//                verticalLines: GridLineOptions(visible: false),
//                horizontalLines: GridLineOptions(visible: false)
//            )
//           )
//           chart.applyOptions(options: chartOptions)
//
//        var options = AreaSeriesOptions()
//        
//        options = self.options
//        
//        let areaSeries = chart.addAreaSeries(options: options)
//        
//        updateChart(with: chartData, areaSeries: areaSeries)
//    }
//
//    func updateChart(with chartData: [ChartData], areaSeries: AreaSeries) {
//        var areaData = [AreaData]()
//        
//        for data in chartData {
//            print("/n Datetime1: \(data.datetime), Close: \(data.close)")
//            self.close = data.close
//            let _areaData = AreaData(time: .utc(timestamp: Double(data.datetime)), value: data.close)
//            areaData.append(_areaData)
//        }
//        
//        areaSeries.setData(data: areaData)
//    }
//    
//    func configure(with trade: TradeDetails, symbolDataObj: SymbolData? = nil) {
//        lblCurrencySymbl.text = trade.symbol
//       
//        lblAmount.text = String(trade.bid).trimmedTrailingZeros()
//       
//        if let symbol = symbolDataObj, let imageUrl = URL(string: symbol.icon_url) {
//        
//            lblCurrencyName.text = symbol.description
//            
//            print("\n Image Symbol: \(symbol.name) \t  Symbol: \(trade.symbol) \n Image URL: \(symbol.icon_url)")
//            
//            if symbol.name == "Platinum" {
//                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/silver.png")
//                currencyICon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
//            }else if symbol.name == "NDX100" {
//                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/ndx.png")
//                currencyICon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
//            }else if symbol.name == "DJI30" {
//                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/dj30.png")
//                currencyICon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
//            }else{
//                let imageUrl = URL(string: symbol.icon_url)
//                currencyICon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
//            }
//            
//        } else {
//            print("Invalid URL for symbol: \(symbolDataObj?.description ?? "unknown symbol")")
//        }
//    }
//    
//    func configureChart(getSymbolData: SymbolChartData) {
//        setupChart(for: getSymbolData.symbol, with: getSymbolData.chartData)
//    }
//    
////    func configureChart(getSymbolData: SymbolCompleteList) {
////
////        setupChart(for: getSymbolData.historyMessage?.symbol ?? "", with: getSymbolData.historyMessage?.chartData ?? [])
////    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//}
//
//
//extension String {
//    func trimmedTrailingZeros() -> String {
//        if let doubleValue = Double(self) {
//            return String(format: "%.2f", doubleValue)
//        }
//        return self
//    }
//}
