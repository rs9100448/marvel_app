//
//  CommonViews.swift
//  MarvelApp
//
//  Small shared building blocks: the Marvel logo, section headers, the 1-2-3
//  step indicator, a full-screen background, and the poster card.
//

import SwiftUI

// MARK: - Marvel logo

struct MarvelLogo: View {
    var width: CGFloat = 188
    var body: some View {
        Image("brand_marvel_logo")
            .resizable()
            .scaledToFit()
            .frame(width: width)
            .accessibilityLabel("Marvel")
    }
}

// MARK: - Screen background

struct ScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.Colors.background.ignoresSafeArea())
    }
}

extension View {
    func screenBackground() -> some View { modifier(ScreenBackground()) }
}

// MARK: - Section header

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(AppFont.sectionTitle)
            .foregroundStyle(Theme.Colors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Step indicator (Plans → Payment → Card)

struct StepIndicatorView: View {
    /// Current step, 1-based.
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...totalSteps, id: \.self) { step in
                circle(for: step)
                if step < totalSteps {
                    Rectangle()
                        .fill(step < currentStep ? Theme.Colors.red : Theme.Colors.redDark)
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 60)
        .accessibilityElement()
        .accessibilityLabel("Step \(currentStep) of \(totalSteps)")
    }

    private func circle(for step: Int) -> some View {
        let active = step <= currentStep
        return Text("\(step)")
            .font(AppFont.caption)
            .foregroundStyle(Theme.Colors.textPrimary)
            .frame(width: 28, height: 28)
            .background(Circle().fill(active ? Theme.Colors.red : Theme.Colors.redDark))
    }
}

// MARK: - Poster card

struct PosterCard: View {
    let title: Title
    /// Fixed width for carousels; pass `nil` (or `.infinity`) to fill a grid
    /// cell using the standard 2:3 poster aspect ratio.
    var width: CGFloat? = 120

    var body: some View {
        poster
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.poster))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.poster)
                    .stroke(Theme.Colors.divider, lineWidth: 0.5)
            )
            .accessibilityLabel(title.name)
    }

    @ViewBuilder private var poster: some View {
        if let width, width != .infinity {
            Image(title.posterName)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: width * 1.5)
        } else {
            Image(title.posterName)
                .resizable()
                .aspectRatio(2.0 / 3.0, contentMode: .fit)
                .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Plan summary bar (payment flow)

struct PlanSummaryBar: View {
    let plan: Plan?
    let onChange: () -> Void

    var body: some View {
        if let plan {
            HStack {
                Text("\(plan.name) \(plan.priceTextLong)")
                    .font(AppFont.bodyMedium)
                    .foregroundStyle(Theme.Colors.textPrimary)
                Spacer()
                Button("Change", action: onChange)
                    .font(AppFont.field)
                    .foregroundStyle(Theme.Colors.red)
                    .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Divider

struct AppDivider: View {
    var body: some View {
        Rectangle()
            .fill(Theme.Colors.divider)
            .frame(height: 1)
    }
}
