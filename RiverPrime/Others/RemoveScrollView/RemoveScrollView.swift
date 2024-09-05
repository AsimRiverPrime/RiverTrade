//
//  RemoveScrollView.swift
//  RiverPrime
//
//  Created by Ross Rostane on 27/07/2024.
//

import Foundation
import TPKeyboardAvoiding

class RemoveScrollView {
    
    static let instance = RemoveScrollView()
    
    func removeScrollView(scrollView: TPKeyboardAvoidingScrollView) -> TPKeyboardAvoidingScrollView {
        let subViews = scrollView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        return scrollView
    }
    
    func removeScrollView(scrollView: UIScrollView) -> UIScrollView {
        let subViews = scrollView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        return scrollView
    }
    
    func removeStackView(stackView: UIStackView) -> UIStackView {
        let subViews = stackView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        return stackView
    }

}
