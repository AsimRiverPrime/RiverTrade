//
//  BaseTableViewCell.swift
//  RiverPrime
//
//  Created by abrar ul haq on 03/08/2024.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//MARK: - DropDown Methods
extension BaseTableViewCell {
    
    func dynamicDropDownButton(_ sender: UIButton, list: [String], completion: @escaping ((Int,String)) -> Void) {
        
        CustomDropDown.instance.dropDownButton(list: list, sender: sender) { [weak self] (index: Int, item: String) in
            print("this is the selected index value:\(index)")
            print("this is the selected item name :\(item)")
//            guard let self = self else { return }
//            sender.setTitle(item, for: .normal)
            completion((index,item))
        }
        
    }
    
}
