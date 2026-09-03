//
//  ValidatorTests.swift
//  MarvelAppTests
//

import Testing
import Foundation
@testable import MarvelApp

@MainActor
struct ValidatorTests {

    // MARK: Email
    @Test("Valid emails pass", arguments: [
        "user@example.com", "a.b+tag@sub.domain.co", "NAME@MARVEL.IO"
    ])
    func validEmails(_ email: String) {
        #expect(Validator.email(email).isValid)
    }

    @Test("Invalid emails fail", arguments: [
        "", "plainaddress", "@no-local.com", "no-at.com", "a@b", "a@b.c"
    ])
    func invalidEmails(_ email: String) {
        #expect(!Validator.email(email).isValid)
    }

    // MARK: Password
    @Test func passwordRules() {
        #expect(Validator.password("Abcd1234").isValid)
        #expect(!Validator.password("short1A").isValid)      // too short
        #expect(!Validator.password("alllower1").isValid)    // no uppercase
        #expect(!Validator.password("ALLUPPER1").isValid)    // no lowercase
        #expect(!Validator.password("NoDigitsHere").isValid) // no number
        #expect(!Validator.password("").isValid)
    }

    // MARK: Card number (Luhn)
    @Test func cardNumberLuhn() {
        #expect(Validator.cardNumber("4242 4242 4242 4242").isValid) // valid Luhn
        #expect(Validator.cardNumber("4111111111111111").isValid)
        #expect(!Validator.cardNumber("1234 5678 9012 3456").isValid) // fails Luhn
        #expect(!Validator.cardNumber("123").isValid)                 // too short
        #expect(!Validator.cardNumber("").isValid)
    }

    @Test func luhnDirect() {
        #expect(Validator.luhnCheck("79927398713"))
        #expect(!Validator.luhnCheck("79927398710"))
    }

    // MARK: Expiry
    @Test func expiryValidation() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let now = DateComponents(calendar: cal, year: 2026, month: 8, day: 27).date!

        #expect(Validator.expiry("12/30", now: now, calendar: cal).isValid)
        #expect(Validator.expiry("08/26", now: now, calendar: cal).isValid)   // current month
        #expect(!Validator.expiry("07/26", now: now, calendar: cal).isValid)  // expired
        #expect(!Validator.expiry("13/30", now: now, calendar: cal).isValid)  // bad month
        #expect(Validator.expiry("1230", now: now, calendar: cal).isValid)    // slash optional
        #expect(!Validator.expiry("ab/cd", now: now, calendar: cal).isValid)
    }

    // MARK: CVV
    @Test func cvvValidation() {
        #expect(Validator.cvv("123").isValid)
        #expect(Validator.cvv("1234").isValid)
        #expect(!Validator.cvv("12").isValid)
        #expect(!Validator.cvv("12345").isValid)
        #expect(!Validator.cvv("").isValid)
    }

    // MARK: Card holder
    @Test func cardHolderValidation() {
        #expect(Validator.cardHolder("Tony Stark").isValid)
        #expect(Validator.cardHolder("J. A. R-V.").isValid)
        #expect(!Validator.cardHolder("Tony3000").isValid)
        #expect(!Validator.cardHolder("").isValid)
    }

    // MARK: Required text
    @Test func requiredText() {
        #expect(Validator.requiredText("Hello", field: "Name").isValid)
        #expect(!Validator.requiredText("  ", field: "Name").isValid)
        #expect(!Validator.requiredText("a", field: "Name", minLength: 2).isValid)
    }
}
