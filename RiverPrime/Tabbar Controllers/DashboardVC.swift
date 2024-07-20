//
//  DashboardVC.swift
//  RiverPrime
//
//  Created by abrar ul haq on 16/07/2024.
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
    
    /*
    @IBOutlet weak var DepositButton: UIButton!
    @IBOutlet weak var WithDrawButton: UIButton!
    @IBOutlet weak var HistoryButton: UIButton!
    @IBOutlet weak var DetailButton: UIButton!
    @IBOutlet weak var NotificationButton: UIButton!
    
    @IBOutlet weak var DepositImage: UIImageView!
    @IBOutlet weak var WithDrawImage: UIImageView!
    @IBOutlet weak var HistoryImage: UIImageView!
    @IBOutlet weak var DetailImage: UIImageView!
    @IBOutlet weak var NotificationImage: UIImageView!
    
    @IBOutlet weak var DepositLabel: UILabel!
    @IBOutlet weak var WithDrawLabel: UILabel!
    @IBOutlet weak var HistoryLabel: UILabel!
    @IBOutlet weak var DetailLabel: UILabel!
    @IBOutlet weak var NotificationLabel: UILabel!
    */
    
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
    
    
    var accountsVC = AccountsVC()
    var tradeVC = TradeVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAccountsButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.setNavBar(vc: self, isBackButton: true, isBar: true)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    //MARK: - Set Calendar picker And Time picker frame.
    override func viewDidLayoutSubviews() {
        accountsVC.frame = self.view.bounds
        tradeVC.frame = self.view.bounds
//        bookFragment.frame = self.view.bounds
//        homeAllReservationFragment.frame = self.view.bounds
//        socialDistancePopupView.frame = self.view.bounds //MARK: - For Social distance popup.
    }
    
    @IBAction func AccountsButton(_ sender: UIButton) {
//        let vc = Utilities.shared.getViewController(identifier: .depositViewController, storyboardType: .dashboard) as! DepositViewController
//        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        setAccountsButton()
    }
    
    @IBAction func TradeButton(_ sender: UIButton) {
//        let vc = Utilities.shared.getViewController(identifier: .withdrawViewController, storyboardType: .dashboard) as! WithdrawViewController
//        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        setTradeButton()
    }
    
    @IBAction func MarketsButton(_ sender: UIButton) {
//        let vc = Utilities.shared.getViewController(identifier: .historyViewController, storyboardType: .dashboard) as! HistoryViewController
//        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        setMarketsButton()
    }
    
    @IBAction func ResultsButton(_ sender: UIButton) {
//        let vc = Utilities.shared.getViewController(identifier: .detailsViewController, storyboardType: .dashboard) as! DetailsViewController
//        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        setResultsButton()
    }
    
    @IBAction func ProfileButton(_ sender: UIButton) {
//        let vc = Utilities.shared.getViewController(identifier: .notificationViewController, storyboardType: .dashboard) as! NotificationViewController
//        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        setProfileButton()
    }
    
}

//MARK: - Custom Tab bar handling.
extension DashboardVC {
    
    private func setAccountsButton() {
//        AccountsImage.image = UIImage(named: "account")//?.tint(with: UIColor.black)
//        AccountsLabel.textColor = UIColor.systemYellow
//        AccountsView.backgroundColor = UIColor.black
////        BookImage.image = UIImage(named: "plus-circle")?.tint(with: ColorController.Colors.Black_Color.color)
////        
////        GlobalManager.sharedInstance.selectedDashboardPage = "My Reservations"
////        
////        navBarTitleButton(setTitle: session.dynamicMyReservationLabel ?? "My Reservations")
//        
//        accountsVC.dismissView() //MARK: - Dismiss Home activity.
////        bookFragment.dismissView() //MARK: - Dismiss Book activity.
////        homeAllReservationFragment.dismissView() //MARK: - Dismiss HomeAllReservationFragment activity.
//        accountsVC = AccountsVC.getView()  //MARK: - Relaunch Home activity.
////        accountsVC.delegate = self
//        self.myViewFragment.addSubview(accountsVC)
        
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
    
    private func CustomBarStatus(customTabBarType: CustomTabBarType) {
//        let customTabBarType = CustomTabBarType.Accounts
        switch customTabBarType {
        case .Accounts:
            
            AccountsImage.image = UIImage(named: "account")//?.tint(with: UIColor.black)
            AccountsLabel.textColor = UIColor.systemYellow
            AccountsView.backgroundColor = UIColor.black
            
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
            
    //        BookImage.image = UIImage(named: "plus-circle")?.tint(with: ColorController.Colors.Black_Color.color)
    //
    //        GlobalManager.sharedInstance.selectedDashboardPage = "My Reservations"
    //
    //        navBarTitleButton(setTitle: session.dynamicMyReservationLabel ?? "My Reservations")
            
            accountsVC.dismissView() //MARK: - Dismiss Home activity.
            tradeVC.dismissView() //MARK: - Dismiss Book activity.
    //        homeAllReservationFragment.dismissView() //MARK: - Dismiss HomeAllReservationFragment activity.
            accountsVC = AccountsVC.getView()  //MARK: - Relaunch Home activity.
            accountsVC.delegate = self
            self.myViewFragment.addSubview(accountsVC)
            
            break
        case .Trade:
            
            AccountsImage.image = UIImage(named: "Teamwork")//?.tint(with: UIColor.black)
            AccountsLabel.textColor = UIColor.black
            AccountsView.backgroundColor = UIColor.lightText
            
            TradeImage.image = UIImage(named: "tradeIconSelect")//?.tint(with: UIColor.black)
            TradeLabel.textColor = UIColor.systemYellow
            TradeView.backgroundColor = UIColor.black
            
            MarketsImage.image = UIImage(named: "market")//?.tint(with: UIColor.black)
            MarketsLabel.textColor = UIColor.black
            MarketsView.backgroundColor = UIColor.lightText
            
            ResultsImage.image = UIImage(named: "Growth")//?.tint(with: UIColor.black)
            ResultsLabel.textColor = UIColor.black
            ResultsView.backgroundColor = UIColor.lightText
            
            ProfileImage.image = UIImage(named: "profile")//?.tint(with: UIColor.black)
            ProfileLabel.textColor = UIColor.black
            ProfileView.backgroundColor = UIColor.lightText
            
            accountsVC.dismissView() //MARK: - Dismiss Home activity.
            tradeVC.dismissView() //MARK: - Dismiss Book activity.
            tradeVC = TradeVC.getView()  //MARK: - Relaunch Home activity.
//            tradeVC.delegate = self
            self.myViewFragment.addSubview(tradeVC)
            
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
            MarketsView.backgroundColor = UIColor.black
            
            ResultsImage.image = UIImage(named: "Growth")//?.tint(with: UIColor.black)
            ResultsLabel.textColor = UIColor.black
            ResultsView.backgroundColor = UIColor.lightText
            
            ProfileImage.image = UIImage(named: "profile")//?.tint(with: UIColor.black)
            ProfileLabel.textColor = UIColor.black
            ProfileView.backgroundColor = UIColor.lightText
            
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
            ResultsView.backgroundColor = UIColor.black
            
            ProfileImage.image = UIImage(named: "profile")//?.tint(with: UIColor.black)
            ProfileLabel.textColor = UIColor.black
            ProfileView.backgroundColor = UIColor.lightText
            
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
            ProfileView.backgroundColor = UIColor.black
            
            break
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
