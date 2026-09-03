//
//  LibraryViews.swift
//  MarvelApp
//
//  Downloads and Watchlist. Both resolve the stored title ids against the
//  content repository and share a common list layout with an empty state.
//

import SwiftUI

struct DownloadsView: View {
    @Environment(\.container) private var container
    @Environment(LibraryStore.self) private var library
    @Environment(Router.self) private var router

    @State private var pendingDeleteID: String?
    @State private var showDeleteConfirm = false

    private var titles: [Title] {
        library.downloadIDs.compactMap { try? container.contentRepository.title(id: $0) }
    }

    var body: some View {
        LibraryList(
            titles: titles,
            emptyIcon: "arrow.down.circle",
            emptyText: "No downloads yet.\nDownload titles to watch offline.",
            onSelect: { router.push(.titleDetail(id: $0)) },
            onRemove: { id in pendingDeleteID = id; showDeleteConfirm = true }
        )
        .screenBackground()
        .navigationTitle("Downloads")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.Colors.background, for: .navigationBar)
        .confirmDialog(isPresented: $showDeleteConfirm,
                       message: "Delete this Downloaded content?") {
            if let id = pendingDeleteID { library.toggleDownload(id) }
            pendingDeleteID = nil
        }
    }
}

struct WatchlistView: View {
    @Environment(\.container) private var container
    @Environment(LibraryStore.self) private var library
    @Environment(Router.self) private var router

    private var titles: [Title] {
        library.watchlistIDs.compactMap { try? container.contentRepository.title(id: $0) }
    }

    var body: some View {
        LibraryList(
            titles: titles,
            emptyIcon: "bookmark",
            emptyText: "Your watchlist is empty.\nAdd titles you want to watch later.",
            onSelect: { router.push(.titleDetail(id: $0)) },
            onRemove: { library.toggleWatchlist($0) }
        )
        .screenBackground()
        .navigationTitle("Watchlist")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.Colors.background, for: .navigationBar)
    }
}

private struct LibraryList: View {
    let titles: [Title]
    let emptyIcon: String
    let emptyText: String
    let onSelect: (String) -> Void
    let onRemove: (String) -> Void

    var body: some View {
        if titles.isEmpty {
            VStack(spacing: 14) {
                Image(systemName: emptyIcon).font(.system(size: 44)).foregroundStyle(Theme.Colors.textSecondary)
                Text(emptyText)
                    .font(AppFont.bodyMedium)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(titles) { title in
                        Button { onSelect(title.id) } label: { row(title) }
                            .buttonStyle(.plain)
                    }
                }
                .padding(Theme.Spacing.md)
            }
        }
    }

    private func row(_ title: Title) -> some View {
        HStack(spacing: 12) {
            PosterCard(title: title, width: 70)
            VStack(alignment: .leading, spacing: 6) {
                Text(title.name).font(AppFont.field).foregroundStyle(.white)
                Text("\(title.kind.displayName) • \(String(title.year))")
                    .font(AppFont.caption).foregroundStyle(Theme.Colors.textSecondary)
            }
            Spacer()
            Button { onRemove(title.id) } label: {
                Image(systemName: "trash").foregroundStyle(Theme.Colors.red)
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: Theme.Radius.card).fill(Theme.Colors.surface))
    }
}

#Preview {
    NavigationStack { DownloadsView() }.inject(.preview)
}
