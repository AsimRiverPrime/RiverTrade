//
//  MarketTopMoversTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/07/2024.
//

import UIKit

class MarketTopMoversTableViewCell: UITableViewCell {

    @IBOutlet weak var topMoverCollectionView: UICollectionView!
    var numberOfItemsPerRow: Int = 2

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        topMoverCollectionView.delegate = self
        topMoverCollectionView.dataSource = self
        topMoverCollectionView.register(UINib(nibName: "MarketsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MarketsCollectionViewCell")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func showMoreAction(_ sender: Any) {
        print("show more btn is clicked")
    }
}

extension MarketTopMoversTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      //  return 10 // Number of items in the collection view
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarketsCollectionViewCell", for: indexPath) as! MarketsCollectionViewCell
       
       
        return cell
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow))
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        return CGSize(width: size, height: size) // Adjust height as needed
    }
    
}
