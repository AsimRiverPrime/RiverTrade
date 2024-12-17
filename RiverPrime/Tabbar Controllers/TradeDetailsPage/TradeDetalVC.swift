//
//  TradeDetalVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 18/07/2024.
//

import UIKit
import Starscream
import TPKeyboardAvoiding

class TradeDetalVC: UIViewController {
    
    @IBOutlet weak var symbolImage: UIImageView!
    @IBOutlet weak var symbolName: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblPercent: UILabel!
    
    @IBOutlet weak var view_timeFrame: UIView!
    @IBOutlet weak var view_chartType: UIView!
    
    var icon_url = String()
    
    @IBOutlet weak var chartView: UIView!
    
    //    var webSocket : WebSocket!
    
    @IBOutlet weak var view_liveValue: UIView!
    private var chart: LightweightCharts?
    private var series: CandlestickSeries!
    private var candlestickData: [CandlestickData] = []
    
    var barSeries: BarSeries!
    var areaSeries: AreaSeries!
    
    @IBOutlet weak var lbl_sellBtn: UILabel!
    //    @IBOutlet weak var lbl_login_id: UILabel!
    @IBOutlet weak var lbl_BuyBtn: UILabel!
    @IBOutlet weak var lbl_LiveAmount: UILabel!
    @IBOutlet weak var lbl_percentage: UILabel!
    @IBOutlet weak var lbl_SymbolLive: UILabel!
    @IBOutlet weak var image_percent: UIImageView!
    
    @IBOutlet var menuButton: [UIButton]!
    @IBOutlet weak var SellBuyView: UIView!
    @IBOutlet weak var btn_chartShowHide: UIButton!
    @IBOutlet weak var btn_timeInterval: UIButton!
    //    var tradeDetails: TradeDetails?
    @IBOutlet weak var btn_ChartType: UIButton!
    
    @IBOutlet var btn_time: [UIButton]!
    
    
    var getSymbolData = SymbolCompleteList()
    var getLiveCandelStick = OhlcCalculator()
    
    //    var symbolChartData: SymbolChartData?
    
    var tradeDetail: TradeDetails?
    var symbolDescription = String()
    var overviewList = [(String, String)]()
    
    var chartType: ChartType = .candlestick
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        connectHistoryWebSocket()
//        self.chartView.backgroundColor = .clear

        self.chartView.isHidden = true
        self.chart?.isHidden = true
        
        self.view_chartType.isHidden = true
        
        setDefaultStyles()
        
        symbolName.text = getSymbolData.tickMessage?.symbol //tradeDetail?.symbol
        //        symbolImage.image = UIImage(named: getSymbolData.tickMessage?.url ?? "")
//        lblAmount.text = "\(getSymbolData.tickMessage?.bid ?? 0.0) \(getSymbolData.tickMessage?.symbol ?? "")"
        lblPercent.text = "$\(getSymbolData.tickMessage?.bid ?? 0.0)"
        
        if let obj = GlobalVariable.instance.symbolDataArray.first(where: {$0.name == symbolName.text}) {
            lbl_SymbolLive.text = obj.description
        }
        
