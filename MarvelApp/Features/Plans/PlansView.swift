//
//  PlansView.swift
//  MarvelApp
//
//  Step 1 of the subscription flow: choose a plan.
//

import SwiftUI

struct PlansView: View {
    @Environment(Router.self) private var router
    @Environment(SessionStore.self) private var session

    @State private var viewModel = PlansViewModel()

    var body: some View {
        VStack(spacing: 0) {
            StepIndicatorView(currentStep: 1, totalSteps: 3)
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: 20) {
                    MarvelLogo(width: 160).padding(.top, 40)

                    VStack(spacing: 6) {
                        Text("Choose your Plan").font(AppFont.title)
                            .foregroundStyle(Theme.Colors.textPrimary)
                        Text("Cancel at any time").font(AppFont.bodyMedium)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                    .padding(.bottom, 8)

                    ForEach(viewModel.plans) { plan in
                        planCard(plan)
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenH)
                .padding(.vertical, 16)
            }

            MarvelButton(title: "Continue", style: .outline, isEnabled: viewModel.canContinue, action: continueTapped)
                .padding(.horizontal, Theme.Spacing.screenH)
                .padding(.bottom, 20)
        }
        .screenBackground()
        .navigationBarBackButtonHidden(false)
        .toolbarBackground(Theme.Colors.background, for: .navigationBar)
        .onAppear {
            viewModel.load()
            viewModel.selectedPlanID = session.profile?.selectedPlanID ?? viewModel.selectedPlanID
        }
    }

    private func planCard(_ plan: Plan) -> some View {
        let isSelected = viewModel.selectedPlanID == plan.id
        return Button {
            viewModel.selectedPlanID = plan.id
        } label: {
            HStack {
                Text(plan.name)
                    .font(AppFont.headline)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(plan.priceText)
                    .font(AppFont.headline)
                    .foregroundStyle(Theme.Colors.textPrimary)
            }
            .padding(.horizontal, 20)
            .frame(height: 90)
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

    private func continueTapped() {
        session.updateProfile { $0.selectedPlanID = viewModel.selectedPlanID }
        router.advanceAuth(to: .paymentMethod)
    }
}

#Preview {
    NavigationStack { PlansView() }.inject(.preview)
}
