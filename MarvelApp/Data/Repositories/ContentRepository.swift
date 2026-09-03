//
//  ContentRepository.swift
//  MarvelApp
//
//  Abstraction over the content data source. The app talks to this protocol,
//  so the JSON-backed implementation used today can be swapped for a networked
//  one without changing any feature code. This is the primary seam for testing.
//

import Foundation

nonisolated protocol ContentRepository {
    func allTitles() throws -> [Title]
    func titles(of kind: TitleKind) throws -> [Title]
    func featured(kind: TitleKind) throws -> [Title]
    func trending() throws -> [Title]
    func title(id: String) throws -> Title?
    func plans() throws -> [Plan]
    func avatars() throws -> [Avatar]
    func plan(id: String) throws -> Plan?
}

extension ContentRepository {
    nonisolated func featuredMovie() throws -> Title? { try featured(kind: .movie).first }
    nonisolated func featuredSeries() throws -> Title? { try featured(kind: .series).first }
}
