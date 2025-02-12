//
//  CryptoVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 12/02/2025.
//

import UIKit

class CryptoVC: BaseViewController {

    @IBOutlet weak var img_qr: UIImageView!
    
    @IBOutlet weak var lbl_walletAddress: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_walletAddress.text = "3FZbgi29cpjq2GjdwV8eyHuJJnkLtktZc5"
        let qrImage = generateQRCode(from: self.lbl_walletAddress.text ?? "")
        img_qr.image = qrImage
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Hide Navigation Bar
        
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: DepositViewController(), navController: self.navigationController, title: "Deposit USDT", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
    }
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel") // High error correction level

        guard let qrImage = filter.outputImage else { return nil }

        let transform = CGAffineTransform(scaleX: 10, y: 10) // Scale the image
        let scaledQRImage = qrImage.transformed(by: transform)

        return UIImage(ciImage: scaledQRImage)
    }
    
    @IBAction func copyAddressAction(_ sender: Any) {
        UIPasteboard.general.string = lbl_walletAddress.text // Copy to clipboard
             
             // Show alert
        let alert = UIAlertController(title: "Wallet Address Copied!", message: "You can paste it anywhere.\n\(self.lbl_walletAddress.text ?? "")\n", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
             present(alert, animated: true)
    }
}
