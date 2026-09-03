//
//  MainTabView.swift
//  MarvelApp
//
//  The signed-in shell: four tabs, each with its own navigation stack bound to
//  the Router so deep links can target any tab and push any route.
//

import SwiftUI

struct MainTabView: View {
    @Environment(Router.self) private var router

    init() {
        configureBars()
    }

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            tab(.home, path: $router.homePath) { HomeView() }
            tab(.categories, path: $router.categoriesPath) { CategoriesView() }
            tab(.downloads, path: $router.downloadsPath) { DownloadsView() }
            tab(.more, path: $router.morePath) { MoreView() }
        }
        .tint(Theme.Colors.red)
    }

    private func tab<Root: View>(
        _ tab: AppTab,
        path: Binding<[AppRoute]>,
        @ViewBuilder root: () -> Root
    ) -> some View {
        NavigationStack(path: path) {
            root()
                .navigationDestination(for: AppRoute.self) { AppRouteView(route: $0) }
        }
        .tabItem {
            Label(tab.title, systemImage: tab.systemImage)
        }
        .tag(tab)
    }

    /// Force dark, opaque navigation and tab bars to match the design.
    private func configureBars() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor.black
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor.black
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
    }
}

#Preview {
    MainTabView().inject(.preview)
}
