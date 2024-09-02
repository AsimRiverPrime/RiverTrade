//
//  TradeTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 12/07/2024.
//

import UIKit
import LightweightCharts
import DGCharts

class TradeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var currencyICon: UIImageView!
    @IBOutlet weak var lblCurrencySymbl: UILabel!
    @IBOutlet weak var lblCurrencyName: UILabel!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblPercent: UILabel!
    @IBOutlet weak var profitIcon: UIImageView!
    
    private var areaSeries: AreaSeries!
    
    let viewmodel = TradesViewModel()
    var isChartLoaded: Bool = false
    var chart: LightweightCharts!
    var lineSeries: LineSeries!
    
    var lineSeriesData: [LineData] = []
    var areaSeriesData: [AreaData] = []
    
    var dataEntries: [ChartDataEntry] = []
    var lineChartView = LineChartView()
    
//    var historyChartData = [[SymbolChartData]]()
//    var historyChartData = [SymbolChartData]()
    var historyChartData = [String: SymbolChartData]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
                setupChart()
//        setupData()
        NotificationCenter.default.addObserver(self, selector: #selector(chartDataUpdated(_:)), name: .symbolDataUpdated, object: nil)
    }
    
    @objc private func chartDataUpdated(_ notification: Notification) {
        if let response = notification.object as? SymbolChartData {
                // Store the chart data based on the symbol
            saveChartData(for: response)
//            historyChartData.append(response)
//                print("\n history chart Data: \(historyChartData)\n")
                // Find the index of the cell that matches the symbol
//                if let index = trades.firstIndex(where: { $0.symbol == response.symbol }) {
//                    // Reload the specific table view cell
//                    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//                }
         //   updateChart(with: response)
            }
    }
    func saveChartData(for newSymbolChartData: SymbolChartData) {
      
        let symbol = newSymbolChartData.symbol
            
            // Check if data for the symbol already exists in historyChartData
            if historyChartData[symbol] == nil {
                // If the symbol does not exist, save the new data
                historyChartData[symbol] = newSymbolChartData
                print("Data for symbol \(symbol) not already exists. saving.")
            } else {
                // If the symbol exists, do nothing (skip saving the new data)
                print("Data for symbol \(symbol) already exists. Skipping save.")
            }
     }
  
    
