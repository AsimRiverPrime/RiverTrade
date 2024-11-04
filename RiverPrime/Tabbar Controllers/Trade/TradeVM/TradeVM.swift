//
//  TradeVM.swift
//  RiverPrime
//
//  Created by Ross Rostane on 10/09/2024.
//

import Foundation
import Alamofire

class TradeVM {
    
    static let shared = TradeVM()
    
//    private(set) var trades: [TradeDetails] = [] {
//        didSet {
//            self.onTradesUpdated?()
//        }
//    }
    
    var trades: [TradeDetails] = [] {
        didSet {
            self.onTradesUpdated?()
        }
    }
    
    var symbolData: [String: SymbolChartData] = [:] {
        didSet {
            self.onSymbolDataUpdated?()
        }
    }
    
    private var processedSymbols: Set<String> = []
    private  var symbolQueue: [String] = []

    var onTradesUpdated: (() -> Void)?
    var onSymbolDataUpdated: (() -> Void)?
    
    
    let odooClientService = OdooClientNew()
    let uid = UserDefaults.standard.integer(forKey: "uid")
    let pass = UserDefaults.standard.string(forKey: "password")
    var email = ""
    var loginId = 0
    
    
     let webSocketManager = WebSocketManager.shared
    
    init() {
//        NotificationCenter.default.addObserver(self, selector: #selector(tradesUpdated), name: .tradesUpdated, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(symbolDataUpdated(_:)), name: .symbolDataUpdated, object: nil)
    }
    
    @objc private func tradesUpdated() {
//        self.trades.removeAll()
        self.trades = Array(webSocketManager.trades.values)
        fetchSymbolDataForNewSymbols()
    }
    
    @objc private func symbolDataUpdated(_ notification: Notification) {
        if let symbolChartData = notification.object as? SymbolChartData {
            self.onSymbolDataUpdated?()
        }
    }
    
}

extension TradeVM {
    
    func fetchSymbolDataForNewSymbols() {
        // Add new symbols to the queue
        for trade in trades {
            if !processedSymbols.contains(trade.symbol) {
                processedSymbols.insert(trade.symbol)
                symbolQueue.append(trade.symbol)
            }
        }

        // Start processing if not already processing
        if !GlobalVariable.instance.isProcessingSymbol {
            processNextSymbolInQueue()
        }
    }

    func processNextSymbolInQueue() {
        guard !symbolQueue.isEmpty else {
            GlobalVariable.instance.isProcessingSymbol = false
            return
        }

        GlobalVariable.instance.isProcessingSymbol = true
     
        if symbolQueue.count != 0 {
            
//            webSocketManager.sendSubscriptionHistoryMessage(for: symbolQueue[0])
            webSocketManager.sendWebSocketMessage(for: "subscribeHistory", symbol: symbolQueue[0])
            symbolQueue.remove(at: 0)
        }else{
            print("the count is finished")
        }

      
    }
    
}

extension TradeVM {
    
    func numberOfRows() -> Int {
        return trades.count
    }
    
    func removeTradeList() {
        processedSymbols.removeAll()
        symbolData.removeAll()
        symbolQueue.removeAll()
        GlobalVariable.instance.changeSymbol = true
        trades.removeAll()
    }
    
    func trade(at indexPath: IndexPath) -> TradeDetails {
        return trades[indexPath.row]
    }
    
    func symbolData(for symbol: String) -> SymbolChartData? {
        print("print data of symbol: \(symbol)")
        print("print data of chart symbol: \(symbolData)")
        return symbolData[symbol]
    }
    
}

extension TradeVM {
    
    func getCurrentAndNextHourTimestamps() -> (current: Int, beforeHour: Int) {
        let now = Date()
        //        let calendar = Calendar.current
        
        // Get current timestamp in milliseconds
        let currentTimestamp = Int(now.timeIntervalSince1970) + (3 * 60 * 60)
        let beforeHourTimestamp = currentTimestamp -  (24 * 60 * 60)
        
        return (current: currentTimestamp, beforeHour: beforeHourTimestamp)
        
    }
    
