//
//  MarvelButton.swift
//  MarvelApp
//
//  The two button styles used throughout the design: a solid red primary
//  button and a red-outlined secondary button. Supports a loading state and
//  disabled styling.
//

import SwiftUI

struct MarvelButton: View {
    enum Style { case filled, outline }

    let title: String
    var style: Style = .filled
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    private var interactive: Bool { isEnabled && !isLoading }

    var body: some View {
        Button(action: action) {
            ZStack {
                background
                if isLoading {
                    ProgressView()
                        .tint(style == .filled ? .white : Theme.Colors.red)
                } else {
                    Text(title)
                        .font(AppFont.button)
                        .foregroundStyle(foreground)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!interactive)
        .opacity(isEnabled ? 1 : 0.5)
        .animation(.easeInOut(duration: 0.15), value: isLoading)
        .accessibilityLabel(title)
    }

    @ViewBuilder private var background: some View {
        switch style {
        case .filled:
            RoundedRectangle(cornerRadius: Theme.Radius.button)
                .fill(Theme.Colors.red)
        case .outline:
            RoundedRectangle(cornerRadius: Theme.Radius.button)
                .fill(Theme.Colors.background)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.button)
                        .stroke(Theme.Colors.red, lineWidth: Theme.Border.regular)
                )
        }
    }

    private var foreground: Color {
        Theme.Colors.textPrimary
    }
}

#Preview {
    VStack(spacing: 20) {
        MarvelButton(title: "Continue", style: .filled) {}
        MarvelButton(title: "Continue", style: .outline) {}
        MarvelButton(title: "Loading", style: .filled, isLoading: true) {}
        MarvelButton(title: "Disabled", style: .filled, isEnabled: false) {}
    }
    .padding(30)
    .background(Theme.Colors.background)
}
