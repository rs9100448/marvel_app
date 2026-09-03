//
//  NavigationGestureTests.swift
//  MarvelAppTests
//
//  Deterministic verification of the interactive swipe-back fix. The gesture is
//  re-enabled by (1) UINavigationController setting itself as the pop
//  recogniser's delegate, and (2) `gestureRecognizerShouldBegin` allowing the
//  swipe only when there is something to pop back to.
//

import Testing
import UIKit
@testable import MarvelApp

@MainActor
struct NavigationGestureTests {

    @Test func swipeIsBlockedAtRootAndAllowedAfterPush() {
        let nav = UINavigationController(rootViewController: UIViewController())
        let recognizer = UIScreenEdgePanGestureRecognizer()

        // Root of the stack: nothing to pop back to → gesture must not begin.
        #expect(nav.gestureRecognizerShouldBegin(recognizer) == false)

        // After a push (like opening a detail screen), swipe-back is enabled.
        nav.pushViewController(UIViewController(), animated: false)
        #expect(nav.gestureRecognizerShouldBegin(recognizer) == true)

        // Popping back to the root disables it again.
        nav.popViewController(animated: false)
        #expect(nav.gestureRecognizerShouldBegin(recognizer) == false)
    }

    @Test func popRecognizerDelegateIsWired() {
        let nav = UINavigationController(rootViewController: UIViewController())
        nav.loadViewIfNeeded() // triggers our viewDidLoad override

        // When the recogniser exists, its delegate must be the nav controller,
        // which is what re-enables the swipe even with the back button hidden.
        if let gesture = nav.interactivePopGestureRecognizer {
            #expect(gesture.delegate === nav)
        }
    }
}
