//
//  JSONContentRepository.swift
//  MarvelApp
//
//  Default ContentRepository backed by the bundled dummy JSON. Data is loaded
//  once and cached. Replace this class with an API-backed repository when the
//  backend becomes available — nothing else in the app needs to change.
//

import Foundation

nonisolated final class JSONContentRepository: ContentRepository {

    private let bundle: Bundle
    private lazy var titlesCache: [Title] = (try? loadTitles()) ?? []
    private lazy var plansCache: [Plan] = (try? loadPlans()) ?? []
    private lazy var avatarsCache: [Avatar] = (try? loadAvatars()) ?? []

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    // MARK: Loading
    private struct TitlesFile: Decodable { let titles: [Title] }
    private struct PlansFile: Decodable { let plans: [Plan] }
    private struct AvatarsFile: Decodable { let avatars: [Avatar] }

    private func loadTitles() throws -> [Title] {
        try BundleJSONLoader.load(TitlesFile.self, from: "content", in: bundle).titles
    }
    private func loadPlans() throws -> [Plan] {
        try BundleJSONLoader.load(PlansFile.self, from: "plans", in: bundle).plans
    }
    private func loadAvatars() throws -> [Avatar] {
        try BundleJSONLoader.load(AvatarsFile.self, from: "avatars", in: bundle).avatars
    }

    // MARK: ContentRepository
    func allTitles() throws -> [Title] { titlesCache }

    func titles(of kind: TitleKind) throws -> [Title] {
        titlesCache.filter { $0.kind == kind }
    }

    func featured(kind: TitleKind) throws -> [Title] {
        titlesCache.filter { $0.kind == kind && $0.isFeatured }
    }

    func trending() throws -> [Title] {
        titlesCache.filter(\.isTrending)
    }

    func title(id: String) throws -> Title? {
        titlesCache.first { $0.id == id }
    }

    func plans() throws -> [Plan] { plansCache }

    func plan(id: String) throws -> Plan? {
        plansCache.first { $0.id == id }
    }

    func avatars() throws -> [Avatar] { avatarsCache }
}
