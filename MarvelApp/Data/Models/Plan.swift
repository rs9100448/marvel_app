//
//  Plan.swift
//  MarvelApp
//
//  Subscription plan shown on the "Choose your Plan" screen.
//

import Foundation

struct Plan: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let pricePerMonth: Int
    let includedKinds: [TitleKind]

    var priceText: String { "$\(pricePerMonth)/mth" }
    var priceTextLong: String { "$\(pricePerMonth)/month" }
}
