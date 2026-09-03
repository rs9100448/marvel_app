//
//  CardDetailsView.swift
//  MarvelApp
//
//  Step 3 of the subscription flow: enter and validate card details, matching
//  the Figma form (First/Last name, card number, expiry, CVV).
//

import SwiftUI

struct CardDetailsView: View {
    @Environment(Router.self) private var router
    @Environment(SessionStore.self) private var session
    @Environment(\.container) private var container

    @State private var viewModel = PaymentViewModel()

    private var plan: Plan? {
        guard let id = session.profile?.selectedPlanID else { return nil }
        return try? container.contentRepository.plan(id: id)
    }

    var body: some View {
        VStack(spacing: 0) {
            StepIndicatorView(currentStep: 3, totalSteps: 3).padding(.top, 8)

            ScrollView {
                VStack(spacing: 16) {
                    MarvelLogo(width: 140).padding(.top, 24)
                    Text("Fill your Credit / Debit\nCard Details")
                        .font(AppFont.headline)
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 4)

                    MarvelTextField(placeholder: "First Name", text: $viewModel.firstName,
                                    autocapitalization: .words,
                                    validator: { Validator.requiredText($0, field: "First name", minLength: 2) })
                    MarvelTextField(placeholder: "Last Name", text: $viewModel.lastName,
                                    autocapitalization: .words,
                                    validator: { Validator.requiredText($0, field: "Last name") })
                    MarvelTextField(placeholder: "Card Number", text: $viewModel.cardNumber,
                                    keyboard: .numberPad, textContentType: .creditCardNumber,
                                    validator: Validator.cardNumber)
                    MarvelTextField(placeholder: "Expiration Date (MM/YY)", text: $viewModel.expiry,
                                    keyboard: .numberPad, validator: { Validator.expiry($0) })
                    MarvelTextField(placeholder: "Security Code (CVV)", text: $viewModel.cvv,
                                    isSecure: true, keyboard: .numberPad, validator: Validator.cvv)

                    PlanSummaryBar(plan: plan) { router.authPath.removeLast() }
                        .padding(.top, 4)
                }
                .padding(.horizontal, Theme.Spacing.screenH)
                .padding(.vertical, 16)
            }

            MarvelButton(title: "Continue",
                         style: viewModel.isCardFormValid ? .filled : .outline,
                         isEnabled: viewModel.isCardFormValid,
                         action: continueTapped)
                .padding(.horizontal, Theme.Spacing.screenH)
                .padding(.bottom, 20)
        }
        .screenBackground()
        .toolbarBackground(Theme.Colors.background, for: .navigationBar)
    }

    private func continueTapped() {
        session.updateProfile { $0.paymentMethod = .card }
        router.advanceAuth(to: .otp)
    }
}

#Preview {
    NavigationStack { CardDetailsView() }.inject(.preview)
}
