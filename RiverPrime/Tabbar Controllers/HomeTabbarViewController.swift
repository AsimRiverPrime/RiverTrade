//
//  TabbarViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 10/07/2024.
//

import UIKit

class HomeTabbarViewController: UITabBarController {
    
    var tabBarIteam = UITabBarItem()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarAppearance = UITabBarAppearance()
        let tabBarItemAppearance = UITabBarItemAppearance()

        tabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
        tabBarItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemYellow]
        tabBarItemAppearance.selected.iconColor =   UIColor.systemYellow
      
        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
        
//        UITabBar.appearance().barTintColor = UIColor.black
//        UITabBar.appearance().tintColor = UIColor.systemYellow
//        UITabBar.appearance().unselectedItemTintColor = .black

        
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemYellow], for: .selected)
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        
//        let selectedImageAccount = UIImage(named: "Teamwork")?.withRenderingMode(.alwaysTemplate)
//        let deSelectedImageAccount = UIImage(named: "account")?.withRenderingMode(.alwaysTemplate)
//        if let tabBarItem = self.tabBar.items?[0] {
//            tabBarIteam = tabBarItem
//            tabBarIteam.image = deSelectedImageAccount
//            tabBarIteam.selectedImage = selectedImageAccount
//        }
//        
//        let selectedImageTrade =  UIImage(named: "tradeIconSelect")?.withRenderingMode(.alwaysOriginal)
//        let deselectedImageTrade = UIImage(named: "tradeIcon")?.withRenderingMode(.alwaysOriginal)
//        if let tabBarItem = self.tabBar.items?[1] {
//            tabBarIteam = tabBarItem
//            tabBarIteam.image = deselectedImageTrade
//            tabBarIteam.selectedImage =  selectedImageTrade
//        }
//        
//        let selectedImageMarket =  UIImage(named: "marketIconSelect")?.withRenderingMode(.alwaysOriginal)
//        let deselectedImageMarket = UIImage(named: "marketIcon")?.withRenderingMode(.alwaysOriginal)
//        
//        if let tabBarItem = self.tabBar.items?[2] {
//            tabBarIteam = tabBarItem
//            tabBarIteam.image = deselectedImageMarket
//            tabBarIteam.selectedImage = selectedImageMarket
//            
//        }
//        let selectedImageResult =  UIImage(named: "resultIconSelect")?.withRenderingMode(.alwaysOriginal)
//        let deselectedImageResult = UIImage(named: "resultIcon")?.withRenderingMode(.alwaysOriginal)
//        
//        if let tabBarItem = self.tabBar.items?[3] {
//            tabBarIteam = tabBarItem
//            tabBarIteam.image = deselectedImageResult
//            tabBarIteam.selectedImage = selectedImageResult
//        }
//        let selectedImageProfile =  UIImage(named: "profileIconSelect")?.withRenderingMode(.alwaysOriginal)
//        let deselectedImageProfile = UIImage(named: "profileIcon")?.withRenderingMode(.alwaysOriginal)
//        
//        if let tabBarItem = self.tabBar.items?[4] {
//            tabBarIteam = tabBarItem
//            tabBarIteam.image = deselectedImageProfile
//            tabBarIteam.selectedImage = selectedImageProfile
//        }
        
        
        
        // selected tab background color
//        let numberOfItems = CGFloat(tabBar.items!.count)
//        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)
//        
////        tabBar.backgroundImage = UIImage.imageWithColor(color: UIColor.lightGray, size: tabBarItemSize)
////        tabBar.selectionIndicatorImage = UIImage.imageWithColor(color: UIColor.black , size: tabBarItemSize)
////        tabBar.selectionIndicatorImage = UIImage.withRoundedCorners(radius: 7, size: tabBarItemSize)
////        
////        // initaial tab bar index
////        tabBar.selectionIndicatorImage = UIImage(named: "selectedBg")
////        tabBar.backgroundImage = UIImage(named: "unSelectBg")
//        self.selectedIndex = 0
    }
    
    
    
}

extension UIImage {
    
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    class func withRoundedCorners(radius: CGFloat? = nil , size: CGSize) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
