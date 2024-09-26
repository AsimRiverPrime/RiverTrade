//
//  TradeDetalVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 18/07/2024.
//

import UIKit
import Starscream

class TradeDetalVC: UIViewController {
    
    @IBOutlet weak var chartView: UIView!
    
    var webSocket : WebSocket!
    
    private var chart: LightweightCharts!
    private var series: CandlestickSeries!
    private var candlestickData: [CandlestickData] = []
    
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    @IBOutlet weak var lbl_sellBtn: UILabel!
    @IBOutlet weak var lbl_BuyBtn: UILabel!
    
//    var tradeDetails: TradeDetails?
    var getSymbolData = SymbolCompleteList()
    var getLiveCandelStick = OhlcCalculator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectHistoryWebSocket()
        setupSeries(candlestickData: [])
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTradesUpdated(_:)), name: .tradesUpdated, object: nil)
        
//        handleTradesUpdated()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        disconnectWebSocket()
    }
    
        @objc private func handleTradesUpdated(_ notification: Notification) {
         
            if let tradeDetail = notification.object as? TradeDetails {
               
                if tradeDetail.symbol == getSymbolData.tickMessage?.symbol {
                    symbolLabel.text = "Symbol: \(tradeDetail.symbol)"
                      
                    // Assuming TradeDetail has properties you want to display
                    detailsLabel.text = "Ask: \(tradeDetail.ask), Bid :\(tradeDetail.bid), \n Time: \(tradeDetail.datetime)"
                    
                    self.lbl_BuyBtn.text = "\(tradeDetail.bid)"
                    self.lbl_sellBtn.text = "\(tradeDetail.ask)"
                    
                    
                    // Update the UI with the latest data for the selected symbol
                    
                    //            self.tradeDetails = tradeDetail
                    
                    //            getLiveCandelStick.update(ask: getSymbolData.tickMessage?.ask, bid: getSymbolData.tickMessage?.bid, currentTimestamp: Int64(getSymbolData.tickMessage?.datetime))
                    getLiveCandelStick.update(ask: tradeDetail.ask, bid: tradeDetail.bid, currentTimestamp: Int64(tradeDetail.datetime))
                    let data =  getLiveCandelStick.getLatestOhlcData()
                    print("latest data: \(data)")
                    
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
                    
                    //            // Use update to add this candlestick incrementally
                    series?.update(bar: dataPoint)
                }
//            setupSeries(candlestickData: dataPoint)
            
        }
    }
   
    /*
    @objc func handleTradesUpdated() {
        updateUI()
        // Update the UI with the latest data for the selected symbol
        if let symbol = getSymbolData.tickMessage?.symbol, let tick = getSymbolData.tickMessage /*, let tradeDetail = WebSocketManager.shared.trades[symbol]*/ {
//            self.tradeDetails = tradeDetail
            
//            getLiveCandelStick.update(ask: getSymbolData.tickMessage?.ask, bid: getSymbolData.tickMessage?.bid, currentTimestamp: Int64(getSymbolData.tickMessage?.datetime))
            getLiveCandelStick.update(ask: tick.ask, bid: tick.bid, currentTimestamp: Int64(tick.datetime))
            let data =  getLiveCandelStick.getLatestOhlcData()
            print("latest data: \(data)")
            
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
            
//            // Use update to add this candlestick incrementally
            series?.update(bar: dataPoint)
            
//            setupSeries(candlestickData: dataPoint)
            
        }
    }
    */
    
//    private func updateUI(detailData: TradeDetails) {
//        if let symbol = detailData.symbol {
//            symbolLabel.text = "Symbol: \(symbol)"
//        }
//        
////        if let tradeDetails = tradeDetails {
//        if let tick = getSymbolData.tickMessage {
//            // Assuming TradeDetail has properties you want to display
//            detailsLabel.text = "Ask: \(tick.ask), Bid :\(tick.bid), \n Time: \(tick.datetime)"
//            
//            self.lbl_BuyBtn.text = "\(tick.bid)"
//            self.lbl_sellBtn.text = "\(tick.ask)"
//        }
//        
//    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .tradesUpdated, object: nil)
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
       
