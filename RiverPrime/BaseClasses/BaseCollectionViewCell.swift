//
//  BaseCollectionViewCell.swift
//  RiverPrime
//
//  Created by abrar ul haq on 03/08/2024.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
}

//MARK: - DropDown Methods
extension BaseCollectionViewCell {
    
    func dynamicDropDownButton(_ sender: UIButton, list: [String], completion: @escaping ((Int,String)) -> Void) {
        
        CustomDropDown.instance.dropDownButton(list: list, sender: sender) { [weak self] (index: Int, item: String) in
            print("this is the selected index value:\(index)")
            print("this is the selected item name :\(item)")
//            guard let self = self else { return }
            sender.setTitle(item, for: .normal)
            completion((index,item))
        }
        
    }
    
}