        if let imageUrl = URL(string: icon_url) {
            
            //            print("\n Symbol: \(getSymbolData.tickMessage?.symbol) \n Image URL: \(icon_url)")
            
            if getSymbolData.tickMessage?.symbol == "Platinum" {
                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/silver.png")
                symbolImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }else if getSymbolData.tickMessage?.symbol == "NDX100" {
                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/ndx.png")
                symbolImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }else if getSymbolData.tickMessage?.symbol == "DJI30" {
                let imageUrl = URL(string: "https://icons-mt5symbols.s3.us-east-2.amazonaws.com/png/dj30.png")
                symbolImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }else{
                let imageUrl = URL(string: icon_url)
                symbolImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "photo.circle"))
            }
            
        } else {
            //            print("Invalid URL for symbol: \(symbolDataObj?.description ?? "unknown symbol")")
        }
        
        
        
        setupSeries(candlestickData: [])
        
        switch chartType {
        case .candlestick:
            
            let historychart = getSymbolData.historyMessage?.chartData ?? []
            for payload in historychart {
                
                let times = Time.utc(timestamp: Double(payload.datetime))
                // Debugging output to check timestamps
                
                print("\n Candlestick each array object data: \(payload)")
                
                let open = payload.open
                let close = payload.close
                let high = payload.high
                let low = payload.low
                
                let dataPoint = CandlestickData(
                    time: times,
                    open: open,
                    high: high,
                    low: low,
                    close: close
                )
                
                // Use update to add this candlestick incrementally
                series?.update(bar: dataPoint)
                candlestickData.append(dataPoint)
            }
            series.setData(data: candlestickData)
            // setupSeries(candlestickData: candlestickData)
            
            // Start a timer to delay showing the chart by 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // After 2 seconds, reveal the chart and graph view
                self.chartView.isHidden = false
                self.chart?.isHidden = false
            }
            
            break
        case .area:
            break
        case .bar:
            break
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTradesUpdated(_:)), name: .tradesUpdated, object: nil)
        
        addTopAndBottomBorders(menuButton[0])
        
        //        btn_chartShowHide.buttonStyle()
        //        btn_timeInterval.buttonStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //        disconnectWebSocket()
    }
   
    
    @IBAction func menuButton(_ sender: UIButton) {
        addTopAndBottomBorders(menuButton[sender.tag])
        self.chartView.isHidden = true
        self.chart?.isHidden = true
        
        if sender.tag == 0 { //For Chart
            //MARK: - Remove previous button content here.
            // Remove all subviews
            self.chartView.subviews.forEach { $0.removeFromSuperview() }
            self.SellBuyView.isHidden = false
            //            self.btn_chartType.isHidden = false
            //            self.btn_timeInterval.isHidden = false
            self.view_chartType.isHidden = false
            self.view_timeFrame.isHidden = false
            self.view_liveValue.isHidden = false
            //MARK: - Add new content from here.
            
            setupChart()
            
        } else { //tag = 1 -> For Overview
            
            //MARK: - Remove previous button content here.
            // Remove all subviews
            self.chartView.subviews.forEach { $0.removeFromSuperview() }
            self.SellBuyView.isHidden = true
            //            self.btn_chartType.isHidden = true
            //            self.btn_timeInterval.isHidden = true
            self.view_chartType.isHidden = true
            self.view_timeFrame.isHidden = true
            self.view_liveValue.isHidden = true
            //MARK: - Add new content from here.
            setupOverview()
            
        }
        
    }
    
    func addTopAndBottomBorders(_ sender: UIButton) {
        
        for i in 0...2 {
            menuButton[i].backgroundColor = UIColor.clear
            menuButton[i].tintColor = UIColor(red: 161/255.0, green: 165/255.0, blue: 183/255.0, alpha: 1.0)
        }
        menuButton[sender.tag].backgroundColor = UIColor.clear
        menuButton[sender.tag].layer.cornerRadius = 10.0
        menuButton[sender.tag].tintColor = UIColor(red: 255/255.0, green: 202/255.0, blue: 35/255.0, alpha: 1.0) // UIColor.black
       
    }
    
    @objc private func handleTradesUpdated(_ notification: Notification) {
        
        if let tradeDetail = notification.object as? TradeDetails {
            
            if tradeDetail.symbol == getSymbolData.tickMessage?.symbol {
                
                self.tradeDetail = tradeDetail
                
                self.lbl_BuyBtn.text = "\(String(tradeDetail.bid))"
                self.lbl_sellBtn.text = "\(String(tradeDetail.ask))"
                
                self.lbl_LiveAmount.text = "$\(String(tradeDetail.bid))"
                
                let bid = tradeDetail.bid
                var oldBid =  Double()
                
                
                let yesterdayClose_value = GlobalVariable.instance.symbolDataArray.filter { $0.name == getSymbolData.tickMessage?.symbol }.map { $0.yesterday_close }
                print("symbolyesterday_close = \(yesterdayClose_value)")
                oldBid = Double(yesterdayClose_value[0]) ?? 0.0
                
                
                let diff = bid - oldBid
                let percentageChange = (diff / oldBid) * 100
                let newValue = (percentageChange * 100.0).rounded() / 100.0
                let percent = String(newValue)
                print("\n new value is: \(newValue)")
                
               
                lbl_percentage.text = "\(newValue)%"
                
                if percent.contains("inf") {
                    lbl_percentage.text = "0.0%"
                }
                
                if newValue > 0.0 {
                    image_percent.image = UIImage(systemName: "arrow.up")
                    image_percent.tintColor = .systemGreen
                    lbl_percentage.textColor = .systemGreen
                    
                } else {
                    image_percent.image = UIImage(systemName: "arrow.down")
                    image_percent.tintColor = .systemRed
                    lbl_percentage.textColor = .systemRed
                }
                
                getLiveCandelStick.update(ask: tradeDetail.ask, bid: tradeDetail.bid, currentTimestamp: Int64(tradeDetail.datetime))
                
                let data =  getLiveCandelStick.getLatestOhlcData()
                //                print("latest data: \(data)")
                
                let times = Time.utc(timestamp: Double(Int64(data!.intervalStart)))
                
                let open = data?.open
                let close = data?.close
                let high = data?.high
                let low = data?.low
                
                let dataPoint = CandlestickData(
                    time: times,
                    open: open,
                    high: high,
                    low: low,
                    close: close
                )
                
                switch self.chartType {
                case .candlestick:
                    
                    series?.update(bar: dataPoint)
                    
                    break
                case .area:
                    
                    let areaData = convertToAreaData(candlestickData: dataPoint)
                    self.areaSeries.update(bar: areaData)
                    
                    break
                case .bar:
                    
                    let barData = convertToBarData(candlestickData: dataPoint)
                    
                    self.barSeries.update(bar: barData)
                    
                    break
                }
            }
            
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func time_buttonTapped(_ sender: UIButton) {
        // Reset all buttons to default styles
        setDefaultStyles()
        
        // Apply selected style to the clicked button
        sender.tintColor = UIColor(red: 255/255.0, green: 202/255.0, blue: 35/255.0, alpha: 1.0) // Change tint color
        sender.titleLabel?.font = UIFont.systemFont(ofSize: 14) // Make font bold
    }
    // Helper function to set default styles for all buttons
    private func setDefaultStyles() {
        for button in btn_time {
            button.tintColor = UIColor(red: 161/255.0, green: 165/255.0, blue: 183/255.0, alpha: 1.0) // Default tint color
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12) // Default font
        }
    }
    
    @IBAction func toggleBtnChartViewTapped(_ sender: UIButton) {
        // Toggle the visibility of the view
        view_chartType.isHidden.toggle()
        
        if  view_chartType.isHidden == false {
            btn_chartShowHide.backgroundColor = UIColor.clear //UIColor(red: 255/255.0, green: 202/255.0, blue: 35/255.0, alpha: 1.0)
            btn_chartShowHide.setImage(UIImage(named: "doubleArrowUp")?.tint(with: UIColor(red: 255/255.0, green: 202/255.0, blue: 35/255.0, alpha: 1.0)),  for: .normal)
//            btn_chartShowHide.tintColor = UIColor(red: 255/255.0, green: 202/255.0, blue: 35/255.0, alpha: 1.0)
            btn_chartShowHide.layer.cornerRadius = 10.0
            
            
        }else{
            btn_chartShowHide.backgroundColor = UIColor.clear
            
            btn_chartShowHide.setImage(UIImage(named: "doubleArrowDown")?.tint(with: UIColor(red: 161/255.0, green: 165/255.0, blue: 183/255.0, alpha: 1.0)),  for: .normal)
//            btn_chartShowHide.tintColor = UIColor(red: 161/255.0, green: 165/255.0, blue: 183/255.0, alpha: 1.0)
        }
        
    }
    
    @IBAction func chartTypeBtn_action(_ sender: Any) {
        let vc = Utilities.shared.getViewController(identifier: .chartTypeVC, storyboardType: .bottomSheetPopups) as! ChartTypeVC
        vc.delegate = self
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .small, VC: vc)
    }
    
    @IBAction func timeFrameBtn_action(_ sender: Any) {
        let vc = Utilities.shared.getViewController(identifier: .timeFrameVC, storyboardType: .bottomSheetPopups) as! TimeFrameVC
        vc.delegate = self
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customMedium, VC: vc)
    }
    
    @IBAction func buyBtn_action(_ sender: Any) {
        let vc = Utilities.shared.getViewController(identifier: .ticketVC, storyboardType: .bottomSheetPopups) as! TicketVC
        vc.titleString = "BUY"
        vc.getSymbolDetail = getSymbolData
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customLarge, VC: vc)
    }
    @IBAction func sellBtn_action(_ sender: Any) {
        let vc = Utilities.shared.getViewController(identifier: .ticketVC, storyboardType: .bottomSheetPopups) as! TicketVC
        vc.titleString = "SELL"
        vc.getSymbolDetail = getSymbolData
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customLarge, VC: vc)
    }
    
    private func setupSeries(candlestickData: [CandlestickData]) {
        
        let options = ChartOptions(
            crosshair: CrosshairOptions(mode: .normal)
        )
        
        let chart = LightweightCharts(options: options)
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.backgroundColor = .clear
        chartView.addSubview(chart)
        self.chart = chart
        //        self.chart.alpha = 0
        let timeScale = chart.timeScale()
        
        timeScale.applyOptions(options: TimeScaleOptions(
            borderColor: "#000000",
            timeVisible: true,
            secondsVisible: false
        ))
        
        timeScale.subscribeVisibleTimeRangeChange()
        
        chart.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                chart.leadingAnchor.constraint(equalTo: chartView.safeAreaLayoutGuide.leadingAnchor),
                chart.trailingAnchor.constraint(equalTo: chartView.safeAreaLayoutGuide.trailingAnchor),
                chart.topAnchor.constraint(equalTo: chartView.safeAreaLayoutGuide.topAnchor),
                chart.bottomAnchor.constraint(equalTo: chartView.safeAreaLayoutGuide.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                chart.leadingAnchor.constraint(equalTo: chartView.leadingAnchor),
                chart.trailingAnchor.constraint(equalTo: chartView.trailingAnchor),
                chart.topAnchor.constraint(equalTo: chartView.topAnchor),
                chart.bottomAnchor.constraint(equalTo: chartView.bottomAnchor)
            ])
        }
        
        var optionss = ChartOptions()
        optionss.layout = LayoutOptions(
            background: .solid(color: ChartColor.init(UIColor(red: 19/255.0, green: 20/255.0, blue: 27/255.0, alpha: 1.0)) ),
            textColor: ChartColor.init(UIColor.white) //"rgba(255, 255, 255, 1)" // Optional: Set text color
        )
        optionss.grid = GridOptions(
            verticalLines: GridLineOptions(color: ChartColor.init(UIColor.clear)),
            horizontalLines: GridLineOptions(color: ChartColor.init(UIColor.clear))
        )
        chart.applyOptions(options: optionss)
        
        
        let myoptions = CandlestickSeriesOptions(
            upColor: "rgba(68, 173, 116, 1)",
            downColor: "rgba(234, 85, 86, 1)",
            borderUpColor: "rgba(68, 173, 116, 1)",
            borderDownColor: "rgba(234, 85, 86, 1)",
            wickUpColor: "rgba(68, 173, 116, 1)",
            wickDownColor: "rgba(234, 85, 86, 1)"
        )
        
        let series = chart.addCandlestickSeries(options: myoptions)
        self.series = series
        
        series.setData(data: candlestickData)
        
        // Scroll to the last candle to ensure it's visible
        timeScale.scrollToPosition(position: 0.0, animated: false)
        
        // Start a timer to delay showing the chart by 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // After 2 seconds, reveal the chart and graph view
            self.chartView.isHidden = false
            self.chart?.isHidden = false
        }
        
    }
    
}

