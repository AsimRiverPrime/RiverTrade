//
//  TradeVC.swift
//  RiverPrime
//
//  Created by abrar ul haq on 17/07/2024.
//

import UIKit
import Starscream
import Alamofire

struct TradeVCModel {
    var id = Int()
    var title = String()
    var detail = String()
    var image = String()
    var totalNumber = Double()
    var percentage = Double()
    var isPositive = Bool()
}

protocol TradeDetailTapDelegate: AnyObject {
    func tradeDetailTap(indexPath: IndexPath)
    
}

class TradeVC: UIView {
    
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblViewTopConstraint: NSLayoutConstraint!
    
    var model = [TradeVCModel]()
    
    weak var delegate: TradeInfoTapDelegate?
    weak var delegateDetail: TradeDetailTapDelegate?
    
    var webSocket: WebSocket!
    
    var trades: [String: TradeDetails] = [:]
    
    public override func awakeFromNib() {
        setupWebSocket()
        setModel(.init(name: "Favorites"))
        
        //MARK: - Handle tableview constraints according to the device logical height.
//        setTableViewLayoutConstraints()
        setTableViewLayoutTopConstraints()
        
        tblView.registerCells([
            AccountTableViewCell.self,TradeTVC.self, TradeTableViewCell.self
            ])
      
        tblView.delegate = self
        tblView.dataSource = self
//        tblView.reloadData()
        //MARK: - connet websocket service and get data
    }
    
    class func getView()->TradeVC {
        return Bundle.main.loadNibNamed("TradeVC", owner: self, options: nil)?.first as! TradeVC
    }
    
    func dismissView() {
        UIView.animate(
            withDuration: 0.4,
            delay: 0.04,
            animations: {
                self.alpha = 0
        }, completion: { (complete) in
            self.removeFromSuperview()
        })
    }
    
}

extension TradeVC {
    
