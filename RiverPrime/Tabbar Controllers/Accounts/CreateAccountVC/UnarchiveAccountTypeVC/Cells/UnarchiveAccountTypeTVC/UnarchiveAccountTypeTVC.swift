//
//  UnarchiveAccountTypeTVC.swift
//  RiverPrime
//
//  Created by abrar ul haq on 11/08/2024.
//

import UIKit

enum UnarchiveTypes {
    case Real
    case Demo
    case Archived
}

protocol UnarchiveDelegate: AnyObject {
    func UnarchivedTypeSelected(unarchiveTypes: UnarchiveTypes)
}

class UnarchiveAccountTypeTVC: UITableViewCell {

    @IBOutlet weak var unarchiveTypeCollectionView: UICollectionView!
    var model: [String] = ["Real","Demo","Archived"]
    
    var selectedIndex = 0
    var unarchiveTypes = UnarchiveTypes.Real
    weak var delegate: UnarchiveDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unarchiveTypeCollectionView.delegate = self
        unarchiveTypeCollectionView.dataSource = self
        unarchiveTypeCollectionView.register(UINib(nibName: "UnarchiveAccountTypeCVC", bundle: nil), forCellWithReuseIdentifier: "UnarchiveAccountTypeCVC")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension UnarchiveAccountTypeTVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      //  return 10 // Number of items in the collection view
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UnarchiveAccountTypeCVC", for: indexPath) as! UnarchiveAccountTypeCVC
       
        cell.lbl_unarchivetype.text = model[indexPath.row]
        if indexPath.row == selectedIndex {
            cell.selectedColorView.isHidden = false
            cell.lbl_unarchivetype.textColor = UIColor.black
        } else {
            cell.selectedColorView.isHidden = true
            cell.lbl_unarchivetype.textColor = UIColor.lightGray
        }
        
        if indexPath.row == model.count-1 {
            cell.sepratorView.isHidden = true
        } else {
            cell.sepratorView.isHidden = false
        }
                
        cell.lbl_unarchivetype.isHidden = false
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            selectedIndex = indexPath.row
            if indexPath.row == 0 {
                delegate?.UnarchivedTypeSelected(unarchiveTypes: .Real)
            } else if indexPath.row == 1 {
                delegate?.UnarchivedTypeSelected(unarchiveTypes: .Demo)
            } else if indexPath.row == 2 {
                delegate?.UnarchivedTypeSelected(unarchiveTypes: .Archived)
            }
            collectionView.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.backgroundColor = .clear
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // get the Collection View width and height
        
        let data = model[indexPath.row]
        return CGSize(width: data.count + 80, height: 40)
        
    }
}
