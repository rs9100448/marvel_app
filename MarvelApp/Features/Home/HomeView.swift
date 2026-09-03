//
//  HomeView.swift
//  MarvelApp
//
//  The home tab: latest movies, latest series and trending titles, each of
//  which deep-links into the detail screen.
//

import SwiftUI

struct HomeView: View {
    @Environment(Router.self) private var router
    @Environment(SessionStore.self) private var session

    @State private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                featuredSection(title: "Latest Movies", titles: viewModel.latestMovies)
                featuredSection(title: "Latest Series", titles: viewModel.latestSeries)
                trendingSection
            }
            .padding(.vertical, 12)
        }
        .scrollIndicators(.hidden)
        .screenBackground()
        .safeAreaInset(edge: .top) { header }
        .onAppear { viewModel.load() }
    }

    // MARK: Header
    private var header: some View {
        HStack {
            Spacer()
            MarvelLogo(width: 110)
            Spacer()
        }
        .overlay(alignment: .trailing) {
            Button {
                router.push(.account)
            } label: {
                AvatarRingView(imageName: session.profile?.avatarImageName ?? "avatar_2",
                               size: 34, ringCount: 3)
            }
            .buttonStyle(.plain)
            .padding(.trailing, Theme.Spacing.md)
        }
        .padding(.vertical, 8)
        .background(Theme.Colors.background)
    }

    // MARK: Sections
    private func featuredSection(title: String, titles: [Title]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: title).padding(.horizontal, Theme.Spacing.md)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(titles) { title in
                        Button { router.push(.titleDetail(id: title.id)) } label: {
                            heroCard(title)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
            }
        }
    }

    private func heroCard(_ title: Title) -> some View {
        Image(title.posterName)
            .resizable()
            .scaledToFill()
            .frame(width: 280, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.poster))
            .overlay(alignment: .bottomLeading) {
                Text(title.name)
                    .font(AppFont.bodyMedium)
                    .foregroundStyle(.white)
                    .padding(10)
                    .shadow(radius: 4)
            }
            .accessibilityLabel(title.name)
    }

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Trending Today").padding(.horizontal, Theme.Spacing.md)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.trending) { title in
                        Button { router.push(.titleDetail(id: title.id)) } label: {
                            PosterCard(title: title, width: 120)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
            }
        }
    }
}

#Preview {
    NavigationStack { HomeView() }.inject(.preview)
}
