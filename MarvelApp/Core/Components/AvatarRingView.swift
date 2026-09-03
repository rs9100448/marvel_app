//
//  AvatarRingView.swift
//  MarvelApp
//
//  The animated profile avatar from the "More" screen: an avatar framed by a
//  set of concentric red rings that continuously pulse outward — recreating the
//  "Profile-ring" motion from the Figma design.
//

import SwiftUI

struct AvatarRingView: View {
    let imageName: String
    var size: CGFloat = 150
    var ringCount: Int = 6
    var animated: Bool = true

    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<ringCount, id: \.self) { index in
                let progress = CGFloat(index) / CGFloat(ringCount)
                Circle()
                    .stroke(Theme.Colors.red.opacity(0.9 - progress * 0.7), lineWidth: 1.5)
                    .frame(
                        width: size + CGFloat(index) * ringSpacing,
                        height: size + CGFloat(index) * ringSpacing
                    )
                    .scaleEffect(animate ? 1.06 : 0.98)
                    .opacity(animate ? 0.35 : 1)
                    .animation(
                        animated ?
                            .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15)
                        : nil,
                        value: animate
                    )
            }

            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: size * 0.86, height: size * 0.86)
                .clipShape(Circle())
        }
        .frame(width: size + CGFloat(ringCount) * ringSpacing,
               height: size + CGFloat(ringCount) * ringSpacing)
        .onAppear { if animated { animate = true } }
        .accessibilityHidden(true)
    }

    private let ringSpacing: CGFloat = 18
}

#Preview {
    AvatarRingView(imageName: "avatar_2")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
}
