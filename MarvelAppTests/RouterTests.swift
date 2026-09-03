//
//  RouterTests.swift
//  MarvelAppTests
//

import Testing
import Foundation
@testable import MarvelApp

@MainActor
struct RouterTests {

    @Test func beginPicksFlowFromState() {
        let a = Router(); a.begin(isOnboardingComplete: false, isAuthenticated: false)
        #expect(a.flow == .onboarding)

        let b = Router(); b.begin(isOnboardingComplete: true, isAuthenticated: false)
        #expect(b.flow == .auth)

        let c = Router(); c.begin(isOnboardingComplete: true, isAuthenticated: true)
        #expect(c.flow == .main)
    }

    @Test func pushAddsToSelectedTabStack() {
        let router = Router()
        router.flow = .main
        router.push(.titleDetail(id: "m1"), on: .home)
        #expect(router.selectedTab == .home)
        #expect(router.homePath == [.titleDetail(id: "m1")])
    }

    @Test func deepLinkTitleWhenAuthenticatedPushesDetail() {
        let router = Router()
        router.flow = .main
        router.handle(.title(id: "s1"), isAuthenticated: true)
        #expect(router.flow == .main)
        #expect(router.selectedTab == .home)
        #expect(router.homePath.contains(.titleDetail(id: "s1")))
    }

    @Test func deepLinkWhenUnauthenticatedStashesPending() {
        let router = Router()
        router.flow = .auth
        router.handle(.title(id: "s1"), isAuthenticated: false)
        #expect(router.flow == .auth)
        #expect(router.pendingDeepLink == .title(id: "s1"))

        // Once the user enters the main app, the pending link is applied.
        router.enterMainApp()
        #expect(router.flow == .main)
        #expect(router.homePath.contains(.titleDetail(id: "s1")))
        #expect(router.pendingDeepLink == nil)
    }

    @Test func categoriesDeepLinkSelectsTabAndKind() {
        let router = Router()
        router.flow = .main
        router.handle(.categories(kind: .series), isAuthenticated: true)
        #expect(router.selectedTab == .categories)
        #expect(router.categoriesPath == [.categoryList(kind: .series)])
    }

    @Test func logoutResetsEverything() {
        let router = Router()
        router.flow = .main
        router.push(.settings, on: .more)
        router.logout()
        #expect(router.flow == .auth)
        #expect(router.morePath.isEmpty)
        #expect(router.selectedTab == .home)
    }

    @Test func handleURLReturnsFalseForUnknown() {
        let router = Router()
        #expect(router.handle(url: URL(string: "https://example.com")!, isAuthenticated: true) == false)
        #expect(router.handle(url: URL(string: "marvelapp://home")!, isAuthenticated: true) == true)
    }
}
