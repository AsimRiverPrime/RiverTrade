//
//  TradeTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 12/07/2024.
//

import UIKit
import SDWebImage
import SDWebImageSVGKitPlugin

class TradeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var currencyICon: UIImageView!
    @IBOutlet weak var lblCurrencySymbl: UILabel!
    @IBOutlet weak var lblCurrencyName: UILabel!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblPercent: UILabel!
    @IBOutlet weak var profitIcon: UIImageView!
    

    var historyChartData = [SymbolChartData]()
    
//    var areaData: [AreaData] = []
    
    private var chart: LightweightCharts!
    private var series: AreaSeries!
    
    // Track created charts for symbols
    var createdCharts = [String: Bool]()
    // Store chart data for each symbol
    var storedChartData = [String: SymbolChartData]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        NotificationCenter.default.addObserver(self, selector: #selector(chartDataUpdated(_:)), name: .symbolDataUpdated, object: nil)
    }
   
    
    @objc private func chartDataUpdated(_ notification: Notification) {
        if let response = notification.object as? SymbolChartData {
                // Store the chart data based on the symbol
            historyChartData.append(response)
                print("\n history chart Data: \(historyChartData)\n")
       
            setupChart(for: response.message.payload.symbol, with: response)
            }
    }
   
    
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
                   lineColor: "rgba(0,0,0,0)",//"rgba(76, 175, 80, 1)",
                   lineWidth: .one
               )
        
        let areaSeries = chart.addAreaSeries(options: options)
        
        updateChart(with: chartData, areaSeries: areaSeries)
    }

    func updateChart(with chartData: SymbolChartData, areaSeries: AreaSeries) {
        var areaData = [AreaData]()
        
        let chartData1 = chartData.message.payload.chartData
        for data in chartData1 {
            print("/n Datetime1: \(data.datetime), Close: \(data.close)")
            let _areaData = AreaData(time: .utc(timestamp: Double(data.datetime)), value: data.close)
            areaData.append(_areaData)
        }
        
        areaSeries.setData(data: areaData)
    }
    
    
    func configure(with trade: TradeDetails, symbolDataObj: SymbolData? = nil) {
        lblCurrencySymbl.text = trade.symbol
       
        lblAmount.text = String(trade.bid).trimmedTrailingZeros()
        lblPercent.text = "+ " + String(trade.ask).trimmedTrailingZeros()
        lblPercent.textColor = trade.ask < 1 ? .systemRed : .systemGreen
        
        if let symbol = symbolDataObj, let imageUrl = URL(string: symbol.icon_url) {
            lblCurrencyName.text = symbol.description
            
            let svgCoder = SDImageSVGKCoder.shared
            SDImageCodersManager.shared.addCoder(svgCoder)
           
//            imageView.sd_setImage(with: url)
            // this arg is optional, if don't provide, use the viewport size instead
            let svgImageSize = CGSize(width: 30, height: 30)
            currencyICon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"), options: [], context: [.imageThumbnailPixelSize : svgImageSize])
            
           // currencyICon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "arrow"), context: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension String {
    func trimmedTrailingZeros() -> String {
        if let doubleValue = Double(self) {
            return String(format: "%.4f", doubleValue)
        }
        return self
    }
}
