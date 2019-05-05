//
//  KOAnimator.swift
//  KOControls
//
//  Copyright (c) 2018 Kuba Ostrowski
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

/// Manages animation
open class KOAnimator {
    private weak var view: UIView?

    /// Current setted animation
    public private(set) var currentViewAnimation: KOAnimation?

    /// Property animator for current setted animation
    public private(set) var currentPropertyAnimator: UIViewPropertyAnimator?

    /// Runs before animation.prepareViewForAnimation and playViewAnimation
    public var prepareViewForAnimationEvent: ((_ : UIView) -> Void)?

    public var isRunning: Bool {
        return currentPropertyAnimator?.isRunning ?? false
    }

    public init(view: UIView) {
        self.view = view
    }

    /// Stops current animation and recreates 'UIViewPropertyAnimator' for the new animation
    ///
    /// - Parameters:
    ///   - animation: animation to set
    ///   - completionHandler: animation completion handler
    open func setViewAnimation(_ animation: KOAnimation, completionHandler: ((UIViewAnimatingPosition) -> Void)?) {
        stopViewAnimation()

        if let view = view {
            prepareViewForAnimationEvent?(view)
            animation.prepareViewForAnimation(view)
        }
        currentViewAnimation = animation
        currentPropertyAnimator = UIViewPropertyAnimator(duration: animation.duration, timingParameters: animation.timingParameters)
        currentPropertyAnimator?.addAnimations { [weak self] in
            guard let view = self?.view else {
                return
            }
            animation.animation(view: view)
        }
        if let completionHandler = completionHandler {
            currentPropertyAnimator?.addCompletion(completionHandler)
        }
    }

    /// Sets the new animation and play it
    ///
    /// - Parameters:
    ///   - animation: animation to set
    ///   - completionHandler: animation completion handler
    open func runViewAnimation(_ animation: KOAnimation, completionHandler: ((UIViewAnimatingPosition) -> Void)?) {
        setViewAnimation(animation, completionHandler: completionHandler)
        playViewAnimation()
    }

    /// Runs animation at 'UIViewControllerTransitionCoordinator', this function dosen't create 'UIViewPropertyAnimator' for animation. So you can't control animation by this property.
    ///
    /// - Parameters:
    ///   - animation: animation to run at coordinator
    ///   - coordinator: coordinator of presented view
    ///   - completionHandler: animation completion handler
    open func runAnimationAlongsideTransition(_ animation: KOAnimation, coordinator: UIViewControllerTransitionCoordinator?, completionHandler: ((UIViewControllerTransitionCoordinatorContext?) -> Void)?) {
        guard let view = view else {
            return
        }
        animation.prepareViewForAnimation(view)
        animation.animateAlongsideTransition(view: view, coordinator: coordinator, completionHandler: completionHandler)
    }

    public func pauseViewAnimation() {
        guard let currentPropertyAnimator = currentPropertyAnimator else {
            return
        }
        currentPropertyAnimator.pauseAnimation()
    }

    public func stopViewAnimation() {
        guard let currentPropertyAnimator = currentPropertyAnimator, currentPropertyAnimator.state != .stopped else {
            return
        }
        currentPropertyAnimator.stopAnimation(true)
    }

    public func playViewAnimation() {
        guard let currentViewAnimation = currentViewAnimation, let currentPropertyAnimator = currentPropertyAnimator else {
            return
        }
        currentPropertyAnimator.startAnimation(afterDelay: currentViewAnimation.delay)
    }
}
