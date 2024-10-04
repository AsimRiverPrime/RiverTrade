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
    
    func showCell(in cell: UITableViewCell, style: UIActivityIndicatorView.Style = .medium, color: UIColor = .gray) {
        activityIndicator.style = style
        activityIndicator.color = color
        activityIndicator.center = cell.center
        cell.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        cell.isUserInteractionEnabled = false // Disable user interaction while loading
    }
    
    func hideCell(from cell: UITableViewCell) {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        cell.isUserInteractionEnabled = true // Enable user interaction after loading
    }
}

class NewActivityIndicator {
    
    private var spinner: UIActivityIndicatorView
    private var overlayView: UIView
    
    init() {
        spinner = UIActivityIndicatorView(style: .large) // Use .medium for cell size
        overlayView = UIView(frame: CGRect.zero)
        overlayView.backgroundColor = .clear //UIColor(white: 0, alpha: 0.5)
        overlayView.isHidden = true
    }
    
    func show(in view: UIView) {
        overlayView.frame = view.bounds
        overlayView.isHidden = false
        spinner.center = overlayView.center
        overlayView.addSubview(spinner)
        view.addSubview(overlayView)
        spinner.startAnimating()
    }
    
    func hide() {
        spinner.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
