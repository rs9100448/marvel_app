//
//  DeepLink.swift
//  MarvelApp
//
//  Parses `marvelapp://` URLs into a typed intent. Kept separate from the
//  Router so URL parsing is independently unit-testable.
//
//  Supported links:
//    marvelapp://home
//    marvelapp://categories            (optionally ?kind=movie|series)
//    marvelapp://downloads
//    marvelapp://watchlist
//    marvelapp://more
//    marvelapp://settings
//    marvelapp://account
//    marvelapp://title/{id}
//    marvelapp://signup
//    marvelapp://onboarding
//    marvelapp://plans
//

import Foundation

enum DeepLink: Equatable {
    case tab(AppTab)
    case title(id: String)
    case categories(kind: TitleKind?)
    case watchlist
    case settings
    case account
    case onboarding
    case signup
    case plans
}

enum DeepLinkParser {
    static let scheme = "marvelapp"

    static func parse(_ url: URL) -> DeepLink? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme?.lowercased() == scheme else {
            return nil
        }

        // The "host" is the first path segment for custom-scheme URLs.
        let host = components.host?.lowercased() ?? ""
        let pathSegments = components.path
            .split(separator: "/")
            .map { String($0) }
        let queryKind = components.queryItems?
            .first { $0.name.lowercased() == "kind" }?
            .value
            .flatMap { TitleKind(rawValue: $0.lowercased()) }

        switch host {
        case "home":
            return .tab(.home)
        case "categories":
            return .categories(kind: queryKind)
        case "downloads":
            return .tab(.downloads)
        case "more":
            return .tab(.more)
        case "watchlist":
            return .watchlist
        case "settings":
            return .settings
        case "account":
            return .account
        case "onboarding":
            return .onboarding
        case "signup", "auth":
            return .signup
        case "plans":
            return .plans
        case "title", "movie", "series":
            // marvelapp://title/{id}
            if let id = pathSegments.first, !id.isEmpty {
                return .title(id: id)
            }
            return nil
        default:
            return nil
        }
    }
}
