//
//  Alert.swift
//  DeskflexProject
//
//  Created by abrar ul haq on 05/06/2023.
//

import UIKit

public class Alert {
    
    //============ Alerts ============
    static var AC: UIAlertController!
    
    
    
    
    //=====================================================//
    // >>>>>>>>>>>>>> START ALERT FUNCTIONS <<<<<<<<<<<<<< //
    //=====================================================//
    
    
    
    
    
    public static func showToast(controller: UIViewController, title: String? = nil, message: String? = nil, seconds: Double) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.view.backgroundColor = .black
//        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    
    
    //============ Alerts ============
    // Logout Popup
    public static func showAlertWithOKHandler(withHandler Message: String?, andTitle Title: String?, OKButtonText: String? = "OK", on vc: UIViewController?, andCompletionHandler action: @escaping (UIAlertAction) -> Void) {
        AC = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        
//        var OK = "OK"
        
        let defaultAction = UIAlertAction(title: OKButtonText, style: .default, handler: action)
        
        defaultAction.setValue(UIColor.black, forKey: "titleTextColor")
        
        AC.addAction(defaultAction)
        vc?.present(AC, animated: true)
    }
    
    
   public static func showTextFieldAlert(message: String, placeholder: String, completion: ((_ textFieldInput: String?) -> Void)? = nil , on vc: UIViewController?) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        // Add a text field to the alert
        alertController.addTextField { textField in
            textField.placeholder = placeholder
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            let textFieldInput = alertController.textFields?.first?.text
            completion?(textFieldInput)
        }
        
        alertController.addAction(okAction)
        vc?.present(alertController, animated: true, completion: nil)
    }
    //============ Alerts ============
    // Present the alert view controller
    public static func showAlert(withMessage Message: String?, andTitle Title: String?, OKButtonText: String? = "OK", on vc: UIViewController?) {
        AC = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        
//        var OK = "OK"
        
        let defaultAction = UIAlertAction(title: OKButtonText, style: .default, handler: { action in
        })
        
        defaultAction.setValue(UIColor.black, forKey: "titleTextColor")
        
        AC.addAction(defaultAction)
        vc?.present(AC, animated: true)
    }
    
    //==============================================================//
    // >>>>>>>>>>>>>> END UP WINDOW ALERT FUNCTIONS <<<<<<<<<<<<<< //
    //==============================================================//
    
    
    public static func setActionForActionSheet() -> [(String, UIAlertAction.Style)] {
        var actions: [(String, UIAlertAction.Style)] = []
        
        actions.append(("Take Photo", UIAlertAction.Style.default))
        actions.append(("Photo Library", UIAlertAction.Style.default))
//        actions.append(("Action 2", UIAlertAction.Style.destructive))
        actions.append(("Cancel", UIAlertAction.Style.cancel))
        
        return actions
    }
    
    public static func showActionsheet(viewController: UIViewController, title: String?, message: String?, actions: [(String, UIAlertAction.Style)], completion: @escaping (_ index: Int) -> Void) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for (index, (title, style)) in actions.enumerated() {
            let alertAction = UIAlertAction(title: title, style: style) { (_) in
                completion(index)
            }
            alertViewController.addAction(alertAction)
         }
         // iPad Support
         alertViewController.popoverPresentationController?.sourceView = viewController.view
         
         viewController.present(alertViewController, animated: true, completion: nil)
        }
    
}
private var window: UIWindow!

extension UIAlertController {
    func present(animated: Bool, completion: (() -> Void)?) {
        window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.windowLevel = .alert + 1
        window.makeKeyAndVisible()
        window.rootViewController?.present(self, animated: animated, completion: completion)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        window = nil
    }
}
