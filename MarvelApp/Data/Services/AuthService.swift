//
//  AuthService.swift
//  MarvelApp
//
//  Dummy authentication. Since no backend is available yet, sign-up/sign-in
//  validate input and simulate a short network delay before succeeding. The
//  protocol keeps the UI decoupled from the eventual real implementation.
//

import Foundation

enum AuthError: Error, LocalizedError, Equatable {
    case invalidCredentials(String)

    var errorDescription: String? {
        switch self {
        case let .invalidCredentials(message): return message
        }
    }
}

enum SocialProvider: String {
    case google, facebook
}

nonisolated protocol AuthService {
    func signUp(email: String, password: String) async throws -> UserProfile
    func signIn(email: String, password: String) async throws -> UserProfile
    func signIn(with provider: SocialProvider) async throws -> UserProfile
}

nonisolated final class DummyAuthService: AuthService {

    /// Artificial latency to exercise loading states. Set to 0 in tests.
    private let latency: Duration

    init(latency: Duration = .milliseconds(700)) {
        self.latency = latency
    }

    func signUp(email: String, password: String) async throws -> UserProfile {
        try validate(email: email, password: password)
        try await sleep()
        return profile(for: email)
    }

    func signIn(email: String, password: String) async throws -> UserProfile {
        try validate(email: email, password: password)
        try await sleep()
        return profile(for: email)
    }

    func signIn(with provider: SocialProvider) async throws -> UserProfile {
        try await sleep()
        return UserProfile(
            email: "\(provider.rawValue)@marvel.example",
            displayName: provider.rawValue.capitalized + " User",
            avatarImageName: "avatar_2",
            selectedPlanID: nil,
            paymentMethod: nil
        )
    }

    // MARK: Helpers
    private func validate(email: String, password: String) throws {
        if case let .invalid(message) = Validator.email(email) {
            throw AuthError.invalidCredentials(message)
        }
        if case let .invalid(message) = Validator.password(password) {
            throw AuthError.invalidCredentials(message)
        }
    }

    private func profile(for email: String) -> UserProfile {
        let handle = email.split(separator: "@").first.map(String.init) ?? "Marvel Fan"
        return UserProfile(
            email: email,
            displayName: handle.uppercased(),
            avatarImageName: "avatar_2",
            selectedPlanID: nil,
            paymentMethod: nil
        )
    }

    private func sleep() async throws {
        if latency > .zero { try await Task.sleep(for: latency) }
    }
}
