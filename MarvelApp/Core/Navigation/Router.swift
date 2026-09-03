//
//  Router.swift
//  MarvelApp
//
//  The single source of truth for navigation. It owns the top-level flow, the
//  selected tab, each tab's navigation stack, and the sign-up flow stack. Both
//  user taps and external deep links flow through the same small API, so every
//  screen is reachable the same way — which is exactly what "connect all pages
//  via deep link" requires.
//

import Foundation

@Observable
final class Router {

    // MARK: Top-level state
    var flow: RootFlow = .splash

    // MARK: Sign-up / subscription flow
    var authPath: [AuthRoute] = []

    // MARK: Main tab state — one navigation stack per tab.
    var selectedTab: AppTab = .home
    var homePath: [AppRoute] = []
    var categoriesPath: [AppRoute] = []
    var downloadsPath: [AppRoute] = []
    var morePath: [AppRoute] = []

    /// A deep link that arrived before the user was authenticated. Applied once
    /// they finish onboarding.
    private(set) var pendingDeepLink: DeepLink?

    // MARK: Flow transitions
    /// Decide the first real screen once the splash finishes.
    func begin(isOnboardingComplete: Bool, isAuthenticated: Bool) {
        if isAuthenticated {
            flow = .main
        } else if isOnboardingComplete {
            flow = .auth
        } else {
            flow = .onboarding
        }
        if let link = pendingDeepLink, isAuthenticated {
            apply(link)
            pendingDeepLink = nil
        }
    }

    func finishOnboarding() {
        authPath = []
        flow = .auth
    }

    func enterMainApp() {
        flow = .main
        authPath = []
        if let link = pendingDeepLink {
            apply(link)
            pendingDeepLink = nil
        }
    }

    /// Returns to the sign-up screen after signing out, clearing all stacks.
    func logout() {
        homePath = []
        categoriesPath = []
        downloadsPath = []
        morePath = []
        authPath = []
        selectedTab = .home
        pendingDeepLink = nil
        flow = .auth
    }

    // MARK: Auth stack
    func advanceAuth(to route: AuthRoute) {
        authPath.append(route)
    }

    func resetAuth() {
        authPath = []
    }

    // MARK: Tab navigation
    func switchTab(_ tab: AppTab) {
        selectedTab = tab
    }

    func push(_ route: AppRoute, on tab: AppTab) {
        selectedTab = tab
        appendRoute(route, to: tab)
    }

    /// Push onto the currently selected tab.
    func push(_ route: AppRoute) {
        appendRoute(route, to: selectedTab)
    }

    func popToRoot(_ tab: AppTab) {
        setPath([], for: tab)
    }

    private func appendRoute(_ route: AppRoute, to tab: AppTab) {
        var path = path(for: tab)
        path.append(route)
        setPath(path, for: tab)
    }

    private func path(for tab: AppTab) -> [AppRoute] {
        switch tab {
        case .home: return homePath
        case .categories: return categoriesPath
        case .downloads: return downloadsPath
        case .more: return morePath
        }
    }

    private func setPath(_ path: [AppRoute], for tab: AppTab) {
        switch tab {
        case .home: homePath = path
        case .categories: categoriesPath = path
        case .downloads: downloadsPath = path
        case .more: morePath = path
        }
    }

    // MARK: Deep linking
    /// Entry point for `marvelapp://` URLs (e.g. from `onOpenURL`).
    @discardableResult
    func handle(url: URL, isAuthenticated: Bool) -> Bool {
        guard let link = DeepLinkParser.parse(url) else { return false }
        handle(link, isAuthenticated: isAuthenticated)
        return true
    }

    func handle(_ link: DeepLink, isAuthenticated: Bool) {
        switch link {
        case .onboarding:
            flow = .onboarding
            return
        case .signup:
            flow = .auth
            authPath = []
            return
        case .plans:
            flow = .auth
            authPath = [.plans]
            return
        default:
            break
        }

        // Everything else targets the signed-in experience.
        guard isAuthenticated, flow == .main else {
            pendingDeepLink = link
            // Route the user toward authentication; the link is applied afterward.
            flow = isAuthenticated ? .main : .auth
            if isAuthenticated { apply(link); pendingDeepLink = nil }
            return
        }
        apply(link)
    }

    /// Applies a link assuming the user is already in the main app.
    private func apply(_ link: DeepLink) {
        flow = .main
        switch link {
        case .tab(let tab):
            selectedTab = tab
            popToRoot(tab)
        case .title(let id):
            push(.titleDetail(id: id), on: .home)
        case .categories(let kind):
            selectedTab = .categories
            categoriesPath = kind.map { [.categoryList(kind: $0)] } ?? []
        case .watchlist:
            push(.watchlist, on: .more)
        case .settings:
            push(.settings, on: .more)
        case .account:
            push(.account, on: .more)
        case .onboarding, .signup, .plans:
            break // handled earlier
        }
    }
}
