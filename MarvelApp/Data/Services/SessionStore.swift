//
//  SessionStore.swift
//  MarvelApp
//
//  Persists authentication / onboarding state and the user's profile and
//  settings. Backed by UserDefaults through a small `KeyValueStore` seam so it
//  can be driven by an in-memory store in unit tests.
//

import Foundation

/// Minimal persistence seam so tests can inject an in-memory store.
protocol KeyValueStore: AnyObject {
    func data(forKey key: String) -> Data?
    func set(_ data: Data?, forKey key: String)
    func removeObject(forKey key: String)
}

extension UserDefaults: KeyValueStore {
    func set(_ data: Data?, forKey key: String) {
        setValue(data, forKey: key)
    }
}

/// In-memory implementation for tests and previews.
final class InMemoryKeyValueStore: KeyValueStore {
    private var storage: [String: Data] = [:]
    func data(forKey key: String) -> Data? { storage[key] }
    func set(_ data: Data?, forKey key: String) { storage[key] = data }
    func removeObject(forKey key: String) { storage[key] = nil }
}

@Observable
final class SessionStore {

    enum Keys {
        static let onboardingComplete = "session.onboardingComplete"
        static let profile = "session.profile"
        static let settings = "session.settings"
    }

    @ObservationIgnored private let store: KeyValueStore

    private(set) var isOnboardingComplete: Bool
    private(set) var profile: UserProfile?
    var settings: AppSettings {
        didSet { persist(settings, key: Keys.settings) }
    }

    var isAuthenticated: Bool { profile != nil }

    init(store: KeyValueStore = UserDefaults.standard) {
        self.store = store
        self.isOnboardingComplete = Self.decodeBool(store.data(forKey: Keys.onboardingComplete))
        self.profile = Self.decode(UserProfile.self, store.data(forKey: Keys.profile))
        self.settings = Self.decode(AppSettings.self, store.data(forKey: Keys.settings)) ?? .default
    }

    // MARK: Mutations
    func completeOnboarding() {
        isOnboardingComplete = true
        store.set(try? JSONEncoder().encode(true), forKey: Keys.onboardingComplete)
    }

    func signIn(profile: UserProfile) {
        self.profile = profile
        persist(profile, key: Keys.profile)
    }

    func updateProfile(_ transform: (inout UserProfile) -> Void) {
        guard var current = profile else { return }
        transform(&current)
        signIn(profile: current)
    }

    func signOut() {
        profile = nil
        store.removeObject(forKey: Keys.profile)
    }

    // MARK: Persistence helpers
    private func persist<T: Encodable>(_ value: T, key: String) {
        store.set(try? JSONEncoder().encode(value), forKey: key)
    }

    private static func decode<T: Decodable>(_ type: T.Type, _ data: Data?) -> T? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private static func decodeBool(_ data: Data?) -> Bool {
        guard let data else { return false }
        return (try? JSONDecoder().decode(Bool.self, from: data)) ?? false
    }
}
