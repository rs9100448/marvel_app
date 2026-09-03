//
//  MarvelTextField.swift
//  MarvelApp
//
//  The white input field from the design, with built-in validation display,
//  optional secure entry with a Show/Hide toggle, and an inline error message.
//  Validation runs on every change but the error is only shown after the field
//  has been "touched" (edited then blurred, or a submit was attempted).
//

import SwiftUI

struct MarvelTextField: View {
    let placeholder: String
    @Binding var text: String

    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var autocapitalization: TextInputAutocapitalization = .never
    var submitLabel: SubmitLabel = .next
    /// Validator run against the current text. `nil` means "no validation".
    var validator: ((String) -> ValidationResult)?
    var onSubmit: (() -> Void)?

    @State private var isRevealed = false
    @State private var isTouched = false
    @FocusState private var isFocused: Bool

    private var validation: ValidationResult { validator?(text) ?? .valid }
    private var showError: Bool { isTouched && !validation.isValid }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Group {
                    if isSecure && !isRevealed {
                        SecureField("", text: $text, prompt: prompt)
                    } else {
                        TextField("", text: $text, prompt: prompt)
                    }
                }
                .font(AppFont.field)
                .foregroundStyle(Theme.Colors.fieldText)
                .tint(Theme.Colors.red)
                .keyboardType(keyboard)
                .textContentType(textContentType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .submitLabel(submitLabel)
                .focused($isFocused)
                .onSubmit { isTouched = true; onSubmit?() }

                if isSecure {
                    Button(isRevealed ? "Hide" : "Show") { isRevealed.toggle() }
                        .font(AppFont.caption)
                        .foregroundStyle(Theme.Colors.fieldText.opacity(0.7))
                        .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(Theme.Colors.fieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.field))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.field)
                    .stroke(showError ? Theme.Colors.red : .clear, lineWidth: 1.5)
            )
            .onChange(of: isFocused) { _, focused in
                if !focused { isTouched = true }
            }

            if showError, let message = validation.errorMessage {
                Text(message)
                    .font(AppFont.caption)
                    .foregroundStyle(Theme.Colors.red)
                    .transition(.opacity)
                    .accessibilityIdentifier("error_\(placeholder)")
            }
        }
        .animation(.easeInOut(duration: 0.15), value: showError)
    }

    private var prompt: Text {
        Text(placeholder).foregroundColor(Theme.Colors.fieldPlaceholder)
    }
}
