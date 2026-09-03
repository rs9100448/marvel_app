//
//  AppRouteView.swift
//  MarvelApp
//
//  Single place that maps an `AppRoute` to its destination view. Shared by
//  every tab's navigation stack so any route is reachable from anywhere.
//

import SwiftUI

struct AppRouteView: View {
    let route: AppRoute

    var body: some View {
        switch route {
        case .titleDetail(let id):
            TitleDetailView(titleID: id)
        case .categoryList(let kind):
            CategoryListView(kind: kind)
        case .watchlist:
            WatchlistView()
        case .account:
            AccountView()
        case .settings:
            SettingsView()
        case .generalSettings:
            InfoScreen(title: "General Settings", message: "Manage general preferences here.")
        case .privacySettings:
            InfoScreen(title: "Privacy Settings", message: "Control how your data is used.")
        case .legal:
            InfoScreen(title: "Legal", message: "Terms of Service, Privacy Policy and licences.")
        case .support:
            InfoScreen(title: "Support", message: "Need help? Reach the Marvel support team.")
        case .parentalControl:
            InfoScreen(title: "Parental Control", message: "Set content restrictions for younger viewers.")
        }
    }
}

/// Lightweight placeholder detail screen so every menu item is navigable.
struct InfoScreen: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 44))
                .foregroundStyle(Theme.Colors.red)
            Text(message)
                .font(AppFont.bodyMedium)
                .foregroundStyle(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.Colors.background, for: .navigationBar)
    }
}