//
//        let options = CandlestickSeriesOptions(
//            upColor: "rgba(8, 153, 52, 1)",
//            downColor: "rgba(204, 13, 13, 1)",
//            borderUpColor: "rgba(8, 153, 52, 1)",
//            borderDownColor: "rgba(204, 13, 13, 1)",
//            wickUpColor: "rgba(8, 153, 52, 1)",
//            wickDownColor: "rgba(204, 13, 13, 1)"
//        )
//
//        let series = chartView.addCandlestickSeries(options: options)
//        series.setData(data: candlestickData)
//        self.series = series
      
        
        let options = ChartOptions(crosshair: CrosshairOptions(mode: .normal))
        let chart = LightweightCharts(options: options)
        chartView.addSubview(chart)
        self.chart = chart
        
        let timeScale = chart.timeScale()
        
        timeScale.applyOptions(options: TimeScaleOptions(
            borderColor: "#D1D4DC",
            timeVisible: true,
            secondsVisible: false
        ))
        
        timeScale.subscribeVisibleTimeRangeChange()
        
//        let options = ChartOptions(crosshair: CrosshairOptions(mode: .normal))
//        let chart = LightweightCharts(options: options)
//        chartView.addSubview(chart)
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
      
        
//        self.chart = chart
        
        let myoptions = CandlestickSeriesOptions(
            upColor: "rgba(8, 153, 52, 1)",
            downColor: "rgba(204, 13, 13, 1)",
            borderUpColor: "rgba(8, 153, 52, 1)",
            borderDownColor: "rgba(204, 13, 13, 1)",
            wickUpColor: "rgba(8, 153, 52, 1)",
            wickDownColor: "rgba(204, 13, 13, 1)"
        )
        
        let series = chart.addCandlestickSeries(options: myoptions)
        self.series = series
   
        series.setData(data: candlestickData)
        
    }
    
}
extension TradeDetalVC: WebSocketDelegate {
    func connectHistoryWebSocket() {
        //        let url =  URL(string:"ws://192.168.3.107:8069/websocket")!
        let url =  URL(string:"wss://mbe.riverprime.com/mobile_web_socket")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        webSocket = WebSocket(request: request)
        webSocket.delegate = self
        webSocket.connect()
    }
    
    func disconnectWebSocket() {
        webSocket?.disconnect()
    }

