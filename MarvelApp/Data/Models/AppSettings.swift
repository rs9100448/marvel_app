//
//  AppSettings.swift
//  MarvelApp
//
//  User-adjustable preferences shown on the Settings screen.
//

import Foundation

enum VideoQuality: String, Codable, CaseIterable, Identifiable {
    case high
    case standard
    var id: String { rawValue }
    var title: String { self == .high ? "High Definition" : "Standard Definition" }
    var subtitle: String { self == .high ? "Uses more data" : "Uses less data" }
}

struct AppSettings: Codable, Equatable {
    var autoplay = true
    var pushNotifications = true
    var autoDeleteOnCompletion = true
    var downloadOnWifiOnly = true
    var videoQuality: VideoQuality = .high

    static let `default` = AppSettings()
}
