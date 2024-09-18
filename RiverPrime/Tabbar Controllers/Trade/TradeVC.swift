//
//  TradeVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/07/2024.
//

import UIKit
import Starscream
import Alamofire
import AEXML
import Foundation


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
     
//    var symbolDataArray: [SymbolData] = []
    
    public override func awakeFromNib() {
        ActivityIndicator.shared.show(in: self)
        
        odooClientService.sendSymbolDetailRequest()
        odooClientService.tradeSymbolDetailDelegate = self
        
        
//        viewModel.webSocketManager.connectWebSocket()
        viewModel.webSocketManager.connectAllWebSockets()
        
//        setModel(.init(name: "Favorites"))
        
        //MARK: - Handle tableview constraints according to the device logical height.
        //        setTableViewLayoutConstraints()
        setTableViewLayoutTopConstraints()
        
        tblView.registerCells([
            AccountTableViewCell.self,TradeTVC.self, TradeTableViewCell.self
        ])
        
        tblView.delegate = self
        tblView.dataSource = self
      
        
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
//                self.viewModel.webSocketManager.closeWebSockets() // or send unsubcribe call for socket stop
            })
    }
    
}

extension TradeVC {
    
    private func setModel(_ tradeInfo: SymbolData) {
        
//        model.removeAll()
        
//        if tradeInfo.sector == "Favorites" {
//            //            model.append(TradeVCModel(id: 0, title: "BTC", detail: "Bitcoin vs Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: true))
//            //            model.append(TradeVCModel(id: 1, title: "XAU/USD", detail: "Bitcoin vs Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: false))
//            //            model.append(TradeVCModel(id: 2, title: "APPL", detail: "Apple Inc.", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: true))
//            //            model.append(TradeVCModel(id: 3, title: "EUR/USD", detail: "Euro vs Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: false))
//            //            model.append(TradeVCModel(id: 4, title: "GBP/USD", detail: "Great Britain vs Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: true))
//            
//        } else {
//            model.append(TradeVCModel(id: 0, title: "XAU/USD", detail: "Bitcoin vs Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: true))
//            model.append(TradeVCModel(id: 1, title: "EUR/USD", detail: "Euro vs US Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: false))
//            model.append(TradeVCModel(id: 2, title: "GBP/USD", detail: "Great Britain vs US Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: true))
//            model.append(TradeVCModel(id: 3, title: "EUR/AUD", detail: "Euro vs Australian Dolar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: false))
//            model.append(TradeVCModel(id: 4, title: "EUR/CAD", detail: "Euro vs US Canadian Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: true))
//        }
        
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
            cell.config(GlobalVariable.instance.symbolDataArray)
            cell.backgroundColor = .clear
            
            return cell
            
        }else  {
            let cell = tableView.dequeueReusableCell(with: TradeTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            
            let trade = viewModel.trade(at: indexPath)
      
            var symbolDataObj: SymbolData?
            
            if let obj = GlobalVariable.instance.symbolDataArray.first(where: {$0.name == trade.symbol}) {
                symbolDataObj = obj
             //   print("\(obj.icon_url)")
            }
            
            cell.configure(with: trade , symbolDataObj: symbolDataObj)
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
            return 90.0
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
                
            }else if screen_height == 844.0 {
                tblViewTopConstraint.constant = -55
            }  else {
                //MARK: - other iphone if not in the above check's.
                tblViewTopConstraint.constant = 0
            }
            
        } else {
            //MARK: - iPad
            
        }
        
    }
    
}

extension TradeVC: TradeInfoTapDelegate {
    
    func tradeInfoTap(_ tradeInfo: SymbolData) {
        
        setModel(tradeInfo)
       
        tblView.reloadData()
    }
}

extension TradeVC: TradeSymbolDetailDelegate {
    func tradeSymbolDetailSuccess(response: String) {
//        print("\n \(response) ")
        convertXMLIntoJson(response)
        ActivityIndicator.shared.hide(from: self)
    }
    
    func tradeSymbolDetailFailure(error: any Error) {
        print("\n the trade symbol detail Error response: \(error) ")
    }
    
    func convertXMLIntoJson(_ xmlString: String) {
        
        do {
            let xmlDoc = try AEXMLDocument(xml: xmlString)

            if let xmlDocFile = xmlDoc.root["params"]["param"]["value"]["array"]["data"]["value"].all {
                
                
                for param in xmlDocFile {
                    if let structElement = param["struct"].first {
                        var parsedData: [String: Any] = [:]
                        for member in structElement["member"].all ?? [] {
                            let name = member["name"].value ?? ""
                            let value = member["value"].children.first?.value ?? ""
                            parsedData[name] = value
                        }
                        
                        if let symbolId = parsedData["id"] as? String, let symbolName = parsedData["name"] as? String,
                            let symbolDescription = parsedData["description"] as? String, let symbolIcon = parsedData["icon_url"] as? String,
                            let symbolVolumeMin = parsedData["volume_min"] as? String, let symbolVolumeMax = parsedData["volume_max"] as? String,
                            let symbolVolumeStep = parsedData["volume_step"] as? String, let symbolContractSize = parsedData["contract_size"] as? String,
                           let symbolDisplayName = parsedData["display_name"] as? String, let symbolSector = parsedData["sector"] as? String, let symbolDigits = parsedData["digits"] as? String, let symbolMobile_available = parsedData["mobile_available"] as? String {
                         
                            GlobalVariable.instance.symbolDataArray.append(SymbolData(id: symbolId , name: symbolName , description: symbolDescription , icon_url: symbolIcon , volumeMin: symbolVolumeMin , volumeMax: symbolVolumeMax , volumeStep: symbolVolumeStep , contractSize: symbolContractSize , displayName: symbolDisplayName , sector: symbolSector , digits: symbolDigits, mobile_available: symbolMobile_available ))
                        }
                           
                        print("symbol data array : \(GlobalVariable.instance.symbolDataArray.count)")
//                       
//                        print("\n the parsed value is :\(parsedData)")
                    }
                }
                self.tblView.reloadData()
            }
        } catch {
            print("Failed to parse XML: \(error.localizedDescription)")
        }

    }

}

struct SymbolData {
    let id: String
    let name: String
    let description: String
    let icon_url: String
    let volumeMin: String
    let volumeMax: String
    let volumeStep: String
    let contractSize: String
    let displayName: String
    let sector: String
    let digits: String
    let mobile_available: String
    
    init(id: String, name: String, description: String, icon_url: String, volumeMin: String, volumeMax: String, volumeStep: String, contractSize: String, displayName: String, sector: String, digits: String, mobile_available: String) {
        self.id = id
        self.name = name
        self.description = description
        self.icon_url = icon_url
        self.volumeMin = volumeMin
        self.volumeMax = volumeMax
        self.volumeStep = volumeStep
        self.contractSize = contractSize
        self.displayName = displayName
        self.sector = sector
        self.digits = digits
        self.mobile_available = mobile_available
        
    }
    
}


