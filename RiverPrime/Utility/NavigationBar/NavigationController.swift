//
//  NavigationController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 17/09/2024.
//

import Foundation
import UIKit

class NavigationController {
    
    static let shared = NavigationController()
    private init() {}
    
    func getViewController(identifier: BottomSheetIdentifierType, storyboardType: StoryboardType) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardType.rawValue, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier.rawValue)
    }
    
    func getStoryboard(storyboardType: StoryboardType) -> String {
        return storyboardType.rawValue
    }
    
    func getStoryboardIdentifier(identifier: BottomSheetIdentifierType) -> String {
        return identifier.rawValue
    }
}
