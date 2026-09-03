//
//  PaymentViewModel.swift
//  MarvelApp
//
//  State + validation for the payment-method choice and the card-details form.
//  Includes light input formatting (grouping card digits, MM/YY expiry).
//

import Foundation

@Observable
@MainActor
final class PaymentViewModel {
    var selectedMethod: PaymentMethod = .card

    var firstName = ""
    var lastName = ""
    var cardNumber = "" { didSet { formatCardNumber() } }
    var expiry = "" { didSet { formatExpiry() } }
    var cvv = "" { didSet { limitCVV() } }

    // MARK: Validation
    var firstNameValidation: ValidationResult { Validator.requiredText(firstName, field: "First name", minLength: 2) }
    var lastNameValidation: ValidationResult { Validator.requiredText(lastName, field: "Last name", minLength: 1) }
    var cardNumberValidation: ValidationResult { Validator.cardNumber(cardNumber) }
    var expiryValidation: ValidationResult { Validator.expiry(expiry) }
    var cvvValidation: ValidationResult { Validator.cvv(cvv) }

    var isCardFormValid: Bool {
        firstNameValidation.isValid && lastNameValidation.isValid &&
        cardNumberValidation.isValid && expiryValidation.isValid && cvvValidation.isValid
    }

    // MARK: Formatting
    private var isFormatting = false

    private func formatCardNumber() {
        guard !isFormatting else { return }
        isFormatting = true
        defer { isFormatting = false }
        let digits = String(cardNumber.filter(\.isNumber).prefix(19))
        var grouped = ""
        for (index, char) in digits.enumerated() {
            if index != 0 && index % 4 == 0 { grouped.append(" ") }
            grouped.append(char)
        }
        cardNumber = grouped
    }

    private func formatExpiry() {
        guard !isFormatting else { return }
        isFormatting = true
        defer { isFormatting = false }
        let digits = String(expiry.filter(\.isNumber).prefix(4))
        if digits.count <= 2 {
            expiry = digits
        } else {
            let month = digits.prefix(2)
            let year = digits.dropFirst(2)
            expiry = "\(month)/\(year)"
        }
    }

    private func limitCVV() {
        guard !isFormatting else { return }
        isFormatting = true
        defer { isFormatting = false }
        cvv = String(cvv.filter(\.isNumber).prefix(4))
    }
}
