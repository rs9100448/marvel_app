//
//  Typography.swift
//  MarvelApp
//
//  Inter type scale (the font used in the Figma design). Custom fonts are
//  registered at launch via `FontRegistrar`. Every text style is defined here
//  so the scale stays consistent and swappable.
//

import SwiftUI

enum InterFont: String {
    case regular = "Inter-Regular"
    case medium = "Inter-Medium"
    case semiBold = "Inter-SemiBold"
    case bold = "Inter-Bold"
    case extraBold = "Inter-ExtraBold"
}

extension Font {
    /// Inter at an explicit size/weight. Uses the PostScript name so the exact
    /// static instance is selected (no synthetic weighting).
    static func inter(_ weight: InterFont, size: CGFloat) -> Font {
        .custom(weight.rawValue, size: size)
    }
}

/// Semantic text styles mapped onto the Inter scale.
enum AppFont {
    static let largeTitle = Font.inter(.extraBold, size: 28)
    static let title = Font.inter(.extraBold, size: 24)
    static let headline = Font.inter(.bold, size: 20)
    static let sectionTitle = Font.inter(.extraBold, size: 22)
    static let button = Font.inter(.semiBold, size: 18)
    static let body = Font.inter(.regular, size: 15)
    static let bodyMedium = Font.inter(.medium, size: 15)
    static let field = Font.inter(.semiBold, size: 14)
    static let caption = Font.inter(.semiBold, size: 12)
    static let link = Font.inter(.extraBold, size: 14)
    static let tabItem = Font.inter(.medium, size: 11)
}

extension Text {
    func interStyle(_ font: Font, color: Color = Theme.Colors.textPrimary) -> some View {
        self.font(font).foregroundStyle(color)
    }
}
