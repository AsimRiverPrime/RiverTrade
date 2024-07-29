//
//  NavigationBar.swift
//  RiverPrime
//
//  Created by abrar ul haq on 28/07/2024.
//

import Foundation
import UIKit

class NavigationBar {
    
    static let instance = NavigationBar()
    
    // MARK: - NavigationBar Styling.
    func NavBarForDashboard(view: UIView, viewController: UIViewController, navController: UINavigationController?, title: String? = nil, leftTitle: String? = nil, rightTitle: String? = nil/*, isHide: Bool? = nil*/, textColor: UIColor, barColor: UIColor) {
        view.backgroundColor = barColor //UIColor.white
        viewController.navigationItem.title = title
        viewController.navigationItem.leftBarButtonItem?.title = leftTitle
        viewController.navigationItem.rightBarButtonItem?.title = rightTitle
//        viewController.navigationController?.navigationBar.isHidden = isHide ?? false
        viewController.navigationItem.rightBarButtonItem?.tintColor = textColor
        viewController.navigationItem.leftBarButtonItem?.tintColor = textColor
        navController?.navigationBar.tintColor = textColor
        viewController.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navController?.navigationBar.barTintColor = barColor
//        if isHide == true {
//            viewController.navigationController?.setNavigationBarHidden(true, animated: false)
//        }
    }
    
    // MARK: - NavigationBar Styling.
    func NavBar(view: UIView, viewController: UIViewController, navController: UINavigationController?, title: String? = nil, leftTitle: String? = nil, rightTitle: String? = nil, isHide: Bool? = nil, textColor: UIColor, barColor: UIColor) {
        if textColor == .white {
            view.backgroundColor = UIColor.white
        } else {
            view.backgroundColor = UIColor.black
        }
        viewController.navigationItem.title = title
        viewController.navigationItem.leftBarButtonItem?.title = leftTitle
        viewController.navigationItem.rightBarButtonItem?.title = rightTitle
        viewController.navigationController?.navigationBar.isHidden = isHide ?? false
        viewController.navigationItem.rightBarButtonItem?.tintColor = textColor
        viewController.navigationItem.leftBarButtonItem?.tintColor = textColor
        navController?.navigationBar.tintColor = textColor
        if textColor == .white {
            viewController.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        } else {
            viewController.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }
        navController?.navigationBar.barTintColor = barColor
        if isHide == true {
            viewController.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    // MARK: - NavigationBar Styling.
    func NavBarBottomSheet(view: UIView, viewController: UIViewController, navController: UINavigationController?, title: String? = nil, leftTitle: String? = nil, rightTitle: String? = nil, isHide: Bool? = nil, textColor: UIColor, barColor: UIColor) {
        view.backgroundColor = UIColor.white
        viewController.navigationItem.title = title
        viewController.navigationItem.leftBarButtonItem?.title = leftTitle
        viewController.navigationItem.rightBarButtonItem?.title = rightTitle
        viewController.navigationController?.navigationBar.isHidden = isHide ?? false
        viewController.navigationItem.rightBarButtonItem?.tintColor = textColor
        viewController.navigationItem.leftBarButtonItem?.tintColor = textColor
        navController?.navigationBar.tintColor = textColor
        viewController.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navController?.navigationBar.barTintColor = barColor
        navController?.navigationBar.prefersLargeTitles = true
    }
    
}
