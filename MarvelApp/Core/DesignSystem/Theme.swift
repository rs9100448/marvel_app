//
//  Theme.swift
//  MarvelApp
//
//  Centralised design tokens (colors, spacing, radii). Screens must reference
//  these tokens rather than hard-coding values, so the visual language can be
//  tuned in one place.
//

import SwiftUI

enum Theme {
    // MARK: Colors
    // Each token resolves to an asset-catalog color when available and falls
    // back to a hard-coded hex so previews/tests work without the bundle.
    enum Colors {
        static let red = color("MarvelRed", fallback: "ED1B24")
        static let redDark = color("MarvelRedDark", fallback: "8B0F14")
        static let background = color("MarvelBackground", fallback: "000000")
        static let surface = color("MarvelSurface", fallback: "111111")
        static let fieldBackground = color("MarvelFieldBackground", fallback: "FFFFFF")
        static let textPrimary = color("MarvelTextPrimary", fallback: "FFFFFF")
        static let textSecondary = color("MarvelTextSecondary", fallback: "8E8E8E")
        static let divider = color("MarvelDivider", fallback: "2A2A2A")

        static let fieldPlaceholder = Color.black.opacity(0.5)
        static let fieldText = Color.black

        private static func color(_ name: String, fallback: String) -> Color {
            #if canImport(UIKit)
            if UIColor(named: name) != nil { return Color(name) }
            #endif
            return Color(hex: fallback)
        }
    }

    // MARK: Spacing (8pt grid)
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        /// Standard horizontal screen inset used across the app.
        static let screenH: CGFloat = 30
    }

    // MARK: Corner radii
    enum Radius {
        static let field: CGFloat = 4
        static let button: CGFloat = 4
        static let card: CGFloat = 6
        static let poster: CGFloat = 8
    }

    // MARK: Border widths
    enum Border {
        static let regular: CGFloat = 3
    }
}
