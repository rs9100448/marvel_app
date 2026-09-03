//
//  DeepLinkParserTests.swift
//  MarvelAppTests
//

import Testing
import Foundation
@testable import MarvelApp

@MainActor
struct DeepLinkParserTests {

    private func parse(_ string: String) -> DeepLink? {
        guard let url = URL(string: string) else { return nil }
        return DeepLinkParser.parse(url)
    }

    @Test func parsesTabs() {
        #expect(parse("marvelapp://home") == .tab(.home))
        #expect(parse("marvelapp://downloads") == .tab(.downloads))
        #expect(parse("marvelapp://more") == .tab(.more))
    }

    @Test func parsesTitle() {
        #expect(parse("marvelapp://title/m1") == .title(id: "m1"))
        #expect(parse("marvelapp://movie/s2") == .title(id: "s2"))
        #expect(parse("marvelapp://title") == nil) // missing id
    }

    @Test func parsesCategoriesWithKind() {
        #expect(parse("marvelapp://categories") == .categories(kind: nil))
        #expect(parse("marvelapp://categories?kind=movie") == .categories(kind: .movie))
        #expect(parse("marvelapp://categories?kind=series") == .categories(kind: .series))
        #expect(parse("marvelapp://categories?kind=bogus") == .categories(kind: nil))
    }

    @Test func parsesSettingsAndAccount() {
        #expect(parse("marvelapp://settings") == .settings)
        #expect(parse("marvelapp://account") == .account)
        #expect(parse("marvelapp://watchlist") == .watchlist)
    }

    @Test func parsesAuthLinks() {
        #expect(parse("marvelapp://signup") == .signup)
        #expect(parse("marvelapp://onboarding") == .onboarding)
        #expect(parse("marvelapp://plans") == .plans)
    }

    @Test func rejectsUnknownSchemesAndHosts() {
        #expect(parse("https://marvel.com/home") == nil)
        #expect(parse("marvelapp://unknownhost") == nil)
        #expect(parse("otherapp://home") == nil)
    }
}
