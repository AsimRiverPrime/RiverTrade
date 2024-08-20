//
//  TradeDetalVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 18/07/2024.
//

import UIKit
import LightweightCharts
import Starscream

class TradeDetalVC: UIViewController {
  
    @IBOutlet weak var chartView: LightweightCharts!
    var trade: TradeDetails?
    
    var webSocket : WebSocket!
    
    private var series: CandlestickSeries!
    private var candlestickData: [CandlestickData] = []
    var groupedData: [String: [ChartData]] = [:]
    
    private lazy var lastClose = candlestickData.last?.close
    private lazy var lastIndex = candlestickData.endIndex - 1
    private lazy var targetIndex = lastIndex + 105 + Int((Double.random(in: 0...1) + 30).rounded())
    private lazy var targetPrice = randomPrice
    private lazy var currentIndex = lastIndex + 1
    private var ticksInCurrentBar = 0
    private var currentBusinessDay = BusinessDay(year: 2019, month: 5, day: 29)
   
    private lazy var currentBar = CandlestickData(time: .businessDay(currentBusinessDay), open: nil, high: nil, low: nil, close: nil)
    
    private var randomPrice: Double {
        10 + .random(in: 0...1) * 10000 / 100
    }
    
    // Timers for continuous update
  
    private var timer: Timer?
    
    deinit {
        timer?.invalidate()
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebSocket()
        setupSeries()
//        startSimulation()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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

        let data = [
            CandlestickData( time: .string("2024-08-19T11:01:00"),open: 2499.57, high: 2500.33, low: 2499.54, close: 2500.15),
//            CandlestickData( time: .string("2024-08-19T11:04:00"),open: 2503.2, high: 2503.76, low: 2503.37, close: 2503.44),
//            CandlestickData( time: .string("2024-08-19T11:05:00"),open: 2503.49, high: 2503.32, low: 2503.1, close: 2503.31),
//            CandlestickData( time: .string("2024-08-19T11:06:00"),open: 2503.434,high: 2503.48, low: 2503.11, close: 2503.15)
           
        ]

        let series = chartView.addCandlestickSeries(options: options)
        series.setData(data: candlestickData)
        self.series = series
        
    }
    
//    func fetchCandlestickData(startTimestamp: Int, endTimestamp: Int, completion: @escaping ([CandlestickData]) -> Void) {
//        // Fetch data from your data source (e.g., network request, local database)
//        // Example:
//        let data = [
//            ["time": startTimestamp + 1000, "open": 100, "high": 120, "low": 90, "close": 110],
//            ["time": endTimestamp - 1000, "open": 110, "high": 130, "low": 100, "close": 120]
//        ]
//        setupWebSocket()
//        completion(candlestickData)
//    }
//    func setupChartUpdateOnScroll() {
//        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            chartView.timeScale().getVisibleRange { visibleRange in
//                guard let range = visibleRange else { return }
//                let startTimestamp = (range.from * 1000) // Convert seconds to milliseconds
//                let endTimestamp = Int(range.to * 1000) // Convert seconds to milliseconds
//                
//                // Fetch and update data based on visible range
//                fetchCandlestickData(startTimestamp: startTimestamp, endTimestamp: endTimestamp) { newData in
//                    let candlestickSeries = chartView.addCandlestickSeries(options: newData)
//                    candlestickSeries.setData(newData)
//                }
//            }
//        }
//    }
    
    private func startSimulation() {
//        series.setData(data: data)
        series.setData(data: candlestickData)
        timer?.invalidate()
        timer = .scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] timer in
            guard let self = self else { return }
            self.tick()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func tick() {
        guard let lastClose = candlestickData.last?.close else { return }
        
        // In a live streaming scenario, you may not need the delta calculations.
        // Instead, you'd be working directly with incoming prices.
        let incomingPrice = candlestickData.last?.close ?? 0
        mergeTickToBar(lastClose)
        
        ticksInCurrentBar += 1
        if ticksInCurrentBar == 5 {
            // move to next bar
            currentIndex += 1
            currentBusinessDay = nextBusinessDay(currentBusinessDay)
            currentBar = CandlestickData(time: .businessDay(currentBusinessDay), open: nil, high: nil, low: nil, close: nil)
            ticksInCurrentBar = 0
            if currentIndex == 5000 {
                reset()
                return
            }
        }
    }

    private func mergeTickToBar(_ price: BarPrice) {
        if currentBar.open == nil {
            currentBar.open = price
            currentBar.high = price
            currentBar.low = price
            currentBar.close = price
        } else {
            currentBar.close = price
            currentBar.high = max(currentBar.high ?? price, price)
            currentBar.low = min(currentBar.low ?? price, price)
        }
        series.update(bar: currentBar)
    }

    private func reset() {
        series.setData(data: candlestickData)
        lastClose = candlestickData.last?.close
        lastIndex = candlestickData.endIndex - 1
        targetIndex = lastIndex + 5 + Int((Double.random(in: 0...1) + 30).rounded())
        targetPrice = randomPrice
        currentIndex = lastIndex + 1
        currentBusinessDay = BusinessDay(year: 2024, month: 9, day: 31) // Adjusted for your data
        ticksInCurrentBar = 0
    }
    func nextBusinessDay(_ time: BusinessDay) -> BusinessDay {
        let timeZone = TimeZone(identifier: "UTC")!
        var dateComponents = DateComponents(
            calendar: .current,
            timeZone: timeZone,
            year: time.year,
            month: time.month,
            day: time.day
        )
        dateComponents.day! += 1
        let date = Calendar.current.date(from: dateComponents)!
        let components = Calendar.current.dateComponents(in: timeZone, from: date)
        return BusinessDay(year: components.year!, month: components.month!, day: components.day!)
    }
  
}
extension TradeDetalVC: WebSocketDelegate {
    func setupWebSocket() {
        let url =  URL(string:"ws://192.168.3.107:8069/websocket")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        webSocket = WebSocket(request: request)
        webSocket.delegate = self
        webSocket.connect()
    }
    
