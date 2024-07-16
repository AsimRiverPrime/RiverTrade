//
//  PresentModelController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import Foundation

import Foundation
import UIKit

class PresentModalController {
    
    static let instance = PresentModalController()
    
    enum SheetDetents {
        case medium
        case large
        case bothMediumLarge
    }
    
    func presentBottomSheet(_ vc: UIViewController, sizeOfSheet sheetDetents: SheetDetents? = nil, VC: UIViewController) {

        let nav = UINavigationController(rootViewController: VC)
        nav.modalPresentationStyle = .pageSheet

        if #available(iOS 15.0, *) {
            if let sheet = nav.sheetPresentationController {
                if sheetDetents == .medium {
                    sheet.detents = [.medium()]
                } else if sheetDetents == .large {
                    sheet.detents = [.large()]
                } else if sheetDetents == .bothMediumLarge {
                    sheet.detents = [.medium(), .large()]
                } else {
                    sheet.detents = [.medium(), .large()]
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
        vc.present(nav, animated: true, completion: nil)
    }
    
    func presentBottomSheet(_ vc: UIViewController, VC: UIViewController) {
        vc.present(VC, animated: true, completion: nil)
    }
 
    func dismisBottomSheet(_ vc: UIViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
    
}
