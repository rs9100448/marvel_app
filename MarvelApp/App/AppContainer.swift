//
//  AppContainer.swift
//  MarvelApp
//
//  Composition root. Owns the app's long-lived dependencies and the shared
//  observable stores, and injects them into the SwiftUI environment. Building
//  everything in one place keeps wiring explicit and makes it trivial to swap
//  in test doubles (see `AppContainer.preview`).
//

import SwiftUI

@MainActor
final class AppContainer {
    let contentRepository: ContentRepository
    let authService: AuthService
    let session: SessionStore
    let library: LibraryStore
    let router: Router

    init(
        contentRepository: ContentRepository = JSONContentRepository(),
        authService: AuthService = DummyAuthService(),
        session: SessionStore? = nil,
        library: LibraryStore? = nil,
        router: Router? = nil
    ) {
        // MainActor stores are built inside the (MainActor) init body rather than
        // as default arguments, which are evaluated in a nonisolated context.
        self.contentRepository = contentRepository
        self.authService = authService
        self.session = session ?? SessionStore()
        self.library = library ?? LibraryStore()
        self.router = router ?? Router()
    }

    /// A container wired with in-memory stores, for previews and tests.
    static var preview: AppContainer {
        AppContainer(
            contentRepository: JSONContentRepository(),
            authService: DummyAuthService(latency: .zero),
            session: SessionStore(store: InMemoryKeyValueStore()),
            library: LibraryStore(store: InMemoryKeyValueStore())
        )
    }
}

// MARK: - Environment injection

private struct AppContainerKey: EnvironmentKey {
    @MainActor static var defaultValue: AppContainer { AppContainer.preview }
}

extension EnvironmentValues {
    var container: AppContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}

extension View {
    /// Injects the container plus each shared observable store so views can read
    /// them individually with `@Environment(Router.self)` etc.
    func inject(_ container: AppContainer) -> some View {
        self
            .environment(\.container, container)
            .environment(container.router)
            .environment(container.session)
            .environment(container.library)
    }
}
