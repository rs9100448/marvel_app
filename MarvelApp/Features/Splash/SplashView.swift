//
//  SplashView.swift
//  MarvelApp
//
//  Animated splash: the Marvel logo fades and scales in, then the app decides
//  the first real screen based on persisted onboarding/auth state.
//

import SwiftUI

struct SplashView: View {
    @Environment(Router.self) private var router
    @Environment(SessionStore.self) private var session

    // The launch screen is solid black; the logo springs in from it (clear
    // entrance motion), the red glow pulses, then it zooms/fades into the app.
    @State private var entered = false
    @State private var glow = false
    @State private var exiting = false

    private var scale: CGFloat { exiting ? 1.2 : (entered ? 1.0 : 0.55) }
    private var opacity: CGFloat { exiting ? 0 : (entered ? 1 : 0) }

    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            MarvelLogo(width: 200)
                .scaleEffect(scale)
                .opacity(opacity)
                .shadow(color: Theme.Colors.red.opacity(glow ? 0.95 : 0.15),
                        radius: glow ? 34 : 6)
        }
        .task {
            // Spring the logo in from the black launch screen.
            withAnimation(.spring(response: 0.55, dampingFraction: 0.62)) { entered = true }
            // Pulse the red glow while the first screen prepares.
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { glow = true }
            try? await Task.sleep(for: .seconds(1.3))
            // Zoom-and-fade hand-off into the app.
            withAnimation(.easeIn(duration: 0.3)) { exiting = true }
            try? await Task.sleep(for: .seconds(0.3))
            router.begin(
                isOnboardingComplete: session.isOnboardingComplete,
                isAuthenticated: session.isAuthenticated
            )
        }
    }
}

#Preview {
    SplashView().inject(.preview)
}
