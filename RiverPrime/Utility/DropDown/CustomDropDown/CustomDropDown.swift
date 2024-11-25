//
//  CustomDropDown.swift
//  RiverPrime
//
//  Created by Ross Rostane on 03/08/2024.
//

import Foundation
import UIKit

protocol iCustomDropDown {
    var criteriaDropDown: DropDown { get }
    func dropDownButton(list: [String], sender: UIButton, completion: @escaping (Int, String) -> Void)
}

final class CustomDropDown: UIButton, iCustomDropDown {
    
    static let instance = CustomDropDown()
    
    let criteriaDropDown = DropDown()
    
    func dropDownButton(list: [String], sender: UIButton, completion: @escaping (Int, String) -> Void) {
        let dropDown = self.criteriaDropDown
      
        dropDown.dataSource = list
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)
//        dropDown.cornerRadius = 10.0
//        dropDown.layer.cornerRadius = 10.0
        dropDown.setupCornerRadius(10.0)
        dropDown.textFont = FontController.Fonts.ListInter_Regular.font
        dropDown.show()
        if #available(iOS 13.0, *) {
            dropDown.backgroundColor = UIColor.black //UIColor.white //.secondarySystemBackground
        } else {
            // Fallback on earlier versions
        }
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            print("this is the selected index value:\(index)")
            print("this is the selected item name :\(item)")
            guard let _ = self else { return }
            
            completion(index, item)
            
        }
    }
    
}
