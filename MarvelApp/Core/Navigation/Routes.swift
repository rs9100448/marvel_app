//
//  Routes.swift
//  MarvelApp
//
//  The complete, type-safe map of every destination in the app. Screens are
//  never instantiated ad-hoc; they are reached through these routes, which is
//  what lets both in-app navigation and external deep links share one system.
//

import Foundation

/// Top-level phase of the app.
enum RootFlow: Equatable {
    case splash
    case onboarding
    case auth
    case main
}

/// The four primary tabs of the signed-in experience.
enum AppTab: String, CaseIterable, Identifiable, Hashable {
    case home
    case categories
    case downloads
    case more

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .categories: return "Categories"
        case .downloads: return "Downloads"
        case .more: return "More"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .categories: return "square.stack.fill"
        case .downloads: return "arrow.down.to.line"
        case .more: return "square.grid.2x2.fill"
        }
    }
}

/// Push destinations that live inside a tab's navigation stack.
enum AppRoute: Hashable {
    case titleDetail(id: String)
    case categoryList(kind: TitleKind)
    case watchlist
    case account
    case settings
    case generalSettings
    case privacySettings
    case legal
    case support
    case parentalControl
}

/// Steps of the sign-up / subscription flow, pushed onto the auth stack.
enum AuthRoute: Hashable {
    case plans
    case paymentMethod
    case cardDetails
    case otp
    case paymentProcessing
    case createProfile
    case pinSetup
    case success
}
