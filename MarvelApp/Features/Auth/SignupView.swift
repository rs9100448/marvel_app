//
//  SignupView.swift
//  MarvelApp
//
//  Email + password sign-up with live validation and social sign-in options.
//  On success the user's profile is stored and the plans step is pushed.
//

import SwiftUI

struct SignupView: View {
    @Environment(Router.self) private var router
    @Environment(SessionStore.self) private var session

    @State private var viewModel = SignupViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                MarvelLogo(width: 188)
                    .padding(.top, 48)
                    .padding(.bottom, 40)

                VStack(spacing: 14) {
                    MarvelTextField(
                        placeholder: "Enter your Email ID",
                        text: $viewModel.email,
                        keyboard: .emailAddress,
                        textContentType: .username,
                        validator: Validator.email
                    )

                    MarvelTextField(
                        placeholder: "Password",
                        text: $viewModel.password,
                        isSecure: true,
                        textContentType: .password,
                        submitLabel: .go,
                        validator: Validator.password,
                        onSubmit: submit
                    )
                }

                MarvelButton(
                    title: "Signup",
                    style: viewModel.isFormValid ? .filled : .outline,
                    isLoading: viewModel.isLoading,
                    action: submit
                )
                .padding(.top, 24)

                Text("Forgot Password?")
                    .font(AppFont.link)
                    .foregroundStyle(Theme.Colors.textPrimary.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 12)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(AppFont.caption)
                        .foregroundStyle(Theme.Colors.red)
                        .padding(.top, 12)
                }

                orDivider.padding(.top, 40)
                socialButtons.padding(.top, 24)
                loginPrompt.padding(.top, 40)
            }
            .padding(.horizontal, Theme.Spacing.screenH)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .screenBackground()
    }

    // MARK: Sections
    private var orDivider: some View {
        VStack(spacing: 16) {
            Text("or")
                .font(AppFont.headline)
                .foregroundStyle(Theme.Colors.textPrimary.opacity(0.5))
            Text("Continue With")
                .font(AppFont.headline)
                .foregroundStyle(Theme.Colors.textPrimary)
        }
    }

    private var socialButtons: some View {
        HStack(spacing: 16) {
            socialButton(image: "brand_facebook", label: "Facebook") { social(.facebook) }
            socialButton(image: "brand_google", label: "Google") { social(.google) }
        }
    }

    private func socialButton(image: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(image).resizable().scaledToFit().frame(width: 22, height: 22)
                Text(label).font(AppFont.field).foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Theme.Colors.fieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.field))
        }
        .buttonStyle(.plain)
    }

    private var loginPrompt: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .foregroundStyle(Theme.Colors.textPrimary.opacity(0.5))
            Text("Login")
                .foregroundStyle(Theme.Colors.red)
        }
        .font(AppFont.link)
    }

    // MARK: Actions
    private func submit() {
        Task {
            if let profile = await viewModel.signUp() {
                session.signIn(profile: profile)
                router.advanceAuth(to: .plans)
            }
        }
    }

    private func social(_ provider: SocialProvider) {
        Task {
            if let profile = await viewModel.signIn(with: provider) {
                session.signIn(profile: profile)
                router.advanceAuth(to: .plans)
            }
        }
    }
}

#Preview {
    NavigationStack { SignupView() }.inject(.preview)
}