    func fetchChartHistory(symbol: String, completion: @escaping (Result<SymbolChartData, Error>) -> Void) {
        // Retrieve the data from UserDefaults
        if let savedUserData = UserDefaults.standard.dictionary(forKey: "userData") {
            if let _email = savedUserData["email"] as? String, let _loginId = savedUserData["loginId"] as? Int {
                email = _email
                loginId = _loginId
            }
        }
//        print("/n uid: \(uid) \t email: \(email) \t pass: \(pass ?? "")) \t loginID: \(loginId) ")
        
        let (currentTimestamp, hourBeforeTimestamp) = getCurrentAndNextHourTimestamps()
        
        let params: [String: Any] = [
            "jsonrpc": "2.0",
            "params": [
                "service": "object",
                "method": "execute_kw",
                "args": [
                    odooClientService.dataBaseName,  // Database name
                    uid,                     // UID
                    odooClientService.dbPassword, // Password
                    "mt.middleware",       // Model
                    "get_chart_history",   // Method
                    [
                        [],
                        email, // Email
                        symbol,                   // Symbol
                        hourBeforeTimestamp,               // Start time
                        currentTimestamp                // End time
                    ]
                ]
            ]
        ]
        
//        print("params is: \(params)")
        
        JSONRPCClient.instance.sendData(endPoint: .jsonrpc, method: .post, jsonrpcBody: params, showLoader: false) { result in
            switch result {
                
            case .success(let value):
                
                do {
                    // Decode the response
                    if let json = value as? [String: Any],
                       let result = json["result"] as? [String: Any],
                       let chartData = result["chart_data"] as? [[String: Any]] {
                        
                        // Create HistoryResponseData from chartData
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                        let historyResponseData = try JSONDecoder().decode(SymbolChartData.self, from: jsonData)
                        completion(.success(historyResponseData))
                    } else {
                        completion(.failure(NSError(domain: "ResponseParsingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid response structure"])))
                    }
                } catch {
                    print("Error decoding response: \(error)")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
}

extension TradeVM {
    
    /*
    func filterSymbolsBySector(symbols: [SymbolData], sector: String) -> [String] {
        return symbols.filter { $0.sector == sector }.map { $0.displayName }
    }
    
    private func setTradeModel(collectionViewIndex: Int) {
        let symbols = GlobalVariable.instance.symbolDataArray
        let sectors = GlobalVariable.instance.sectors
        
//        // Clear previous data
//        vm.trades.removeAll()
        GlobalVariable.instance.filteredSymbols.removeAll()
        GlobalVariable.instance.filteredSymbolsUrl.removeAll()
        
        // Populate filteredSymbols and filteredSymbolsUrl for each sector
        for sector in sectors {
            let filteredSymbols = filterSymbolsBySector(symbols: symbols, sector: sector.sector)
            
            GlobalVariable.instance.filteredSymbols.append(filteredSymbols)
        }
        
        // Append trades for the selected collectionViewIndex
        let selectedSymbols = GlobalVariable.instance.filteredSymbols[safe: collectionViewIndex] ?? []
        let selectedUrls = GlobalVariable.instance.filteredSymbolsUrl[safe: collectionViewIndex] ?? []
        
//        for (symbol, url) in zip(selectedSymbols, selectedUrls) {
//            vm.trades.append(TradeDetails(datetime: 0, symbol: symbol, ask: 0.0, bid: 0.0, url: url))
//        }
        
        print("GlobalVariable.instance.filteredSymbolsUrl = \(GlobalVariable.instance.filteredSymbolsUrl)")
        
        webSocketManager.sendWebSocketMessage(for: "subscribeTrade", symbolList: selectedSymbols)
    }
    */

}


//extension Notification.Name {
//    static let tradesUpdated = Notification.Name("tradesUpdated")
//    static let symbolDataUpdated = Notification.Name("symbolDataUpdated")
//    static let checkSocketConnectivity = Notification.Name("socketConnectivity")
//    static let OPCListDismissall = Notification.Name("opcListDismiss")
//}
