//
//  TradingSignalTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/07/2024.
//

import UIKit

class TradingSignalTableViewCell: UITableViewCell {

    @IBOutlet weak var tradeSignalCollectionView: UICollectionView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tradeSignalCollectionView.delegate = self
        tradeSignalCollectionView.dataSource = self
        tradeSignalCollectionView.register(UINib(nibName: "TradingSignalCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TradingSignalCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func showMoreAction(_ sender: Any) {
        print("show more btn is clicked")
    }
}

extension TradingSignalTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      //  return 10 // Number of items in the collection view
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TradingSignalCollectionViewCell", for: indexPath) as! TradingSignalCollectionViewCell
       
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.frame.width, height: 200) // Fixed height
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath){
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath){
//        cell.backgroundColor = .clear
        
    }
}
}