//    private func setupData() {
//        chart = LightweightCharts()
//        graphView.addSubview(chart)
//        chart.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            chart.leadingAnchor.constraint(equalTo: graphView.leadingAnchor),
//            chart.trailingAnchor.constraint(equalTo: graphView.trailingAnchor),
//            chart.topAnchor.constraint(equalTo: graphView.topAnchor),
//            chart.bottomAnchor.constraint(equalTo: graphView.bottomAnchor)
//        ])
//        
//        
//        
//        let areaSeriesOptions = AreaSeriesOptions(
//            topColor: "rgba(76, 175, 80, 0.5)",
//            bottomColor: "rgba(76, 175, 80, 0)",
//            lineColor: "rgba(76, 175, 80, 1)",
//            lineWidth: .one
//        )
//        let areaSeries = chart.addAreaSeries(options: areaSeriesOptions)
//        
//        let areaData: [AreaData] = [
//            AreaData(time: .string("2018-10-19"), value: 219.31),
//            AreaData(time: .string("2018-10-22"), value: 220.65),
//            AreaData(time: .string("2018-10-23"), value: 222.73),
//            AreaData(time: .string("2018-10-24"), value: 215.09),
//            AreaData(time: .string("2018-10-25"), value: 219.80),
//            AreaData(time: .string("2018-10-26"), value: 216.30),
//            AreaData(time: .string("2018-10-29"), value: 212.24),
//            AreaData(time: .string("2018-10-30"), value: 213.30),
//            AreaData(time: .string("2018-10-31"), value: 218.86),
//            AreaData(time: .string("2018-11-01"), value: 222.22),
//            AreaData(time: .string("2018-11-02"), value: 207.48),
//            AreaData(time: .string("2018-11-05"), value: 201.59),
//            AreaData(time: .string("2018-11-06"), value: 203.77),
//            AreaData(time: .string("2018-11-07"), value: 209.95),
//            AreaData(time: .string("2018-11-08"), value: 208.49),
//            AreaData(time: .string("2018-11-09"), value: 204.47),
//            AreaData(time: .string("2018-11-12"), value: 194.17),
//            AreaData(time: .string("2018-11-13"), value: 192.23),
//            AreaData(time: .string("2018-11-14"), value: 186.80),
//            AreaData(time: .string("2018-11-15"), value: 191.41),
//            AreaData(time: .string("2018-11-16"), value: 193.53),
//            AreaData(time: .string("2018-11-19"), value: 185.86),
//            AreaData(time: .string("2018-11-20"), value: 176.98),
//            AreaData(time: .string("2018-11-21"), value: 176.78),
//            AreaData(time: .string("2018-11-23"), value: 172.29),
//            AreaData(time: .string("2018-11-26"), value: 174.62),
//            AreaData(time: .string("2018-11-27"), value: 174.24),
//            AreaData(time: .string("2018-11-28"), value: 180.94),
//            AreaData(time: .string("2018-11-29"), value: 179.55),
//            AreaData(time: .string("2018-11-30"), value: 178.58),
//            AreaData(time: .string("2018-12-03"), value: 184.82),
//            AreaData(time: .string("2018-12-04"), value: 176.69),
//            AreaData(time: .string("2018-12-06"), value: 174.72),
//            AreaData(time: .string("2018-12-07"), value: 168.49),
//            AreaData(time: .string("2018-12-10"), value: 169.60),
//            AreaData(time: .string("2018-12-11"), value: 168.63),
//            AreaData(time: .string("2018-12-12"), value: 169.10),
//            AreaData(time: .string("2018-12-13"), value: 170.95),
//            AreaData(time: .string("2018-12-14"), value: 165.48),
//            AreaData(time: .string("2018-12-17"), value: 163.94),
//            AreaData(time: .string("2018-12-18"), value: 166.07),
//            AreaData(time: .string("2018-12-19"), value: 160.89),
//            AreaData(time: .string("2018-12-20"), value: 156.83),
//            AreaData(time: .string("2018-12-21"), value: 150.73),
//            AreaData(time: .string("2018-12-24"), value: 146.83),
//            AreaData(time: .string("2018-12-26"), value: 157.17),
//            AreaData(time: .string("2018-12-27"), value: 156.15),
//            AreaData(time: .string("2018-12-28"), value: 156.23),
//            AreaData(time: .string("2018-12-31"), value: 157.74),
//            AreaData(time: .string("2019-01-02"), value: 157.92),
//            AreaData(time: .string("2019-01-03"), value: 142.19),
//            AreaData(time: .string("2019-01-04"), value: 148.26),
//            AreaData(time: .string("2019-01-07"), value: 147.93),
//            AreaData(time: .string("2019-01-08"), value: 150.75),
//            AreaData(time: .string("2019-01-09"), value: 153.31),
//            AreaData(time: .string("2019-01-10"), value: 153.80),
//            AreaData(time: .string("2019-01-11"), value: 152.29),
//            AreaData(time: .string("2019-01-14"), value: 150.00),
//            AreaData(time: .string("2019-01-15"), value: 153.07),
//            AreaData(time: .string("2019-01-16"), value: 154.94),
//            AreaData(time: .string("2019-01-17"), value: 155.86)
//        ]
//        
////        areaSeries.setData(data: areaData)
//        
//        self.areaSeries = areaSeries
//        
//    }
    
    private func setupChart() {
          
           graphView.addSubview(lineChartView)
           lineChartView.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               lineChartView.leadingAnchor.constraint(equalTo: graphView.leadingAnchor),
               lineChartView.trailingAnchor.constraint(equalTo: graphView.trailingAnchor),
               lineChartView.topAnchor.constraint(equalTo: graphView.topAnchor),
               lineChartView.bottomAnchor.constraint(equalTo: graphView.bottomAnchor)
           ])
           
           
           
           let areaData = [
               (date: "2018-10-19", value: 219.31), (date: "2018-10-22", value: 220.65), (date: "2018-10-23", value: 222.73), (date: "2018-10-24", value: 215.09), (date: "2018-10-25", value: 219.80),
               (date: "2018-10-26", value: 216.30), (date: "2018-10-29", value: 212.24), (date: "2018-10-30", value: 213.30), (date: "2018-10-31", value: 218.86), (date: "2018-11-01", value: 222.22),
               (date: "2018-11-02", value: 207.48), (date: "2018-11-05", value: 201.59), (date: "2018-11-06", value: 203.77), (date: "2018-11-07", value: 209.95), (date: "2018-11-08", value: 208.49),
               (date: "2018-11-09", value: 204.47), (date: "2018-11-12", value: 194.17), (date: "2018-11-13", value: 192.23), (date: "2018-11-14", value: 186.80), (date: "2018-11-15", value: 191.41),
               (date: "2018-11-16", value: 193.53), (date: "2018-11-19", value: 185.86), (date: "2018-11-20", value: 176.98), (date: "2018-11-21", value: 176.78), (date: "2018-11-23", value: 172.29),
               (date: "2018-11-26", value: 174.62), (date: "2018-11-27", value: 174.24), (date: "2018-11-28", value: 180.94), (date: "2018-11-29", value: 179.55), (date: "2018-11-30", value: 178.58),
               (date: "2018-12-03", value: 184.82), (date: "2018-12-04", value: 176.69), (date: "2018-12-06", value: 174.72), (date: "2018-12-07", value: 168.49), (date: "2018-12-10", value: 169.60),
               (date: "2018-12-11", value: 168.63), (date: "2018-12-12", value: 169.10), (date: "2018-12-13", value: 170.95), (date: "2018-12-14", value: 165.48), (date: "2018-12-17", value: 163.94),
               (date: "2018-12-18", value: 166.07), (date: "2018-12-19", value: 160.89), (date: "2018-12-20", value: 156.83), (date: "2018-12-21", value: 150.73), (date: "2018-12-24", value: 146.83),
               (date: "2018-12-26", value: 157.17), (date: "2018-12-27", value: 156.15), (date: "2018-12-28", value: 156.23), (date: "2018-12-31", value: 157.74), (date: "2019-01-02", value: 157.92),
               (date: "2019-01-03", value: 142.19), (date: "2019-01-04", value: 148.26), (date: "2019-01-07", value: 147.93), (date: "2019-01-08", value: 150.75), (date: "2019-01-09", value: 153.31),
               (date: "2019-01-10", value: 153.80), (date: "2019-01-11", value: 152.29), (date: "2019-01-14", value: 150.00), (date: "2019-01-15", value: 153.07), (date: "2019-01-16", value: 154.94)
           ]
           
           for (index, dataPoint) in areaData.enumerated() {
               let entry = ChartDataEntry(x: Double(index), y: dataPoint.value)
               dataEntries.append(entry)
           }
           
           let dataSet = LineChartDataSet(entries: dataEntries, label: "Area Data")
           dataSet.colors = [NSUIColor.systemGreen]
           dataSet.fillColor = NSUIColor.systemGreen
           dataSet.drawFilledEnabled = true
           dataSet.fillAlpha = 0.5
           dataSet.lineWidth = 1.0
            dataSet.drawCirclesEnabled = false
            dataSet.mode = .cubicBezier

           // Disable drawing values (toggles) on data points
           dataSet.drawValuesEnabled = false
           
           let lineChartData = LineChartData(dataSet: dataSet)
           lineChartView.data = lineChartData
           
        // Customization to remove background grid lines and axis values
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawLabelsEnabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.legend.enabled = false
        lineChartView.drawBordersEnabled = false

                // Disable user interaction
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.dragEnabled = false
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.highlightPerTapEnabled = false
       }
   

