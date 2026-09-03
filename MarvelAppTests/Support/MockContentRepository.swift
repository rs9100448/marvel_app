//
//  MockContentRepository.swift
//  MarvelAppTests
//
//  In-memory ContentRepository used to drive view-model and navigation tests
//  without touching the app bundle.
//

import Foundation
@testable import MarvelApp

final class MockContentRepository: ContentRepository {
    var titles: [Title]
    var plansList: [Plan]
    var avatarsList: [Avatar]

    init(titles: [Title] = MockContentRepository.sampleTitles,
         plans: [Plan] = MockContentRepository.samplePlans,
         avatars: [Avatar] = MockContentRepository.sampleAvatars) {
        self.titles = titles
        self.plansList = plans
        self.avatarsList = avatars
    }

    func allTitles() throws -> [Title] { titles }
    func titles(of kind: TitleKind) throws -> [Title] { titles.filter { $0.kind == kind } }
    func featured(kind: TitleKind) throws -> [Title] { titles.filter { $0.kind == kind && $0.isFeatured } }
    func trending() throws -> [Title] { titles.filter(\.isTrending) }
    func title(id: String) throws -> Title? { titles.first { $0.id == id } }
    func plans() throws -> [Plan] { plansList }
    func plan(id: String) throws -> Plan? { plansList.first { $0.id == id } }
    func avatars() throws -> [Avatar] { avatarsList }

    // MARK: Samples
    static func makeTitle(id: String, kind: TitleKind, featured: Bool = false, trending: Bool = false) -> Title {
        Title(id: id, name: "Title \(id)", kind: kind, posterName: "poster_iron_man",
              year: 2020, ageRating: "PG-13", durationMinutes: 120, genres: ["Action"],
              overview: "Overview", cast: [CastMember(id: "c1", name: "Actor", character: "Hero")],
              isFeatured: featured, isTrending: trending)
    }

    static let sampleTitles: [Title] = [
        makeTitle(id: "m1", kind: .movie, featured: true, trending: true),
        makeTitle(id: "m2", kind: .movie),
        makeTitle(id: "s1", kind: .series, featured: true),
        makeTitle(id: "s2", kind: .series, trending: true)
    ]

    static let samplePlans: [Plan] = [
        Plan(id: "plan_all", name: "Movies & Series", pricePerMonth: 20, includedKinds: [.movie, .series]),
        Plan(id: "plan_movies", name: "Movies", pricePerMonth: 15, includedKinds: [.movie])
    ]

    static let sampleAvatars: [Avatar] = [
        Avatar(id: "avatar_1", imageName: "avatar_1"),
        Avatar(id: "avatar_2", imageName: "avatar_2")
    ]
}
