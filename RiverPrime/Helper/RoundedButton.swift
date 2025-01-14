//
//  RoundedButton.swift
//  RiverPrime
//
//  Created by Ross Rostane on 24/10/2024.
//

import UIKit

class RoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create a path with rounded bottom corners
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: [.bottomLeft, .bottomRight],
                                cornerRadii: CGSize(width: 15, height: 15)) // Adjust the radius as needed
        
        // Create a mask layer
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