//    private func setupChart1() {
//        chart = LightweightCharts()
//        graphView.addSubview(chart)
//        chart.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            chart.leadingAnchor.constraint(equalTo: graphView.leadingAnchor),
//            chart.trailingAnchor.constraint(equalTo: graphView.trailingAnchor),
//            chart.topAnchor.constraint(equalTo: graphView.topAnchor),
//            chart.bottomAnchor.constraint(equalTo: graphView.bottomAnchor)
//        ])
//        
//        let options = LineSeriesOptions(
//            priceLineVisible: false, color: "systemGreen",
//            lineWidth: .two
//        )
//        lineSeries = chart.addLineSeries(options: options)
//        
//    }
    
    func updateChart(with chartData: SymbolChartData) {
       
//        let chartData1 = chartData.chartData
//        for data in chartData1 {
//            print("/n Datetime: \(data.datetime), Close: \(data.close)")
//            let lineData = LineData(time: .utc(timestamp: Double(data.datetime)), value: data.close)
//            lineSeriesData.append(lineData)
//        }
      
       
        for (index, dataPoint) in chartData.chartData.enumerated() {
            let entry = ChartDataEntry(x: Double(index), y: dataPoint.close)
            dataEntries.append(entry)
        }
        
        let dataSet = LineChartDataSet(entries: dataEntries, label: "Area Data")
        dataSet.colors = [NSUIColor.systemGreen]
        dataSet.fillColor = NSUIColor.systemGreen
        dataSet.drawFilledEnabled = true
        dataSet.fillAlpha = 0.5
        dataSet.lineWidth = 1.0
         dataSet.drawCirclesEnabled = false
         dataSet.mode = .cubicBezier

        // Disable drawing values (toggles) on data points
        dataSet.drawValuesEnabled = false
        
        
        let lineChartData = LineChartData(dataSet: dataSet)
        self.lineChartView.data = lineChartData
        // Customization to remove background grid lines and axis values
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawLabelsEnabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.legend.enabled = false
        lineChartView.drawBordersEnabled = false

                // Disable user interaction
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.dragEnabled = false
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.highlightPerTapEnabled = false
//        lineSeries.setData(data: lineSeriesData)
        
    }
    
    func configure(with trade: TradeDetails) {
        lblCurrencySymbl.text = trade.symbol
        lblAmount.text = String(trade.bid).trimmedTrailingZeros()
        lblPercent.text = "+ " + String(trade.ask).trimmedTrailingZeros()
        lblPercent.textColor = trade.ask < 1 ? .systemRed : .systemGreen
        
        
        
        if !isChartLoaded {
            
            //            WebSocketManager.shared.sendSubscriptionHistoryMessage(for: trade.symbol)
            //  setupChart()
            isChartLoaded = true
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
