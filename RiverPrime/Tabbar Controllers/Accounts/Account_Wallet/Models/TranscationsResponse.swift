//
//  TranscationsResponse.swift
//  RiverPrime
//
//  Created by Ross Rostane on 19/08/2025.
//
//

import Foundation

// MARK: - First Response (Transactions)

struct TransactionResponse: Codable {
    let jsonrpc: String
    let id: Int
    let result: TransactionResult
}

struct TransactionResult: Codable {
    @SafeDecode var success: Bool = false
    @SafeDecode var transactions: [Transaction] = []
}

struct Transaction: Codable {
    @SafeDecode var id: Int? // Made optional to handle null
    @SafeDecode var requestNumber: String = ""
    @SafeDecode var transactionType: String = ""
    @SafeDecode var amount: Double = 0.0
    @SafeDecode var currency: String = ""
    @SafeDecode var status: String = ""
    @SafeDecode var statusDisplay: String = ""
    @SafeDecode var priority: String = ""
    @SafeDecode var walletType: String = ""
    @SafeDecode var createdDate: String = ""
    @SafeDecode var submissionDate: String = ""
    @SafeDecode var completionDate: String?
    @SafeDecode var expectedCompletionDate: String?
    @SafeDecode var daysPending: Int = 0
    @SafeDecode var processingDays: Int = 0
    @SafeDecode var isOverdue: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case requestNumber = "request_number"
        case transactionType = "transaction_type"
        case amount, currency, status
        case statusDisplay = "status_display"
        case priority
        case walletType = "wallet_type"
        case createdDate = "created_date"
        case submissionDate = "submission_date"
        case completionDate = "completion_date"
        case expectedCompletionDate = "expected_completion_date"
        case daysPending = "days_pending"
        case processingDays = "processing_days"
        case isOverdue = "is_overdue"
    }
}

// MARK: - Second Response (Records)

struct RecordsResponse: Codable {
    let jsonrpc: String
    let id: Int
    let result: RecordsResult
}

struct RecordsResult: Codable {
    @SafeDecode var success: Bool = false
    @SafeDecode var records: [TransactionRecord] = []
    @SafeDecode var totalCount: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case success, records
        case totalCount = "total_count"
    }
}

struct TransactionRecord: Codable {
    @SafeDecode var id: Int? // Made optional to handle null
    @SafeDecode var displayName: String = ""
    @SafeDecode var type: String = ""
    @SafeDecode var state: String = ""
    @SafeDecode var amount: Double = 0.0
    @SafeDecode var balanceBefore: Double = 0.0
    @SafeDecode var balanceAfter: Double = 0.0
    @SafeDecode var createDate: String = ""
    @SafeDecode var processedDate: String = ""
    @SafeDecode var reference: String = ""
    @SafeDecode var description: String = ""
    @SafeDecode var currencySymbol: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case type, state, amount
        case balanceBefore = "balance_before"
        case balanceAfter = "balance_after"
        case createDate = "create_date"
        case processedDate = "processed_date"
        case reference, description
        case currencySymbol = "currency_symbol"
    }
}

// MARK: - SafeDecode Property Wrapper

@propertyWrapper
struct SafeDecode<T: Codable>: Codable {
    let wrappedValue: T
    
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Handle null values first
        if container.decodeNil() {
            if let defaultValue = DefaultValueProvider.defaultValue(for: T.self) as? T {
                wrappedValue = defaultValue
                return
            }
        }
        
