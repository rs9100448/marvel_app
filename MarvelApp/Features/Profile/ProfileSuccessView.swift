//
//  ProfileSuccessView.swift
//  MarvelApp
//
//  Confirmation screen shown after the profile is created. Enters the main app.
//

import SwiftUI

struct ProfileSuccessView: View {
    @Environment(Router.self) private var router
    @Environment(SessionStore.self) private var session

    @State private var appear = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            AvatarRingView(imageName: session.profile?.avatarImageName ?? "avatar_2", size: 150)
                .scaleEffect(appear ? 1 : 0.6)
                .opacity(appear ? 1 : 0)

            VStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.Colors.red)
                Text("Your Profile is Created\nSuccessfully!!")
                    .font(AppFont.title)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appear ? 1 : 0)

            Spacer()

            MarvelButton(title: "Start Watching", style: .filled) {
                router.enterMainApp()
            }
            .padding(.horizontal, Theme.Spacing.screenH)
            .padding(.bottom, 20)
        }
        .screenBackground()
        .navigationBarBackButtonHidden(true)
        .task {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) { appear = true }
        }
    }
}

#Preview {
    NavigationStack { ProfileSuccessView() }.inject(.preview)
}
