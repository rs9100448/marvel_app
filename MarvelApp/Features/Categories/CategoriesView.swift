//
//  CategoriesView.swift
//  MarvelApp
//
//  Browse titles by kind. The tab root offers a Movies/Series switch; the same
//  grid is reused by `CategoryListView` for deep links like
//  `marvelapp://categories?kind=movie`.
//

import SwiftUI

@Observable
@MainActor
final class CategoriesViewModel {
    private(set) var movies: [Title] = []
    private(set) var series: [Title] = []

    @ObservationIgnored private let repository: ContentRepository
    init(repository: ContentRepository = JSONContentRepository()) { self.repository = repository }

    func load() {
        movies = (try? repository.titles(of: .movie)) ?? []
        series = (try? repository.titles(of: .series)) ?? []
    }

    func titles(for kind: TitleKind) -> [Title] { kind == .movie ? movies : series }

    /// Distinct genres available for a kind, with "All" first.
    func genres(for kind: TitleKind) -> [String] {
        let all = titles(for: kind).flatMap(\.genres)
        return ["All"] + Array(Set(all)).sorted()
    }

    func titles(for kind: TitleKind, genre: String) -> [Title] {
        let base = titles(for: kind)
        return genre == "All" ? base : base.filter { $0.genres.contains(genre) }
    }
}

struct CategoriesView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = CategoriesViewModel()
    @State private var kind: TitleKind = .movie
    @State private var genre = "All"

    var body: some View {
        VStack(spacing: 14) {
            Picker("Kind", selection: $kind) {
                ForEach(TitleKind.allCases) { Text($0.pluralName).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, 8)
            .onChange(of: kind) { _, _ in genre = "All" }

            GenreChips(genres: viewModel.genres(for: kind), selection: $genre)

            TitleGrid(titles: viewModel.titles(for: kind, genre: genre)) { id in
                router.push(.titleDetail(id: id))
            }
        }
        .screenBackground()
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.Colors.background, for: .navigationBar)
        .onAppear { viewModel.load() }
    }
}

/// Horizontally scrolling genre filter chips.
struct GenreChips: View {
    let genres: [String]
    @Binding var selection: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(genres, id: \.self) { genre in
                    let isSelected = selection == genre
                    Button { selection = genre } label: {
                        Text(genre)
                            .font(AppFont.caption)
                            .foregroundStyle(isSelected ? .white : Theme.Colors.textSecondary)
                            .padding(.horizontal, 16)
                            .frame(height: 34)
                            .background(
                                Capsule().fill(isSelected ? Theme.Colors.red : Theme.Colors.surface)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
        }
    }
}

/// A single-kind grid pushed by deep links.
struct CategoryListView: View {
    let kind: TitleKind
    @Environment(Router.self) private var router
    @State private var viewModel = CategoriesViewModel()

    var body: some View {
        TitleGrid(titles: viewModel.titles(for: kind)) { id in
            router.push(.titleDetail(id: id))
        }
        .screenBackground()
        .navigationTitle(kind.pluralName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.Colors.background, for: .navigationBar)
        .onAppear { viewModel.load() }
    }
}

/// Reusable poster grid.
struct TitleGrid: View {
    let titles: [Title]
    let onSelect: (String) -> Void

    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(titles) { title in
                    Button { onSelect(title.id) } label: {
                        PosterCard(title: title, width: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, 12)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    NavigationStack { CategoriesView() }.inject(.preview)
}
