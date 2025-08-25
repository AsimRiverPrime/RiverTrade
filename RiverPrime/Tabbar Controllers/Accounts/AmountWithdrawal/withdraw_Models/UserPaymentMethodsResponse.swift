//
//  UserPaymentMethodsResponse.swift
//  RiverPrime
//
//  Created by Ross Rostane on 07/07/2025.
//

import Foundation
//
// struct UserPaymentMethodsResponse: Codable {
//    let jsonrpc: String
//    let id: Int
//    let result: PaymentMethodsResult
//}
//
//struct PaymentMethodsResult: Codable {
//    let success: Bool
//    let paymentMethods: [PaymentMethod]
//    let totalMethods: Int?
//    let defaultMethodID: Int?
//    let securityInfo: TopLevelSecurityInfo?
//
//    enum CodingKeys: String, CodingKey {
//        case success
//        case paymentMethods = "payment_methods"
//        case totalMethods = "total_methods"
//        case defaultMethodID = "default_method_id"
//        case securityInfo = "security_info"
//    }
//}
//
//struct PaymentMethod: Codable {
//    let id: Int
//    let name: String
//    let displayName: String
//    let methodType: String
//    let isDefault: Bool
//    let active: Bool
//    let details: String
//    let limits: MethodLimits
//    let fees: MethodFees
//    let processingTime: String
//    let createdDate: String
//    let securityInfo: MethodSecurityInfo
//
//    enum CodingKeys: String, CodingKey {
//        case id, name
//        case displayName = "display_name"
//        case methodType = "method_type"
//        case isDefault = "is_default"
//        case active, details, limits, fees
//        case processingTime = "processing_time"
//        case createdDate = "created_date"
//        case securityInfo = "security_info"
//    }
//}
//
//struct MethodLimits: Codable {
//    let minAmount: Double
//    let maxAmount: Double
//
//    enum CodingKeys: String, CodingKey {
//        case minAmount = "min_amount"
//        case maxAmount = "max_amount"
//    }
//}
//
//struct MethodFees: Codable {
//    let processingFee: Double
//    let feePercentage: Double
//
//    enum CodingKeys: String, CodingKey {
//        case processingFee = "processing_fee"
//        case feePercentage = "fee_percentage"
//    }
//}
//
//struct MethodSecurityInfo: Codable {
//    let validated: Bool
//    let masked: Bool
//}
//
//struct TopLevelSecurityInfo: Codable {
//    let dataMasked: Bool
//    let accessLogged: Bool
//
//    enum CodingKeys: String, CodingKey {
//        case dataMasked = "data_masked"
//        case accessLogged = "access_logged"
//    }
//}
//

struct UserPaymentMethodsResponse: Codable {
    let jsonrpc: String
    let id: Int
    let result: PaymentMethodsResult
}

struct PaymentMethodsResult: Codable {
    let success: Bool
    let paymentMethods: [PaymentMethod]
    let totalMethods: Int?
    let defaultMethodID: Int?
    let securityInfo: TopLevelSecurityInfo?

    enum CodingKeys: String, CodingKey {
        case success
        case paymentMethods = "payment_methods"
        case totalMethods = "total_methods"
        case defaultMethodID = "default_method_id"
        case securityInfo = "security_info"
    }
}

struct PaymentMethod: Codable {
    let id: Int
    let name: String
    let displayName: String
    let methodType: String
    let isDefault: Bool
    let active: Bool
    let details: String
    let limits: MethodLimits
    let fees: MethodFees
    let processingTime: String
    let createdDate: String
    let supportsDeposits: Bool
    let supportsWithdrawals: Bool
    let securityInfo: MethodSecurityInfo?  // Made optional since it's not in your JSON

    enum CodingKeys: String, CodingKey {
        case id, name
        case displayName = "display_name"
        case methodType = "method_type"
        case isDefault = "is_default"
        case active, details, limits, fees
        case processingTime = "processing_time"
        case createdDate = "created_date"
        case supportsDeposits = "supports_deposits"
        case supportsWithdrawals = "supports_withdrawals"
        case securityInfo = "security_info"
    }
}

struct MethodLimits: Codable {
    let minAmount: Double
    let maxAmount: Double

    enum CodingKeys: String, CodingKey {
        case minAmount = "min_amount"
        case maxAmount = "max_amount"
    }
}

struct MethodFees: Codable {
    let processingFee: Double
    let feePercentage: Double

    enum CodingKeys: String, CodingKey {
        case processingFee = "processing_fee"
        case feePercentage = "fee_percentage"
    }
}

struct MethodSecurityInfo: Codable {
    let validated: Bool
    let masked: Bool
}

struct TopLevelSecurityInfo: Codable {
    let dataMasked: Bool
    let accessLogged: Bool

    enum CodingKeys: String, CodingKey {
        case dataMasked = "data_masked"
        case accessLogged = "access_logged"
    }
}

