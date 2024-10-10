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
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblPercent: UILabel!
    @IBOutlet weak var profitIcon: UIImageView!
    

//    var historyChartData = [SymbolChartData]()
  
    private var chart: LightweightCharts!
    private var series: AreaSeries!
    
    // Track created charts for symbols
    var createdCharts = [String: Bool]()
    // Store chart data for each symbol
    var storedChartData = [String: SymbolChartData]()
    
    var getSymbolData = SymbolCompleteList()
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk(onCompletion: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(chartDataUpdated(_:)), name: .symbolDataUpdated, object: nil)
        setupChart(for: getSymbolData.historyMessage?.symbol ?? "", with: getSymbolData.historyMessage?.chartData ?? [])
    }
   
    //let cell = tableView.dequeueReusableCell(with: TradeTableViewCell.self, for: indexPath)
    class func cellForTableView(_ tableView: UITableView,  atIndexPath indexPath: IndexPath, trades: [TradeDetails]) -> TradeTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell", for: indexPath) as? TradeTableViewCell else {
            return UITableViewCell() as! TradeTableViewCell
        }
        
        let trade = trades[indexPath.row] //vm.trade(at: indexPath)
        
        var symbolDataObj: SymbolData?
        
        if let obj = GlobalVariable.instance.symbolDataArray.first(where: {$0.name == trade.symbol}) {
            symbolDataObj = obj
            //   print("\(obj.icon_url)")
        }
        
        cell.configure(with: trade , symbolDataObj: symbolDataObj)
        
        return cell
    }
    
   
    private func setupChart(for symbol: String, with chartData: [ChartData]) {
        // Check if the chart has already been created for the symbol
        guard createdCharts[symbol] == nil else { return }
        
        // Mark the chart as created for the symbol
            createdCharts[symbol] = true

//            // Store the chart data for the symbol
//            storedChartData[symbol] = chartData
        
        chart = LightweightCharts()
        graphView.addSubview(chart)
        chart.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chart.leadingAnchor.constraint(equalTo: graphView.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: graphView.trailingAnchor),
            chart.topAnchor.constraint(equalTo: graphView.topAnchor),
            chart.bottomAnchor.constraint(equalTo: graphView.bottomAnchor)
        ])
        // Options to hide the x-axis and y-axis
           let chartOptions = ChartOptions(
            layout: LayoutOptions(background: .none ),
               rightPriceScale: VisiblePriceScaleOptions(visible: false),
               timeScale: TimeScaleOptions(visible: false)
           )
           chart.applyOptions(options: chartOptions)
        
        // Update options to hide the line and values
        let options = AreaSeriesOptions(
                   priceLineVisible: false,
                   topColor: "rgba(76, 175, 80, 0.5)",
                   bottomColor: "rgba(76, 175, 80, 0)",
                   lineColor: "rgba(76, 175, 80, 1)",
                   lineWidth: .one
               )
        
        let areaSeries = chart.addAreaSeries(options: options)
        
        updateChart(with: chartData, areaSeries: areaSeries)
    }

    func updateChart(with chartData: [ChartData], areaSeries: AreaSeries) {
        var areaData = [AreaData]()
        
//        let chartData = chartData.chartData
//        let chartData = chartData.message.payload.chartData
        for data in chartData {
            print("/n Datetime1: \(data.datetime), Close: \(data.close)")
            let _areaData = AreaData(time: .utc(timestamp: Double(data.datetime)), value: data.close)
            areaData.append(_areaData)
        }
        
        areaSeries.setData(data: areaData)
//        GlobalVariable.instance.isProcessingSymbol = false
    }
    
    /*
    private func setupChart(for symbol: String, with chartData: SymbolChartData) {
        // Check if the chart has already been created for the symbol
        guard createdCharts[symbol] == nil else { return }
        
        // Mark the chart as created for the symbol
            createdCharts[symbol] = true

            // Store the chart data for the symbol
            storedChartData[symbol] = chartData
        
        chart = LightweightCharts()
        graphView.addSubview(chart)
        chart.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chart.leadingAnchor.constraint(equalTo: graphView.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: graphView.trailingAnchor),
            chart.topAnchor.constraint(equalTo: graphView.topAnchor),
            chart.bottomAnchor.constraint(equalTo: graphView.bottomAnchor)
        ])
        // Options to hide the x-axis and y-axis
           let chartOptions = ChartOptions(
            layout: LayoutOptions(background: .none ),
               rightPriceScale: VisiblePriceScaleOptions(visible: false),
               timeScale: TimeScaleOptions(visible: false)
           )
           chart.applyOptions(options: chartOptions)
        
        // Update options to hide the line and values
        let options = AreaSeriesOptions(
                   priceLineVisible: false,
                   topColor: "rgba(76, 175, 80, 0.5)",
                   bottomColor: "rgba(76, 175, 80, 0)",
                   lineColor: "rgba(76, 175, 80, 1)",
                   lineWidth: .one
               )
        
        let areaSeries = chart.addAreaSeries(options: options)
        
        updateChart(with: chartData, areaSeries: areaSeries)
    }

    func updateChart(with chartData: SymbolChartData, areaSeries: AreaSeries) {
        var areaData = [AreaData]()
        
        let chartData = chartData.chartData
//        let chartData = chartData.message.payload.chartData
        for data in chartData {
            print("/n Datetime1: \(data.datetime), Close: \(data.close)")
            let _areaData = AreaData(time: .utc(timestamp: Double(data.datetime)), value: data.close)
            areaData.append(_areaData)
        }
        
        areaSeries.setData(data: areaData)
    }
    */
    
    func configure(with trade: TradeDetails, symbolDataObj: SymbolData? = nil) {
        lblCurrencySymbl.text = trade.symbol
       
        lblAmount.text = String(trade.bid).trimmedTrailingZeros()
        lblPercent.text = "+ " + String(trade.ask).trimmedTrailingZeros()
        lblPercent.textColor = trade.ask < 1 ? .systemRed : .systemGreen
        
        if let symbol = symbolDataObj, let imageUrl = URL(string: symbol.icon_url) {
            
            let trimString = removeParentheses(from: symbol.description)
            lblCurrencyName.text = trimString
            
            print("\n Image Symbol: \(symbol.name) \t  Symbol: \(trade.symbol) \n Image URL: \(symbol.icon_url)")
            if symbol.name == "Platinum" {
                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/silver.png")
                currencyICon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }else {
                let imageUrl = URL(string: symbol.icon_url)
                currencyICon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }
            
           
            
        } else {
            print("Invalid URL for symbol: \(symbolDataObj?.description ?? "unknown symbol")")
        }
    }
    
    func configureChart(getSymbolData: SymbolCompleteList) {
        
        setupChart(for: getSymbolData.historyMessage?.symbol ?? "", with: getSymbolData.historyMessage?.chartData ?? [])
        
    }
    
    func removeParentheses(from input: String) -> String {
            let pattern = "\\s*\\([^)]*\\)"  // Regular expression pattern to match parentheses and content
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: input.utf16.count)
            
            // Replacing the matched part (parentheses and content inside) with an empty string
            let trimmedString = regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: "")
            
            return trimmedString.trimmingCharacters(in: .whitespacesAndNewlines)
        }

    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension String {
    func trimmedTrailingZeros() -> String {
        if let doubleValue = Double(self) {
            return String(format: "%.3f", doubleValue)
        }
        return self
    }
}
