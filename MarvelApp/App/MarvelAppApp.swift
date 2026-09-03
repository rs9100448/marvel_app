//
//  MarvelAppApp.swift
//  MarvelApp
//
//  App entry point. Registers fonts, builds the composition root, and injects
//  it into the environment. External `marvelapp://` deep links are forwarded to
//  the Router.
//

import SwiftUI

@main
struct MarvelAppApp: App {
    @State private var container: AppContainer

    init() {
        FontRegistrar.registerFonts()
        let container = AppContainer()
        Self.applyUITestConfiguration(to: container)
        _container = State(initialValue: container)
    }

    /// Fast-path launch configuration for automated UI tests. Guarded by a
    /// launch argument so it never affects normal runs.
    private static func applyUITestConfiguration(to container: AppContainer) {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-uitestAuthed") {
            container.session.completeOnboarding()
            container.session.signIn(profile: UserProfile(
                email: "tester@marvel.io", displayName: "TESTER",
                avatarImageName: "avatar_2", selectedPlanID: "plan_all", paymentMethod: .card))
            container.router.flow = .main
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .inject(container)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    container.router.handle(url: url, isAuthenticated: container.session.isAuthenticated)
                }
        }
    }
}
