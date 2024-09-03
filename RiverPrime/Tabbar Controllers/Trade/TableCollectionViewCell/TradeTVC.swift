//
//  TradeTVC.swift
//  RiverPrime
//
//  Created by abrar ul haq on 17/07/2024.
//

import UIKit

protocol TradeInfoTapDelegate: AnyObject {
    func tradeInfoTap(_ tradeInfo: SymbolData)
}

struct TradeInfo {
    var name = String()
}

class TradeTVC: UITableViewCell {

    @IBOutlet weak var tradeTVCCollectionView: UICollectionView!
    
    var layout = UICollectionViewFlowLayout()
    
    var model = [TradeInfo]()
    var selectedIndex = 0
    
    weak var delegate: TradeInfoTapDelegate?
    var symbolDataSector: [SymbolData] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        model.removeAll()
//        model.append(TradeInfo(name: "Favorites"))
//        model.append(TradeInfo(name: "Popular"))
//        model.append(TradeInfo(name: "Top Movers"))
//        model.append(TradeInfo(name: "Majors"))
//        model.append(TradeInfo(name: "Metals"))
//        model.append(TradeInfo(name: "test1"))
//        model.append(TradeInfo(name: "test2"))
        
        tradeTVCCollectionView.delegate = self
        tradeTVCCollectionView.dataSource = self
        tradeTVCCollectionView.register(UINib(nibName: "TradeCVCCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TradeCVCCollectionViewCell")

    }

    func config(_ symbolData: [SymbolData]){
        self.symbolDataSector = symbolData
        self.tradeTVCCollectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension TradeTVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      //  return 10 // Number of items in the collection view
        return symbolDataSector.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TradeCVCCollectionViewCell", for: indexPath) as! TradeCVCCollectionViewCell
        
//        let data = model[indexPath.row].name
        let data = symbolDataSector[indexPath.row]
        cell.lbl_tradetype.text = data.sector
       
        if indexPath.row == selectedIndex {
            cell.selectedColorView.isHidden = false
        }else{
            cell.selectedColorView.isHidden = true
        }
        if indexPath.row == model.count-1 {
            cell.sepratorView.isHidden = true
        } else {
            cell.sepratorView.isHidden = false
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath){
            let data = symbolDataSector[indexPath.row]
            selectedIndex = indexPath.row
            self.delegate?.tradeInfoTap(data)
            collectionView.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath){
            cell.backgroundColor = .clear
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        // get the Collection View width and height
        
//        let data =
        
        return CGSize(width: symbolDataSector.count + 30 , height: 40)
        
    }
}