extension TradeDetalVC: TimeFrameVCDelegate {
    func didSelectTimeFrame(value: String) {
        
        //        btn_timeInterval.setTitle(value, for: .normal)
    }
}


//MARK: - Setup the Chart view.
extension TradeDetalVC {
    
    private func setupChart() {
        
        self.lbl_BuyBtn.text = "\(String(tradeDetail?.bid ?? 0.0))"
        self.lbl_sellBtn.text = "\(String(tradeDetail?.ask ?? 0.0))"
        
        getLiveCandelStick.update(ask: tradeDetail?.ask ?? 0.0, bid: tradeDetail?.bid ?? 0.0, currentTimestamp: Int64(tradeDetail?.datetime ?? 0))
        let data =  getLiveCandelStick.getLatestOhlcData()
        
        let times = Time.utc(timestamp: Double(Int64(data!.intervalStart)))
        
        let open = data?.open
        let close = data?.close
        let high = data?.high
        let low = data?.low
        
        let dataPoint = CandlestickData(
            time: times,
            open: open,
            high: high,
            low: low,
            close: close
        )
        
        switch self.chartType {
        case .candlestick:
            setupSeries(candlestickData: candlestickData)
            series?.update(bar: dataPoint)
            
            break
        case .area:
            let areaData1 = convertToAreaData(candlestickData: candlestickData)
            setupAreaSeries(areaData: areaData1)
            let areaData = convertToAreaData(candlestickData: dataPoint)
            self.areaSeries.update(bar: areaData)
            
            break
        case .bar:
            let barData1 = convertToBarData(candlestickData: candlestickData)
            setupBarSeries(barData: barData1)
            let barData = convertToBarData(candlestickData: dataPoint)
            
            self.barSeries.update(bar: barData)
            
            break
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // After 2 seconds, reveal the chart and graph view
            self.chartView.isHidden = false
            self.chart?.isHidden = false
        }
        
    }
    
