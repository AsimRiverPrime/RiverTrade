//
//  TradeTypeTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 15/07/2024.
//

import UIKit

class TradeTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var tradeTypeCollectionView: UICollectionView!
    var model: [String] = ["Open","Pending","Close","test","test1","test2","test3"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tradeTypeCollectionView.delegate = self
        tradeTypeCollectionView.dataSource = self
        tradeTypeCollectionView.register(UINib(nibName: "TradeTypeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TradeTypeCollectionViewCell")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension TradeTypeTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      //  return 10 // Number of items in the collection view
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TradeTypeCollectionViewCell", for: indexPath) as! TradeTypeCollectionViewCell
       
        cell.lbl_tradetype.text = model[indexPath.row]
        if indexPath.row == 0 {
            cell.selectedColorView.isHidden = false
        }else{
            cell.selectedColorView.isHidden = true
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath){
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath){
        cell.backgroundColor = .clear
        
    }
}
}
