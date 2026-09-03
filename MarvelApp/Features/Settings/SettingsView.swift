//
//  SettingsView.swift
//  MarvelApp
//
//  App preferences, bound directly to the persisted `SessionStore.settings`.
//

import SwiftUI

struct SettingsView: View {
    @Environment(SessionStore.self) private var session
    @Environment(LibraryStore.self) private var library

    var body: some View {
        @Bindable var session = session
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                section("General Settings") {
                    toggleRow("Autoplay", isOn: $session.settings.autoplay)
                    toggleRow("Push Notifications", isOn: $session.settings.pushNotifications)
                }

                section("Download Preferences") {
                    toggleRow("Autodelete upon completion", isOn: $session.settings.autoDeleteOnCompletion)
                    toggleRow("Download only with Wi-Fi", isOn: $session.settings.downloadOnWifiOnly)
                    Button("Delete all downloads") { library.clearDownloads() }
                        .font(AppFont.headline)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .buttonStyle(.plain)
                }

                section("Download Video Quality") {
                    ForEach(VideoQuality.allCases) { quality in
                        qualityRow(quality, selection: $session.settings.videoQuality)
                    }
                }

                storageSection
            }
            .padding(Theme.Spacing.md)
        }
        .scrollIndicators(.hidden)
        .screenBackground()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.Colors.background, for: .navigationBar)
    }

    // MARK: Builders
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title.uppercased())
                .font(AppFont.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
            content()
            AppDivider()
        }
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title).font(AppFont.headline).foregroundStyle(.white)
        }
        .tint(Theme.Colors.red)
    }

    private func qualityRow(_ quality: VideoQuality, selection: Binding<VideoQuality>) -> some View {
        Button { selection.wrappedValue = quality } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(quality.title).font(AppFont.headline).foregroundStyle(.white)
                    Text(quality.subtitle).font(AppFont.caption).foregroundStyle(Theme.Colors.textSecondary)
                }
                Spacer()
                Image(systemName: selection.wrappedValue == quality ? "checkmark.square.fill" : "square")
                    .foregroundStyle(Theme.Colors.red)
                    .font(.system(size: 22))
            }
        }
        .buttonStyle(.plain)
    }

    private var storageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mobile Storage").font(AppFont.headline).foregroundStyle(.white)
            GeometryReader { geo in
                HStack(spacing: 0) {
                    Rectangle().fill(Color.blue).frame(width: geo.size.width * 0.5)
                    Rectangle().fill(Theme.Colors.red).frame(width: geo.size.width * 0.2)
                    Rectangle().fill(Color.white).frame(width: geo.size.width * 0.3)
                }
            }
            .frame(height: 14)
            .clipShape(Capsule())

            HStack(spacing: 20) {
                legend(color: .blue, label: "Used")
                legend(color: Theme.Colors.red, label: "Marvel")
                legend(color: .white, label: "Free")
            }
        }
    }

    private func legend(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 14, height: 14)
            Text(label).font(AppFont.caption).foregroundStyle(.white)
        }
    }
}

#Preview {
    NavigationStack { SettingsView() }.inject(.preview)
}
