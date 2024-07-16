//
//  Extension.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/07/2024.
//

import Foundation
import UIKit

extension UIViewController {
    func setCustomNavigation(title: String, rightButton1Image: UIImage, rightButton1Action: Selector, rightButton2Image: UIImage, rightButton2Action: Selector) {
        // Set the title of the navigation bar
        self.navigationItem.title = title
        // Add the back button
//        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
//        self.navigationItem.leftBarButtonItem = backButton
        
        let originalRightButton1Image = rightButton1Image.withRenderingMode(.alwaysOriginal)
        let originalRightButton2Image = rightButton2Image.withRenderingMode(.alwaysOriginal)
               
        
        // Add the first right button
        let rightButton1 = UIBarButtonItem(image: originalRightButton1Image, style: .plain, target: self, action: rightButton1Action)
        
        // Add the second right button
        let rightButton2 = UIBarButtonItem(image: originalRightButton2Image, style: .plain, target: self, action: rightButton2Action)
        
        // Add both right buttons to the navigation item
        self.navigationItem.rightBarButtonItems = [rightButton2, rightButton1]
    }
    
    // Back button action
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func navigate(to viewController: UIViewController, animated: Bool = true) {
           if let navigationController = self.navigationController {
               navigationController.pushViewController(viewController, animated: animated)
           } else {
               let navigationController = UINavigationController(rootViewController: viewController)
               navigationController.modalPresentationStyle = .fullScreen
               self.present(navigationController, animated: animated, completion: nil)
           }
       }
       
       func instantiateViewController(fromStoryboard storyboardName: String, withIdentifier identifier: String) -> UIViewController? {
           let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
           return storyboard.instantiateViewController(withIdentifier: identifier)
       }
   
}

extension UITableView {
    func registerCells(_ cells: [UITableViewCell.Type]) {
        cells.forEach({ register(UINib(nibName: String(describing: $0), bundle: nil), forCellReuseIdentifier: String(describing: $0)) })
    }
    
    func registerHeaderFooter(_ headerFooter: [UITableViewHeaderFooterView.Type]) {
        headerFooter.forEach({ register(UINib(nibName: String(describing: $0), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: $0)) })
    }
    
    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withIdentifier: String(describing: type), for: indexPath) as! T
        return cell
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(with type: T.Type) -> T? {
        return dequeueReusableHeaderFooterView(withIdentifier: String(describing: type)) as? T
    }
}

extension UITextField {
func setIcon(_ image: UIImage) {
   let iconView = UIImageView(frame:
                  CGRect(x: 5, y: 5, width: 20, height: 17))
   iconView.image = image
   let iconContainerView: UIView = UIView(frame:
                  CGRect(x: 20, y: 0, width: 25, height: 25))
   iconContainerView.addSubview(iconView)
   leftView = iconContainerView
   leftViewMode = .always
}
}
