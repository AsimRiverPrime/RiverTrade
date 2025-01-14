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
}
