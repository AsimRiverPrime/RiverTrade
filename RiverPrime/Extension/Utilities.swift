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
    case signInViewController = "SignInViewController"
    case signupViewController = "SignUpViewController"
    case verifyCodeViewController = "VerifyCodeViewController"
    case phoneVerifyVC = "PhoneVerifyVC"
    case dashboardVC = "DashboardVC"
    
    case withdrawViewController = "WithdrawViewController"
    case depositViewController = "DepositViewController"
    case accountsViewController = "AccountsViewController"
    case detailsViewController = "DetailsViewController"
    case historyViewController = "HistoryViewController"
    case notificationViewController = "NotificationViewController"
    case tradeDetalVC = "TradeDetalVC"
    case chartTypeVC = "ChartTypeVC"
    case timeFrameVC = "TimeFrameVC"
    case selectAccountTypeVC = "SelectAccountTypeVC"
    case createDemoAccountVC = "CreateDemoAccountVC"
    case createAccountSelectTradeType = "CreateAccountSelectTradeType"
    case createAccountTypeVC = "CreateAccountTypeVC"
    case unarchiveAccountTypeVC = "UnarchiveAccountTypeVC"
    case allRealAccountsVC = "AllRealAccountsVC"
    case ticketVC = "TicketVC"
    
    case completeVerificationProfileScreen1 = "CompleteVerificationProfileScreen1"
    case completeVerificationProfileScreen2 = "CompleteVerificationProfileScreen2" 
    case completeVerificationProfileScreen3 = "CompleteVerificationProfileScreen3"
    case completeVerificationProfileScreen4 = "CompleteVerificationProfileScreen4"
    case completeVerificationProfileScreen5 = "CompleteVerificationProfileScreen5"
    case completeVerificationProfileScreen6 = "CompleteVerificationProfileScreen6"
    case completeVerificationProfileScreen7 = "CompleteVerificationProfileScreen7"
    
    case openTicketBottomSheetVC = "OpenTicketBottomSheetVC"
    case pendingTicketBottomSheetVC = "PendingTicketBottomSheetVC"
    case closeTicketBottomSheetVC = "CloseTicketBottomSheetVC"
    case datePickerPopupBottomSheet = "DatePickerPopupBottomSheet"
}