    private func setupAreaSeries(areaData: [AreaData]) {
        let options = ChartOptions(crosshair: CrosshairOptions(mode: .normal))
        let chart = LightweightCharts(options: options)
        chartView.addSubview(chart)
        self.chart = chart
        
        let timeScale = chart.timeScale()
        
        timeScale.applyOptions(options: TimeScaleOptions(
            borderColor: "#000000",
            timeVisible: true,
            secondsVisible: false
        ))
        
        timeScale.subscribeVisibleTimeRangeChange()
        
        var optionss = ChartOptions()
        optionss.layout = LayoutOptions(
            background: .solid(color: ChartColor.init(UIColor(red: 19/255.0, green: 20/255.0, blue: 27/255.0, alpha: 1.0)) ),
            textColor: ChartColor.init(UIColor.white) //"rgba(255, 255, 255, 1)" // Optional: Set text color
        )
        optionss.grid = GridOptions(
            verticalLines: GridLineOptions(color: ChartColor.init(UIColor.clear)),
            horizontalLines: GridLineOptions(color: ChartColor.init(UIColor.clear))
        )
        chart.applyOptions(options: optionss)
        
        let areaSeriesOptions = AreaSeriesOptions(
            priceLineVisible: false,
            topColor: "rgba(68, 173, 116, 0.7)",
            bottomColor: "rgba(68, 173, 116, 0.2)",
            lineColor: "rgba(68, 173, 116, 1)",
            lineWidth: .one
        )
        
        let areaSeries = chart.addAreaSeries(options: areaSeriesOptions)
        self.areaSeries = areaSeries
        areaSeries.setData(data: areaData)
        
        timeScale.scrollToPosition(position: 0.0, animated: false)
        
        setupChartConstraints(chart)
    }
    
