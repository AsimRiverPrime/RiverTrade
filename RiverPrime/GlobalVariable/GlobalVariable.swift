//
//  GlobalVariable.swift
//  RiverPrime
//
//  Created by abrar ul haq on 16/07/2024.
//

import Foundation
import UIKit

class GlobalVariable: NSObject {
    
    static var instance = GlobalVariable()
    static var dashboardLogout = false
    static var SiteIDLabel = ""
    var dynamicLink = Bool()
    static var qrCode = String()
    static var isPushNotification = false
    
    var _QuestionairByPass = Bool()
    
    public func showBarBackButton(vc: UIViewController) {
       
        // Hide Navigation Back Button on this View Controller
        vc.navigationItem.setHidesBackButton(false, animated:true);
    }
    
    public func hideBarBackButton(vc: UIViewController) {
        
        // Hide Navigation Back Button on this View Controller
        vc.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    public func showBar(vc: UIViewController){
        vc.navigationController?.isNavigationBarHidden = false
    }
    
    public func hideBar(vc: UIViewController) {
        vc.navigationController?.isNavigationBarHidden = true
    }
    
    public func barDataShowHide(vc: UIViewController, isBackButton: Bool, isBar: Bool) {
        vc.navigationItem.setHidesBackButton(isBackButton, animated:true)
        vc.navigationController?.isNavigationBarHidden = isBar
        vc.navigationController?.setNavigationBarHidden(isBar, animated: true)
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
}
