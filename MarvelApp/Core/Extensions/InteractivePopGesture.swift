//
//  InteractivePopGesture.swift
//  MarvelApp
//
//  Re-enables the interactive "swipe from the left edge to go back" gesture on
//  screens that hide the default navigation back button (e.g. the title detail
//  screen, which uses a custom transparent-bar back button). UIKit normally
//  disables the gesture whenever the default back button is hidden; setting the
//  recognizer's delegate ourselves restores it while still preventing a swipe
//  on the root view controller.
//

import UIKit

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Only allow the swipe when there is something to pop back to.
        viewControllers.count > 1
    }
}
