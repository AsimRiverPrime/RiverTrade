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

