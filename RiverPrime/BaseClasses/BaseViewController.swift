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
    
    
    
//    //MARK: - New design Alert
//    func alertMessage(title: String, Message: String, image: UIImage? = UIImage(named: "confirmIcon"), completion handler: @escaping() -> Void) {
//        
//        let OK = LanguageController._LanguageController.getLocalizedString(value: LabelTranslation.AlertLabel.OK.rawValue)
//        
//        AlertModel.instance.showConfirmAlertWithImage(withTitle: title, andMessage: Message, on: self, image: image, isRound: true, ActionTitle: OK) { alert in
//            print("Testing OK...")
//            handler()
//        }
//        
//    }
//    
//    
//    
//    //MARK: - New design Alert
//    func alertPopup(title: String, isTitleDefaultColor: Bool? = false, Message: String, image: UIImage? = UIImage(named: "confirmIcon"), isCancel: Bool? = false, ActionTitle: String? = "OK", completion handler: @escaping(UIAlertAction) -> Void) {
//        
//        var OK = ""
//        if ActionTitle == "OK" {
//            OK = LanguageController._LanguageController.getLocalizedString(value: LabelTranslation.AlertLabel.OK.rawValue)
//        } else {
//            OK = ActionTitle ?? LanguageController._LanguageController.getLocalizedString(value: LabelTranslation.AlertLabel.OK.rawValue)
//        }
//        
//        AlertModel.instance.showConfirmAlertWithImage(withTitle: title, andMessage: Message, on: self, image: image, isRound: true, ActionTitle: OK, isCancel: isCancel, isTitleDefaultColor: isTitleDefaultColor) { alert in
//            print("Testing OK...")
//            handler(alert)
//        }
//        
//    }
//    
//    
//    
//    //MARK: - Toast
//    
//    func ToastMessage(_ str: String) {
//        self.navigationController?.view.makeToast(str)
//    }
//    
//    
//    
//    //MARK: - Show Popup view in present view controller
//    func showTimeAlert(str: String) {
//        if var topController = SCENE_DELEGATE.window?.rootViewController {
//            while let presentedViewController = topController.presentedViewController {
//                topController = presentedViewController
//                topController.view.makeToast(str)
//            }
//        }
//    }
//    
//    
//    
//    
//    //MARK: - Navigation
//    
//    func navigation(_ vc: UIViewController, storyboardType: StoryboardType, identifier: BottomSheetIdentifierType) {
//        let VC = UIStoryboard(name: NavigationController.shared.getStoryboard(storyboardType: storyboardType), bundle: nil).instantiateViewController(withIdentifier: NavigationController.shared.getStoryboardIdentifier(identifier: identifier))
//        vc.navigationController?.pushViewController(VC, animated: true)
//    }
    
    
    
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
    
    
    
//    func setBarStyling(animated: Bool, view: UIView, vc: UIViewController, VC: UIViewController, navController: UINavigationController?, title: String? = nil, leftTitle: String? = nil, rightTitle: String? = nil, isHide: Bool? = nil, textColor: UIColor, barColor: UIColor) {
//        
//        NavigationBar.instance.NavBar(view: view, viewController: vc, navController: navController, title: title, leftTitle: leftTitle, rightTitle: rightTitle, isHide: isHide, textColor: textColor, barColor: barColor)
//        VC.navigationController?.setNavigationBarHidden(false, animated: animated)
//        
//    }
//    
//    func setBarStylingForDashboard(animated: Bool, view: UIView, vc: UIViewController, VC: UIViewController, navController: UINavigationController?, title: String? = nil, leftTitle: String? = nil, rightTitle: String? = nil, isHide: Bool? = nil, textColor: UIColor, barColor: UIColor) {
//        
//        NavigationBar.instance.NavBarForDashboard(view: view, viewController: vc, navController: navController, title: title, leftTitle: leftTitle, rightTitle: rightTitle, isHide: isHide, textColor: textColor, barColor: barColor)
//        VC.navigationController?.setNavigationBarHidden(false, animated: animated)
//        
//    }
//    
//    
//    
//    //MARK: - Drop down
//    
//    func configureDropDown(dropDown: DropDown,anchorView: UIView,dataSource: [String]) {
//        
//        dropDown.anchorView = anchorView
//        dropDown.dataSource = dataSource
//        dropDown.direction = .any
//        dropDown.textFont = UIFont(name: APP_MANAGER.fontRubikRegular, size: 16)!
//        dropDown.textColor = .lightGray //.greyTextColor
//    }
    //MARK: -Open URL outside the app
    func openUrl(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
//    //MARK: - Toast Methods
//    func showToast(message : String, yPosition: CGFloat = 100, xPosition: CGFloat = 20) {
//        let window = SCENE_DELEGATE.window! //UIApplication.shared.keyWindow!
//        //        let v = UIView(frame: window.bounds)
//        //        window.addSubview(v);
//        
//        let toastLabel = UILabel(frame: CGRect(x: xPosition, y: self.view.frame.size.height-yPosition, width: self.view.frame.width - 40, height: 40))
//        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//        toastLabel.textColor = UIColor.white
//        toastLabel.font = UIFont.systemFont(ofSize: 12)
//        toastLabel.textAlignment = .center;
//        toastLabel.text = message
//        toastLabel.numberOfLines = 2
//        toastLabel.layer.cornerRadius = 10;
//        toastLabel.clipsToBounds  =  true
//        toastLabel.font = UIFont(name: APP_MANAGER.fontRubikMedium, size: 12)
//        window.addSubview(toastLabel)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            toastLabel.removeFromSuperview()
//        }
//    }
//    
//    //MARK: -CheckBox And Radio Button
//    func configureRadioButton(view: Checkbox) {
//     view.borderStyle = .circle
//     view.checkedBorderColor = .white
//     view.uncheckedBorderColor = .white
//     view.checkmarkColor = .white
//     view.checkmarkStyle = .circle
//     }
//     
//    func configureCheckBoxButton(view: Checkbox, color: UIColor = .white) {
//         view.checkmarkStyle = .tick
//         view.borderCornerRadius = 4
//         view.checkmarkColor = color
//         view.checkedBorderColor = color
//         view.uncheckedBorderColor = color
//         
//     }
    //MARK: -Navigation  Bar
    func setNavigationBarBackButton(shouldShow: Bool) {
        if shouldShow {
            self.setNavigationBackButtonTitleEmpty()
            let backImg = UIImage(named: "back-en")
            self.navigationController?.navigationBar.backIndicatorImage = backImg
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImg
//            self.navigationController?.navigationBar.backItem?.title = ""
            self.navigationController?.navigationBar.tintColor = .white
            //            self.navigationItem.backBarButtonItem?.title = ""
        } else {
            self.navigationController?.navigationBar.topItem?.hidesBackButton = true
            self.setNavigationBackButtonTitleEmpty()
            self.navigationItem.setHidesBackButton(true, animated: false)
        }
    }
    
//    func setNavigationBar(title: String,isTabController: Bool = false) {
//        self.navigationController?.navigationBar.isHidden = false
////        self.title = title
//        
//        if isTabController {
//            self.navigationController?.navigationBar.topItem?.title = title
//        } else {
//            self.title = title
//        }
//        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
//        let navBar = self.navigationController?.navigationBar
//        navBar?.barTintColor = ColorController.Colors.Blue_Color.color //.appThemeColor
//        navBar?.tintColor = .blue//UIColor.buttonColor
//        navBar?.isTranslucent = false
//       
//    }
    
    
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

