//
//  CreateProfileView.swift
//  MarvelApp
//
//  Avatar selection. Loads the avatar set from the repository and stores the
//  chosen avatar on the user's profile.
//

import SwiftUI

@Observable
@MainActor
final class CreateProfileViewModel {
    private(set) var avatars: [Avatar] = []
    var selectedID: String?

    @ObservationIgnored private let repository: ContentRepository
    init(repository: ContentRepository = JSONContentRepository()) { self.repository = repository }

    var selectedImageName: String? { avatars.first { $0.id == selectedID }?.imageName }

    func load() {
        avatars = (try? repository.avatars()) ?? []
        if selectedID == nil { selectedID = avatars.first?.id }
    }
}

struct CreateProfileView: View {
    @Environment(Router.self) private var router
    @Environment(SessionStore.self) private var session

    @State private var viewModel = CreateProfileViewModel()

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            MarvelLogo(width: 160).padding(.top, 20)
            Text("Choose your Avatar")
                .font(AppFont.title)
                .foregroundStyle(Theme.Colors.textPrimary)
                .padding(.top, 16)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.avatars) { avatar in
                        avatarCell(avatar)
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenH)
                .padding(.vertical, 24)
            }

            MarvelButton(title: "Looks Good", style: .outline, isEnabled: viewModel.selectedID != nil, action: confirm)
                .padding(.horizontal, Theme.Spacing.screenH)
                .padding(.bottom, 20)
        }
        .screenBackground()
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Theme.Colors.background, for: .navigationBar)
        .onAppear {
            viewModel.load()
            if let name = session.profile?.avatarImageName {
                viewModel.selectedID = viewModel.avatars.first { $0.imageName == name }?.id ?? viewModel.selectedID
            }
        }
    }

    private func avatarCell(_ avatar: Avatar) -> some View {
        let isSelected = viewModel.selectedID == avatar.id
        return Button { viewModel.selectedID = avatar.id } label: {
            Image(avatar.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(isSelected ? Theme.Colors.red : Theme.Colors.divider,
                                    lineWidth: isSelected ? 3 : 1)
                )
                .scaleEffect(isSelected ? 1.05 : 1)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    private func confirm() {
        if let name = viewModel.selectedImageName {
            session.updateProfile { $0.avatarImageName = name }
        }
        router.advanceAuth(to: .pinSetup)
    }
}

#Preview {
    NavigationStack { CreateProfileView() }.inject(.preview)
}
