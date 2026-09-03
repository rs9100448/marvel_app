//
//  PINSetupView.swift
//  MarvelApp
//
//  Sets a 4-digit profile login PIN, shown after avatar selection.
//

import SwiftUI

struct PINSetupView: View {
    @Environment(Router.self) private var router
    @State private var pin = ""

    private var isValid: Bool { pin.count == 4 }

    var body: some View {
        VStack(spacing: 24) {
            MarvelLogo(width: 150).padding(.top, 48)

            Text("Set your PIN")
                .font(AppFont.title)
                .foregroundStyle(Theme.Colors.textPrimary)

            Text("This pin will be used to log-in to your profile")
                .font(AppFont.body)
                .foregroundStyle(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.screenH)

            CodeEntryField(code: $pin, length: 4, isSecure: true)
                .padding(.vertical, 12)

            Spacer()

            MarvelButton(title: "Continue", style: isValid ? .filled : .outline, isEnabled: isValid) {
                router.advanceAuth(to: .success)
            }
            .padding(.horizontal, Theme.Spacing.screenH)
            .padding(.bottom, 20)
        }
        .screenBackground()
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Theme.Colors.background, for: .navigationBar)
    }
}

#Preview {
    NavigationStack { PINSetupView() }.inject(.preview)
}