        // Try to decode the expected type
        if let value = try? container.decode(T.self) {
            wrappedValue = value
        } else {
            // If decoding fails, use default value
            if let defaultValue = DefaultValueProvider.defaultValue(for: T.self) as? T {
                wrappedValue = defaultValue
            } else {
                throw DecodingError.typeMismatch(T.self, DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Could not decode \(T.self) and no default value available"
                ))
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

// Helper to provide default values
struct DefaultValueProvider {
    static func defaultValue<T>(for type: T.Type) -> Any? {
        switch type {
        case is String.Type:
            return ""
        case is Int.Type:
            return 0
        case is Double.Type:
            return 0.0
        case is Bool.Type:
            return false
        case is Array<Any>.Type:
            return []
        case is Optional<String>.Type:
            return nil
        case is Optional<Int>.Type:
            return nil
        case is Optional<Double>.Type:
            return nil
        case is Optional<Bool>.Type:
            return nil
        default:
            // For optional types, return nil
            if String(describing: type).contains("Optional") {
                return nil
            }
            return nil
        }
    }
}

// MARK: - Usage Extensions

extension TransactionResponse {
    // Decode from Data
    static func decode(from jsonData: Data) -> TransactionResponse? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(TransactionResponse.self, from: jsonData)
        } catch {
            print("Transaction decoding error: \(error)")
            return nil
        }
    }
    
    // Decode from Dictionary
    static func decode(from dictionary: [String: Any]) -> TransactionResponse? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            return decode(from: jsonData)
        } catch {
            print("Dictionary to Data conversion error: \(error)")
            return nil
        }
    }
    
    // Decode from Any (for API responses)
    static func decode(from response: Any?) -> TransactionResponse? {
        guard let dictionary = response as? [String: Any] else {
            print("Response is not a valid dictionary")
            return nil
        }
        return decode(from: dictionary)
    }
}

extension RecordsResponse {
    // Decode from Data
    static func decode(from jsonData: Data) -> RecordsResponse? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(RecordsResponse.self, from: jsonData)
        } catch {
            print("Records decoding error: \(error)")
            return nil
        }
    }
    
    // Decode from Dictionary
    static func decode(from dictionary: [String: Any]) -> RecordsResponse? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            return decode(from: jsonData)
        } catch {
            print("Dictionary to Data conversion error: \(error)")
            return nil
        }
    }
    
    // Decode from Any (for API responses)
    static func decode(from response: Any?) -> RecordsResponse? {
        guard let dictionary = response as? [String: Any] else {
            print("Response is not a valid dictionary")
            return nil
        }
        return decode(from: dictionary)
    }
}

// MARK: - Combined Transaction Model for UI

struct CombinedTransactionRecord {
    // From Transaction (First API)
    var transactionId: Int?
    var requestNumber: String?
    var transactionType: String?
    var transactionAmount: Double?
    var currency: String?
    var status: String?
    var statusDisplay: String?
    var priority: String?
    var walletType: String?
    var createdDate: String?
    var submissionDate: String?
    var completionDate: String?
    var expectedCompletionDate: String?
    var daysPending: Int?
    var processingDays: Int?
    var isOverdue: Bool?
    
    // From TransactionRecord (Second API)
    var recordId: Int?
    var displayName: String?
    var recordType: String?
    var state: String?
    var recordAmount: Double?
    var balanceBefore: Double?
    var balanceAfter: Double?
    var createDate: String?
    var processedDate: String?
    var reference: String?
    var description: String?
    var currencySymbol: String?
    
    // Computed properties for final values
    var finalAmount: Double {
        return recordAmount ?? transactionAmount ?? 0.0
    }
    
    var finalType: String {
        return recordType ?? transactionType ?? ""
    }
    
    var finalStatus: String {
        return state?.capitalized ?? statusDisplay ?? status?.capitalized ?? ""
    }
    
    var finalDescription: String {
        return displayName ?? description ?? "\(finalType.capitalized) Transaction"
    }
    
    var finalDate: String {
        // Priority: processedDate > completionDate > createDate > createdDate > submissionDate
        if let processed = processedDate, !processed.isEmpty {
            return processed
        }
        if let completion = completionDate, !completion.isEmpty {
            return completion
        }
        if let create = createDate, !create.isEmpty {
            return create
        }
        if let created = createdDate, !created.isEmpty {
            return created
        }
        return submissionDate ?? ""
    }
    
    var finalCurrency: String {
        return currencySymbol ?? currency ?? "$"
    }
}
