    func sendSubscriptionHistoryMessage() {
        // Define the message dictionary
        let (currentTimestamp, hourBeforeTimestamp) = getCurrentAndNextHourTimestamps()
        
        let timestamps = currentAndBeforeBusinessDayTimestamps()
        print("Current Timestamp: \(timestamps.currentTimestamp)")
        print("Previous Business Day Timestamp: \(timestamps.previousTimestamp)")

        
        let message: [String: Any] = [
            "event_name": "get_chart_history",
            "data": [
                "symbol":  getSymbolData.tickMessage?.symbol ?? "",
//                "from": timestamps.previousTimestamp,
//                "to":  timestamps.currentTimestamp
                "from": hourBeforeTimestamp,
                "to":  currentTimestamp
            ]
        ]
        
        // Convert the dictionary to JSON string
        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            //            socket write(string: jsonString)
            print("the message is \(jsonString)")
            webSocket.write(string: jsonString)
        }
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("\n WebSocket chart is connected: \(headers)")
            sendSubscriptionHistoryMessage() // Send the message once connected
        case .disconnected(let reason, let code):
            print("WebSocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            handleHistoryWebSocketMessage(string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .error(let error):
            handleHistoryError(error)
        default:
            break
        }
    }
    
    func handleHistoryWebSocketMessage(_ string: String) {
        print("\n this is history json: \(string)")
         
                    
        if let jsonData = string.data(using: .utf8) {
            do {
                let response = try JSONDecoder().decode(WebSocketResponse<SymbolChartData>.self, from: jsonData)
//                let response = try JSONDecoder().decode(SymbolChartData.self, from: jsonData)
                for payload in response.message.payload.chartData {
                    
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
//                setupSeries(candlestickData: candlestickData)
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
    }
    func handleHistoryError(_ error: Error?) {
        if let error = error {
            print("History chart WebSocket encountered an error: \(error)")
        }
    }
    
    
    func getCurrentAndNextHourTimestamps() -> (current: Int, beforeHour: Int) {
        let now = Date()
        //        let calendar = Calendar.current
        
        // Get current timestamp in milliseconds
        let currentTimestamp = Int(now.timeIntervalSince1970) + (3 * 60 * 60)
        let beforeHourTimestamp = currentTimestamp -  (24 * 60 * 60)
        
        return (current: currentTimestamp, beforeHour: beforeHourTimestamp)
        
    }
    
    func currentAndBeforeBusinessDayTimestamps() -> (currentTimestamp: Int, previousTimestamp: Int) {
        let timeZone = TimeZone(identifier: "UTC")!
        let currentDate = Date()
        
        // Get current date components
        let components = Calendar.current.dateComponents(in: timeZone, from: currentDate)
        
        // Create the current timestamp
        let currentTimestamp = Int(currentDate.timeIntervalSince1970)
        
        // Calculate previous business day
        var previousBusinessDay = currentDate
        
        // Check if the current day is a business day (for this example, we'll consider weekdays only)
        let weekday = components.weekday ?? 1 // Default to Sunday (1)
        
        // If today is Sunday (1), go back to Friday (5)
        if weekday == 1 {
            previousBusinessDay = Calendar.current.date(byAdding: .day, value: -2, to: currentDate)!
        }
        // If today is Monday (2), go back to Friday (5)
        else if weekday == 2 {
            previousBusinessDay = Calendar.current.date(byAdding: .day, value: -3, to: currentDate)!
        }
        // Otherwise, just go back one day
        else {
            previousBusinessDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        // Get previous timestamp
        let previousTimestamp = Int(previousBusinessDay.timeIntervalSince1970)
        
        return (currentTimestamp: currentTimestamp, previousTimestamp: previousTimestamp)
    }

    
//    func nextBusinessDay(_ time: BusinessDay) -> BusinessDay {
//        let timeZone = TimeZone(identifier: "UTC")!
//        let dateComponents = DateComponents(
//            calendar: .current,
//            timeZone: timeZone,
//            year: time.year,
//            month: time.month - 1,
//            day: time.day + 1
//        )
//        let date = Calendar.current.date(from: dateComponents)!
//        let components = Calendar.current.dateComponents(in: timeZone, from: date)
//        return BusinessDay(year: components.year!, month: components.month! + 1, day: components.day!)
//    }
    
}





/*class TradeDetalVC: UIViewController {
    
    @IBOutlet weak var chartView: LightweightCharts!
    
    var webSocket : WebSocket!
    
    private var series: CandlestickSeries!
    private var candlestickData: [CandlestickData] = []
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    @IBOutlet weak var lbl_sellBtn: UILabel!
    @IBOutlet weak var lbl_BuyBtn: UILabel!
    
    var tradeDetails: TradeDetails?
    var getLiveCandelStick = OhlcCalculator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectHistoryWebSocket()
        setupSeries()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTradesUpdated), name: .tradesUpdated, object: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
   
    @objc func handleTradesUpdated() {
        updateUI()
        // Update the UI with the latest data for the selected symbol
        if let symbol = self.tradeDetails?.symbol, let tradeDetail = WebSocketManager.shared.trades[symbol] {
            self.tradeDetails = tradeDetail
            
            getLiveCandelStick.update(ask: tradeDetail.ask, bid: tradeDetail.bid, currentTimestamp: Int64(tradeDetail.datetime))
            let data =  getLiveCandelStick.getLatestOhlcData()
            print("latest data: \(data)")
            
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
            
            // Use update to add this candlestick incrementally
            series?.update(bar: dataPoint)
            
        }
    }
    
    private func updateUI() {
        if let symbol = self.tradeDetails?.symbol {
            symbolLabel.text = "Symbol: \(symbol)"
        }
        
        if let tradeDetails = tradeDetails {
            // Assuming TradeDetail has properties you want to display
            detailsLabel.text = "Ask: \(tradeDetails.ask), Bid :\(tradeDetails.bid), \n Time: \(tradeDetails.datetime)"
            
            self.lbl_BuyBtn.text = "\(tradeDetails.bid)"
            self.lbl_sellBtn.text = "\(tradeDetails.ask)"
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .tradesUpdated, object: nil)
    }
    
    @IBAction func buyBtn_action(_ sender: Any) {
        let vc = Utilities.shared.getViewController(identifier: .ticketVC, storyboardType: .bottomSheetPopups) as! TicketVC
        vc.titleString = "BUY"
        
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customLarge, VC: vc)
    }
    @IBAction func sellBtn_action(_ sender: Any) {
        let vc = Utilities.shared.getViewController(identifier: .ticketVC, storyboardType: .bottomSheetPopups) as! TicketVC
        vc.titleString = "SELL"
        
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .customLarge, VC: vc)
    }
    
    private func setupSeries() {
        //  chartView.timeScale().subscribeVisibleTimeRangeChange()
        
        let timeScale = chartView.timeScale()
        timeScale.applyOptions(options: TimeScaleOptions(
            borderColor: "#D1D4DC",
            timeVisible: true,
            secondsVisible: false
        ))
        
        let options = CandlestickSeriesOptions(
            upColor: "rgba(8, 153, 52, 1)",
            downColor: "rgba(204, 13, 13, 1)",
            borderUpColor: "rgba(8, 153, 52, 1)",
            borderDownColor: "rgba(204, 13, 13, 1)",
            wickUpColor: "rgba(8, 153, 52, 1)",
            wickDownColor: "rgba(204, 13, 13, 1)"
        )
        
        let series = chartView.addCandlestickSeries(options: options)
        series.setData(data: candlestickData)
        self.series = series
    }
    
}
extension TradeDetalVC: WebSocketDelegate {
    func connectHistoryWebSocket() {
        //        let url =  URL(string:"ws://192.168.3.107:8069/websocket")!
        let url =  URL(string:"wss://mbe.riverprime.com/mobile_web_socket")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        webSocket = WebSocket(request: request)
        webSocket.delegate = self
        webSocket.connect()
    }
    
    func sendSubscriptionHistoryMessage() {
        // Define the message dictionary
        let (currentTimestamp, hourBeforeTimestamp) = getCurrentAndNextHourTimestamps()
        
        let message: [String: Any] = [
            "event_name": "get_chart_history",
            "data": [
                "symbol":  tradeDetails?.symbol ?? "",
                "from": hourBeforeTimestamp,
                "to":  currentTimestamp
            ]
        ]
        
        // Convert the dictionary to JSON string
        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            //            socket write(string: jsonString)
            print("the message is \(jsonString)")
            webSocket.write(string: jsonString)
        }
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("\n WebSocket chart is connected: \(headers)")
            sendSubscriptionHistoryMessage() // Send the message once connected
        case .disconnected(let reason, let code):
            print("WebSocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            handleHistoryWebSocketMessage(string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .error(let error):
            handleHistoryError(error)
        default:
            break
        }
    }
    
    func handleHistoryWebSocketMessage(_ string: String) {
        print("\n this is history json: \(string)")
        if let jsonData = string.data(using: .utf8) {
            do {
                let response = try JSONDecoder().decode(SymbolChartData.self, from: jsonData)
                
                for payload in response.message.payload.chartData {
                    
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
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
    }
    func handleHistoryError(_ error: Error?) {
        if let error = error {
            print("History chart WebSocket encountered an error: \(error)")
        }
    }
    
    
    func getCurrentAndNextHourTimestamps() -> (current: Int, beforeHour: Int) {
        let now = Date()
        //        let calendar = Calendar.current
        
        // Get current timestamp in milliseconds
        let currentTimestamp = Int(now.timeIntervalSince1970) + (3 * 60 * 60)
        let beforeHourTimestamp = currentTimestamp -  (1 * 60 * 60)
        
        return (current: currentTimestamp, beforeHour: beforeHourTimestamp)
        
    }
    
}
*/
