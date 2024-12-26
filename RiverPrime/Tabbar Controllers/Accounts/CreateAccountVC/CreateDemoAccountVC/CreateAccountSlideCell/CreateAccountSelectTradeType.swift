//
//  CreateAccountSelectTradeType.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/08/2024.
//

import UIKit
import FirebaseFirestore

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
        
    var isRealAccount: Bool?
    var counter = 0
//    var getSelectedAccountType = GetSelectedAccountType()
    let db = Firestore.firestore()
    var accounts: [AccountModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        mainTitle.text = "PRO" //"Standard Account"
        setSwapGesture()
        counter = 0
        pageControl.currentPage = counter
        // Setup swipe gestures
           setSwapGesture()

           // Fetch data and update UI
           fetchAccountsAndSetupPageControl()

        
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
        let vc = Utilities.shared.getViewController(identifier: .createAccountTypeVC, storyboardType: .bottomSheetPopups) as! CreateAccountTypeVC
//        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
        let selectedAccount = accounts[counter]
//        vc.preferredSheetSizing = .large
//        vc.getSelectedAccountType = getSelectedAccountType
        vc.account = selectedAccount
        vc.isReal = isRealAccount ?? false
//        PresentModalController.instance.presentBottomSheet(self, VC: vc)
        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .large, VC: vc)
//        self.dismiss(animated: true, completion: {
//            print("Bottom sheet dismissed after Move to next screen")
//        })
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
        guard !accounts.isEmpty else {
            print("No accounts available.")
            return
        }

        let maxCounter = accounts.count - 1

        if gestureRecognizer.direction == .left {
            print("left")
            if counter < maxCounter {
                counter += 1
                self.view.inoutAnimation(to: -self.view.frame.width, sView: self.bgView)
                getIndexValues(counter: counter, accounts: self.accounts)
            }
        } else if gestureRecognizer.direction == .right {
            print("right")
            if counter > 0 {
                counter -= 1
                self.view.inoutAnimation(to: self.view.frame.width, sView: self.bgView)
                getIndexValues(counter: counter, accounts: self.accounts)
            }
        } else {
            print("Unhandled swipe direction")
        }

        print("Counter = \(counter)")
        pageControl.currentPage = counter
    }

    
    func fetchAccountsAndSetupPageControl() {
        fetchAccounts { [weak self] fetchedAccounts in
            guard let self = self else { return }
            self.accounts = fetchedAccounts

            // Set up the first account view
            if let firstAccount = self.accounts.first {
                self.getIndexValues(counter: 0, accounts: self.accounts)
            }

            // Setup page control with the number of accounts
            self.setupPageControl()
        }
    }

    func fetchAccounts(completion: @escaping ([AccountModel]) -> Void) {
        db.collection("accountsGroup").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion([])
                return
            }

            for document in querySnapshot!.documents {
                let data = document.data()
                if let account = try? AccountModel(
                    id: document.documentID,
                    tradingInstruments: data["tradingInstruments"] as? String ?? "",
                    spreadsFrom: data["spreadsFrom"] as? String ?? "",
                    startingDeposit: data["startingDeposit"] as? Int ?? 0,
                    order: data["order"] as? Int ?? 0,
                    accountCurrency: data["accountCurrency"] as? String ?? "",
                    EA: data["EA"] as? Int ?? 0,
                    minimumOrderSize: data["minimumOrderSize"] as? Double ?? 0.0,
                    islamicAccounts: data["islamicAccounts"] as? Int ?? 0,
                    name: data["name"] as? String ?? "",
                    platform: data["platform"] as? String ?? "",
                    stopOutLevel: data["stopOutLevel"] as? String ?? "",
                    orderExecution: data["orderExecution"] as? String ?? "",
                    commission: data["commission"] as? Int ?? 0,
                    recommended: data["recommended"] as? Int ?? 0,
                    hedging: data["hedging"] as? Int ?? 0,
                    leverage: data["leverage"] as? String ?? ""
                ) {
                    self.accounts.append(account)
                }
            }
            print("accountGroup data:\(self.accounts)")
            completion(self.accounts)
        }
    }
    private func getIndexValues(counter: Int, accounts: [AccountModel]) {
        guard counter >= 0 && counter < accounts.count else { return }

        let account = accounts[counter]

        mainTitle.text = "\(account.name.uppercased()) Account"
        lbl_Spread.text = "Floating/ As low as \(account.spreadsFrom)"
        lbl_leverage.text = account.leverage
        lbl_commission.text = "$\(account.commission)"
        lbl_miniDeposit.text = "$\(account.startingDeposit)"
        lbl_swap.text = account.islamicAccounts == 1 ? "Free" : "Not Free"
        lbl_stopOutLevel.text = account.stopOutLevel
        img_ProRibbon.isHidden = account.recommended != 1

        // Update selected account type
//        getSelectedAccountType.title = mainTitle.text ?? ""
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