//import Foundation
//
//struct TransactionsResponse: Codable {
//    let jsonrpc: String?
//    let id: Int?
//    let result: TransactionsResult?
//}
//
//struct TransactionsResult: Codable {
//    let success: Bool?
//    let records: [TransactionRecord]?
//    let total_count: Int?
//}
//
//struct TransactionRecord: Codable {
//    @SafeDecode var id: Int?
//    @SafeDecode var display_name: String?
//    @SafeDecode var type: String?
//    @SafeDecode var state: String?
//    @SafeDecode var amount: Double?
//    @SafeDecode var balance_before: Double?
//    @SafeDecode var balance_after: Double?
//    @SafeDecode var create_date: String?
//    @SafeDecode var processed_date: String?   // ✅ will not crash if it's Bool
//    @SafeDecode var description: String?
//    @SafeDecode var currency_symbol: String?
//
//    // nested objects
//    let currency_id: NestedInfo?
//    let wallet_id: NestedInfo?
//    let partner_id: NestedInfo?
//    
//    struct NestedInfo: Codable {
//        let id: Int?
//        let name: String?
//    }
//}
//
///// A wrapper that ignores decoding errors and sets the value to nil
//@propertyWrapper
//struct SafeDecode<T: Codable>: Codable {
//    var wrappedValue: T?
//
//    init(wrappedValue: T?) {
//        self.wrappedValue = wrappedValue
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        self.wrappedValue = try? container.decode(T.self)  // will fail silently
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encode(wrappedValue)
//    }
//}
//
//// MARK: - Combined Transaction Model
//struct CombinedTransactionRecord {
//    // From first API (get_User_transcations)
//    var transactionId: Int?
//    var amount: Double?
//    var currency: String?
//    var transactionType: String?
//    var status: String?
//    var statusDisplay: String?
//    var createdDate: String?
//    var submissionDate: String?
//    var completionDate: String?
//    var expectedCompletionDate: String?
//    var paymentMethod: PaymentMethod1?
//    var fees: Fees?
//    var riskInfo: RiskInfo?
//    var priority: String?
//    var canCancel: Bool?
//    
//    // From second API (get_transcations_search_read)
//    var balanceBefore: Double?
//    var balanceAfter: Double?
//    var processedDate: String?
//    var description: String?
//    var displayName: String?
//    var reference: String?
//    var searchReadId: Int?
//    
//    // Computed properties for easier access
//    var finalAmount: Double {
//        return amount ?? 0
//    }
//    
//    var finalStatus: String {
//        return statusDisplay ?? status ?? "Unknown"
//    }
//    
//    var finalDescription: String {
//        return description ?? transactionType?.capitalized ?? "Transaction"
//    }
//    
//    var finalDate: String {
//        return processedDate ?? completionDate ?? createdDate ?? submissionDate ?? ""
//    }
//}
//
//// MARK: - Supporting Models for first API
//struct PaymentMethod1: Codable {
//    let details: String?
//    let id: Int?
//    let name: String?
//    let processingTime: String?
//    let type: String?
//    
//    private enum CodingKeys: String, CodingKey {
//        case details, id, name, type
//        case processingTime = "processing_time"
//    }
//}
//
//struct Fees: Codable {
//    let feePercentage: Double?
//    let grossAmount: Double?
//    let netAmount: Double?
//    let percentageFeeAmount: Double?
//    let processingFee: Double?
//    let totalFees: Double?
//    
//    private enum CodingKeys: String, CodingKey {
//        case feePercentage = "fee_percentage"
//        case grossAmount = "gross_amount"
//        case netAmount = "net_amount"
//        case percentageFeeAmount = "percentage_fee_amount"
//        case processingFee = "processing_fee"
//        case totalFees = "total_fees"
//    }
//}
//
//struct RiskInfo: Codable {
//    let amlCleared: Int?
//    let kycVerified: Int?
//    let requiresManualReview: Int?
//    let riskScore: Int?
//    
//    private enum CodingKeys: String, CodingKey {
//        case amlCleared = "aml_cleared"
//        case kycVerified = "kyc_verified"
//        case requiresManualReview = "requires_manual_review"
//        case riskScore = "risk_score"
//    }
//}
