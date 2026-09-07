# MarvelApp

[![CI](https://github.com/rs9100448/marvel_app/actions/workflows/ci.yml/badge.svg)](https://github.com/rs9100448/marvel_app/actions/workflows/ci.yml)

A SwiftUI iOS app implementing the [MARVEL APP (Community) Figma design](https://www.figma.com/design/qSCSoED83y65lgBkp6XPDv/MARVEL-APP--Community-) — a Marvel movies & series streaming concept. Built with a scalable, testable MVVM + Router architecture, type-safe navigation with `marvelapp://` deep links, per-field validation, and a dummy-JSON data layer that can be swapped for a real API without touching the UI.

> The design has no live backend, so all content is served from bundled JSON. The data layer sits behind a protocol so a networked implementation can drop in later.

---

## Contents
- [Requirements](#requirements)
- [Getting started](#getting-started)
- [Features](#features)
- [Architecture](#architecture)
- [Project structure](#project-structure)
- [Navigation & deep links](#navigation--deep-links)
- [Design system](#design-system)
- [Data layer](#data-layer)
- [Validation](#validation)
- [Testing](#testing)
- [Assets & fonts](#assets--fonts)
- [Roadmap](#roadmap)
- [Credits](#credits)

---

## Requirements

| Tool | Version |
|------|---------|
| Xcode | 26.x |
| iOS Deployment Target | 17.0+ |
| Swift | 5.0 (Swift 6 concurrency-clean) |
| Language | SwiftUI, Swift Concurrency, Observation (`@Observable`) |

No third-party dependencies or package managers — everything is first-party Apple frameworks.

---

## Getting started

```bash
git clone <your-repo-url>
cd MarvelApp
open MarvelApp.xcodeproj
```

Then in Xcode: select the **MarvelApp** scheme and an iPhone simulator (iOS 17+) and press **⌘R**.

From the command line:

```bash
# Build
xcodebuild -project MarvelApp.xcodeproj -scheme MarvelApp \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run all unit tests
xcodebuild -project MarvelApp.xcodeproj -scheme MarvelApp \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:MarvelAppTests test
```

The app is fully self-contained; there is nothing to configure on first launch.

---

## Features

- **Full onboarding & subscription flow** — Splash → Welcome (paged) → Signup → Choose Plan → Payment method → Card details → Bank OTP → Payment verification → Choose avatar → PIN setup → Success → Home.
- **Main app** — tabbed experience (Home, Categories, Downloads, More) with independent navigation stacks per tab.
- **Home** — Latest Movies, Latest Series, and Trending sections sourced from dummy JSON.
- **Title detail** — hero art, play button, download & watchlist toggles, synopsis, and Trailer/Cast/More tabs.
- **Categories** — Movies/Series switch with genre-chip filtering.
- **Library** — Watchlist and Downloads, with a themed delete-download confirmation.
- **More / Settings / Account** — animated profile avatar (pulsing rings), toggles, sign out.
- **Deep links** — every primary screen is reachable via a `marvelapp://` URL (see below).
- **Per-field validation** — email, password strength, card number (Luhn), expiry, CVV, names.
- **Branded launch** — solid launch screen that hands off to an animated splash (logo spring-in + red glow).
- **Custom typography** — the Inter typeface from the Figma design, bundled and registered at runtime.

---

## Architecture

The app follows **MVVM with a centralized Router**, wired together by a single composition root.

```
┌─────────────────────────────────────────────────────────────┐
│  AppContainer  (composition root, @MainActor)                │
│  ├─ ContentRepository   (protocol)  → JSONContentRepository   │
│  ├─ AuthService         (protocol)  → DummyAuthService        │
│  ├─ SessionStore        (@Observable, persisted)             │
│  ├─ LibraryStore        (@Observable, persisted)             │
│  └─ Router              (@Observable, navigation)            │
└─────────────────────────────────────────────────────────────┘
        │ injected via .environment(...)
        ▼
   Feature Views  ──uses──▶  Feature ViewModels (@Observable)
        │                          │
        └── read shared stores ────┘── depend on repositories (protocols)
```

**Principles**

- **Protocol-oriented data access** — views/view-models depend on `ContentRepository` / `AuthService` protocols, never on concrete types. The JSON-backed implementations are one swap away from a real API. This is also the main seam for tests (`MockContentRepository`).
- **Single source of truth for navigation** — the `Router` owns the top-level flow, the selected tab, each tab's `NavigationStack` path, and the sign-up flow path. Both user taps and external deep links go through the same small API.
- **Type-safe routes** — destinations are enums (`AppRoute`, `AuthRoute`, `AppTab`), driving `NavigationStack(path:)` bindings. No stringly-typed navigation.
- **Composition root** — `AppContainer` builds all dependencies in one place and injects them into the SwiftUI environment, so test doubles can be substituted wholesale (`AppContainer.preview`).
- **Pure, isolated logic** — validation and deep-link parsing are `nonisolated`, side-effect-free, and independently unit-tested.

---

## Project structure

```
MarvelApp/
├─ App/
│  ├─ MarvelAppApp.swift        # @main entry, font registration, onOpenURL
│  ├─ RootView.swift            # switches splash / onboarding / auth / main
│  └─ AppContainer.swift        # composition root + environment injection
├─ Core/
│  ├─ DesignSystem/             # Theme (colors/spacing/radii), Typography, FontRegistrar
│  ├─ Navigation/               # Routes, Router, DeepLink, DeepLinkParser
│  ├─ Components/               # MarvelButton, MarvelTextField, CodeEntryField,
│  │                            #   AvatarRingView, MarvelConfirmDialog, CommonViews …
│  ├─ Validation/               # Validator, ValidationResult
│  └─ Extensions/               # Color+Hex, InteractivePopGesture
├─ Data/
│  ├─ Models/                   # Title, Plan, Avatar, UserProfile, PaymentMethod, AppSettings
│  ├─ Repositories/             # ContentRepository (protocol) + JSONContentRepository
│  ├─ Services/                 # AuthService, SessionStore, LibraryStore
│  └─ Resources/                # content.json, plans.json, avatars.json
├─ Features/                    # One folder per screen/flow (View + ViewModel)
│  ├─ Splash/ Onboarding/ Auth/ Plans/ Payment/ Profile/
│  └─ Main/ Home/ Detail/ Categories/ Library/ More/ Settings/
├─ Resources/Fonts/             # Inter-*.ttf (Regular…ExtraBold)
├─ Assets.xcassets/             # colors, posters, avatars, brand SVGs
└─ Info.plist                   # URL scheme, UIAppFonts, launch screen

MarvelAppTests/                 # unit tests (Swift Testing)
MarvelAppUITests/               # UI tests (XCTest)
```

---

## Navigation & deep links

Every primary destination is reachable through a `marvelapp://` URL, parsed by `DeepLinkParser` into a typed `DeepLink` and applied by the `Router`. Content links that arrive before sign-in are stashed and replayed after authentication.

| URL | Opens |
|-----|-------|
| `marvelapp://home` | Home tab |
| `marvelapp://categories` | Categories tab |
| `marvelapp://categories?kind=movie` | Categories filtered to Movies |
| `marvelapp://downloads` | Downloads tab |
| `marvelapp://more` | More tab |
| `marvelapp://watchlist` | Watchlist |
| `marvelapp://settings` | Settings |
| `marvelapp://account` | Account |
| `marvelapp://title/{id}` | A movie/series detail (e.g. `title/m1`) |
| `marvelapp://signup` | Sign-up screen |
| `marvelapp://plans` | Choose-your-plan screen |

**Test a deep link against a running simulator:**

```bash
xcrun simctl openurl booted "marvelapp://title/m1"
xcrun simctl openurl booted "marvelapp://categories?kind=series"
```

Title IDs are defined in `Data/Resources/content.json` (`m1`–`m8` movies, `s1`–`s10` series).

---

## Design system

All visual tokens live in `Core/DesignSystem/Theme.swift` and `Typography.swift` — screens reference tokens, never raw values.

| Token | Value |
|-------|-------|
| Primary red | `#ED1B24` (`Theme.Colors.red`) |
| Background | `#000000` |
| Text primary / secondary | `#FFFFFF` / `#8E8E8E` |
| Field background | `#FFFFFF` |
| Typeface | **Inter** (Regular, Medium, SemiBold, Bold, ExtraBold) |

Type styles are exposed semantically via `AppFont` (e.g. `AppFont.title`, `AppFont.button`, `AppFont.body`). Fonts are declared in `Info.plist` (`UIAppFonts`) **and** registered at runtime by `FontRegistrar`, so they also resolve in previews and tests.

---

## Data layer

Content is decoded from bundled JSON by `JSONContentRepository`, behind the `ContentRepository` protocol:

```swift
protocol ContentRepository {
    func allTitles() throws -> [Title]
    func titles(of kind: TitleKind) throws -> [Title]
    func featured(kind: TitleKind) throws -> [Title]
    func trending() throws -> [Title]
    func title(id: String) throws -> Title?
    func plans() throws -> [Plan]
    func avatars() throws -> [Avatar]
}
```

To move to a live API, add a `RemoteContentRepository: ContentRepository` and inject it in `AppContainer` — no UI or view-model changes required.

Local user state (onboarding complete, profile, settings, watchlist, downloads) is persisted through a `KeyValueStore` seam (`UserDefaults` in the app, `InMemoryKeyValueStore` in tests).

---

## Validation

`Core/Validation/Validator.swift` provides pure, `nonisolated` functions returning a `ValidationResult` (`.valid` / `.invalid(message)`):

- **Email** — RFC-lite pattern
- **Password** — ≥ 8 chars, upper + lower + digit
- **Card number** — length + **Luhn checksum**
- **Expiry** — `MM/YY`, not in the past
- **CVV** — 3–4 digits
- **Names / required text** — non-empty, min length

`MarvelTextField` renders inline errors after a field is touched, and view-models aggregate field results into a form-level `isValid` that gates the primary button.

---

## Testing

**Unit tests** (Swift Testing, `MarvelAppTests/`):

| Suite | Covers |
|-------|--------|
| `ValidatorTests` | Every validation rule, incl. Luhn & expiry edge cases |
| `DeepLinkParserTests` | URL → `DeepLink` parsing |
| `RouterTests` | Flow transitions, tab stacks, pending-link replay |
| `DataLayerTests` | JSON decoding, repository queries |
| `ViewModelTests` | Home / Plans / Payment / Signup view-model logic |
| `NavigationGestureTests` | Swipe-back gesture gating (`shouldBegin`) |

**UI tests** (XCTest, `MarvelAppUITests/`):

- `DetailNavigationUITests` — opens a detail screen, asserts the back button, and verifies both tap-back and swipe-back return to Home.

```bash
# Unit tests
xcodebuild -project MarvelApp.xcodeproj -scheme MarvelApp \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:MarvelAppTests test

# UI tests
xcodebuild -project MarvelApp.xcodeproj -scheme MarvelApp \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:MarvelAppUITests test
```

**UI-test launch argument** — pass `-uitestAuthed` (DEBUG only) to boot straight into the authenticated Home screen, skipping onboarding:

```swift
let app = XCUIApplication()
app.launchArguments = ["-uitestAuthed"]
app.launch()
```

---

## Assets & fonts

All imagery and typography come from the Figma design:

- **Marvel logo, Google, Facebook** — vector SVGs in the asset catalog.
- **Posters** — 18 Marvel movie/series posters mapped to titles in `content.json`.
- **Avatars** — 8 hero-mask illustrations for the Create Profile screen.
- **Inter** — the design's typeface, generated as static weights from the official OFL variable font and bundled under `Resources/Fonts/`.

---

## Roadmap

Implemented: the full core flow and primary screens (see [Features](#features)). Not yet built to pixel-fidelity:

- Secondary More-menu pages (Legal, Support, Privacy Settings, Parental Control) — currently functional placeholder screens.
- Netbanking payment path detail.
- A rasterized logo for a branded (non-black) launch screen.

---

## Credits

- Design: **MARVEL APP (Community)** on Figma.
- Typeface: **Inter** by Rasmus Andersson (SIL Open Font License).
- Marvel names, logos, and artwork are the property of Marvel; used here for a non-commercial design implementation.
