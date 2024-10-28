//
//  FundsView.swift
//  RiverPrime
//
//  Created by abrar ul haq on 25/10/2024.
//

import UIKit

class FundsView: UIView {
    
    @IBOutlet weak var lbl_balance: UILabel!
    @IBOutlet weak var lbl_equity: UILabel!
    @IBOutlet weak var lbl_totalPL: UILabel!
    @IBOutlet weak var lbl_Margin: UILabel!
    @IBOutlet weak var lbl_freeMargin: UILabel!
    @IBOutlet weak var lbl_marginLevel: UILabel!
    @IBOutlet weak var lbl_leverage: UILabel!
    
    
    
    public override func awakeFromNib() {
        
    }
    
    class func getView()->FundsView {
        return Bundle.main.loadNibNamed("FundsView", owner: self, options: nil)?.first as! FundsView
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
