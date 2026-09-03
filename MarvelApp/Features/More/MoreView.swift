//
//  MoreView.swift
//  MarvelApp
//
//  Account hub with the animated avatar, navigation rows to every settings
//  area, and Sign Out.
//

import SwiftUI

struct MoreView: View {
    @Environment(Router.self) private var router
    @Environment(SessionStore.self) private var session

    private struct Item: Identifiable {
        let id = UUID()
        let title: String
        let route: AppRoute
    }

    private let items: [Item] = [
        .init(title: "Account", route: .account),
        .init(title: "Settings", route: .settings),
        .init(title: "Legal", route: .legal),
        .init(title: "Support", route: .support),
        .init(title: "Privacy Settings", route: .privacySettings),
        .init(title: "Parental Control", route: .parentalControl),
        .init(title: "Watchlist", route: .watchlist)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AvatarRingView(imageName: session.profile?.avatarImageName ?? "avatar_2", size: 150)
                    .padding(.top, 20)

                Text(session.profile?.displayName ?? "Marvel Fan")
                    .font(AppFont.title)
                    .foregroundStyle(.white)
                    .padding(.top, 8)
                    .padding(.bottom, 24)

                VStack(spacing: 0) {
                    ForEach(items) { item in
                        Button { router.push(item.route) } label: { row(item.title) }
                            .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)

                AppDivider().padding(.vertical, 16).padding(.horizontal, Theme.Spacing.md)

                Button(action: signOut) {
                    Text("Sign Out")
                        .font(AppFont.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Theme.Spacing.md)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 40)
            }
        }
        .scrollIndicators(.hidden)
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func row(_ title: String) -> some View {
        HStack {
            Text(title).font(AppFont.headline).foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.white)
        }
        .padding(.vertical, 14)
    }

    private func signOut() {
        session.signOut()
        router.logout()
    }
}

#Preview {
    NavigationStack { MoreView() }.inject(.preview)
}
