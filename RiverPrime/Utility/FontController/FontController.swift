//
//  FontController.swift
//  RiverPrime
//
//  Created by abrar ul haq on 28/07/2024.
//

import Foundation
import UIKit

class FontController {
    
    enum Fonts {
        
        case Inter_SemiBold
        case Inter_Regular
        case Inter_Medium
        
        case ListInter_Regular
        case ListInter_SemiBold
        case ListInter_Medium
        
        var font: UIFont {
            switch self {
                
            case .Inter_SemiBold: return UIFont(name: "Inter-SemiBold", size: 18) ?? UIFont.systemFont(ofSize: 18)
            case .Inter_Regular: return UIFont(name: "Inter-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)
            case .Inter_Medium: return UIFont(name: "Inter-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18)
                
            case .ListInter_SemiBold: return UIFont(name: "Inter-SemiBold", size: 14) ?? UIFont.systemFont(ofSize: 14)
            case .ListInter_Regular: return UIFont(name: "Inter-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
            case .ListInter_Medium: return UIFont(name: "Inter-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
                
            
            }
        }
    }
    
}
