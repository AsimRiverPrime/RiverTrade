//
//  ActivityIndicator.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import Foundation
import UIKit

class ActivityIndicator {
    static let shared = ActivityIndicator()
    
    private var activityIndicator: UIActivityIndicatorView!
    
    private init() {
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
    }
    
    func show(in view: UIView, style: UIActivityIndicatorView.Style = .medium, color: UIColor = .gray) {
        activityIndicator.style = style
        activityIndicator.color = color
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false // Disable user interaction while loading
    }
    
    func hide(from view: UIView) {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        view.isUserInteractionEnabled = true // Enable user interaction after loading
    }
}
