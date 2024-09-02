//
//  TradeVC.swift
//  RiverPrime
//
//  Created by abrar ul haq on 17/07/2024.
//

import UIKit
import Starscream
import Alamofire
import AEXML


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
    func tradeDetailTap(indexPath: IndexPath, details: TradeDetails)
}

class TradeVC: UIView {
    
    
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblViewTopConstraint: NSLayoutConstraint!
    
    var model = [TradeVCModel]()
    
    weak var delegate: TradeInfoTapDelegate?
    weak var delegateDetail: TradeDetailTapDelegate?
   
    var odooClientService = OdooClient()
    
     let viewModel = TradesViewModel()
    
    var processedSymbols: [String] = [] // Your symbols array
       var loadedSymbols: Set<String> = []
    
    public override func awakeFromNib() {
        odooClientService.sendSymbolDetailRequest()
        odooClientService.tradeSymbolDetailDelegate = self
        
        
        viewModel.webSocketManager.connectAllWebSockets()
        
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
        
        // Bind the ViewModel's data update closure to reload the table view
        viewModel.onTradesUpdated = { [weak self] in
            self?.tblView.reloadData()
        }
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
                self.viewModel.webSocketManager.closeAllWebSockets()
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
            return viewModel.numberOfRows() //WebSocketManager.shared.trades.count
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
            
            //            print("\nIndexPath section: \(indexPath.section),\n chartData count: \(Array(trades.values))")
            
            let trade = viewModel.trade(at: indexPath)
            
           // if let chartData = viewModel.symbolData(for: trade.symbol) {
                // Update the cell with the symbol's chart data
                // cell.detailTextLabel?.text =
             //   print("\n symbol: \(chartData.symbol) \t count: \(chartData.chartData.count) \t close: \(chartData.chartData[indexPath.row].close)")
                
            
            
            //            let symbols = Array(WebSocketManager.shared.trades.keys)
            //                      let symbol = symbols[indexPath.row]
            //                      if let tradeDetail = WebSocketManager.shared.trades[symbol] {
            //                       cell.configure(with: tradeDetail)
            //
            //                   }
            
            
            cell.configure(with: trade)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            
            let selectedSymbol = Array(WebSocketManager.shared.trades.keys)[indexPath.row]
            if let tradeDetail = WebSocketManager.shared.trades[selectedSymbol] {
                delegateDetail?.tradeDetailTap(indexPath: indexPath, details: tradeDetail)
            }
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
        
        setModel(tradeInfo)
        
        tblView.reloadData()
    }
}

extension TradeVC: TradeSymbolDetailDelegate {
    func tradeSymbolDetailSuccess(response: Any) {
        print("\n this is the trade symbol detail response: \(response) ")
//        let parsedSymbols = parseXMLData(xmlString: response as! String)
//        print("model value : \(parsedSymbols)")
      
    }
    
    func tradeSymbolDetailFailure(error: any Error) {
        print("\n the trade symbol detail Error response: \(error) ")
    }
    
    
}

struct SymbolData {
    let id: Int
    let name: String
    let description: String
    let icon_url: String
    let volumeMin: Int
    let volumeMax: Int
    let volumeStep: Int
    let contractSize: Int
    let displayName: String
    let sector: String
    let digits: Int
}


