//
//  BaseViewController.swift
//  RiverPrime
//
//  Created by Ross Rostane on 16/07/2024.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLocalisedString()
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectionLost), name: .connectionLost, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectionRestored), name: .connectionRestored, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleConnectionLost() {
        showNoInternetAlert()
    }
    
    @objc func handleConnectionRestored() {
        print("\n<---***---Internet connection restored!---***--->>>>>>\n")
    }
    
    func showNoInternetAlert() {
        let alert = UIAlertController(title: "No Internet Connection", message: "Please check your network settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    
    //MARK: - localization
    func setLocalisedString() {}
    
    
    
    //MARK: - Hide Back button in the Nav bar.
    func setNavBar(isLogin: Bool? = nil, vc: UIViewController, isBackButton: Bool, isBar: Bool) {
        //        GlobalVariable.instance.barDataShowHide(vc: vc, isBackButton: isBackButton, isBar: isBar)
        if isLogin != nil {
            //            if Session.instance.IsSimpleLogout == true {
            //                GlobalVariable.instance.barDataShowHide(vc: vc, isBackButton: isBackButton, isBar: isBar)
            //            }
            GlobalVariable.instance.barDataShowHide(vc: vc, isBackButton: isLogin ?? false, isBar: isBar)
        } else {
            GlobalVariable.instance.barDataShowHide(vc: vc, isBackButton: isBackButton, isBar: isBar)
        }
    }
    
    
    
    func setBarStylingForDashboard(animated: Bool, view: UIView, vc: UIViewController, VC: UIViewController, navController: UINavigationController?, title: String? = nil, leftTitle: String? = nil, rightTitle: String? = nil/*, isHide: Bool? = nil*/, textColor: UIColor, barColor: UIColor) {
        
        NavigationBar.instance.NavBarForDashboard(view: view, viewController: vc, navController: navController, title: title, leftTitle: leftTitle, rightTitle: rightTitle/*, isHide: isHide*/, textColor: textColor, barColor: barColor)
        VC.navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    
    
    //MARK: -Open URL outside the app
    func openUrl(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    
    
    //MARK: -Navigation  Bar
    func setNavigationBarBackButton(shouldShow: Bool) {
        if shouldShow {
            self.setNavigationBackButtonTitleEmpty()
            let backImg = UIImage(named: "back-en")
            self.navigationController?.navigationBar.backIndicatorImage = backImg
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImg
            self.navigationController?.navigationBar.tintColor = .white
        } else {
            self.navigationController?.navigationBar.topItem?.hidesBackButton = true
            self.setNavigationBackButtonTitleEmpty()
            self.navigationItem.setHidesBackButton(true, animated: false)
        }
    }
    
    
    
    func setNavigationBackButtonTitleEmpty() {
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    
    
    //MARK: - Image from gradient
    func getImageFrom(gradientLayer:CAGradientLayer) -> UIImage? {
        var gradientImage:UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
    
    
    
    //MARK: -small screen devices
    func is_IPHONE_5_OR_LESS () -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            return UIScreen.main.bounds.height <= 568.0
        } else {
            return false
        }
    }
    
}

//MARK: - Alert Methods
extension BaseViewController {
    
    func alertPopup(title: String, isTitleDefaultColor: Bool? = false, Message: String, image: UIImage? = UIImage(named: "AppIcon"), isCancel: Bool? = false, ActionTitle: String? = "OK", completion handler: @escaping(UIAlertAction) -> Void) {
        
        AlertModel.instance.showConfirmAlertWithImage(withTitle: title, andMessage: Message, on: self, image: image, isRound: true, ActionTitle: ActionTitle ?? "OK", isCancel: isCancel, isTitleDefaultColor: isTitleDefaultColor) { alert in
            print("Testing OK...")
            handler(alert)
        }
        
    }
    
}

//MARK: - Toast Methods
extension BaseViewController {
    
    func ToastMessage(_ str: String) {
        self.navigationController?.view.makeToast(str)
    }
    
    //MARK: - Show Popup view in present view controller
    func showTimeAlert(str: String) {
        if var topController = SCENE_DELEGATE.window?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
                topController.view.makeToast(str)
            }
        }
    }
    
}

//MARK: - DropDown Methods
extension BaseViewController {
    
    func dynamicDropDownButton(_ sender: UIButton, list: [String], completion: @escaping ((Int,String)) -> Void) {
        
        CustomDropDown.instance.dropDownButton(list: list, sender: sender) { [weak self] (index: Int, item: String) in
            print("this is the selected index value:\(index)")
            print("this is the selected item name :\(item)")
            //            guard let self = self else { return }
            sender.setTitle(item, for: .normal)
            completion((index,item))
        }
        
    }
    
    func dynamicDropDownButtonForTakeProfit(_ sender: UIButton, list: [String], completion: @escaping ((Int,String)) -> Void) {
        
        CustomDropDown.instance.dropDownButton(list: list, sender: sender) { [weak self] (index: Int, item: String) in
            print("this is the selected index value:\(index)")
            print("this is the selected item name :\(item)")
            //            guard let self = self else { return }
            // Split the selected item into words and get the last word
            let words = item.split(separator: " ")
            if let lastWord = words.last {
                sender.setTitle(String(lastWord), for: .normal) // Set button title to the last word
            }
            //            sender.setTitle(item, for: .normal)
            completion((index,item))
        }
        
    }
}

