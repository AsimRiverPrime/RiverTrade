//
//  SelectAccountTypeCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 24/12/2024.
//

import UIKit

protocol SelectAccountCellDelegate: AnyObject {
    func didTapButton(accountNumber: Int)
}

class SelectAccountTypeCell: UITableViewCell {

    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_group: UILabel!
    @IBOutlet weak var lbl_loginID: UILabel!
    @IBOutlet weak var lbl_balance: UILabel!
    @IBOutlet weak var btn_checkAccount: UIButton!
    
    weak var delegate: SelectAccountCellDelegate?
    
       var accountNumber: Int?
       var isDefault = Bool()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(account: [String: Any]) {
           if let accountNumber = account["accountNumber"] as? Int {
             
               lbl_loginID.text = " #\(accountNumber)"
           }
           if let name = account["name"] as? String {
               lbl_name.text = name
           }
          
               lbl_balance.text = "$10,000"
           
           if let groupName = account["groupName"] as? String {
               lbl_group.text = groupName
           }
        
        if let isDefault = account["isDefault"] as? Bool {
               if !isDefault  {
                   self.isDefault = false
               }else{
                   self.isDefault = true
               }
           }
           updateButtonState()
       }

       private func updateButtonState() {
          
           if isDefault {
               btn_checkAccount.tintColor = .systemYellow
               btn_checkAccount.isHidden = false
           }else{
               btn_checkAccount.isHidden = true
           }
       }

       @IBAction func checkButtonTapped(_ sender: UIButton) {
           guard let accountNumber = accountNumber else { return }
           delegate?.didTapButton(accountNumber: accountNumber)
       }
}
