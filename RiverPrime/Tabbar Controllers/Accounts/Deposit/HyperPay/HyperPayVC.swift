//
//  HyperPayVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 05/05/2025.
//

import UIKit
import OPPWAMobile
import ipworks3ds_sdk

class HyperPayVC: BaseViewController {
    
    //    var paymentProvider = OPPPaymentProvider(mode: .test)
    var checkout_ID = String()
    
    var checkoutProvider: OPPCheckoutProvider?
    var paymentProvider: OPPPaymentProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        print("\ncheckout_ID : \(checkout_ID)\\n")
        // Initialize payment provider in .test mode (change to .live in production)
        //        paymentProvider = OPPPaymentProvider(mode: .test)
        //        if let provider = paymentProvider {
        //            checkoutProvider = OPPCheckoutProvider(paymentProvider: provider)
        //        }
    }
    
    private func setupUI() {
        let button = UIButton(type: .system)
        button.setTitle("Pay with HyperPay", for: .normal)
//        button.addTarget(self, action: #selector(startPayment), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
//    @objc private func startPayment() {
//        // 🔁 Replace with actual checkout ID from your backend
//        let checkoutID = "YOUR_CHECKOUT_ID_FROM_BACKEND"
//
//        let settings = OPPCheckoutSettings()
//        settings.paymentBrands = ["VISA", "MASTER", "MADA", "AMEX"] // customize as needed
//
//        // Optional: UI customizations
//        settings.shopperResultURL = "yourappscheme://result"
//
//        guard let checkoutProvider = self.checkoutProvider else {
//            print("❌ Failed to create checkout provider.")
//            return
//        }
//
//        checkoutProvider.presentCheckout(withCheckoutID: checkoutID, settings: settings, presenting: self) { transaction, error in
//            if let error = error {
//                print("❌ Checkout error: \(error.localizedDescription)")
//                return
//            }
//
//            guard let transaction = transaction else {
//                print("❗️No transaction returned.")
//                return
//            }
//
//            switch transaction.type {
//            case .synchronous:
//                print("✅ Synchronous transaction. Verifying...")
//                self.verifyPayment(resourcePath: transaction.resourcePath)
//            case .asynchronous:
//                print("⏳ Asynchronous transaction. Wait for callback.")
//            @unknown default:
//                print("⚠️ Unknown transaction type")
//            }
//        }
//    }
//
//    private func verifyPayment(resourcePath: String?) {
//        guard let resourcePath = resourcePath else {
//            print("❌ No resource path to verify.")
//            return
//        }
//
//        // 🔁 Send `resourcePath` to your backend for verification
//        print("🔁 Send this to backend for payment verification: \(resourcePath)")
//    }
//}
