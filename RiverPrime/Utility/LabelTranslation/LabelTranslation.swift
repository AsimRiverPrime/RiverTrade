//
//  LabelTranslation.swift
//  RiverPrime
//
//  Created by Ross Rostane on 28/07/2024.
//

import Foundation

class LabelTranslation: Codable {
    
    var validationString: ValidationLabels?
    
    //MARK: - Validation Strings

    struct ValidationLabels: Codable {
        
        var newtworkValidatoin: NetworkValidationLabel?
        
        init() {
            self.newtworkValidatoin = NetworkValidationLabel()
        }
        
        mutating func removeObjects() {
            
            self.newtworkValidatoin = nil
            
        }
        
    }

    struct NetworkValidationLabel:Codable {
        var kGeneralServer: String?
        var kUnknownServer: String?
        var kRequestTimeOut: String?
        var kServiceUnavailable: String?
        var kNoInternet: String?
        var kConnectionLost: String?
        var labelError: String?
        var labelOK: String?
    }
    
    static let labelTranslation = LabelTranslation()
    
    static var translationKV: [String: String] = [:]
    
     func getLocalizedString(value: String) -> String {
        let targetLanguage = "en"
        print("targetLanguage = \(targetLanguage)")
        return NSLocalizedString(LabelTranslation.translationKV[value] ?? value, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    //MARK: - SVProgressHUD Labels
    enum SVProgressHUDLabel: String {
        case loadingLabel = "Loading..."
    }
    
    //MARK: - NetworkValidation Labels
    enum NetworkValidation: String {
        case kGeneralServer = "We are unable to process your request at the moment. Please try again later"
        case kUnknownServer = "Connection with the server cannot be established at this time. Please try again or contact your service provider"
        case kRequestTimeOut = "This seems to be taking longer than usual. Please try again later"
        case kServiceUnavailable = "Service unavailable due to technical difficulties. Please try again or contact service provider"
        case kNoInternet = "There is no or poor internet connection. Please connect to stable internet connection and try again"
        case kConnectionLost = "The network connection was lost"
        case labelError = "Error"
        case labelOK = "OK"
    }

    //MARK: - Welcome Screens
    enum WelcomeScreen: String {
        case Title = "Start trading journey with"
        case CompanyNameLabel = "RIVER PRIME"
        case RegisterNowButton = "Register Now"

        var localized: String {
            return rawValue
        }
        
    }
    
    //MARK: - SummaryTradingActivityCell Screen
    enum SummaryTradingActivityCellScreen: String {
        case title = "No trading activity found"
        case selectedText = "Select different account or period."
        case tradeButton = "Trade"
        
        var localized: String {
            return rawValue
        }
    }
    
    //MARK: - BenefitsTradingActivityCell Screen
    enum BenefitsTradingActivityCell: String {
        case mainTitle = "Our benefits have saved you"
        case title = "Yoy don’t have any savings data yet"
        case selectedText = "Select start trading to see how our better-than-market condition reduce your trading costs and protect against stop outs."
        case tradeButton = "Start Trading"
        
        var localized: String {
            return rawValue
        }
    }
    
}
