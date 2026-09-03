//
//  Validator.swift
//  MarvelApp
//
//  Pure, side-effect-free validation functions for every text field in the app.
//  Kept independent of SwiftUI so they are trivially unit-testable.
//

import Foundation

/// Result of validating a single field.
enum ValidationResult: Equatable {
    case valid
    case invalid(String)

    var isValid: Bool { if case .valid = self { return true }; return false }
    var errorMessage: String? { if case let .invalid(message) = self { return message }; return nil }
}

enum Validator {

    // MARK: Email
    nonisolated static func email(_ input: String) -> ValidationResult {
        let value = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty { return .invalid("Email is required") }
        // RFC-5322-lite: local part + domain with a TLD of at least two letters.
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        let matches = value.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
        return matches ? .valid : .invalid("Enter a valid email address")
    }

    // MARK: Password
    /// At least 8 chars, one uppercase, one lowercase, one digit.
    nonisolated static func password(_ input: String) -> ValidationResult {
        if input.isEmpty { return .invalid("Password is required") }
        if input.count < 8 { return .invalid("Password must be at least 8 characters") }
        if input.range(of: "[A-Z]", options: .regularExpression) == nil {
            return .invalid("Add at least one uppercase letter")
        }
        if input.range(of: "[a-z]", options: .regularExpression) == nil {
            return .invalid("Add at least one lowercase letter")
        }
        if input.range(of: "[0-9]", options: .regularExpression) == nil {
            return .invalid("Add at least one number")
        }
        return .valid
    }

    // MARK: Name / non-empty
    nonisolated static func requiredText(_ input: String, field: String, minLength: Int = 1) -> ValidationResult {
        let value = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty { return .invalid("\(field) is required") }
        if value.count < minLength { return .invalid("\(field) is too short") }
        return .valid
    }

    // MARK: Card number (Luhn + length)
    nonisolated static func cardNumber(_ input: String) -> ValidationResult {
        let digits = input.filter(\.isNumber)
        if digits.isEmpty { return .invalid("Card number is required") }
        if digits.count < 13 || digits.count > 19 { return .invalid("Enter a valid card number") }
        return luhnCheck(digits) ? .valid : .invalid("Card number is invalid")
    }

    /// Luhn checksum used by all major card networks.
    nonisolated static func luhnCheck(_ digits: String) -> Bool {
        var sum = 0
        let reversed = digits.reversed().map { Int(String($0)) ?? 0 }
        for (index, digit) in reversed.enumerated() {
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        return sum % 10 == 0
    }

    // MARK: Cardholder name
    nonisolated static func cardHolder(_ input: String) -> ValidationResult {
        let value = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty { return .invalid("Name on card is required") }
        let allowed = value.allSatisfy { $0.isLetter || $0.isWhitespace || $0 == "." || $0 == "-" }
        return allowed ? .valid : .invalid("Name contains invalid characters")
    }

    // MARK: Expiry MM/YY
    nonisolated static func expiry(_ input: String, now: Date = Date(), calendar: Calendar = .current) -> ValidationResult {
        let value = input.trimmingCharacters(in: .whitespaces)
        let pattern = #"^(0[1-9]|1[0-2])\/?([0-9]{2})$"#
        guard let match = value.range(of: pattern, options: .regularExpression) else {
            return .invalid("Use MM/YY format")
        }
        let normalized = String(value[match]).replacingOccurrences(of: "/", with: "")
        guard normalized.count == 4,
              let month = Int(normalized.prefix(2)),
              let year = Int(normalized.suffix(2)) else {
            return .invalid("Use MM/YY format")
        }
        let currentYear = calendar.component(.year, from: now) % 100
        let currentMonth = calendar.component(.month, from: now)
        if year < currentYear || (year == currentYear && month < currentMonth) {
            return .invalid("Card has expired")
        }
        return .valid
    }

    // MARK: CVV
    nonisolated static func cvv(_ input: String) -> ValidationResult {
        let digits = input.filter(\.isNumber)
        if digits.isEmpty { return .invalid("CVV is required") }
        return (digits.count == 3 || digits.count == 4) ? .valid : .invalid("CVV must be 3 or 4 digits")
    }
}
