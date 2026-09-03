//
//  PaymentMethodView.swift
//  MarvelApp
//
//  Step 2 of the subscription flow: choose how to pay.
//

import SwiftUI

struct PaymentMethodView: View {
    @Environment(Router.self) private var router
    @Environment(SessionStore.self) private var session
    @Environment(\.container) private var container

    @State private var selected: PaymentMethod = .card

    private var plan: Plan? {
        guard let id = session.profile?.selectedPlanID else { return nil }
        return try? container.contentRepository.plan(id: id)
    }

    var body: some View {
        VStack(spacing: 0) {
            StepIndicatorView(currentStep: 2, totalSteps: 3).padding(.top, 8)

            ScrollView {
                VStack(spacing: 20) {
                    MarvelLogo(width: 160).padding(.top, 40)
                    Text("Choose how to pay")
                        .font(AppFont.title)
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .padding(.bottom, 12)

                    ForEach(PaymentMethod.allCases) { method in
                        optionCard(method)
                    }

                    planSummary.padding(.top, 12)
                }
                .padding(.horizontal, Theme.Spacing.screenH)
                .padding(.vertical, 16)
            }

            MarvelButton(title: "Continue", style: .outline, action: continueTapped)
                .padding(.horizontal, Theme.Spacing.screenH)
                .padding(.bottom, 20)
        }
        .screenBackground()
        .toolbarBackground(Theme.Colors.background, for: .navigationBar)
    }

    private func optionCard(_ method: PaymentMethod) -> some View {
        let isSelected = selected == method
        return Button { selected = method } label: {
            Text(method.displayName)
                .font(AppFont.headline)
                .foregroundStyle(Theme.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .fill(isSelected ? Theme.Colors.red.opacity(0.12) : Theme.Colors.background)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .stroke(Theme.Colors.red, lineWidth: isSelected ? Theme.Border.regular : 1.5)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    @ViewBuilder private var planSummary: some View {
        if let plan {
            HStack {
                Text("\(plan.name) \(plan.priceTextLong)")
                    .font(AppFont.bodyMedium)
                    .foregroundStyle(Theme.Colors.textPrimary)
                Spacer()
                Button("Change") { router.authPath.removeLast() }
                    .font(AppFont.field)
                    .foregroundStyle(Theme.Colors.red)
                    .buttonStyle(.plain)
            }
        }
    }

    private func continueTapped() {
        switch selected {
        case .card:
            router.advanceAuth(to: .cardDetails)
        case .netbanking:
            session.updateProfile { $0.paymentMethod = .netbanking }
            router.advanceAuth(to: .createProfile)
        }
    }
}

#Preview {
    NavigationStack { PaymentMethodView() }.inject(.preview)
}
