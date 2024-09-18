//
//  CreateAccountSelectTradeType.swift
//  RiverPrime
//
//  Created by Ross Rostane on 08/08/2024.
//

import UIKit

struct GetSelectedAccountType {
    var title = String()
    
}

class CreateAccountSelectTradeType: BottomSheetController {

    @IBOutlet weak var bgView: CardView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var lbl_Spread: UILabel!
    @IBOutlet weak var lbl_leverage: UILabel!
    @IBOutlet weak var lbl_commission: UILabel!
    @IBOutlet weak var lbl_miniDeposit: UILabel!
    @IBOutlet weak var lbl_swap: UILabel!
    @IBOutlet weak var lbl_stopOutLevel: UILabel!
    
    
    
    var counter = 0
    var getSelectedAccountType = GetSelectedAccountType()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainTitle.text = "Pro Account" //"Standard Account"
        setSwapGesture()
        counter = 0
        pageControl.currentPage = counter
        
        getIndexValues(counter: counter)
        
    }
    
    @IBAction func continusBtnAction(_ sender: UIButton) {
        let vc = Utilities.shared.getViewController(identifier: .createAccountTypeVC, storyboardType: .bottomSheetPopups) as! CreateAccountTypeVC
//        PresentModalController.instance.presentBottomSheet(self, sizeOfSheet: .medium, VC: vc)
        vc.preferredSheetSizing = .large
        vc.getSelectedAccountType = getSelectedAccountType
        PresentModalController.instance.presentBottomSheet(self, VC: vc)
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
        if gestureRecognizer.direction == .left {
            // Handle left swipe
            print("left")
            if counter < 2 {
                counter += 1
                self.view.inoutAnimation(to: -self.view.frame.width, sView: self.bgView)
            }
            getIndexValues(counter: counter)
        } else if gestureRecognizer.direction == .right {
            // Handle right swipe
            print("right")
            if counter > 0 {
                counter -= 1
                self.view.inoutAnimation(to: self.view.frame.width, sView: self.bgView)
            }
            getIndexValues(counter: counter)
        } else {
            print("Swipe")
        }
        print("counter = \(counter)")
        pageControl.currentPage = counter
    }
    
    private func getIndexValues(counter: Int) {
        
        if counter == 0 {
            mainTitle.text = "Pro Account"
            lbl_Spread.text = "Floating/ As low as 1 pips"
            lbl_leverage.text = "1:400"
            lbl_commission.text = "$0"
            lbl_miniDeposit.text = "$20"
            lbl_swap.text = "Free"
            lbl_stopOutLevel.text = "20%"
            
        } else if counter == 1 {
            mainTitle.text = "Prime Account"
            lbl_Spread.text = "Floating/ As low as 0 pips"
            lbl_leverage.text = "1:400"
            lbl_commission.text = "$6"
            lbl_miniDeposit.text = "$250"
            lbl_swap.text = "Free"
            lbl_stopOutLevel.text = "20%"
        } else if counter == 2 {
            mainTitle.text = "Premium Account"
            lbl_Spread.text = "Floating/ As low as 0 pips"
            lbl_leverage.text = "1:400"
            lbl_commission.text = "$3"
            lbl_miniDeposit.text = "$3000"
            lbl_swap.text = "Free"
            lbl_stopOutLevel.text = "20%"
        }
        
        //MARK: - get selected account values here.
        getSelectedAccountType.title = mainTitle.text ?? ""
        
    }
    
}