    private func setupBarSeries(barData: [BarData]) {
        let options = ChartOptions(crosshair: CrosshairOptions(mode: .normal))
        let chart = LightweightCharts(options: options)
        chartView.addSubview(chart)
        self.chart = chart
        
        let timeScale = chart.timeScale()
        
        timeScale.applyOptions(options: TimeScaleOptions(
            borderColor: "#000000",
            timeVisible: true,
            secondsVisible: false
        ))
        
        timeScale.subscribeVisibleTimeRangeChange()
        
        var optionss = ChartOptions()
        optionss.layout = LayoutOptions(
            background: .solid(color: ChartColor.init(UIColor(red: 19/255.0, green: 20/255.0, blue: 27/255.0, alpha: 1.0)) ),
            textColor: ChartColor.init(UIColor.white) //"rgba(255, 255, 255, 1)" // Optional: Set text color
        )
        optionss.grid = GridOptions(
            verticalLines: GridLineOptions(color: ChartColor.init(UIColor.clear)),
            horizontalLines: GridLineOptions(color: ChartColor.init(UIColor.clear))
        )
        chart.applyOptions(options: optionss)
        
        let barSeriesOptions = BarSeriesOptions(
            upColor: "rgba(68, 173, 116, 1)",//"rgba(76, 175, 80, 1)",   // Color of bars that moved up
            downColor: "rgba(234, 85, 86, 1)"//"rgba(255, 82, 82, 1)" // Color of bars that moved down
        )
        
        let barSeries = chart.addBarSeries(options: barSeriesOptions)
        self.barSeries = barSeries
        barSeries.setData(data: barData)
        timeScale.scrollToPosition(position: 0.0, animated: false)
        
        // Add constraints as you did for candlestick chart
        setupChartConstraints(chart)
        
    }
    
