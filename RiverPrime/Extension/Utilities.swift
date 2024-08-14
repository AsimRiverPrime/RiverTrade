//
//  Utilities.swift
//  RiverPrime
//
//  Created by Ross Rostane on 11/07/2024.
//

import Foundation
import UIKit


class Utilities {
    
    static let shared = Utilities()
    private init() {}
    
    func getViewController(identifier: BottomSheetIdentifierType, storyboardType: StoryboardType) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardType.rawValue, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier.rawValue)
    }
}

enum StoryboardType: String {
    case main = "Main"
    case dashboard = "Dashboard"
    case bottomSheetPopups = "BottomSheetPopups"
}

enum BottomSheetIdentifierType: String {
    case withdrawViewController = "WithdrawViewController"
    case depositViewController = "DepositViewController"
    case accountsViewController = "AccountsViewController"
    case detailsViewController = "DetailsViewController"
    case historyViewController = "HistoryViewController"
    case notificationViewController = "NotificationViewController"
    case tradeDetalVC = "TradeDetalVC"
    case selectAccountTypeVC = "SelectAccountTypeVC"
    case createDemoAccountVC = "CreateDemoAccountVC"
    case createAccountSelectTradeType = "CreateAccountSelectTradeType"
    case createAccountTypeVC = "CreateAccountTypeVC"
    case unarchiveAccountTypeVC = "UnarchiveAccountTypeVC"
    case allRealAccountsVC = "AllRealAccountsVC"
    case ticketVC = "TicketVC"
}
