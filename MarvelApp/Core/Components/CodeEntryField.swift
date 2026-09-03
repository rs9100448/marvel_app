//
//  CodeEntryField.swift
//  MarvelApp
//
//  A fixed-length numeric code entry (used for OTP and login PIN). Renders a row
//  of boxes backed by a single hidden text field.
//

import SwiftUI

struct CodeEntryField: View {
    @Binding var code: String
    var length: Int = 6
    var isSecure: Bool = false

    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            // Hidden field captures keystrokes.
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focused)
                .opacity(0.001)
                .onChange(of: code) { _, newValue in
                    code = String(newValue.filter(\.isNumber).prefix(length))
                }

            HStack(spacing: 12) {
                ForEach(0..<length, id: \.self) { index in
                    box(at: index)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { focused = true }
        }
        .onAppear { focused = true }
    }

    private func box(at index: Int) -> some View {
        let characters = Array(code)
        let hasValue = index < characters.count
        let display: String = hasValue ? (isSecure ? "•" : String(characters[index])) : ""
        let isActive = index == characters.count

        return Text(display)
            .font(AppFont.headline)
            .foregroundStyle(Theme.Colors.textPrimary)
            .frame(width: 44, height: 52)
            .background(RoundedRectangle(cornerRadius: Theme.Radius.field).fill(Theme.Colors.surface))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.field)
                    .stroke(isActive && focused ? Theme.Colors.red : Theme.Colors.divider,
                            lineWidth: isActive && focused ? 2 : 1)
            )
    }
}
