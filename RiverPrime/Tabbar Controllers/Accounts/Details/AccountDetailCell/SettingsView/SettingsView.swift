//
//  SettingsView.swift
//  RiverPrime
//
//  Created by abrar ul haq on 26/10/2024.
//

import UIKit

class SettingsView: UIView {
    
    @IBOutlet weak var lbl_accountType: UILabel!
    @IBOutlet weak var lbl_serverType: UILabel!
    @IBOutlet weak var lbl_accountGroup: UILabel!
    
    @IBOutlet weak var lbl_accountNumber: UILabel!
    @IBOutlet weak var lbl_acctUserName: UILabel!
    
    @IBOutlet weak var lbl_commission: UILabel!
    
    @IBOutlet weak var lbl_minimiumSpread: UILabel!
    @IBOutlet weak var lbl_maximumLeverage: UILabel!
    
    @IBOutlet weak var lbl_loginID: UILabel!
    @IBOutlet weak var lbl_serverName: UILabel!
    
    
    
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
    
    @IBAction func copyLoginID_action(_ sender: Any) {
        
    }
    
    @IBAction func changePassword_action(_ sender: Any) {
        
    }
    
    
}
