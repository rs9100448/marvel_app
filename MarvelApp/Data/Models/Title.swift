//
//  Title.swift
//  MarvelApp
//
//  A unified content model representing either a Movie or a Series. Backed by
//  the bundled dummy JSON today; the same shape can be decoded from a real API
//  later without touching the UI layer.
//

import Foundation

enum TitleKind: String, Codable, CaseIterable, Identifiable {
    case movie
    case series

    var id: String { rawValue }
    var displayName: String { self == .movie ? "Movie" : "Series" }
    var pluralName: String { self == .movie ? "Movies" : "Series" }
}

struct CastMember: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let character: String
}

struct Title: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let kind: TitleKind
    let posterName: String       // Asset-catalog image name
    let year: Int
    let ageRating: String        // e.g. "PG-13"
    let durationMinutes: Int
    let genres: [String]
    let overview: String
    let cast: [CastMember]
    let isFeatured: Bool          // Shown in the "Latest" hero slots
    let isTrending: Bool

    var durationText: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    var genreText: String { genres.joined(separator: " • ") }
}
