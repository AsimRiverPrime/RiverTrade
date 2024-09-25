//
//  TradeVM.swift
//  RiverPrime
//
//  Created by abrar ul haq on 10/09/2024.
//

import Foundation

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

extension Notification.Name {
    static let tradesUpdated = Notification.Name("tradesUpdated")
    static let symbolDataUpdated = Notification.Name("symbolDataUpdated")
    static let checkSocketConnectivity = Notification.Name("socketConnectivity")
}
