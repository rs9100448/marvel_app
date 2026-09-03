//
//  Color+Hex.swift
//  MarvelApp
//
//  Convenience for constructing colors from hex, used as a fallback when a
//  named asset color is not available (e.g. SwiftUI previews and unit tests).
//

import SwiftUI

extension Color {
    /// Creates a color from a hex string such as `#ED1B24`, `ED1B24` or `#ED1B24FF`.
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let a, r, g, b: UInt64
        switch sanitized.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (value >> 8) * 17, (value >> 4 & 0xF) * 17, (value & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, value >> 16, value >> 8 & 0xFF, value & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (value >> 24, value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
