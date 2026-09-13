---
description: Build, run in the iOS Simulator, and screenshot a screen to verify UI
argument-hint: "[screen or flow to verify, e.g. Home, Signup, Movie detail]"
---

Verify the app's UI on the iOS Simulator for: **$ARGUMENTS** (default: the Home screen).

Steps:
1. Build for a simulator (`iPhone 16` or another available iOS 17+ device):
   `xcodebuild build -project MarvelApp.xcodeproj -scheme MarvelApp -destination 'platform=iOS Simulator,name=iPhone 16'`
2. Install & launch the app on a booted simulator (`xcrun simctl`).
3. Navigate to the requested screen. To skip onboarding, launch with the
   `-uitestAuthed` argument (DEBUG-only fast path to the authenticated Home).
   Deep links also work: `xcrun simctl openurl booted "marvelapp://title/m1"`.
4. Capture a screenshot (`xcrun simctl io booted screenshot ...`) and show it.

Report what renders and flag any visual issues (spacing, missing assets, wrong
Theme tokens). If the exact simulator name is missing, list available devices with
`xcrun simctl list devices available | grep iPhone` and use one that exists.
