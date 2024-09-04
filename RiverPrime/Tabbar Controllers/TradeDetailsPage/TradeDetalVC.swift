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