    private func setupChartConstraints(_ chart: LightweightCharts) {
        chart.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                chart.leadingAnchor.constraint(equalTo: chartView.safeAreaLayoutGuide.leadingAnchor),
                chart.trailingAnchor.constraint(equalTo: chartView.safeAreaLayoutGuide.trailingAnchor),
                chart.topAnchor.constraint(equalTo: chartView.safeAreaLayoutGuide.topAnchor),
                chart.bottomAnchor.constraint(equalTo: chartView.safeAreaLayoutGuide.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                chart.leadingAnchor.constraint(equalTo: chartView.leadingAnchor),
                chart.trailingAnchor.constraint(equalTo: chartView.trailingAnchor),
                chart.topAnchor.constraint(equalTo: chartView.topAnchor),
                chart.bottomAnchor.constraint(equalTo: chartView.bottomAnchor)
            ])
        }
        
        // Start a timer to delay showing the chart by 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // After 2 seconds, reveal the chart and graph view
            self.chartView.isHidden = false
            self.chart?.isHidden = false
        }
        
    }
    
    private func clearChart() {
        if let chart = self.chart {
            chart.removeFromSuperview()
            self.chart = nil
        }
    }
    
    private func convertToBarData(candlestickData: [CandlestickData]) -> [BarData] {
        return candlestickData.map { candle in
            return BarData(
                time: candle.time,
                open: candle.open,
                high: candle.high,
                low: candle.low,
                close: candle.close
            )
        }
    }
    
    private func convertToBarData(candlestickData: CandlestickData) -> BarData {
        
        return BarData(
            time: candlestickData.time,
            open: candlestickData.open,
            high: candlestickData.high,
            low: candlestickData.low,
            close: candlestickData.close
        )
    }
    
    private func convertToAreaData(candlestickData: [CandlestickData]) -> [AreaData] {
        return candlestickData.map { candle in
            return AreaData(time: candle.time, value: candle.close)
        }
    }
    
    private func convertToAreaData(candlestickData: CandlestickData) -> AreaData {
        
        AreaData(time: candlestickData.time, value: candlestickData.close)
    }
}

