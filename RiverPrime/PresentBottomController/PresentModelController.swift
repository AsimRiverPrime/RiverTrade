//
//  PresentModelController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import Foundation

import Foundation
import UIKit

@available(iOS 16.0, *)
class PresentModalController {
    
    static let instance = PresentModalController()
    
    enum SheetDetents {
        case medium
        case large
        case bothMediumLarge
        case customSmall
        case customMedium
        case customLarge
        case small
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
                } else if sheetDetents == .customSmall {
                    sheet.detents = [
                        .custom { context in
                            return 300 // Custom height for small detent
                        }
                    ]
                } else if sheetDetents == .small {
                    sheet.detents = [
                        .custom { context in
                            return 200 // Custom height for small detent
                        }
                    ]
                } else if sheetDetents == .customMedium {
                    sheet.detents = [
//                        .custom { context in
//                            return 200 // Custom height for small detent
//                        },
//                        .custom { context in
//                            return 400 // Custom height for large detent
//                        }
                        .custom { context in
                            return 500 // Custom height for medium detent
                        }
                    ]
                } else if sheetDetents == .customLarge {
                    sheet.detents = [
                        .custom { context in
                            return 600 // Custom height for large detent
                        }
                    ]
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
