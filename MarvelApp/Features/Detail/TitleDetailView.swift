//
//  TitleDetailView.swift
//  MarvelApp
//
//  Detail screen for a movie or series. Resolves the title by id (so it works
//  from deep links) and offers Download / Watchlist actions plus tabbed
//  Trailer / Cast / More content.
//

import SwiftUI

struct TitleDetailView: View {
    let titleID: String

    @Environment(\.container) private var container
    @Environment(LibraryStore.self) private var library
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: DetailTab = .trailer

    enum DetailTab: String, CaseIterable, Identifiable {
        case trailer = "Trailer", cast = "Cast", more = "More"
        var id: String { rawValue }
    }

    private var title: Title? { try? container.contentRepository.title(id: titleID) }

    var body: some View {
        Group {
            if let title {
                content(for: title)
            } else {
                notFound
            }
        }
        .screenBackground()
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 3)
                }
                .accessibilityLabel("Back")
            }
        }
    }

    private func content(for title: Title) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero(for: title)

                HStack(spacing: 24) {
                    downloadButton(for: title)
                    watchlistButton(for: title)
                    Spacer()
                }
                .padding(.horizontal, Theme.Spacing.md)

                Text(title.overview)
                    .font(AppFont.body)
                    .foregroundStyle(Theme.Colors.textPrimary.opacity(0.85))
                    .padding(.horizontal, Theme.Spacing.md)

                tabBar
                tabContent(for: title)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.bottom, 40)
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
    }

    // MARK: Hero
    private func hero(for title: Title) -> some View {
        ZStack(alignment: .bottom) {
            Image(title.posterName)
                .resizable()
                .scaledToFill()
                .frame(height: 430)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(
                    LinearGradient(colors: [.black.opacity(0.6), .clear, .clear, Theme.Colors.background],
                                   startPoint: .top, endPoint: .bottom)
                )

            Button { } label: {
                Image(systemName: "play.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(Circle().fill(Theme.Colors.red))
            }
            .buttonStyle(.plain)
            .offset(y: 32)
        }
        .overlay(alignment: .top) { heroTitle(title) }
        .frame(height: 430)
    }

    private func heroTitle(_ title: Title) -> some View {
        Text(title.name)
            .font(AppFont.title)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .padding(.top, 60)
            .shadow(radius: 6)
    }


    // MARK: Action buttons
    private func downloadButton(for title: Title) -> some View {
        let isDownloaded = library.isDownloaded(title.id)
        return Button { library.toggleDownload(title.id) } label: {
            HStack(spacing: 8) {
                Image(systemName: isDownloaded ? "checkmark.circle.fill" : "arrow.down.to.line")
                Text(isDownloaded ? "Downloaded" : "Download")
                    .font(AppFont.field)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .frame(height: 44)
            .overlay(RoundedRectangle(cornerRadius: Theme.Radius.button)
                .stroke(Theme.Colors.red, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private func watchlistButton(for title: Title) -> some View {
        let inList = library.isInWatchlist(title.id)
        return Button { library.toggleWatchlist(title.id) } label: {
            HStack(spacing: 6) {
                Image(systemName: inList ? "checkmark" : "plus")
                Text("Watchlist").font(AppFont.field)
            }
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }

    // MARK: Tabs
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(DetailTab.allCases) { tab in
                Button { withAnimation { selectedTab = tab } } label: {
                    VStack(spacing: 8) {
                        Text(tab.rawValue)
                            .font(AppFont.field)
                            .foregroundStyle(selectedTab == tab ? .white : Theme.Colors.textSecondary)
                        Rectangle()
                            .fill(selectedTab == tab ? Theme.Colors.red : .clear)
                            .frame(height: 2)
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .background(Theme.Colors.surface)
    }

    @ViewBuilder private func tabContent(for title: Title) -> some View {
        switch selectedTab {
        case .trailer:
            VStack(alignment: .leading, spacing: 8) {
                Text("Official Trailer").font(AppFont.headline).foregroundStyle(.white)
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .fill(Theme.Colors.surface)
                    .frame(height: 180)
                    .overlay(Image(systemName: "play.circle.fill")
                        .font(.system(size: 44)).foregroundStyle(Theme.Colors.red))
            }
        case .cast:
            VStack(alignment: .leading, spacing: 12) {
                ForEach(title.cast) { member in
                    HStack(spacing: 12) {
                        Circle().fill(Theme.Colors.surface).frame(width: 44, height: 44)
                            .overlay(Text(String(member.name.prefix(1))).foregroundStyle(.white).font(AppFont.field))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(member.name).font(AppFont.field).foregroundStyle(.white)
                            Text(member.character).font(AppFont.caption).foregroundStyle(Theme.Colors.textSecondary)
                        }
                        Spacer()
                    }
                }
            }
        case .more:
            VStack(alignment: .leading, spacing: 10) {
                infoRow("Type", title.kind.displayName)
                infoRow("Year", String(title.year))
                infoRow("Rating", title.ageRating)
                infoRow("Duration", title.durationText)
                infoRow("Genres", title.genreText)
            }
        }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(AppFont.field).foregroundStyle(Theme.Colors.textSecondary)
            Spacer()
            Text(value).font(AppFont.field).foregroundStyle(.white)
        }
    }

    private var notFound: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.circle").font(.system(size: 44)).foregroundStyle(Theme.Colors.textSecondary)
            Text("Title not found").font(AppFont.headline).foregroundStyle(.white)
            MarvelButton(title: "Go Back", style: .outline) { dismiss() }
                .frame(width: 160)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack { TitleDetailView(titleID: "m1") }.inject(.preview)
}
