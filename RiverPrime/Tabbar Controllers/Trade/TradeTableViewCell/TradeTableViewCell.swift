//
//  TradeTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 12/07/2024.
//

import UIKit
import LightweightCharts

class TradeTableViewCell: UITableViewCell {

    @IBOutlet weak var currencyICon: UIImageView!
    @IBOutlet weak var lblCurrencySymbl: UILabel!
    @IBOutlet weak var lblCurrencyName: UILabel!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblPercent: UILabel!
    @IBOutlet weak var profitIcon: UIImageView!
    
    var chart: LightweightCharts!
    var areaSeries: AreaSeries!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    private func setupUI() {
        
        let options = ChartOptions(
            layout: LayoutOptions(background: .solid(color: "#fafafa")),
            leftPriceScale: VisiblePriceScaleOptions(visible: false),
            rightPriceScale: VisiblePriceScaleOptions(visible: false),
            timeScale: TimeScaleOptions(visible: false),
            crosshair: CrosshairOptions(
                vertLine: CrosshairLineOptions(visible: false),
                horzLine: CrosshairLineOptions(visible: false)
            ),
            grid: GridOptions(
                verticalLines: GridLineOptions(color: "#fff"),
                horizontalLines: GridLineOptions(color: "#fff")
            )
        )
        chart = LightweightCharts(options: options)
        graphView.addSubview(chart)
        chart.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                chart.leadingAnchor.constraint(equalTo: graphView.safeAreaLayoutGuide.leadingAnchor),
                chart.trailingAnchor.constraint(equalTo: graphView.safeAreaLayoutGuide.trailingAnchor),
                chart.topAnchor.constraint(equalTo: graphView.safeAreaLayoutGuide.topAnchor),
                chart.bottomAnchor.constraint(equalTo: graphView.safeAreaLayoutGuide.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                chart.leadingAnchor.constraint(equalTo: graphView.leadingAnchor),
                chart.trailingAnchor.constraint(equalTo: graphView.trailingAnchor),
                chart.topAnchor.constraint(equalTo: graphView.topAnchor),
                chart.bottomAnchor.constraint(equalTo: graphView.bottomAnchor)
            ])
        }
        let areaSeriesOptions = AreaSeriesOptions(
               topColor: "rgba(76, 175, 80, 0.5)",
               bottomColor: "rgba(76, 175, 80, 0)",
               lineColor: "rgba(76, 175, 80, 1)",
               lineWidth: .one
   
           )
           areaSeries = chart.addAreaSeries(options: areaSeriesOptions)
        
    }
    
    
    func configure(with trade: TradeDetails) {
      
        
//
//        if trade.symbol == "XRPUSDT" && trade.quantity > "1000.00" {
//            self.price_lbl.textColor = .red
//        }else if trade.symbol == "BTCUSDT" && trade.quantity > "0.03" {
//            self.price_lbl.textColor = .red
//        }else if trade.symbol == "ETHUSDT" && trade.quantity > "0.002" {
//            self.price_lbl.textColor = .red
//        }
        
        lblCurrencySymbl.text = trade.symbol
        lblAmount.text = String(trade.bid)
        lblPercent.text = "+ " + String(trade.ask) //trimmedTrailingZeros()
        // Update the chart with new data
        if (trade.ask) < 1 {
            lblPercent.textColor = .systemRed
            lblPercent.text = "- " + String(trade.ask)
        }else{
            lblPercent.textColor = .systemGreen
        }
        var price =  (trade.bid) //Double(trade.price) ?? 0.0
        
        areaSeries.setData(data: [AreaSeries.TickValue(time: .string(Date().ISO8601Format()), value: price)])
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

extension Double {
    func trimmedTrailingZeros() -> String {
        // Convert the Double to a String with a specified maximum precision
        let formattedString = String(format: "%.3f", self)
        
        // Use a NumberFormatter to automatically trim trailing zeros
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 3 // Set your maximum precision
        numberFormatter.numberStyle = .decimal
        
        // Convert the formatted string back to a Double
        if let number = Double(formattedString) {
            // Use the formatter to convert the number back to a string
            return numberFormatter.string(from: NSNumber(value: number)) ?? formattedString
        }
        
        return formattedString
    }
}
