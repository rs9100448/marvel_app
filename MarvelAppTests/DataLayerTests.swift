//
//  DataLayerTests.swift
//  MarvelAppTests
//

import Testing
import Foundation
@testable import MarvelApp

@MainActor
struct DataLayerTests {

    // MARK: Bundled JSON decodes and is internally consistent.
    @Test func bundledContentLoads() throws {
        let repo = JSONContentRepository(bundle: .main)
        let titles = try repo.allTitles()
        #expect(!titles.isEmpty)
        #expect(try !repo.titles(of: .movie).isEmpty)
        #expect(try !repo.titles(of: .series).isEmpty)
        #expect(try !repo.plans().isEmpty)
        #expect(try repo.avatars().count == 8)
    }

    @Test func lookupById() throws {
        let repo = MockContentRepository()
        #expect(try repo.title(id: "m1")?.id == "m1")
        #expect(try repo.title(id: "missing") == nil)
        #expect(try repo.plan(id: "plan_all")?.pricePerMonth == 20)
    }

    @Test func filteringHelpers() throws {
        let repo = MockContentRepository()
        #expect(try repo.featured(kind: .movie).allSatisfy { $0.isFeatured && $0.kind == .movie })
        #expect(try repo.trending().allSatisfy(\.isTrending))
    }

    @Test func missingResourceThrows() {
        #expect(throws: (any Error).self) {
            _ = try BundleJSONLoader.load([String].self, from: "does_not_exist", in: .main)
        }
    }

    // MARK: Model conveniences
    @Test func durationText() {
        let t = MockContentRepository.makeTitle(id: "x", kind: .movie)
        #expect(t.durationText == "2h 0m")
    }

    @Test func planPriceText() {
        let plan = Plan(id: "p", name: "Movies", pricePerMonth: 15, includedKinds: [.movie])
        #expect(plan.priceText == "$15/mth")
        #expect(plan.priceTextLong == "$15/month")
    }
}
