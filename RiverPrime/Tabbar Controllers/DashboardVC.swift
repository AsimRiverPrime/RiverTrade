//
//  DashboardVC.swift
//  RiverPrime
//
//  Created by Ross Rostane on 16/07/2024.
//

import UIKit

enum CustomTabBarType {
    case Accounts
    case Trade
    case Markets
    case Results
    case Profile
}

class DashboardVC: BaseViewController {

    @IBOutlet weak var myViewFragment: UIView!
    @IBOutlet weak var myCustomTabbarView: UIView!
    
    @IBOutlet weak var AccountsButton: UIButton!
    @IBOutlet weak var TradeButton: UIButton!
    @IBOutlet weak var MarketsButton: UIButton!
    @IBOutlet weak var ResultsButton: UIButton!
    @IBOutlet weak var ProfileButton: UIButton!
    
    @IBOutlet weak var AccountsImage: UIImageView!
    @IBOutlet weak var TradeImage: UIImageView!
    @IBOutlet weak var MarketsImage: UIImageView!
    @IBOutlet weak var ResultsImage: UIImageView!
    @IBOutlet weak var ProfileImage: UIImageView!
    
    @IBOutlet weak var AccountsLabel: UILabel!
    @IBOutlet weak var TradeLabel: UILabel!
    @IBOutlet weak var MarketsLabel: UILabel!
    @IBOutlet weak var ResultsLabel: UILabel!
    @IBOutlet weak var ProfileLabel: UILabel!
    
    @IBOutlet weak var AccountsView: CardView!
    @IBOutlet weak var TradeView: CardView!
    @IBOutlet weak var MarketsView: CardView!
    @IBOutlet weak var ResultsView: CardView!
    @IBOutlet weak var ProfileView: CardView!
    
    var createAccountVC = CreateAccountVC()
    var accountsVC = AccountsVC()
    var tradeVC = TradeVC()
    var marketsVC = MarketsVC()
    var resultVC = ResultVC()
    var profileVC = ProfileVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAccountsButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.setNavBar(vc: self, isBackButton: true, isBar: true)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.setNavBar(vc: self, isBackButton: true, isBar: true)
    }
    
    override func viewDidLayoutSubviews() {
        createAccountVC.frame = self.view.bounds
        accountsVC.frame = self.view.bounds
        tradeVC.frame = self.view.bounds
        marketsVC.frame = self.view.bounds
        resultVC.frame = self.view.bounds
        profileVC.frame = self.view.bounds
//        bookFragment.frame = self.view.bounds
//        homeAllReservationFragment.frame = self.view.bounds
//        socialDistancePopupView.frame = self.view.bounds //MARK: - For Social distance popup.
    }
    
    @IBAction func AccountsButton(_ sender: UIButton) {
      
        setAccountsButton()
    }
    
    @IBAction func TradeButton(_ sender: UIButton) {
       
        setTradeButton()
    }
    
    @IBAction func MarketsButton(_ sender: UIButton) {
       
        setMarketsButton()
    }
    
    @IBAction func ResultsButton(_ sender: UIButton) {
        setResultsButton()
    }
    
    @IBAction func ProfileButton(_ sender: UIButton) {
        setProfileButton()
    }
    
}

//MARK: - Custom Tab bar handling.
extension DashboardVC {
    
    private func setAccountsButton() {

        CustomBarStatus(customTabBarType: .Accounts)
    }
    
    private func setTradeButton() {
        CustomBarStatus(customTabBarType: .Trade)
    }
    
    private func setMarketsButton() {
        CustomBarStatus(customTabBarType: .Markets)
    }
    
    private func setResultsButton() {
        CustomBarStatus(customTabBarType: .Results)
    }
    
    private func setProfileButton() {
        CustomBarStatus(customTabBarType: .Profile)
    }
    
