//
//  AlertModel.swift
//  DeskflexProject
//
//  Created by Ross Rostane on 03/07/2023.
//

import Foundation
import UIKit

class AlertModel {
    
    static let instance = AlertModel()
        
    var AC: UIAlertController!
    
    //============ Alerts ============
    static var _AC: UIAlertController!
    
    public static func showUserInfoAlert(withMessage Message: String?, andTitle Title: String?, on vc: UIViewController?, andCompletionHandler parentAction: @escaping (UIAlertAction) -> Void, andCompletionHandler siblingAction: @escaping (UIAlertAction) -> Void, andCompletionHandler friendsAction: @escaping (UIAlertAction) -> Void) {
        
        _AC = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        let parentAction = UIAlertAction(title: "Parents", style: .default, handler: parentAction)
        let siblingAction = UIAlertAction(title: "Siblings", style: .default, handler: siblingAction)
        let friendsAction = UIAlertAction(title: "Friends", style: .default, handler: friendsAction)

        _AC.addAction(parentAction)
        _AC.addAction(siblingAction)
        _AC.addAction(friendsAction)
        vc?.present(_AC, animated: true)
        
    }
    
    private func isImage(image: UIImage? = nil) -> Bool {
        var isImage = Bool()
        if image == nil {
            isImage = false
        } else {
            isImage = true
        }
        return isImage
    }
    
    func showConfirmAlertWithImage(withTitle Title: String? = nil, andMessage Message: String? = nil, attributedMessage: NSMutableAttributedString? = nil, on vc: UIViewController?, image : UIImage? = nil, isRound: Bool, ActionTitle: String, isCancel: Bool? = false, isTitleDefaultColor: Bool? = false, urlImage: String? = "", andCompletionHandler action: @escaping (UIAlertAction) -> Void) {
        
        AC = UIAlertController(style: .alert)
        
        AC.setBackgroundColor(color: UIColor.white)
             
        AC.setLoginViewController(image: image ?? UIImage(), title: Title ?? "", message: Message ?? "", attributedMessage: attributedMessage, isRound: isRound, isImage: isImage(image: image), isTitleDefaultColor: isTitleDefaultColor, urlImage: urlImage ?? "")
        
        let _ActionTitle = ActionTitle
        
        let IUnderstand = UIAlertAction(title: _ActionTitle, style: .default, handler: action)
        IUnderstand.setValue(UIColor.black, forKey: "titleTextColor")
        AC.addAction(IUnderstand)
        
        if isCancel ?? false {
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            })
            cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
            AC.addAction(cancelAction)
            
        }
        
        vc?.present(AC, animated: true)
        
    }
    
    // added a new function for attributedString
        func attributedString(_ text: String, _ fontSize: CGFloat, _ color: UIColor) -> NSAttributedString {
            let attributedString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: fontSize), NSAttributedString.Key.foregroundColor: color])
            return attributedString
        }
    
    func showLoginAlertWithImage(withTitle Title: String? = nil, andMessage Message: String? = nil, on vc: UIViewController?, image : UIImage? = nil, isRound: Bool, andCompletionHandler action: @escaping (UIAlertAction) -> Void) {
        
        AC = UIAlertController(style: .alert)
        
        AC.setBackgroundColor(color: UIColor.lightGray)
             
        AC.setLoginViewController(image: image ?? UIImage(), title: Title ?? "", message: Message ?? "", isRound: isRound, isImage: isImage(image: image))
        let IUnderstand = UIAlertAction(title: "OK", style: .default) { action in
            print("its okay")
        }
        IUnderstand.setValue(UIColor.green, forKey: "titleTextColor")
        AC.addAction(IUnderstand)
        vc?.present(AC, animated: true)
        
    }
    
    
    func showCustomAlert(withTitle Title: String? = nil, andMessage Message: String? = nil, andButtonTitle ButtonTitle: String? = nil, on vc: UIViewController?, image : UIImage? = nil, isRound: Bool, andCompletionHandler action: @escaping (UIAlertAction) -> Void) {
        
        AC = UIAlertController(style: .alert)
        
        AC.setBackgroundColor(color: UIColor.white)
             
        AC.setLoginViewController(image: image ?? UIImage(), title: Title ?? "", message: Message ?? "", isRound: isRound, isImage: isImage(image: image))
        let OK = UIAlertAction(title: ButtonTitle, style: .default, handler: action)
        let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        OK.setValue(UIColor.lightGray, forKey: "titleTextColor")
        Cancel.setValue(UIColor.lightGray, forKey: "titleTextColor")
        AC.addAction(OK)
        AC.addAction(Cancel)
        vc?.present(AC, animated: true)
        
    }
    
    
    func showConfirmAlert(withTitle Title: String? = nil, andMessage Message: String? = nil, andButtonTitle ButtonTitle: String? = nil, on vc: UIViewController?, image : UIImage? = nil, isRound: Bool, andCompletionHandler action: @escaping (UIAlertAction) -> Void) {
        
        AC = UIAlertController(style: .alert)
        
        AC.setBackgroundColor(color: UIColor.white)
             
        AC.setLoginViewController(image: image ?? UIImage(), title: Title ?? "", message: Message ?? "", isRound: isRound, isImage: isImage(image: image))
        let OK = UIAlertAction(title: ButtonTitle, style: .default, handler: action)
        let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        OK.setValue(UIColor.green, forKey: "titleTextColor")
        AC.addAction(OK)
        AC.addAction(Cancel)
        vc?.present(AC, animated: true)
        
    }
    
    func showUserInfoAlertWithoutImage(withTitle Title: String? = nil, andMessage Message: String? = nil, on vc: UIViewController?, image : UIImage? = nil, isRound: Bool, andCompletionHandler parentAction: @escaping (UIAlertAction) -> Void, andCompletionHandler siblingAction: @escaping (UIAlertAction) -> Void, andCompletionHandler friendsAction: @escaping (UIAlertAction) -> Void) {
        
        AC = UIAlertController(style: .alert)
        
        AC.setBackgroundColor(color: UIColor.lightGray)
             
        AC.setLoginViewController(image: image ?? UIImage(), title: Title ?? "", message: Message ?? "", isRound: isRound, isImage: isImage(image: image))
        let parentAction = UIAlertAction(title: "OK", style: .default) { parentAction in
//            print("its okay")
//            let vc = self.AC.storyboard?.instantiateViewController(withIdentifier: "") as! ParentsViewController
//            self.AC.
        }
        let siblingAction = UIAlertAction(title: "OK", style: .default) { siblingAction in
//            print("its okay")
        }
        let friendsAction = UIAlertAction(title: "OK", style: .default) { friendsAction in
//            print("its okay")
        }
        parentAction.setValue(UIColor.green, forKey: "titleTextColor")
        siblingAction.setValue(UIColor.green, forKey: "titleTextColor")
        friendsAction.setValue(UIColor.green, forKey: "titleTextColor")
        AC.addAction(parentAction)
        AC.addAction(siblingAction)
        AC.addAction(friendsAction)
        vc?.present(AC, animated: true)
        
    }
    
}
