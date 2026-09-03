//
//  FontRegistrar.swift
//  MarvelApp
//
//  Registers the bundled Inter fonts at runtime. Fonts are also declared in
//  Info.plist (UIAppFonts); runtime registration makes them robust in unit
//  tests and SwiftUI previews where the app's Info.plist may not be loaded.
//

import Foundation
import CoreText

enum FontRegistrar {
    private static var didRegister = false

    static let fontFileNames = [
        "Inter-Regular", "Inter-Medium", "Inter-SemiBold", "Inter-Bold", "Inter-ExtraBold"
    ]

    /// Registers all bundled fonts exactly once. Safe to call repeatedly.
    static func registerFonts(in bundle: Bundle = .main) {
        guard !didRegister else { return }
        didRegister = true
        for name in fontFileNames {
            guard let url = bundle.url(forResource: name, withExtension: "ttf") else { continue }
            var error: Unmanaged<CFError>?
            // Ignore "already registered" errors so previews/tests stay quiet.
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        }
    }
}
