//
//  OTPView.swift
//  MarvelApp
//
//  Bank OTP entry during the payment flow.
//

import SwiftUI
import Combine

struct OTPView: View {
    @Environment(Router.self) private var router

    @State private var code = ""
    @State private var secondsRemaining = 30
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var isValid: Bool { code.count == 6 }

    var body: some View {
        VStack(spacing: 24) {
            MarvelLogo(width: 150).padding(.top, 40)

            Text("Verify Payment")
                .font(AppFont.title)
                .foregroundStyle(Theme.Colors.textPrimary)

            Text("Please enter the OTP that we’ve sent on your phone number 55XXXXXX99 linked with your bank account.")
                .font(AppFont.body)
                .foregroundStyle(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.screenH)

            CodeEntryField(code: $code, length: 6)
                .padding(.vertical, 8)

            resend

            Spacer()

            MarvelButton(title: "Verify", style: isValid ? .filled : .outline, isEnabled: isValid) {
                router.advanceAuth(to: .paymentProcessing)
            }
            .padding(.horizontal, Theme.Spacing.screenH)
            .padding(.bottom, 20)
        }
        .screenBackground()
        .toolbarBackground(Theme.Colors.background, for: .navigationBar)
        .onReceive(timer) { _ in if secondsRemaining > 0 { secondsRemaining -= 1 } }
    }

    @ViewBuilder private var resend: some View {
        if secondsRemaining > 0 {
            Text("Resend code in 0:\(String(format: "%02d", secondsRemaining))")
                .font(AppFont.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
        } else {
            Button("Resend OTP") { secondsRemaining = 30 }
                .font(AppFont.link)
                .foregroundStyle(Theme.Colors.red)
                .buttonStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack { OTPView() }.inject(.preview)
}