    private func setModel(_ tradeInfo: TradeInfo) {
        
        model.removeAll()
        
        if tradeInfo.name == "Favorites" {
//            model.append(TradeVCModel(id: 0, title: "BTC", detail: "Bitcoin vs Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: true))
//            model.append(TradeVCModel(id: 1, title: "XAU/USD", detail: "Bitcoin vs Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: false))
//            model.append(TradeVCModel(id: 2, title: "APPL", detail: "Apple Inc.", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: true))
//            model.append(TradeVCModel(id: 3, title: "EUR/USD", detail: "Euro vs Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: false))
//            model.append(TradeVCModel(id: 4, title: "GBP/USD", detail: "Great Britain vs Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: true))
            
        } else {
            model.append(TradeVCModel(id: 0, title: "XAU/USD", detail: "Bitcoin vs Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: true))
            model.append(TradeVCModel(id: 1, title: "EUR/USD", detail: "Euro vs US Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: false))
            model.append(TradeVCModel(id: 2, title: "GBP/USD", detail: "Great Britain vs US Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: true))
            model.append(TradeVCModel(id: 3, title: "EUR/AUD", detail: "Euro vs Australian Dolar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: false))
            model.append(TradeVCModel(id: 4, title: "EUR/CAD", detail: "Euro vs US Canadian Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: true))
        }
        
    }
    
}

extension TradeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return 1
        }else{
            return  trades.count //model.count //10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: AccountTableViewCell.self, for: indexPath)
            cell.setHeaderUI(.trade)
//            cell.delegate = self
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(with: TradeTVC.self, for: indexPath)
            cell.delegate = self
            cell.backgroundColor = .clear
            
            return cell
            
        }else  {
            let cell = tableView.dequeueReusableCell(with: TradeTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
//            cell.lblCurrencyName.text = model[indexPath.row].detail
//            cell.lblCurrencySymbl.text = model[indexPath.row].title
            print("\nIndexPath section: \(indexPath.section), chartData count: \(Array(trades.keys))")

            let symbol = Array(trades.keys)[indexPath.row]
                   if let trade = trades[symbol] {
                       cell.configure(with: trade)
                   }
            return cell
        }
               
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TradeTableViewCell") as? TradeTableViewCell
//            print("cell?.lblCurrencyName.text = \(cell?.lblCurrencyName.text ?? "")")
            
            delegateDetail?.tradeDetailTap(indexPath: indexPath)
            
//            closeWebSocket()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300.0
        }else if indexPath.section == 1{
            return 40
            
        }else{
            return 100.0
        }
    }
    
    func refreshSection(at section: Int) {
           let indexSet = IndexSet(integer: section)
           tblView.reloadSections(indexSet, with: .automatic)
        
       }
}
//MARK: - Set websocket congituration with binanceAPI.
extension TradeVC: WebSocketDelegate {
//    func setupWebSocket() {
//        let url = URL(string: "wss://stream.binance.com:9443/stream?streams=btcusdt@trade/ethusdt@trade/xrpusdt@trade")!
////        let url = URL(string: "ws://192.168.3.107:8069/websocket")!
//        var request = URLRequest(url: url)
//        request.timeoutInterval = 5
//
//        socket = WebSocket(request: request)
//        socket.delegate = self
//        socket.connect()
//    }
    
    
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
                "channels": ["price_tick"]
//                "channels": ["price_chart"]
            ]
        ]

        // Convert the dictionary to JSON string
        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("the message is \(jsonString)")
            webSocket.write(string: jsonString)
        }
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
                case .connected(let headers):
                    print("WebSocket is connected: \(headers)")
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
        print("Received JSON string: \(string) \n")
        
        if let jsonData = string.data(using: .utf8) {
            do {
                // Decode the JSON into a WebSocketResponse
                let response = try JSONDecoder().decode(WebSocketResponse.self, from: jsonData)
                
                // Ensure the message type is what you're expecting (e.g., "tick")
                guard response.message.type == "tick" else {
                    print("Unexpected message type: \(response.message.type)")
                    return
                }
                
                // Process each trade detail
                for tradeDetail in response.message.payload {
                    // Store the trade details or update your data model
                    trades[tradeDetail.symbol] = tradeDetail
                    
                    print("Trade details: \(tradeDetail)")
                }
               
                
                DispatchQueue.main.async {
                    self.tblView.reloadData()
                    //                    self.refreshSection(at: 2)
                }
            } catch let error as DecodingError {
                switch error {
                case .typeMismatch(let type, let context):
                    print("Type mismatch error for type \(type): \(context.debugDescription), codingPath: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("Value not found error for type \(type): \(context.debugDescription), codingPath: \(context.codingPath)")
                case .keyNotFound(let key, let context):
                    print("Key not found error for key \(key): \(context.debugDescription), codingPath: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("Data corrupted error: \(context.debugDescription), codingPath: \(context.codingPath)")
                default:
                    print("Decoding error: \(error.localizedDescription)")
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        } else {
            print("Error converting string to Data")
        }
    }
//                catch {
//                print("Error parsing JSON: \(error.localizedDescription)\n")
//                print("Error parsing JSON: \(error)\n")
//            }
        
        
    

    func handleError(_ error: Error?) {
        if let error = error {
            print("WebSocket encountered an error: \(error)")
        }
    }
    
    func closeWebSocket() {
            webSocket.disconnect()
        }
}
//MARK: - Set TableViewTopConstraint.
extension TradeVC {
    
    private func setTableViewLayoutTopConstraints() {
        
        if UIDevice.isPhone {
            print("screen_height = \(screen_height)")
            if screen_height >= 667.0 && screen_height <= 736.0 {
                //MARK: - iphone6s, iphoneSE, iphone7 plus
                tblViewTopConstraint.constant = -20
                
            } else if screen_height == 812.0 {
                //MARK: - iphoneXs
                tblViewTopConstraint.constant = -30
                
            } else if screen_height >= 852.0 && screen_height <= 932.0 {
                //MARK: - iphone14 pro, iphone14, iphone14 Plus, iphone14 Pro Max
                tblViewTopConstraint.constant = -60
                
            } else {
                //MARK: - other iphone if not in the above check's.
                tblViewTopConstraint.constant = 0
            }
            
        } else {
            //MARK: - iPad
            
        }
        
    }
    
}

extension TradeVC: TradeInfoTapDelegate {
    
    func tradeInfoTap(_ tradeInfo: TradeInfo) {
//        delegate?.tradeInfoTap(tradeInfo)
//        setupWebSocket()
        setModel(tradeInfo)
        
        tblView.reloadData()
    }
    
}
