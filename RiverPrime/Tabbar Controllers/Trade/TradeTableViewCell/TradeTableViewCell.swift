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
    
    var lineSeries: LineSeries!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        setupUI()
        setupChart()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    private func setupChart() {
        chart = LightweightCharts()
        graphView.addSubview(chart)
           
           // Layout the chart view to fill the cell's contentView
        chart.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
            chart.leadingAnchor.constraint(equalTo: chart.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: chart.trailingAnchor),
            chart.topAnchor.constraint(equalTo: chart.topAnchor),
            chart.bottomAnchor.constraint(equalTo: chart.bottomAnchor)
           ])
           
           // Create a line series
           let options = LineSeriesOptions(
            priceLineVisible: false, color: "blue",
            lineWidth: .two
           )
           lineSeries = chart.addLineSeries(options: options)
       }

       func updateChart(with data: [LineData]) {
           lineSeries.setData(data: data)
       }
   
//    func prepareLineData(ask: Double, bid: Double, timeDate: TimeInterval) -> LineData {
//        // Assuming you're plotting 'ask' as the y-value
//        let lineData = LineData(time: .utc(timestamp: timeDate), value: ask)
//        return lineData
//    }
    
//    private func setupUI() {
//        
//        let options = ChartOptions(
//            layout: LayoutOptions(background: .solid(color: "#fafafa")),
//            leftPriceScale: VisiblePriceScaleOptions(visible: false),
//            rightPriceScale: VisiblePriceScaleOptions(visible: false),
//            timeScale: TimeScaleOptions(visible: false),
//            crosshair: CrosshairOptions(
//                vertLine: CrosshairLineOptions(visible: false),
//                horzLine: CrosshairLineOptions(visible: false)
//            ),
//            grid: GridOptions(
//                verticalLines: GridLineOptions(color: "#fff"),
//                horizontalLines: GridLineOptions(color: "#fff")
//            )
//        )
//        chart = LightweightCharts(options: options)
//        graphView.addSubview(chart)
//        chart.translatesAutoresizingMaskIntoConstraints = false
//        if #available(iOS 11.0, *) {
//            NSLayoutConstraint.activate([
//                chart.leadingAnchor.constraint(equalTo: graphView.safeAreaLayoutGuide.leadingAnchor),
//                chart.trailingAnchor.constraint(equalTo: graphView.safeAreaLayoutGuide.trailingAnchor),
//                chart.topAnchor.constraint(equalTo: graphView.safeAreaLayoutGuide.topAnchor),
//                chart.bottomAnchor.constraint(equalTo: graphView.safeAreaLayoutGuide.bottomAnchor)
//            ])
//        } else {
//            NSLayoutConstraint.activate([
//                chart.leadingAnchor.constraint(equalTo: graphView.leadingAnchor),
//                chart.trailingAnchor.constraint(equalTo: graphView.trailingAnchor),
//                chart.topAnchor.constraint(equalTo: graphView.topAnchor),
//                chart.bottomAnchor.constraint(equalTo: graphView.bottomAnchor)
//            ])
//        }
//        let areaSeriesOptions = AreaSeriesOptions(
//               topColor: "rgba(76, 175, 80, 0.5)",
//               bottomColor: "rgba(76, 175, 80, 0)",
//               lineColor: "rgba(76, 175, 80, 1)",
//               lineWidth: .one
//   
//           )
//           areaSeries = chart.addAreaSeries(options: areaSeriesOptions)
//            
//    }
    
    
    func configure(with trade: TradeDetails) {
        
        lblCurrencySymbl.text = trade.symbol
        lblAmount.text = String(trade.bid).trimmedTrailingZeros()
        lblPercent.text = "+ " + String(trade.ask).trimmedTrailingZeros()
        // Update the chart with new data
        if (trade.ask) < 1 {
            lblPercent.textColor = .systemRed
            lblPercent.text = "- " + String(trade.ask)
        }else{
            lblPercent.textColor = .systemGreen
        }
        var price =  (trade.bid) //Double(trade.price) ?? 0.0
        
        let times = Time.utc(timestamp: Double(trade.datetime))
        
        // Prepare the line data
              
               
               let lineData = LineData(time: times, value: price)
               
               // Update the chart with the new data
               lineSeries.setData(data: [lineData])
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