    //MARK: - Custom tabbarView changing.
    private func CustomBarStatus(customTabBarType: CustomTabBarType) {
//        let customTabBarType = CustomTabBarType.Accounts
        switch customTabBarType {
        case .Accounts:
            
            AccountsImage.image = UIImage(named: "account")//?.tint(with: UIColor.black)
            AccountsLabel.textColor = UIColor.systemYellow
            AccountsView.backgroundColor = UIColor.splashScreen
            
            TradeImage.image = UIImage(named: "trade")//?.tint(with: UIColor.black)
            TradeLabel.textColor = UIColor.black
            TradeView.backgroundColor = UIColor.lightText
            
            MarketsImage.image = UIImage(named: "market")//?.tint(with: UIColor.black)
            MarketsLabel.textColor = UIColor.black
            MarketsView.backgroundColor = UIColor.lightText
            
            ResultsImage.image = UIImage(named: "Growth")//?.tint(with: UIColor.black)
            ResultsLabel.textColor = UIColor.black
            ResultsView.backgroundColor = UIColor.lightText
            
            ProfileImage.image = UIImage(named: "profile")//?.tint(with: UIColor.black)
            ProfileLabel.textColor = UIColor.black
            ProfileView.backgroundColor = UIColor.lightText
            
            
            dismissViews()
            accountsVC = AccountsVC.getView()
            accountsVC.delegate = self
            accountsVC.delegateCreateAccount = self
            addView(customTabBarType: .Accounts)
            
            
            /*if GlobalVariable.instance.isAccountCreated { //MARK: - if account is already created.
                accountsVC = AccountsVC.getView()
                accountsVC.delegate = self
                addView(customTabBarType: .Accounts)
            } else { //MARK: - if no account exist.
                createAccountVC = CreateAccountVC.getView()
                createAccountVC.delegate = self
                self.myViewFragment.addSubview(createAccountVC)
            }*/
            
            
            break
        case .Trade:
            
            AccountsImage.image = UIImage(named: "Teamwork")//?.tint(with: UIColor.black)
            AccountsLabel.textColor = UIColor.black
            AccountsView.backgroundColor = UIColor.lightText
            
            TradeImage.image = UIImage(named: "tradeIconSelect")//?.tint(with: UIColor.black)
            TradeLabel.textColor = UIColor.systemYellow
            TradeView.backgroundColor = UIColor.splashScreen
            
            MarketsImage.image = UIImage(named: "market")//?.tint(with: UIColor.black)
            MarketsLabel.textColor = UIColor.black
            MarketsView.backgroundColor = UIColor.lightText
            
            ResultsImage.image = UIImage(named: "Growth")//?.tint(with: UIColor.black)
            ResultsLabel.textColor = UIColor.black
            ResultsView.backgroundColor = UIColor.lightText
            
            ProfileImage.image = UIImage(named: "profile")//?.tint(with: UIColor.black)
            ProfileLabel.textColor = UIColor.black
            ProfileView.backgroundColor = UIColor.lightText
            
            dismissViews()
            tradeVC = TradeVC.getView()
//            tradeVC.delegate = self
            tradeVC.delegateDetail = self
            addView(customTabBarType: .Trade)
            
            break
        case .Markets:
            
            AccountsImage.image = UIImage(named: "Teamwork")//?.tint(with: UIColor.black)
            AccountsLabel.textColor = UIColor.black
            AccountsView.backgroundColor = UIColor.lightText
            
            TradeImage.image = UIImage(named: "trade")//?.tint(with: UIColor.black)
            TradeLabel.textColor = UIColor.black
            TradeView.backgroundColor = UIColor.lightText
            
            MarketsImage.image = UIImage(named: "marketIconSelect")//?.tint(with: UIColor.black)
            MarketsLabel.textColor = UIColor.systemYellow
            MarketsView.backgroundColor = UIColor.splashScreen
            
            ResultsImage.image = UIImage(named: "Growth")//?.tint(with: UIColor.black)
            ResultsLabel.textColor = UIColor.black
            ResultsView.backgroundColor = UIColor.lightText
            
            ProfileImage.image = UIImage(named: "profile")//?.tint(with: UIColor.black)
            ProfileLabel.textColor = UIColor.black
            ProfileView.backgroundColor = UIColor.lightText
            
            dismissViews()
            marketsVC = MarketsVC.getView()
//            tradeVC.delegate = self
            addView(customTabBarType: .Markets)
            
            break
        case .Results:
            
            AccountsImage.image = UIImage(named: "Teamwork")//?.tint(with: UIColor.black)
            AccountsLabel.textColor = UIColor.black
            AccountsView.backgroundColor = UIColor.lightText
            
            TradeImage.image = UIImage(named: "trade")//?.tint(with: UIColor.black)
            TradeLabel.textColor = UIColor.black
            TradeView.backgroundColor = UIColor.lightText
            
            MarketsImage.image = UIImage(named: "market")//?.tint(with: UIColor.black)
            MarketsLabel.textColor = UIColor.black
            MarketsView.backgroundColor = UIColor.lightText
            
            ResultsImage.image = UIImage(named: "resultIconSelect")//?.tint(with: UIColor.black)
            ResultsLabel.textColor = UIColor.systemYellow
            ResultsView.backgroundColor = UIColor.splashScreen
            
            ProfileImage.image = UIImage(named: "profile")//?.tint(with: UIColor.black)
            ProfileLabel.textColor = UIColor.black
            ProfileView.backgroundColor = UIColor.lightText
            
            dismissViews()
            resultVC = ResultVC.getView()
            resultVC.delegate = self
//            tradeVC.delegate = self
            addView(customTabBarType: .Results)
            
            break
        case .Profile:
            
            AccountsImage.image = UIImage(named: "Teamwork")//?.tint(with: UIColor.black)
            AccountsLabel.textColor = UIColor.black
            AccountsView.backgroundColor = UIColor.lightText
            
            TradeImage.image = UIImage(named: "trade")//?.tint(with: UIColor.black)
            TradeLabel.textColor = UIColor.black
            TradeView.backgroundColor = UIColor.lightText
            
            MarketsImage.image = UIImage(named: "market")//?.tint(with: UIColor.black)
            MarketsLabel.textColor = UIColor.black
            MarketsView.backgroundColor = UIColor.lightText
            
            ResultsImage.image = UIImage(named: "Growth")//?.tint(with: UIColor.black)
            ResultsLabel.textColor = UIColor.black
            ResultsView.backgroundColor = UIColor.lightText
            
            ProfileImage.image = UIImage(named: "profileIconSelect")//?.tint(with: UIColor.black)
            ProfileLabel.textColor = UIColor.systemYellow
            ProfileView.backgroundColor = UIColor.splashScreen
            
            dismissViews()
            profileVC = ProfileVC.getView()
////            tradeVC.delegate = self
            addView(customTabBarType: .Profile)
            
            break
        }
    }
    
