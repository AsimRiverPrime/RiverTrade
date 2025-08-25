//
//  WalletVC_TVCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 18/08/2025.
//

import UIKit

class WalletVC_TVCell: UITableViewCell {

    @IBOutlet weak var lbl_transcationType: UILabel!
    @IBOutlet weak var lbl_Wallet_balance: UILabel!
    @IBOutlet weak var lbl_date: UILabel!
   
    @IBOutlet weak var lbl_balance: UILabel!
    @IBOutlet weak var lbl_balance_status: UILabel!
    @IBOutlet weak var lbl_ref_status: UILabel!
  
    @IBOutlet weak var image_transctionType: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
}
extension WalletVC_TVCell {
    
    func configure(with record: CombinedTransactionRecord) {
        print("\n--- CONFIGURING CELL ---")
        print("Transaction ID: \(record.transactionId ?? record.recordId ?? 0)")
        print("Transaction Type: '\(record.finalType)'")
        print("Amount: \(record.finalAmount)")
        print("Status: '\(record.finalStatus)'")
        print("Description: '\(record.finalDescription)'")
        
        // Use the combined description
        
        lbl_transcationType.text = record.finalType
        
        // Show balance information
        if let balanceBefore = record.balanceBefore {
            let formattedBalance = String.formatStringNumber("\(balanceBefore)")
            lbl_Wallet_balance.text = "Balance: \(record.finalCurrency)\(formattedBalance)"
        } else {
            lbl_Wallet_balance.text = "Balance: --"
        }
        
        // Use the combined status
        lbl_balance_status.text = record.finalStatus
        
        // Use the final date
        if !record.finalDate.isEmpty {
            lbl_date.text = record.finalDate.formattedDate()
        } else {
            lbl_date.text = "--"
        }
        
        // Enhanced transaction type matching
        let transactionType = record.finalType.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("Processing transaction type: '\(transactionType)'")
        
        // Handle different transaction types
        switch transactionType {
        case "deposit":
            print("→ Configuring as DEPOSIT")
            configureDepositUI(with: record)
            
        case "withdrawal":
            print("→ Configuring as WITHDRAWAL")
            configureWithdrawalUI(with: record)
            
        case "transfer_to_mt", "transfer_to":
            print("→ Configuring as TRANSFER TO MT")
            configureTransferToMTUI(with: record)
            
        case "transfer_from_mt", "transfer_from":
            print("→ Configuring as TRANSFER FROM MT")
            configureTransferFromMTUI(with: record)
            
        default:
            print("→ Configuring as DEFAULT (unrecognized type: '\(transactionType)')")
            configureDefaultUI(with: record)
        }
        
        print("--- END CELL CONFIGURATION ---\n")
    }
    
    // MARK: - UI Configuration Methods
    private func configureDepositUI(with record: CombinedTransactionRecord) {
        image_transctionType.image = UIImage(systemName: "plus")
        image_transctionType.tintColor = .systemGreen
        lbl_balance.textColor = .systemGreen
        lbl_balance_status.textColor = .systemGreen
        
        let amount = record.finalAmount
        let formattedAmount = String.formatStringNumber("\(amount)")
        lbl_balance.text = "$\(formattedAmount)"
    }
    
    private func configureWithdrawalUI(with record: CombinedTransactionRecord) {
        print("🔴 CONFIGURING WITHDRAWAL UI - Amount: \(record.finalAmount)")
        
        image_transctionType.image = UIImage(systemName: "minus")
        image_transctionType.tintColor = .systemRed
        lbl_balance.textColor = .systemRed
        lbl_balance_status.textColor = .systemRed
        
        let amount = record.finalAmount
        let formattedAmount = String.formatStringNumber("\(amount)")
        lbl_balance.text = "-$\(formattedAmount)"
        
        print("🔴 Withdrawal UI configured - Label text: '\(lbl_balance.text ?? "nil")'")
    }
    
    private func configureTransferToMTUI(with record: CombinedTransactionRecord) {
        image_transctionType.image = UIImage(systemName: "arrow.up")
        image_transctionType.tintColor = .systemGreen
        lbl_balance.textColor = .systemGreen
        lbl_balance_status.textColor = .systemGreen
        
        let amount = record.finalAmount
        let formattedAmount = String.formatStringNumber("\(amount)")
        lbl_balance.text = "-$\(formattedAmount)"
    }
    
    private func configureTransferFromMTUI(with record: CombinedTransactionRecord) {
        image_transctionType.image = UIImage(systemName: "arrow.down")
        image_transctionType.tintColor = .systemGreen
        lbl_balance.textColor = .systemGreen
        lbl_balance_status.textColor = .systemGreen
        
        let amount = record.finalAmount
        let formattedAmount = String.formatStringNumber("\(amount)")
        lbl_balance.text = "$\(formattedAmount)"
    }
    
    private func configureDefaultUI(with record: CombinedTransactionRecord) {
        print("⚠️ USING DEFAULT UI - Transaction type not recognized")
        image_transctionType.image = UIImage(systemName: "questionmark")
        image_transctionType.tintColor = .systemGray
        lbl_balance.textColor = .systemGray
        lbl_balance_status.textColor = .systemGray
        
        let amount = record.finalAmount
        let formattedAmount = String.formatStringNumber("\(amount)")
        lbl_balance.text = "$\(formattedAmount)"
    }
}
