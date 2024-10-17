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
        
//    @IBOutlet weak var symbolLabel: UILabel!
//    @IBOutlet weak var detailsLabel: UILabel!
    
    @IBOutlet weak var lbl_sellBtn: UILabel!
//    @IBOutlet weak var lbl_login_id: UILabel!
    @IBOutlet weak var lbl_BuyBtn: UILabel!
    @IBOutlet weak var lbl_amount: UILabel!
    
//    @IBOutlet weak var lbl_accountType: UILabel!
//    @IBOutlet weak var lbl_accountGroup: UILabel!
    
    @IBOutlet var menuButton: [UIButton]!
    
//    var tradeDetails: TradeDetails?
    var getSymbolData = SymbolCompleteList()
    var getLiveCandelStick = OhlcCalculator()
    
    var login_Id = Int()
    var account_type = String()
    var account_group = String()
    var mt5 = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectHistoryWebSocket()
        setupSeries(candlestickData: [])
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTradesUpdated(_:)), name: .tradesUpdated, object: nil)
        
//        handleTradesUpdated()
        
        addTopAndBottomBorders(menuButton[0])
        
//        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
//            print("saved User Data: \(savedUserData)")
//            // Access specific values from the dictionary
//            
//            if let loginID = savedUserData["loginId"] as? Int, let isCreateDemoAccount = savedUserData["demoAccountCreated"] as? Bool, let accountType = savedUserData["demoAccountGroup"] as? String, let isRealAccount = savedUserData["realAccountCreated"] as? Bool  {
//               
//                self.login_Id = loginID
//                
//                if isCreateDemoAccount == true {
//                    self.account_type = " Demo "
//                }
//                if isRealAccount == true {
//                    self.account_type = " Real "
//                }
//                if accountType == "Pro Account" {
//                    self.account_group = " PRO "
//                    mt5 = " MT5 "
//                }else if accountType == "Prime Account" {
//                    self.account_group = " PRIME "
//                    mt5 = " MT5 "
//                }else if accountType == "Premium Account" {
//                    self.account_group = " PREMIUM "
//                    mt5 = " MT5 "
//                }else{
//                    self.account_group = ""
//                    mt5 = ""
//                    
//                }
//            }
//        }
        
//        self.lbl_login_id.text = "#\(self.login_Id)"
//        self.lbl_accountType.text = self.account_type
//        self.lbl_accountGroup.text = self.account_group
//        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        disconnectWebSocket()
    }
    
    @IBAction func menuButton(_ sender: UIButton) {
        addTopAndBottomBorders(menuButton[sender.tag])
        
        //MARK: - Remove previous button content here.
//        for view in self.chartView.subviews {
//            view.removeFromSuperview()
//        }
        
        //MARK: - Add new content from here.
        
//        lazy var label: UILabel = {
//          let label = UILabel()
//            label.text = "test label."
//            label.translatesAutoresizingMaskIntoConstraints = false
//            return label
//        }()
//
//        self.chartView.addSubview(label)
//
//        label.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//        label.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
//        label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//        label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
    }
    
    func addTopAndBottomBorders(_ sender: UIButton) {
        
        for i in 0...2 {
            let thickness: CGFloat = 3.0
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x:0, y: self.menuButton[i].frame.size.height - thickness, width: self.menuButton[i].frame.size.width + 100, height:thickness)
            bottomBorder.backgroundColor = UIColor.white.cgColor
           
            menuButton[i].titleLabel?.font = UIFont.systemFont(ofSize: 16)
            menuButton[i].layer.addSublayer(bottomBorder)
        }
        
        let thickness: CGFloat = 3.0
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x:0, y: self.menuButton[sender.tag].frame.size.height - thickness, width: self.menuButton[sender.tag].frame.size.width, height:thickness)
        bottomBorder.backgroundColor = UIColor.systemYellow.cgColor
        menuButton[sender.tag].titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        menuButton[sender.tag].layer.addSublayer(bottomBorder)
       
    }
    
        @objc private func handleTradesUpdated(_ notification: Notification) {
         
            if let tradeDetail = notification.object as? TradeDetails {
               
                if tradeDetail.symbol == getSymbolData.tickMessage?.symbol {
                    
                    self.lbl_BuyBtn.text = "\(String(tradeDetail.bid).trimmedTrailingZeros())"
                    self.lbl_sellBtn.text = "\(String(tradeDetail.ask).trimmedTrailingZeros())"
                    
                    
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

}

