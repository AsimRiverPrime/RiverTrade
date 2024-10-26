//
//  SettingsView.swift
//  RiverPrime
//
//  Created by abrar ul haq on 26/10/2024.
//

import UIKit

class SettingsView: UIView {
    
    public override func awakeFromNib() {
        
    }
    
    class func getView()->SettingsView {
        return Bundle.main.loadNibNamed("SettingsView", owner: self, options: nil)?.first as! SettingsView
    }
    
    func dismissView() {
        UIView.animate(
            withDuration: 0.4,
            delay: 0.04,
            animations: {
                self.alpha = 0
            }, completion: { (complete) in
                self.removeFromSuperview()
            })
    }
    
}
