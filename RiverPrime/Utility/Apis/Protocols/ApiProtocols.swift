//
//  ApiProtocols.swift
//  RiverPrime
//
//  Created by Ross Rostane on 16/09/2024.
//

import Foundation


protocol SendOTPDelegate: AnyObject {
    func otpSuccess(response: Any)
    func otpFailure(error: Error)
}
protocol VerifyOTPDelegate: AnyObject {
    func otpVerifySuccess(response: Any)
    func otpVerifyFailure(error: Error)
}

protocol CreateLeadOdooDelegate: AnyObject {
    func leadCreatSuccess(response: Any)
    func leadCreatFailure(error: Error)
}
protocol TradeSymbolDetailDelegate: AnyObject {
    func tradeSymbolDetailSuccess(response: [String: Any])
    func tradeSymbolDetailFailure(error: Error)
}
protocol UpdatePhoneNumebrDelegate: AnyObject {
    func updateNumberSuccess(response: Any)
    func updateNumberFailure(error: Error)
}

protocol CreateUserAccountTypeDelegate: AnyObject {
    func createAccountSuccess(response: Any)
    func createAccountFailure(error: Error)
}
protocol UpdateUserNamePassword: AnyObject {
    func updateSuccess(response: Any)
    func updateFailure(error: Error)
}

protocol TopNewsProtocol: AnyObject {
    func topNewsSuccess(response: TopNewsModel)
//    func topNewsSuccess(response: [PayloadItem])
    func topNewsFailure(error: Error)
}
