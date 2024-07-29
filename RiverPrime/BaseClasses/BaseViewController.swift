//
//  BaseViewController.swift
//  RiverPrime
//
//  Created by abrar ul haq on 16/07/2024.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLocalisedString()
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
