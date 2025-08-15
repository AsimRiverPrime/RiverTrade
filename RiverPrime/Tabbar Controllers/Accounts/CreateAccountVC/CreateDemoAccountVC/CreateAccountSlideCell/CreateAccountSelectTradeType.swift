//
//  CreateAccountSelectTradeType.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/08/2024.
//

import UIKit
import FirebaseFirestore
import Firebase
//struct GetSelectedAccountType {
//    var title = String()
//}

class CreateAccountSelectTradeType: BottomSheetController {

    @IBOutlet weak var bgView: CardView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var img_ProRibbon: UIImageView!
    @IBOutlet weak var lbl_Spread: UILabel!
    @IBOutlet weak var lbl_leverage: UILabel!
    @IBOutlet weak var lbl_commission: UILabel!
    @IBOutlet weak var lbl_miniDeposit: UILabel!
    @IBOutlet weak var lbl_swap: UILabel!
    @IBOutlet weak var lbl_stopOutLevel: UILabel!
        
    
    weak var accountDismisalProtocol: AccountDismisalProtocol?
    weak var newAccoutDelegate : CreateAccountUpdateProtocol?
    weak var dismissDelegate: BottomSheetDismissDelegate?
    
    var realAccountAfterLogin = false
    
    var isRealAccount = Bool()
    var counter = 0
//    var getSelectedAccountType = GetSelectedAccountType()
    let db = Firestore.firestore()
    var accounts: [AccountModel] = []
    var firebaseObj = FirestoreServices()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
//        mainTitle.text = "PRO" //"Standard Account"
        setSwapGesture()
        counter = 0
        pageControl.currentPage = counter
        // Setup swipe gestures
           setSwapGesture()

           // Fetch data and update UI
           fetchAccountsAndSetupPageControl()

        NotificationCenter.default.addObserver(self, selector: #selector(self.dismissScreens), name: NSNotification.Name(rawValue: "dismissCreateAccountScreen"), object: nil)
        
    }
    
    @objc func dismissScreens(){
        self.dismiss(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name("updateSelectedAccountList"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("updateSelectedAccountListForRealAccount"), object: nil)
        self.accountDismisalProtocol?.accountDismisal()
    }
    
    func setupPageControl() {
        // Example page control setup
        pageControl.numberOfPages = self.accounts.count
        pageControl.addTarget(self, action: #selector(pageControlDidChange(_:)), for: .valueChanged)
    }

    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        getIndexValues(counter: currentPage, accounts: self.accounts)
    }
    
    @IBAction func continusBtnAction(_ sender: UIButton) {
//        self.dismiss(animated: true)
        let selectedAccount = accounts
      
//        dismissDelegate?.presentNextBottomSheet(screen: .createAccount, AccountReal: isRealAccount, accounts: selectedAccount, index: counter)

        let vc = Utilities.shared.getViewController(identifier: .createAccountTypeVC, storyboardType: .bottomSheetPopups) as! CreateAccountTypeVC
//        vc.dismissDelegate = self
        vc.account = accounts[counter]
        vc.isReal = isRealAccount
        vc.realAccountAfterLogin = realAccountAfterLogin
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
        
    }
}

extension CreateAccountSelectTradeType: UIGestureRecognizerDelegate {
    
    private func setSwapGesture() {
        // Create left swipe gesture recognizer
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipe.direction = .left
        self.view.addGestureRecognizer(leftSwipe)
        
        // Create right swipe gesture recognizer
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
        
    }
    
    @objc func handleSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        guard !accounts.isEmpty else { return }

        let maxCounter = accounts.count - 1
        var newCounter = counter

        if gestureRecognizer.direction == .left, counter < maxCounter {
            newCounter += 1
            animateTransition(isLeft: true, newCounter: newCounter)
        } else if gestureRecognizer.direction == .right, counter > 0 {
            newCounter -= 1
            animateTransition(isLeft: false, newCounter: newCounter)
        }
    }
    
