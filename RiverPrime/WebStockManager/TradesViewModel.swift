//
////
////  TradesViewModel.swift
////  RiverPrime
////
////  Created by Ross Rostane on 27/08/2024.
////
//import Foundation
//
//class TradesViewModel {
//    static let shared = TradesViewModel()
//    
//    private(set) var trades: [TradeDetails] = [] {
//        didSet {
//            self.onTradesUpdated?()
//        }
//    }
//    
//    var symbolData: [String: SymbolChartData] = [:] {
//        didSet {
//            self.onSymbolDataUpdated?()
//        }
//    }
//    
//    private var processedSymbols: Set<String> = []
//    private  var symbolQueue: [String] = []
////    private  var isProcessingSymbol: Bool = false
//
//    var onTradesUpdated: (() -> Void)?
//    var onSymbolDataUpdated: (() -> Void)?
//    
//     let webSocketManager = WebSocketManager.shared
////    private let webSocketDetail = WebSocketDetail()
//    
//    init() {
//        NotificationCenter.default.addObserver(self, selector: #selector(tradesUpdated), name: .tradesUpdated, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(symbolDataUpdated(_:)), name: .symbolDataUpdated, object: nil)
//       // webSocketManager.connecttradeWebSocket()
//    }
//    
//    func isSymbolAlreadyProcessed(_ symbol: String) -> Bool {
//           return processedSymbols.contains(symbol)
//       }
//
//       func markSymbolAsProcessed(_ symbol: String) {
//           processedSymbols.insert(symbol)
//       }
//    @objc private func tradesUpdated() {
//        self.trades = Array(webSocketManager.trades.values)
//        fetchSymbolDataForNewSymbols()
//    }
//    
//    private func fetchSymbolDataForNewSymbols() {
//        // Add new symbols to the queue
//        for trade in trades {
//            if !processedSymbols.contains(trade.symbol) {
//                processedSymbols.insert(trade.symbol)
//                symbolQueue.append(trade.symbol)
//            }
//        }
//
//        // Start processing if not already processing
//        if !GlobalVariable.instance.isProcessingSymbol {
//            processNextSymbolInQueue()
//        }
//    }
//
//    func processNextSymbolInQueue() {
//        guard !symbolQueue.isEmpty else {
//            GlobalVariable.instance.isProcessingSymbol = false
//            return
//        }
//
//        GlobalVariable.instance.isProcessingSymbol = true
//     
//        if symbolQueue.count != 0 {
//            
////            webSocketManager.sendSubscriptionHistoryMessage(for: symbolQueue[0])
//            webSocketManager.sendWebSocketMessage(for: "subscribeHistory", symbol: symbolQueue[0])
//            symbolQueue.remove(at: 0)
//        }else{
//            print("the count is finished")
//        }
//
//      
//    }
//    
//    @objc private func symbolDataUpdated(_ notification: Notification) {
//        if let symbolChartData = notification.object as? SymbolChartData {
//            self.onSymbolDataUpdated?()
//        }
//    }
//    
//    func numberOfRows() -> Int {
//        return trades.count
//    }
//    
//    func removeTradeList() {
//        processedSymbols.removeAll()
//        symbolData.removeAll()
//        symbolQueue.removeAll()
//        GlobalVariable.instance.changeSymbol = true
//        trades.removeAll()
//    }
//    
//    func trade(at indexPath: IndexPath) -> TradeDetails {
//        return trades[indexPath.row]
//    }
//    
//    func symbolData(for symbol: String) -> SymbolChartData? {
//        print("print data of symbol: \(symbol)")
//        print("print data of chart symbol: \(symbolData)")
//        return symbolData[symbol]
//    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//}
//
//extension Notification.Name {
//    static let tradesUpdated = Notification.Name("tradesUpdated")
//    static let symbolDataUpdated = Notification.Name("symbolDataUpdated")
//}
