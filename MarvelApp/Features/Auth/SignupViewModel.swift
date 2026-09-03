//
//  SignupViewModel.swift
//  MarvelApp
//
//  Owns the sign-up form state, per-field validation and the (dummy) auth call.
//  Navigation and session persistence are performed by the view using the
//  returned profile, keeping this type free of UI/router dependencies and easy
//  to unit-test.
//

import Foundation

@Observable
@MainActor
final class SignupViewModel {
    var email = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored private let auth: AuthService

    init(auth: AuthService = DummyAuthService()) {
        self.auth = auth
    }

    // MARK: Validation
    var emailValidation: ValidationResult { Validator.email(email) }
    var passwordValidation: ValidationResult { Validator.password(password) }
    var isFormValid: Bool { emailValidation.isValid && passwordValidation.isValid }

    // MARK: Actions
    /// Attempts sign-up. Returns the created profile on success, or nil (with
    /// `errorMessage` set) on failure.
    func signUp() async -> UserProfile? {
        guard isFormValid else {
            errorMessage = emailValidation.errorMessage ?? passwordValidation.errorMessage
            return nil
        }
        return await run { try await auth.signUp(email: email, password: password) }
    }

    func signIn(with provider: SocialProvider) async -> UserProfile? {
        await run { try await auth.signIn(with: provider) }
    }

    private func run(_ operation: () async throws -> UserProfile) async -> UserProfile? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            return try await operation()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            return nil
        }
    }
}
