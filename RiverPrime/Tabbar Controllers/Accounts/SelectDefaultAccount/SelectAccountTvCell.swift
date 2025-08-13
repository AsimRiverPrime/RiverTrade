//
//  SelectAccountTvCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 07/08/2025.
//

import UIKit

class SelectAccountTvCell: UITableViewCell {

    @IBOutlet weak var lbl_mtName: UILabel!
    @IBOutlet weak var lbl_account_number: UILabel!
    @IBOutlet weak var lbl_account_type: UILabel!
    @IBOutlet weak var lbl_account_group: UILabel!
    @IBOutlet weak var btn_checkAccount: UIButton!
    
    
    weak var delegate: SelectAccountCellDelegate?
    var accountNumber: Int?
    
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
             
               lbl_account_number.text = "Account: \(accountNumber)"
           }
           if let name = account["name"] as? String {
               lbl_mtName.text = name
           }
        
        if let isReal = account["isReal"] as? Int {
            lbl_account_type.layer.cornerRadius = 5
            lbl_account_type.clipsToBounds = true
            
            if isReal == 0 {
                lbl_account_type.text = "  Demo Account  "
                //lbl_account_type.layer.backgroundColor = UIColor(red: 255/255, green: 38/255, blue: 0/255, alpha: 0.1).cgColor // UIColor.red.withAlphaComponent(0.01).cgColor
                lbl_account_type.textColor = .systemOrange
            } else if isReal == 1 {
                lbl_account_type.text = "  Live Account  "
               // lbl_account_type.layer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.01).cgColor
                lbl_account_type.textColor = .systemGreen
            }
        }
        
           if let groupName = account["groupName"] as? String {
               lbl_account_group.text = "  " + groupName + " Group "
               lbl_account_group.layer.cornerRadius = 5
               lbl_account_group.clipsToBounds = true
           }
        
           updateButtonState()
       }

       private func updateButtonState() {
           
            btn_checkAccount.tintColor = .lightGray
            btn_checkAccount.setImage(UIImage(systemName: "circle"), for: .normal)
           
//           btn_checkAccount.tintColor = isDefault ? .darkGray : .lightGray
//           btn_checkAccount.setImage(UIImage(systemName: isDefault ? "checkmark.circle" : "circle"), for: .normal)
       }

       @IBAction func checkButtonTapped(_ sender: UIButton) {
           guard let accountNumber = accountNumber else { return }
           delegate?.didTapButton(accountNumber: accountNumber)
       }
    
}
