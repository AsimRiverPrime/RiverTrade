//
//  TradesViewModel.swift
//  RiverPrime
//
//  Created by Ross Rostane on 27/08/2024.
//
import Foundation

class TradesViewModel {
    private(set) var trades: [TradeDetails] = [] {
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
    
    var onTradesUpdated: (() -> Void)?
    var onSymbolDataUpdated: (() -> Void)?
    
    private let webSocketManager = WebSocketManager.shared
//    private let webSocketDetail = WebSocketDetail()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(tradesUpdated), name: .tradesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(symbolDataUpdated(_:)), name: .symbolDataUpdated, object: nil)
        webSocketManager.connecttradeWebSocket()
    }
    
    @objc private func tradesUpdated() {
        self.trades = Array(webSocketManager.trades.values)
        fetchSymbolDataForNewSymbols()
    }
    
    private func fetchSymbolDataForNewSymbols() {
        for trade in trades {
            if !processedSymbols.contains(trade.symbol) {
                processedSymbols.insert(trade.symbol)
                webSocketManager.connectHistoryWebSocket()
                webSocketManager.sendSubscriptionHistoryMessage(for: trade.symbol)
            }
        }
    }
    
    @objc private func symbolDataUpdated(_ notification: Notification) {
        if let symbolChartData = notification.object as? SymbolChartData {
            self.symbolData[symbolChartData.symbol] = symbolChartData
            self.onSymbolDataUpdated?()
        }
    }
    
    func numberOfRows() -> Int {
        return trades.count
    }
    
    func trade(at indexPath: IndexPath) -> TradeDetails {
        return trades[indexPath.row]
    }
    
    func symbolData(for symbol: String) -> SymbolChartData? {
        return symbolData[symbol]
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension Notification.Name {
    static let tradesUpdated = Notification.Name("tradesUpdated")
    static let symbolDataUpdated = Notification.Name("symbolDataUpdated")
}