    private func animateTransition(isLeft: Bool, newCounter: Int) {
        let offset = isLeft ? bgView.frame.width : -bgView.frame.width
        let startFrame = bgView.frame

        // Snapshot current bgView
        UIGraphicsBeginImageContextWithOptions(bgView.bounds.size, false, UIScreen.main.scale)
        bgView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let bgSnapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let bgSnapshot = UIImageView(image: bgSnapshotImage)
        bgSnapshot.frame = startFrame

        // Create newView snapshot for incoming content
        let tempCard = CardView(frame: bgView.frame)
        fillView(tempCard, with: accounts[newCounter])
        UIGraphicsBeginImageContextWithOptions(tempCard.bounds.size, false, UIScreen.main.scale)
        tempCard.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newCardImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let newSnapshot = UIImageView(image: newCardImage)
        newSnapshot.frame = startFrame.offsetBy(dx: offset, dy: 0)

        // Hide original bgView
        bgView.isHidden = true

        // Add snapshots above everything
        if let superV = bgView.superview {
            superV.addSubview(bgSnapshot)
            superV.addSubview(newSnapshot)
        }

        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut], animations: {
            bgSnapshot.frame = startFrame.offsetBy(dx: -offset, dy: 0)
            newSnapshot.frame = startFrame
        }) { _ in
            // Reveal original bgView with new data
            self.fillView(self.bgView, with: self.accounts[newCounter])
            self.bgView.isHidden = false

            // Remove snapshots
            bgSnapshot.removeFromSuperview()
            newSnapshot.removeFromSuperview()

            // Update counter/page
            self.counter = newCounter
            self.pageControl.currentPage = newCounter
        }
    }


    private func fillView(_ targetView: UIView, with account: AccountModel) {
        // Directly set labels/images into the target view
        // Here we use your existing getIndexValues logic
        // but adapted for a given target view if needed.
        mainTitle.text = "\(account.name) Account\nSpecifications"
        lbl_Spread.text = "Floating/ As low as \(account.spreadsFrom)"
        lbl_leverage.text = account.leverage
        lbl_commission.text = "$\(account.commission)"
        lbl_miniDeposit.text = "$\(account.startingDeposit)"
        lbl_swap.text = account.islamicAccounts == 1 ? "Free" : "Not Free"
        lbl_stopOutLevel.text = account.stopOutLevel
        img_ProRibbon.isHidden = account.recommended != 1
    }


    
    func fetchAccountsAndSetupPageControl() {
        firebaseObj.fetchAccountsGroup { [weak self] fetchedAccounts in
            guard let self = self else { return }
            self.accounts = fetchedAccounts

            // Set up the first account group view
            if let firstAccount = self.accounts.first {
                self.getIndexValues(counter: 0, accounts: self.accounts)
            }

            // Setup page control with the number of accounts
            self.setupPageControl()
        }
    }

  
    private func getIndexValues(counter: Int, accounts: [AccountModel]) {
        guard counter >= 0 && counter < accounts.count else { return }

        let account = accounts[counter]

        mainTitle.text = "\(account.name) Account\nSpecifications"
        lbl_Spread.text = "Floating/ As low as \(account.spreadsFrom)"
        lbl_leverage.text = account.leverage
        lbl_commission.text = "$\(account.commission)"
        lbl_miniDeposit.text = "$\(account.startingDeposit)"
        lbl_swap.text = account.islamicAccounts == 1 ? "Free" : "Not Free"
        lbl_stopOutLevel.text = account.stopOutLevel
        img_ProRibbon.isHidden = account.recommended != 1

    }
    
}

struct AccountModel: Codable {
    let id: String
    let tradingInstruments: String
    let spreadsFrom: String
    let startingDeposit: Int
    let order: Int
    let accountCurrency: String
    let EA: Int
    let minimumOrderSize: Double
    let islamicAccounts: Int
    let name: String
    let platform: String
    let stopOutLevel: String
    let orderExecution: String
    let commission: Int
    let recommended: Int
    let hedging: Int
    let leverage: String
   
}
