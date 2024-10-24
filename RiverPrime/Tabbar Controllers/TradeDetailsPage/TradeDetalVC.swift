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
    @IBOutlet weak var SellBuyView: UIView!
    
//    var tradeDetails: TradeDetails?
    var getSymbolData = SymbolCompleteList()
    var getLiveCandelStick = OhlcCalculator()
    
    var login_Id = Int()
    var account_type = String()
    var account_group = String()
    var mt5 = String()
    
    var tradeDetail: TradeDetails?
    
    var overviewList = [(String, String)]()
    
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
        
        if sender.tag == 0 { //For Chart
            //MARK: - Remove previous button content here.
            // Remove all subviews
            self.chartView.subviews.forEach { $0.removeFromSuperview() }
            self.SellBuyView.isHidden = false
            
            //MARK: - Add new content from here.
            setupChart()
            
        } else { //tag = 1 -> For Overview
            
            //MARK: - Remove previous button content here.
            // Remove all subviews
            self.chartView.subviews.forEach { $0.removeFromSuperview() }
            self.SellBuyView.isHidden = true
            
            //MARK: - Add new content from here.
            setupOverview()
            
        }
        
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
                    
                    
                    self.tradeDetail = tradeDetail
                    
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

//MARK: - Setup the Chart view.
extension TradeDetalVC {
    
    private func setupChart() {
        
        setupSeries(candlestickData: candlestickData)
        
        self.lbl_BuyBtn.text = "\(String(tradeDetail?.bid ?? 0.0).trimmedTrailingZeros())"
        self.lbl_sellBtn.text = "\(String(tradeDetail?.ask ?? 0.0).trimmedTrailingZeros())"
        
        
        // Update the UI with the latest data for the selected symbol
        
        //            self.tradeDetails = tradeDetail
        
        //            getLiveCandelStick.update(ask: getSymbolData.tickMessage?.ask, bid: getSymbolData.tickMessage?.bid, currentTimestamp: Int64(getSymbolData.tickMessage?.datetime))
        getLiveCandelStick.update(ask: tradeDetail?.ask ?? 0.0, bid: tradeDetail?.bid ?? 0.0, currentTimestamp: Int64(tradeDetail?.datetime ?? 0))
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
    
}

//MARK: - Setup the Overview view.
extension TradeDetalVC {
    
    private func setupOverview() {
        
        lazy var scrollView: TPKeyboardAvoidingScrollView = {
            let scroll = TPKeyboardAvoidingScrollView()
            scroll.backgroundColor = .white //.clear
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
            
            let minVol = Double(volumeMin)! / 10000
            let maxVol = Double(volumeMax)! / 10000
            let volStep = Double(volumeStep)! / 10000
            
            overviewList = [("Minimum volume, lots","\(minVol)"), ("Maximum volume, lots","\(maxVol)"), ("Volume step","\(volStep)"), ("Contract size","\(contractSize)"), ("Stop level","\(stopLevel)"), ("Swap long","\(swapLong)"), ("Swap short","\(swapShort)")]
            
        } else {
            overviewList = [("Minimum volume, lots","0"), ("Maximum volume, lots","0"), ("Volume step","0"), ("Contract size","0"), ("Stop level","0"), ("Swap long","0"), ("Swap short","0")]
        }
        
        
        
        var stackViewList = [UIStackView]()
        stackViewList.removeAll()
        
        for (index, item) in overviewList.enumerated() {
            
            lazy var lineView: UIView = {
                let view = UIView()
                view.backgroundColor = .gray
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
                label.textColor = .darkGray
                label.font = FontController.Fonts.ListInter_Regular.font
                label.text = item.0
                label.tag = index
                return label
            }()
            
            lazy var detail: UILabel = {
                let label = UILabel()
                label.textColor = .darkGray
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
                    stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
                    
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