extension TradeDetalVC: ChartOptionsDelegate {
    func didSelectChartType(_ chartType: ChartType) {
        // Clear existing chart
        clearChart()
        
        self.chartType = chartType
        
        self.chartView.isHidden = true
        self.chart?.isHidden = true
        
        switch chartType {
        case .candlestick:
            setupSeries(candlestickData: candlestickData)
        case .area:
            let areaData = convertToAreaData(candlestickData: candlestickData)
            setupAreaSeries(areaData: areaData)
        case .bar:
            let barData = convertToBarData(candlestickData: candlestickData)
            setupBarSeries(barData: barData)
            
        }
    }
    
}
//MARK: - Setup the Overview view.
extension TradeDetalVC {
    //    UIColor(red: 19/255.0, green: 21/255.0, blue: 26/255.0, alpha: 1.0)
    private func setupOverview() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // After 2 seconds, reveal the chart and graph view
            self.chartView.isHidden = false
            self.chart?.isHidden = false
        }
        
        lazy var scrollView: TPKeyboardAvoidingScrollView = {
            let scroll = TPKeyboardAvoidingScrollView()
            scroll.backgroundColor = UIColor(red: 19/255.0, green: 21/255.0, blue: 26/255.0, alpha: 1.0)
            scroll.layer.cornerRadius = 10
            
            scroll.layer.masksToBounds = false
            // Shadow settings
            scroll.layer.shadowColor = UIColor.black.cgColor
            scroll.layer.shadowOpacity = 0.2
            scroll.layer.shadowOffset = CGSize(width: 0, height: 2)
            scroll.layer.shadowRadius = 4
            
            scroll.translatesAutoresizingMaskIntoConstraints = false
            return scroll
        }()
        
        
        self.chartView.addSubview(scrollView)
        
        scrollView.isScrollEnabled = false
        scrollView.isUserInteractionEnabled = false
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                scrollView.leadingAnchor.constraint(equalTo: chartView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                scrollView.trailingAnchor.constraint(equalTo: chartView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                scrollView.topAnchor.constraint(equalTo: chartView.safeAreaLayoutGuide.topAnchor, constant: 20),
                scrollView.bottomAnchor.constraint(equalTo: chartView.safeAreaLayoutGuide.bottomAnchor, constant: -10)
            ])
        } else {
            NSLayoutConstraint.activate([
                scrollView.leadingAnchor.constraint(equalTo: chartView.leadingAnchor, constant: 10),
                scrollView.trailingAnchor.constraint(equalTo: chartView.trailingAnchor, constant: -20),
                scrollView.topAnchor.constraint(equalTo: chartView.topAnchor, constant: 20),
                scrollView.bottomAnchor.constraint(equalTo: chartView.bottomAnchor, constant: -10)
            ])
        }
        
        //        if tradeDetail.symbol == getSymbolData.tickMessage?.symbol {
        //            if let contractValue = (GlobalVariable.instance.symbolDataArray.firstIndex(where: {$0.name == x })) {
        //                let symbolContractSize = GlobalVariable.instance.symbolDataArray[contractValue].contractSize
        
        if let valueIndex = (GlobalVariable.instance.symbolDataArray.firstIndex(where: {$0.name == getSymbolData.tickMessage?.symbol })) {
            let volumeMin = GlobalVariable.instance.symbolDataArray[valueIndex].volumeMin
            let volumeMax = GlobalVariable.instance.symbolDataArray[valueIndex].volumeMax
            let volumeStep = GlobalVariable.instance.symbolDataArray[valueIndex].volumeStep
            let contractSize = GlobalVariable.instance.symbolDataArray[valueIndex].contractSize
            //            let spreadSize = GlobalVariable.instance.symbolDataArray[valueIndex].spreadSize
            let stopLevel = GlobalVariable.instance.symbolDataArray[valueIndex].stopsLevel
            let swapLong = GlobalVariable.instance.symbolDataArray[valueIndex].swapLong
            let swapShort = GlobalVariable.instance.symbolDataArray[valueIndex].swapShort
            //            let volumeStep = GlobalVariable.instance.symbolDataArray[valueIndex].volumeStep
            
            let session_trade = GlobalVariable.instance.symbolDataArray[valueIndex].trading_sessions_ids
            print("session_trade: \(session_trade)")
            
            let minVol = Double(volumeMin)! / 10000
            let maxVol = Double(volumeMax)! / 10000
            let volStep = Double(volumeStep)! / 10000
            
            overviewList = [("INFO DETAIL",""),("Minimum volume, lots","\(minVol)"), ("Maximum volume, lots","\(maxVol)"), ("Volume step","\(volStep)"), ("Contract size","\(contractSize)"), ("Stop level","\(stopLevel)"), ("Swap long","\(swapLong)"), ("Swap short","\(swapShort)")]
            
        } else {
            overviewList = [("Minimum volume, lots","0"), ("Maximum volume, lots","0"), ("Volume step","0"), ("Contract size","0"), ("Stop level","0"), ("Swap long","0"), ("Swap short","0")]
        }
        
        
        
        var stackViewList = [UIStackView]()
        stackViewList.removeAll()
        
        for (index, item) in overviewList.enumerated() {
            
            lazy var lineView: UIView = {
                let view = UIView()
                view.backgroundColor = UIColor(red: 19/255.0, green: 21/255.0, blue: 26/255.0, alpha: 1.0)
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            lazy var stackView: UIStackView = {
                let view = UIStackView()
                view.axis = .horizontal        // Arrange views horizontally
                view.spacing = 10              // Space between labels
                view.distribution = .equalSpacing  // Equal spacing between items
                view.alignment = .center       // Align labels in the center
                view.tag = index
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            lazy var title: UILabel = {
                let label = UILabel()
                label.textColor = UIColor(red: 161/255.0, green: 165/255.0, blue: 183/255.0, alpha: 1.0)
                label.font = FontController.Fonts.ListInter_Regular.font
                label.text = item.0
                label.tag = index
                return label
            }()
            
            lazy var detail: UILabel = {
                let label = UILabel()
                label.textColor = UIColor(red: 161/255.0, green: 165/255.0, blue: 183/255.0, alpha: 1.0)
                label.font = FontController.Fonts.ListInter_Regular.font
                label.text = item.1
                label.tag = index
                return label
            }()
            
            scrollView.addSubview(stackView)
            
            stackViewList.append(stackView)
            
            stackView.addArrangedSubview(title)
            stackView.addArrangedSubview(detail)
            
            scrollView.addSubview(lineView)
            
            if index == 0 {
                NSLayoutConstraint.activate([
                    stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                    stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30),
                    stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -30),
                    stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
                    
                    lineView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0),
                    lineView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                    lineView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                ])
            } else {
                NSLayoutConstraint.activate([
                    stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                    stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30),
                    stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -30),
                    stackView.topAnchor.constraint(equalTo: stackViewList[index-1].bottomAnchor, constant: 20),
                ])
                if index == overviewList.count-1 {
                    NSLayoutConstraint.activate([
                        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
                    ])
                } else {
                    
                    NSLayoutConstraint.activate([
                        lineView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0),
                        lineView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                        lineView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                    ])
                }
                
            }
        }
        
    }
    
}



extension UIButton {
    func buttonStyle() {
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 4
        self.layer.borderWidth = 0.1
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.clipsToBounds = false
    }
}

