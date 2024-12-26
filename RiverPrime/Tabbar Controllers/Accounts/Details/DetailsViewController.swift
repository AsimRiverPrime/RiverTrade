//
//  DetailsViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var fundsUnderline: UIView!
    @IBOutlet weak var settingsUnderline: UIView!
    @IBOutlet weak var fundsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    //    @IBOutlet weak var detail_tableView: UITableView!
    @IBOutlet weak var mainUIView: UIView!
    
    var fundsView = FundsView()
    var settingsView = SettingsView()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: - START Call balance api
        
        let getbalanceApi = TradeTypeCellVM()
        
        getbalanceApi.getBalance(completion: { response in
            print("response of get balance: \(response)")
            if response == "Invalid Response" {
              
                return
            }
//            self.balance = response
            GlobalVariable.instance.balanceUpdate = response
            //                    NotificationCenter.default.post(name: .BalanceUpdate, object: nil,  userInfo: ["BalanceUpdateType": self.balance])
            NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: response])
                    
        })
        
        //MARK: - END Call balance api
        fundsV()
    }
    
    
    
    override func viewDidLayoutSubviews() {
        fundsView.frame = self.view.bounds
        settingsView.frame = self.view.bounds
    }
    
    @IBAction func fundsButton(_ sender: UIButton) {
        fundsV()
    }
    
    @IBAction func settingsButton(_ sender: UIButton) {
        settingsV()
    }
    
    private func fundsV() {
        fundsButton.tintColor = .systemYellow
        settingsButton.tintColor = .white
        fundsUnderline.backgroundColor = .systemYellow
        settingsUnderline.backgroundColor = .lightGray
        
        settingsView.dismissView()
        fundsView.dismissView()
        fundsView = FundsView.getView()
        self.mainUIView.addSubview(fundsView)
        
    }
    
    private func settingsV() {
        settingsButton.tintColor = .systemYellow
        fundsButton.tintColor = .white
        fundsUnderline.backgroundColor = .lightGray
        settingsUnderline.backgroundColor = .systemYellow
        
        fundsView.dismissView()
        settingsView.dismissView()
        settingsView = SettingsView.getView()
//        settingsView.updateUserNameDelegate = self
        settingsView.changePassDelegate = self
        self.mainUIView.addSubview(settingsView)
        
    }
    
}
extension DetailsViewController: ChangePasswordDelegate {
    func didTapButton() {
        let vc = Utilities.shared.getViewController(identifier: .changeTradePasswordVC, storyboardType: .bottomSheetPopups) as! ChangeTradePasswordVC
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
    }
    
}