    func sendSubscriptionMessage() {
        // Define the message dictionary
        let (currentTimestamp, hourBeforeTimestamp) = getCurrentAndNextHourTimestamps()

        let message: [String: Any] = [
                   "event_name": "get_chart_history",
                   "data": [
                    "symbol":  "Silver.",
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
            sendSubscriptionMessage() // Send the message once connected
        case .disconnected(let reason, let code):
            print("WebSocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            handleWebSocketMessage(string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .error(let error):
            handleError(error)
        default:
            break
        }
    }

    func handleWebSocketMessage(_ string: String) {
    if let jsonData = string.data(using: .utf8) {
        do {
            let response = try JSONDecoder().decode(SymbolChartData.self, from: jsonData)
            
            for payload in response.chartData {
          
                let times = Time.utc(timestamp: Double(payload.datetime))
                // Debugging output to check timestamps
                print("\n Candlestick time: \(times)")
                print(" Candlestick each array object data: \(payload)")
                
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
    func handleError(_ error: Error?) {
        if let error = error {
            print("WebSocket encountered an error: \(error)")
        }
    }
    
    func closeWebSocket() {
        webSocket.disconnect()
    }
    
    func getCurrentAndNextHourTimestamps() -> (current: Int, beforeHour: Int) {
        let now = Date()
        let calendar = Calendar.current
        
        // Get current timestamp in milliseconds
        let currentTimestamp = Int(now.timeIntervalSince1970) + (3 * 60 * 60)
        var beforeHourTimestamp = currentTimestamp -  (1 * 60 * 60)
        // Calculate the next hour
//        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
//        dateComponents.hour = (dateComponents.hour ?? 0) + 3 // minu one hour
//        dateComponents.minute = 0
//        dateComponents.second = 0
//        
//        if let beforeHourDate = calendar.date(from: dateComponents) {
//             beforeHourTimestamp = Int(beforeHourDate.timeIntervalSince1970)
//            return (current: currentTimestamp, beforeHour: beforeHourTimestamp)
//        } else {
            return (current: currentTimestamp, beforeHour: beforeHourTimestamp)
        
    }
    
}


/*extension TradeDetalVC: WebSocketDelegate {
    func setupWebSocket() {
        let url =  URL(string:"ws://192.168.3.107:8069/websocket")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        webSocket = WebSocket(request: request)
        webSocket.delegate = self
        webSocket.connect()
    }
    
    func sendSubscriptionMessage() {
        // Define the message dictionary
        let message: [String: Any] = [
            "event_name": "subscribe",
            "data": [
                "last": 0,
                "channels": ["price_chart"]
            ]
        ]
        
        // Convert the dictionary to JSON string
        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            //            socket write(string: jsonString)
            webSocket.write(string: jsonString)
        }
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("WebSocket for chart is connected: \(headers)")
            sendSubscriptionMessage() // Send the message once connected
        case .disconnected(let reason, let code):
            print("WebSocket chart is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            handleWebSocketMessage(string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .error(let error):
            handleError(error)
        default:
            break
        }
    }
    
    func handleWebSocketMessage(_ string: String) {
        if let jsonData = string.data(using: .utf8) {
            do {
                let response = try JSONDecoder().decode(WebSocketChartResponse.self, from: jsonData)

                guard response.message.type == "chart" else {
                    return
                }

                for payload in response.message.payload {
                    let dataPoint = CandlestickData(
                        time: .string(String(payload.datetime)),
                        open: payload.priceOpen,
                        high: payload.askHigh,
                        low: payload.askLow,
                        close: payload.priceClose
                    )
                    candlestickData.append(dataPoint)
                }

                // Update the candlestick data
                series.setData(data: candlestickData)
                tick()

            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
    }

//    func handleWebSocketMessage(_ string: String) {
//        print("Received JSON string: \(string) \n")
//        if let jsonData = string.data(using: .utf8) {
//              do {
//                  let response = try JSONDecoder().decode(WebSocketChartResponse.self, from: jsonData)
//
//                  guard response.message.type == "chart" else {
//                      print("Unexpected message type: \(response.message.type)")
//                      return
//                  }
//
//                  var newData: [CandlestickData] = []
//                  for payload in response.message.payload {
//                      let dataPoint = CandlestickData(
//                        time: Time.string(String(payload.datetime)), //payload.datetime,
//                          open: payload.priceOpen,
//                          high: payload.askHigh,
//                          low: payload.askLow,
//                          close: payload.priceClose
//                      )
//                      newData.append(dataPoint)
//                  }
//
//                  // Update the candlestick data
//                  candlestickData = newData
//
//                  // Reload the chart with new data

//                  series.setData(data: candlestickData)
//
//
//            } catch {
//                print("Error parsing JSON: \(error)")
//            }
//        }
//    }
    
    func handleError(_ error: Error?) {
        if let error = error {
            print("WebSocket encountered an error: \(error)")
        }
    }
    
    func closeWebSocket() {
        webSocket.disconnect()
    }
    
}
*/
