//
//  Notification+Extension.swift
//  RiverPrime
//
//  Created by Ross Rostane on 22/10/2024.
//

import Foundation

extension Notification.Name {
    static let tradesUpdated = Notification.Name("tradesUpdated")
    static let symbolDataUpdated = Notification.Name("symbolDataUpdated")
    static let checkSocketConnectivity = Notification.Name("socketConnectivity")
    static let OPCListDismissall = Notification.Name("opcListDismiss")
    static let MetaTraderLogin = Notification.Name("metaTraderLogin")
    static let BalanceUpdate = Notification.Name("balanceUpdate")
    static let didReceivePushNotification = Notification.Name("didReceivePushNotification")
    
    static let connectionLost = Notification.Name("connectionLost")
    static let connectionRestored = Notification.Name("connectionRestored")
    static let accountChangeUpdation = Notification.Name("accountChangeUpdation")
}
