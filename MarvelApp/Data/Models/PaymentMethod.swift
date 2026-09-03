//
//  PaymentMethod.swift
//  MarvelApp
//
//  Payment options presented on the "Choose how to pay" screen.
//

import Foundation

enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    case card
    case netbanking

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .card: return "Credit / Debit Card"
        case .netbanking: return "Netbanking"
        }
    }
}
