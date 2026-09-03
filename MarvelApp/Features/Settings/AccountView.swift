//
//  AccountView.swift
//  MarvelApp
//
//  Shows the signed-in user's profile, subscription plan and payment method.
//

import SwiftUI

struct AccountView: View {
    @Environment(\.container) private var container
    @Environment(SessionStore.self) private var session

    private var plan: Plan? {
        guard let id = session.profile?.selectedPlanID else { return nil }
        return try? container.contentRepository.plan(id: id)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AvatarRingView(imageName: session.profile?.avatarImageName ?? "avatar_2",
                               size: 120, ringCount: 4)
                    .padding(.top, 16)

                Text(session.profile?.displayName ?? "Marvel Fan")
                    .font(AppFont.title).foregroundStyle(.white)

                VStack(spacing: 0) {
                    infoRow("Email", session.profile?.email ?? "—")
                    AppDivider()
                    infoRow("Plan", plan.map { "\($0.name) · \($0.priceTextLong)" } ?? "No plan selected")
                    AppDivider()
                    infoRow("Payment", session.profile?.paymentMethod?.displayName ?? "Not set")
                }
                .padding(Theme.Spacing.md)
                .background(RoundedRectangle(cornerRadius: Theme.Radius.card).fill(Theme.Colors.surface))
                .padding(.horizontal, Theme.Spacing.md)
            }
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .screenBackground()
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.Colors.background, for: .navigationBar)
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(AppFont.field).foregroundStyle(Theme.Colors.textSecondary)
            Spacer()
            Text(value).font(AppFont.field).foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack { AccountView() }.inject(.preview)
}
