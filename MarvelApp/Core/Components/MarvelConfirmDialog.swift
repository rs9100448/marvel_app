//
//  MarvelConfirmDialog.swift
//  MarvelApp
//
//  A themed modal confirmation card (e.g. "Delete this Downloaded content?").
//  Presented as an overlay via the `confirmDialog` view modifier.
//

import SwiftUI

struct MarvelConfirmDialog: View {
    let message: String
    var confirmTitle: String = "Yes"
    var cancelTitle: String = "No"
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture(perform: onCancel)

            VStack(spacing: 20) {
                Text(message)
                    .font(AppFont.field)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    MarvelButton(title: cancelTitle, style: .outline, action: onCancel)
                    MarvelButton(title: confirmTitle, style: .filled, action: onConfirm)
                }
            }
            .padding(20)
            .frame(maxWidth: 320)
            .background(RoundedRectangle(cornerRadius: Theme.Radius.card).fill(Theme.Colors.surface))
            .overlay(RoundedRectangle(cornerRadius: Theme.Radius.card).stroke(Theme.Colors.divider, lineWidth: 1))
            .padding(.horizontal, 24)
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
    }
}

extension View {
    /// Presents a themed confirmation dialog when `isPresented` is true.
    func confirmDialog(
        isPresented: Binding<Bool>,
        message: String,
        confirmTitle: String = "Yes",
        cancelTitle: String = "No",
        onConfirm: @escaping () -> Void
    ) -> some View {
        overlay {
            if isPresented.wrappedValue {
                MarvelConfirmDialog(
                    message: message,
                    confirmTitle: confirmTitle,
                    cancelTitle: cancelTitle,
                    onConfirm: { isPresented.wrappedValue = false; onConfirm() },
                    onCancel: { isPresented.wrappedValue = false }
                )
                .animation(.easeInOut(duration: 0.2), value: isPresented.wrappedValue)
            }
        }
    }
}
