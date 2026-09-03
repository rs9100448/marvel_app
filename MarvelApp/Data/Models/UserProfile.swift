//
//  UserProfile.swift
//  MarvelApp
//
//  The signed-in user's profile and subscription selection. Persisted locally
//  (UserDefaults) so onboarding is only shown once.
//

import Foundation

struct UserProfile: Codable, Equatable {
    var email: String
    var displayName: String
    var avatarImageName: String
    var selectedPlanID: String?
    var paymentMethod: PaymentMethod?

    static let placeholder = UserProfile(
        email: "",
        displayName: "UIUXDIVYANSHU",
        avatarImageName: "avatar_2",
        selectedPlanID: nil,
        paymentMethod: nil
    )
}
