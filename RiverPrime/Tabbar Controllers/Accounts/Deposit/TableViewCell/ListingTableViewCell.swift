//
//  ListingTableViewCell.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit

class ListingTableViewCell: UITableViewCell {

    @IBOutlet weak var icon_bank: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
        @IBOutlet weak var lblprocess: UILabel!
        @IBOutlet weak var lblFee: UILabel!
        @IBOutlet weak var lblLimits: UILabel!
        @IBOutlet weak var lockBtn: UIButton!
    
    
        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)

            // Configure the view for the selected state
        }
    @IBAction func btn_availableAction(_ sender: Any) {
        print("btn click")
    
//        let netellerService = NetellerService(environment: .test, keyUsername: "pmle-441874", keyPassword: "B-p1-0-6679395c-0-302d02150085f00a398fb3afdfe5752df077cbbf36811a67ea02147810894c197da443cf74ce3dff6c5bee49bec2d6")
//
//        netellerService.initiatePayment(amount: 10.0, currency: "USD", merchantRefId: "261674847") { result in
//            switch result {
//            case .success(let redirectUrl):
//                print("Redirect to: \(redirectUrl)")
//            case .failure(let error):
//                print("Error: \(error)")
//            }
//        }
    }
  
    }
