//
//  HomeViewModel.swift
//  MarvelApp
//

import Foundation

@Observable
@MainActor
final class HomeViewModel {
    private(set) var latestMovies: [Title] = []
    private(set) var latestSeries: [Title] = []
    private(set) var trending: [Title] = []
    private(set) var loadError: String?

    @ObservationIgnored private let repository: ContentRepository
    init(repository: ContentRepository = JSONContentRepository()) { self.repository = repository }

    func load() {
        do {
            let movies = try repository.titles(of: .movie)
            let series = try repository.titles(of: .series)
            latestMovies = movies.sorted { $0.isFeatured && !$1.isFeatured }
            latestSeries = series.sorted { $0.isFeatured && !$1.isFeatured }
            trending = try repository.trending()
            loadError = nil
        } catch {
            loadError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}
