//
//  UIView+Extension.swift
//  RiverPrime
//
//  Created by abrar ul haq on 11/08/2024.
//

import Foundation
import UIKit

extension UIView {
    
    func inoutAnimation(to offset: CGFloat, sView: UIView, timeDuration: CGFloat = 0.25) {
        UIView.animate(withDuration: timeDuration, animations: {
            sView.transform = CGAffineTransform(translationX: offset, y: 0)
        }) { _ in
            // Reset the view's position after the animation completes
            UIView.animate(withDuration: timeDuration) {
//                self.view.transform = .identity
//                self.view.transform = CGAffineTransform(translationX: -offset, y: 0)
                sView.isHidden = true
                UIView.animate(withDuration: timeDuration, animations: {
                    sView.transform = CGAffineTransform(translationX: -offset, y: 0)
                }) { _ in
                    // Reset the view's position after the animation completes
                    UIView.animate(withDuration: timeDuration) {
                        sView.isHidden = false
                        sView.transform = .identity
//                        self.view.transform = CGAffineTransform(translationX: offset, y: 0)
                    }
                }
                
            }
        }
    }
    
}
