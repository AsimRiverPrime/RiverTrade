//
//  NotificationObserver.swift
//  RiverPrime
//
//  Created by Ross Rostane on 22/10/2024.
//

import Foundation

public protocol iNotificationPopup: AnyObject {
    func notificationListner(_ notification: NSNotification)
}

public class NotificationObserver {
    
    public weak var delegate: iNotificationPopup?
    
    static let shared = NotificationObserver()
    public init() {}
    
    enum Constants {
        
        //MARK: - class MetaTraderLogin
        struct MetaTraderLoginConstant {
            static let key = "metaTraderLogin"
            static let title = "title"
        }
        
        //MARK: - class BalanceUpdate
        struct BalanceUpdateConstant {
            static let key = "balanceUpdate"
            static let title = "title"
        }
        //MARK: - class OPCUpdate
        struct OPCUpdateConstant {
            static let key = "opcUpdate"
            static let title = "title"
        }
        //MARK: - class OPCUpdate
        struct TradeApiUpdateConstant {
            static let key = "tradeApiUpdate"
            static let title = "title"
        }
        //MARK: - class After login faceid
        struct FaceAfterLoginConstant {
            static let key = "faceidupdate"
            static let title = "title"
        }
        
    }

    func postNotificationObserver(key: String, dict: [String: Any]) {
        
        // post a notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: key), object: nil, userInfo: dict)
        // `default` is now a property, not a method call

    }
    
    func registerNotificationObserver(key: String) {
        
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationPopup(_:)), name: NSNotification.Name(rawValue: key), object: nil)

    }
    
    @objc func notificationPopup(_ notification: NSNotification) {
        
        delegate?.notificationListner(notification)
        
    }
    
    
}
