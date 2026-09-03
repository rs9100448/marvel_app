//
//  WelcomeView.swift
//  MarvelApp
//
//  Paged onboarding. A shared Marvel hero image sits behind a paging control of
//  taglines drawn from the Figma design. The final slide starts the sign-up
//  flow.
//

import SwiftUI

struct OnboardingSlide: Identifiable {
    let id = UUID()
    let tagline: String
    let cta: String
}

enum OnboardingContent {
    static let slides: [OnboardingSlide] = [
        .init(tagline: "All your favourite MARVEL Movies & Series at one place", cta: "Continue"),
        .init(tagline: "Watch Online or Download Offline", cta: "Continue"),
        .init(tagline: "Create profiles for different members & get personalised recommendations", cta: "Continue"),
        .init(tagline: "Plans according to your needs at affordable prices", cta: "Continue"),
        .init(tagline: "Let’s Get Started !!!", cta: "Get Started")
    ]
}

struct WelcomeView: View {
    @Environment(Router.self) private var router
    @Environment(SessionStore.self) private var session

    @State private var index = 0
    private let slides = OnboardingContent.slides

    var body: some View {
        VStack(spacing: 0) {
            hero
            Spacer(minLength: 0)
            pageDots
                .padding(.top, 24)
            tagline
                .padding(.top, 20)
            Spacer(minLength: 0)
            MarvelButton(title: slides[index].cta, style: .filled, action: advance)
                .padding(.horizontal, Theme.Spacing.screenH)
                .padding(.bottom, 24)
        }
        .screenBackground()
    }

    // MARK: Sections
    private var hero: some View {
        ZStack(alignment: .center) {
            Image("onboarding_hero")
                .resizable()
                .scaledToFill()
                .frame(height: 560)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.clear, .clear, Theme.Colors.background],
                        startPoint: .top, endPoint: .bottom
                    )
                )
            MarvelLogo(width: 188)
                .shadow(color: .black.opacity(0.4), radius: 10)
        }
        .frame(height: 560)
        .ignoresSafeArea(edges: .top)
    }

    private var pageDots: some View {
        HStack(spacing: 10) {
            ForEach(slides.indices, id: \.self) { i in
                Circle()
                    .fill(i == index ? Theme.Colors.red : Theme.Colors.textSecondary.opacity(0.5))
                    .frame(width: 10, height: 10)
                    .animation(.easeInOut, value: index)
            }
        }
    }

    private var tagline: some View {
        Text(slides[index].tagline)
            .font(AppFont.headline)
            .foregroundStyle(Theme.Colors.textPrimary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .frame(height: 80)
            .id(index)
            .transition(.opacity)
    }

    // MARK: Actions
    private func advance() {
        if index < slides.count - 1 {
            withAnimation { index += 1 }
        } else {
            session.completeOnboarding()
            withAnimation { router.finishOnboarding() }
        }
    }
}

#Preview {
    WelcomeView().inject(.preview)
}
