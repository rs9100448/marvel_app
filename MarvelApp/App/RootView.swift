//
//  RootView.swift
//  MarvelApp
//
//  Top-level coordinator view. Switches between the splash, onboarding, auth
//  and main experiences based on `Router.flow`.
//

import SwiftUI

struct RootView: View {
    @Environment(Router.self) private var router
    @Environment(SessionStore.self) private var session

    var body: some View {
        Group {
            switch router.flow {
            case .splash:
                SplashView()
            case .onboarding:
                WelcomeView()
            case .auth:
                AuthFlowView()
            case .main:
                MainTabView()
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.35), value: router.flow)
    }
}
