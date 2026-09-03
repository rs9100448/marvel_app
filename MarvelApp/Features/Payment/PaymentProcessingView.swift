//
//  PaymentProcessingView.swift
//  MarvelApp
//
//  Interstitial shown while the (simulated) bank verifies the payment. Auto-
//  advances to profile creation.
//

import SwiftUI

struct PaymentProcessingView: View {
    @Environment(Router.self) private var router
    @State private var spin = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Theme.Colors.red, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 64, height: 64)
                    .rotationEffect(.degrees(spin ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: spin)
                Image(systemName: "creditcard.fill")
                    .foregroundStyle(Theme.Colors.red)
            }
            Text("Please wait while we verify your\npayment from the bank...")
                .font(AppFont.bodyMedium)
                .foregroundStyle(Theme.Colors.textPrimary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .screenBackground()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            spin = true
            try? await Task.sleep(for: .seconds(2.5))
            router.advanceAuth(to: .createProfile)
        }
    }
}

#Preview {
    NavigationStack { PaymentProcessingView() }.inject(.preview)
}
