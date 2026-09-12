# MarvelApp — project guide for AI assistants

A SwiftUI iOS app implementing the MARVEL APP (Community) Figma design.
Read this before making changes so suggestions match the project's conventions.

## Stack
- **SwiftUI**, iOS **17.0+**, Swift Concurrency, Observation (`@Observable`).
- **No third-party dependencies.** Do not add SPM/CocoaPods packages without asking.
- Architecture: **MVVM + a central `Router`** (see `Core/Navigation/`).

## Project layout
- `App/` — entry point, `RootView` coordinator, `AppContainer` (composition root / DI).
- `Core/DesignSystem/` — `Theme` (colors/spacing/radii), `Typography` (`AppFont`), fonts.
- `Core/Navigation/` — `AppRoute`/`AuthRoute`/`AppTab`, `Router`, `DeepLink` parser.
- `Core/Components/`, `Core/Validation/`, `Core/Extensions/`.
- `Data/Models`, `Data/Repositories` (protocol + JSON impl), `Data/Services`, `Data/Resources` (dummy JSON).
- `Features/<Name>/` — one folder per screen/flow: a `View` + an `@Observable` ViewModel.

## Conventions (follow these)
- **Design tokens only** — use `Theme.Colors.*` and `AppFont.*`. Never hardcode hex colors or system fonts.
- **Navigation only via the Router** — push `AppRoute` values; don't instantiate destination views ad-hoc. Every screen is reachable by a typed route and a `marvelapp://` deep link.
- **Validation** — put field rules in `Core/Validation/Validator.swift` (pure, `nonisolated`) and surface errors via `MarvelTextField`.
- **Data access** — depend on the `ContentRepository` / `AuthService` **protocols**, never the concrete classes, so the dummy-JSON layer can be swapped for an API. Bundled JSON lives in `Data/Resources/`.
- **New screen** = new `Features/<Name>/` folder (View + `@Observable` ViewModel), a case in `AppRoute`, and a `navigationDestination` mapping.

## Build & test
- Open `MarvelApp.xcodeproj`, scheme **`MarvelApp`**.
- CLI build: `xcodebuild build -project MarvelApp.xcodeproj -scheme MarvelApp -destination 'platform=iOS Simulator,name=iPhone 16'`
- Unit tests: `bundle exec fastlane test` (Swift Testing suites in `MarvelAppTests/`).
- Simulator compile / unsigned archive: `bundle exec fastlane build_ci` / `bundle exec fastlane archive`.
- Tests inject `MockContentRepository` and in-memory stores — keep logic testable.

## ⚠️ Environment gotcha (this Mac)
- **Do NOT use the system Ruby** (`/usr/bin/ruby`, `arm64e`) — it makes `fastlane` die with `zsh: killed` (SIGKILL). Use the **rbenv Ruby 3.3.6** pinned in `.ruby-version`.
- Always run fastlane with **`bundle exec`** so the pinned version is used.

## CI
- **GitHub Actions** (`.github/workflows/ci.yml`) builds + tests on every push/PR. `main` is
  protected: merges require the **`Build & Test`** check to pass.
- A `Jenkinsfile` mirrors the same Fastlane lanes (reference for a local/self-hosted runner).

## Notes
- Don't commit Xcode per-user state (`xcuserdata`) or build artifacts (see `.gitignore`).
- Marvel names/artwork are for a non-commercial design implementation.
