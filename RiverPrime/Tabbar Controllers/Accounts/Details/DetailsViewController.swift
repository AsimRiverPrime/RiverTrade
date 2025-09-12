//
//  DetailsViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import UIKit

class DetailsViewController: BaseViewController {

    @IBOutlet weak var fundsUnderline: UIView!
    @IBOutlet weak var settingsUnderline: UIView!
    @IBOutlet weak var fundsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    //    @IBOutlet weak var detail_tableView: UITableView!
    @IBOutlet weak var mainUIView: UIView!
    
    var fundsView = FundsView()
    var settingsView = SettingsView()
    let getbalanceApi = TradeTypeCellVM()
    var odooClientUpdateUserName  = OdooClientNew()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: - START Call balance api
        odooClientUpdateUserName.updateUserNamePasswordDelegate = self
        getbalanceApi.getUserBalance(completion: { response in
            print("get response of user balance from detailVC: \(response)")
            switch response{
        case .success(let responseModel):
    
            UserManager.shared.currentUser = responseModel.result.user
            
            GlobalVariable.instance.balanceUpdate = "\(responseModel.result.user.balance)"
         
            print("GlobalVariable.instance.balanceUpdate = \(GlobalVariable.instance.balanceUpdate)")
            NotificationObserver.shared.postNotificationObserver(key: NotificationObserver.Constants.BalanceUpdateConstant.key, dict: [NotificationObserver.Constants.BalanceUpdateConstant.title: GlobalVariable.instance.balanceUpdate])
         
            case .failure(let error):
                print("Failed to fetch balance: \(error.localizedDescription)")
            }
        })
 
        //MARK: - END Call balance api
        fundsV()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNavBar(vc: self, isBackButton: false, isBar: false)
        self.setBarStylingForDashboard(animated: animated, view: self.view, vc: self, VC: AccountsViewController(), navController: self.navigationController, title: "Details", leftTitle: "", rightTitle: "", textColor: .white, barColor: .black)
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
        settingsView.odooClientService = odooClientUpdateUserName
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

extension DetailsViewController: UpdateUserNamePassword {
    func updateSuccess(response: Any) {
        print("update MT User Name sucess response: \(response) ")
        if let dict = response as? [String: Any],
           let result = dict["result"] as? [String: Any],
           let success = result["success"] as? Int {
            
            if success == 1 {
                // ✅ Show success toast
                self.ToastMessage("MT UserName updated successfully")
             }else{
                 self.ToastMessage("MT UserName updated Failed, please try again later.")
            }
        }
    }
    
    func updateFailure(error: any Error) {
        print("update MT User Name failed response: \(error) ")
    }
    
}