    private func dismissViews() {
        createAccountVC.dismissView()
        accountsVC.dismissView()
        tradeVC.dismissView()
        marketsVC.dismissView()
        resultVC.dismissView()
        profileVC.dismissView()
    }
    
    private func addView(customTabBarType: CustomTabBarType) {
        switch customTabBarType {
            
        case .Accounts:
            self.myViewFragment.addSubview(accountsVC)
        case .Trade:
            self.myViewFragment.addSubview(tradeVC)
        case .Markets:
            self.myViewFragment.addSubview(marketsVC)
        case .Results:
            self.myViewFragment.addSubview(resultVC)
        case .Profile:
            self.myViewFragment.addSubview(profileVC)
            
        }
    }
    
}

//MARK: - AccountInfo Button Taps is here.
extension DashboardVC: AccountInfoTapDelegate {
    func accountInfoTap(_ accountInfo: AccountInfo) {
        print("delegte called  \(accountInfo)" )
        
        switch accountInfo {
       
        case .deposit:
            let vc = Utilities.shared.getViewController(identifier: .depositViewController, storyboardType: .dashboard) as! DepositViewController
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .withDraw:
            let vc = Utilities.shared.getViewController(identifier: .withdrawViewController, storyboardType: .dashboard) as! WithdrawViewController
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .history:
            let vc = Utilities.shared.getViewController(identifier: .historyViewController, storyboardType: .dashboard) as! HistoryViewController
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .detail:
            let vc = Utilities.shared.getViewController(identifier: .detailsViewController, storyboardType: .dashboard) as! DetailsViewController
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .notification:
            let vc = Utilities.shared.getViewController(identifier: .notificationViewController, storyboardType: .dashboard) as! NotificationViewController
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        case .createAccount:
            let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .dashboard) as! SelectAccountTypeVC
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
            break
        }

        
    }
    
    
}

extension DashboardVC: CreateAccountInfoTapDelegate {
    
    func createAccountInfoTap(_ createAccountInfo: CreateAccountInfo) {
        print("delegte called  \(createAccountInfo)" )
        
        switch createAccountInfo {
        case .createNew:
            print("Create new")
            let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .dashboard) as! SelectAccountTypeVC
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
//            let vc = Utilities.shared.getViewController(identifier: .createAccountSelectTradeType, storyboardType: .dashboard) as! CreateAccountSelectTradeType
//            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
            
            break
        case .unarchive:
            print("Unarchive")
            let vc = Utilities.shared.getViewController(identifier: .unarchiveAccountTypeVC, storyboardType: .dashboard) as! UnarchiveAccountTypeVC
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
            break
        case .notification:
            let vc = Utilities.shared.getViewController(identifier: .notificationViewController, storyboardType: .dashboard) as! NotificationViewController
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
            break
        }
    }
    
}

//MARK: - TradeVC cell Taps is handle here.
extension DashboardVC: TradeDetailTapDelegate {
    
    func tradeDetailTap(indexPath: IndexPath) {
        
        let vc = Utilities.shared.getViewController(identifier: .tradeDetalVC, storyboardType: .dashboard) as! TradeDetalVC
       
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)

    }
    
}

extension DashboardVC: iResultVCDelegate {
    
    func resultClicks(resultVCType: iResultVCType) {
        switch resultVCType {
        case .SummaryAllRealAccountFilter:
            let vc = Utilities.shared.getViewController(identifier: .allRealAccountsVC, storyboardType: .bottomSheetPopups) as! AllRealAccountsVC
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
            break
        case .DaysFilter:
            break
        case .BenifitAllRealAccountFilter:
            break
        case .ExnessStartTrading:
            let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .dashboard) as! SelectAccountTypeVC
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
            break
        case .ExnessTrading:
            let vc = Utilities.shared.getViewController(identifier: .selectAccountTypeVC, storyboardType: .dashboard) as! SelectAccountTypeVC
            PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
            break
        }
    }
    
}

////MARK: - TradeInfo Collection Taps is here.
//extension DashboardVC: TradeInfoTapDelegate {
//    
//    func tradeInfoTap(_ tradeInfo: TradeInfo) {
//        
//    }
//    
//}
