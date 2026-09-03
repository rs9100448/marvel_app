//
//  LibraryStore.swift
//  MarvelApp
//
//  Tracks the user's Watchlist and Downloads. In-memory and observable so the
//  Home, Detail, Watchlist and Downloads screens stay in sync. Persisted via
//  the KeyValueStore seam.
//

import Foundation

@Observable
final class LibraryStore {

    enum Keys {
        static let watchlist = "library.watchlist"
        static let downloads = "library.downloads"
    }

    @ObservationIgnored private let store: KeyValueStore

    private(set) var watchlistIDs: Set<String>
    private(set) var downloadIDs: Set<String>

    init(store: KeyValueStore = UserDefaults.standard) {
        self.store = store
        self.watchlistIDs = Self.decodeSet(store.data(forKey: Keys.watchlist))
        self.downloadIDs = Self.decodeSet(store.data(forKey: Keys.downloads))
    }

    // MARK: Watchlist
    func isInWatchlist(_ id: String) -> Bool { watchlistIDs.contains(id) }

    func toggleWatchlist(_ id: String) {
        if watchlistIDs.contains(id) { watchlistIDs.remove(id) } else { watchlistIDs.insert(id) }
        persist(watchlistIDs, key: Keys.watchlist)
    }

    // MARK: Downloads
    func isDownloaded(_ id: String) -> Bool { downloadIDs.contains(id) }

    func toggleDownload(_ id: String) {
        if downloadIDs.contains(id) { downloadIDs.remove(id) } else { downloadIDs.insert(id) }
        persist(downloadIDs, key: Keys.downloads)
    }

    func clearDownloads() {
        downloadIDs.removeAll()
        persist(downloadIDs, key: Keys.downloads)
    }

    // MARK: Persistence
    private func persist(_ set: Set<String>, key: String) {
        store.set(try? JSONEncoder().encode(set), forKey: key)
    }

    private static func decodeSet(_ data: Data?) -> Set<String> {
        guard let data else { return [] }
        return (try? JSONDecoder().decode(Set<String>.self, from: data)) ?? []
    }
}
