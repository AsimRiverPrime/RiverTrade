//
//  TradeVC.swift
//  RiverPrime
//
//  Created by abrar ul haq on 17/07/2024.
//

import UIKit

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
    
    public override func awakeFromNib() {
        
        setModel(.init(name: "Favorites"))
        
        //MARK: - Handle tableview constraints according to the device logical height.
//        setTableViewLayoutConstraints()
        setTableViewLayoutTopConstraints()
        
        tblView.registerCells([
            AccountTableViewCell.self,TradeTVC.self, TradeTableViewCell.self
            ])
      
        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
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
            model.append(TradeVCModel(id: 0, title: "BTC", detail: "Bitcoin vs Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: true))
            model.append(TradeVCModel(id: 1, title: "XAU/USD", detail: "Bitcoin vs Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: false))
            model.append(TradeVCModel(id: 2, title: "APPL", detail: "Apple Inc.", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: true))
            model.append(TradeVCModel(id: 3, title: "EUR/USD", detail: "Euro vs Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: false))
            model.append(TradeVCModel(id: 4, title: "GBP/USD", detail: "Great Britain vs Dollar", image: "", totalNumber: 1234.12, percentage: 2.3, isPositive: true))
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
            return model.count //10
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
            
        }else{
            let cell = tableView.dequeueReusableCell(with: TradeTableViewCell.self, for: indexPath)
            cell.backgroundColor = .clear
            cell.lblCurrencyName.text = model[indexPath.row].detail
            cell.lblCurrencySymbl.text = model[indexPath.row].title
            return cell
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TradeTableViewCell") as? TradeTableViewCell
//            print("cell?.lblCurrencyName.text = \(cell?.lblCurrencyName.text ?? "")")
            
            delegateDetail?.tradeDetailTap(indexPath: indexPath)
            
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
        setModel(tradeInfo)
        tblView.reloadData()
    }
    
}