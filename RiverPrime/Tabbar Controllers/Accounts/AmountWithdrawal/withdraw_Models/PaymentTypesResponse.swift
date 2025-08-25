import Foundation

struct PaymentTypesResponse: Codable {
    let jsonrpc: String
    let id: Int
    let result: PaymentResult
}

struct PaymentResult: Codable {
    let success: Bool
    let paymentTypes: [PaymentType]
    let totalTypes: Int

    enum CodingKeys: String, CodingKey {
        case success
        case paymentTypes = "payment_types"
        case totalTypes = "total_types"
    }
}

struct PaymentType: Codable {
    let id: Int
    let name: String
    let code: String
    let sequence: Int
    let active: Bool
    let defaults: PaymentDefaults
    let requiredFields: [Field]
    let optionalFields: [Field]
    let security: [String: String]
    let supportsDeposits: Bool
    let supportsWithdrawals: Bool
    
    // Optional arrays for different payment types
    let cardTypeOptions: [Option]?
    let providerOptions: [Option]?
    let cryptoOptions: [Option]?

    enum CodingKeys: String, CodingKey {
        case id, name, code, sequence, active, defaults, security
        case requiredFields = "required_fields"
        case optionalFields = "optional_fields"
        case supportsDeposits = "supports_deposits"
        case supportsWithdrawals = "supports_withdrawals"
        case cardTypeOptions = "card_type_options"
        case providerOptions = "provider_options"
        case cryptoOptions = "crypto_options"
    }
}

struct PaymentDefaults: Codable {
    let minAmount: Double
    let maxAmount: Double
    let processingFee: Double
    let feePercentage: Double
    let processingTime: String

    enum CodingKeys: String, CodingKey {
        case minAmount = "min_amount"
        case maxAmount = "max_amount"
        case processingFee = "processing_fee"
        case feePercentage = "fee_percentage"
        case processingTime = "processing_time"
    }
}

struct Field: Codable {
    let name: String
    let type: String
    let string: String
    let help: String
    let required: Bool
    let readonly: Bool
    let size: Int?
    let maxLength: Int?
    let multiline: Bool?
    let options: [Option]?
    let validation: Validation?

    enum CodingKeys: String, CodingKey {
        case name, type, string, help, required, readonly, size, options, validation, multiline
        case maxLength = "max_length"
    }
}

struct Option: Codable {
    let value: String
    let label: String
}

struct Validation: Codable {
    let minLength: Int?
    let maxLength: Int?
    let alphaSpaces: Bool?
    let trimWhitespace: Bool?
    let noSpecialChars: Bool?
    let alphanumeric: Bool?
    let pattern: String?
    let patternMessage: String?
    let numericOnly: Bool?
    let uppercase: Bool?
    let selectionOnly: Bool?
    let requiredSelection: Bool?
    let validationMethod: String?
    let sensitiveData: Bool?
    let maskForDisplay: Bool?
    let stripSpaces: Bool?
    let stripSpecialChars: Bool?
    let checkDuplicates: Bool?
    let duplicateScope: String?
    let dependsOn: String?
    let toLowercase: Bool?
    let alphanumericWithSpecial: Bool?
    let alphanumericWithDash: Bool?
    let examples: [String]?
    let multiline: Bool?
    let allowLineBreaks: Bool?
    let checksumValidation: Bool?
    let contextValidation: Bool?
    let conditionalValidation: [String: ConditionalValidation]?
    let emailFormat: Bool?

    enum CodingKeys: String, CodingKey {
        case minLength = "min_length"
        case maxLength = "max_length"
        case alphaSpaces = "alpha_spaces"
        case trimWhitespace = "trim_whitespace"
        case noSpecialChars = "no_special_chars"
        case alphanumeric
        case pattern
        case patternMessage = "pattern_message"
        case numericOnly = "numeric_only"
        case uppercase
        case selectionOnly = "selection_only"
        case requiredSelection = "required_selection"
        case validationMethod = "validation_method"
        case sensitiveData = "sensitive_data"
        case maskForDisplay = "mask_for_display"
        case stripSpaces = "strip_spaces"
        case stripSpecialChars = "strip_special_chars"
        case checkDuplicates = "check_duplicates"
        case duplicateScope = "duplicate_scope"
        case dependsOn = "depends_on"
        case toLowercase = "to_lowercase"
        case alphanumericWithSpecial = "alphanumeric_with_special"
        case alphanumericWithDash = "alphanumeric_with_dash"
        case examples
        case multiline
        case allowLineBreaks = "allow_line_breaks"
        case checksumValidation = "checksum_validation"
        case contextValidation = "context_validation"
        case conditionalValidation = "conditional_validation"
        case emailFormat = "email_format"
    }
}

struct ConditionalValidation: Codable {
    let emailFormat: Bool?
    let pattern: String?
    let patternMessage: String?
    let alphanumericWithSpecial: Bool?

    enum CodingKeys: String, CodingKey {
        case emailFormat = "email_format"
        case pattern
        case patternMessage = "pattern_message"
        case alphanumericWithSpecial = "alphanumeric_with_special"
    }
}

// MARK: - UIKit Usage Extensions
extension PaymentType {
    var displayName: String {
        return name
    }
    
    var isEnabled: Bool {
        return active
    }
    
    var canDeposit: Bool {
        return supportsDeposits
    }
    
    var canWithdraw: Bool {
        return supportsWithdrawals
    }
    
    var formattedMinAmount: String {
        return String(format: "%.2f", defaults.minAmount)
    }
    
    var formattedMaxAmount: String {
        return String(format: "%.2f", defaults.maxAmount)
    }
    
    var formattedProcessingFee: String {
        return String(format: "%.2f", defaults.processingFee)
    }
    
    var allFields: [Field] {
        return requiredFields + optionalFields
    }
}

extension Field {
    var isRequiredField: Bool {
        return required
    }
    
    var isReadOnlyField: Bool {
        return readonly
    }
    
    var displayLabel: String {
        return string
    }
    
    var helpText: String {
        return help.isEmpty ? "" : help
    }
    
    var isMultilineField: Bool {
        return multiline ?? false
    }
    
    var isSelectionField: Bool {
        return type == "selection"
    }
    
    var hasOptions: Bool {
        return options?.isEmpty == false
    }
}

extension PaymentDefaults {
    var amountRange: String {
        return "\(formattedMinAmount) - \(formattedMaxAmount)"
    }
    
    private var formattedMinAmount: String {
        return String(format: "%.2f", minAmount)
    }
    
    private var formattedMaxAmount: String {
        return String(format: "%.2f", maxAmount)
    }
    
    var hasFee: Bool {
        return processingFee > 0 || feePercentage > 0
    }
    
    var feeDescription: String {
        if processingFee > 0 && feePercentage > 0 {
            return "\(String(format: "%.2f", processingFee)) + \(String(format: "%.2f", feePercentage))%"
        } else if processingFee > 0 {
            return String(format: "%.2f", processingFee)
        } else if feePercentage > 0 {
            return "\(String(format: "%.2f", feePercentage))%"
        } else {
            return "No fee"
        }
    }
}
