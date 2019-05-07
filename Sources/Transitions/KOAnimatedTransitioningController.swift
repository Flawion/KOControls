//
//  KOAnimatedTransitioningController.swift
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

import UIKit

/// Manages animations of transition from and to views
open class KOAnimatedTransitioningController: NSObject, UIViewControllerAnimatedTransitioning {
    private var animatorTo: KOAnimator!
    private var animatorFrom: KOAnimator!

    public private(set) var duration: TimeInterval

    /// If it is a presenting animation, it will be a new view
    public private(set) var viewToAnimation: KOAnimation?

    /// If it is a presenting animation, it will be a presenting view. For dismissing animation it will be a current presented view.
    public private(set) var viewFromAnimation: KOAnimation?

    /// Duration of animations
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    public init(duration: TimeInterval, viewToAnimation: KOAnimation?, viewFromAnimation: KOAnimation?) {
        self.duration = duration
        self.viewToAnimation = viewToAnimation
        self.viewFromAnimation = viewFromAnimation
        super.init()
    }

    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        addViewTo(using: transitionContext)

        let completeTransitionHandler: (UIViewAnimatingPosition) -> Void = { _ in
            transitionContext.completeTransition(true)
        }
        var completeTransitionAtTheEndOfToAnimation = isViewToAnimationIsLongerThanFrom

        if !tryRunAnimationTo(transitionContext: transitionContext, completeTransitionHandler: completeTransitionAtTheEndOfToAnimation ? completeTransitionHandler : nil) {
            completeTransitionAtTheEndOfToAnimation = false
        }
        if !tryRunAnimationFrom(transitionContext: transitionContext, completeTransitionHandler: completeTransitionAtTheEndOfToAnimation ? nil : completeTransitionHandler)
            && !completeTransitionAtTheEndOfToAnimation {
            transitionContext.completeTransition(true)
        }
    }

    private var isViewToAnimationIsLongerThanFrom: Bool {
        return (viewToAnimation?.duration ?? -1) >= (viewFromAnimation?.duration ?? -1)
    }

    private func tryRunAnimationTo(transitionContext: UIViewControllerContextTransitioning, completeTransitionHandler: ((UIViewAnimatingPosition) -> Void)?) -> Bool {
        guard let viewToAnimation = viewToAnimation, let viewTo = transitionContext.view(forKey: .to) else {
            return false
        }
        viewToAnimation.duration = min(duration, viewToAnimation.duration)
        animatorTo = KOAnimator(view: viewTo)
        animatorTo.runViewAnimation(viewToAnimation, completionHandler: completeTransitionHandler)
        return true
    }

    private func tryRunAnimationFrom(transitionContext: UIViewControllerContextTransitioning, completeTransitionHandler: ((UIViewAnimatingPosition) -> Void)?) -> Bool {
        guard let viewFromAnimation = viewFromAnimation, let viewFrom = transitionContext.view(forKey: .from) else {
            return false
        }
        viewFromAnimation.duration = min(duration, viewFromAnimation.duration)
        animatorFrom = KOAnimator(view: viewFrom)
        animatorFrom.runViewAnimation(viewFromAnimation, completionHandler: completeTransitionHandler)
        return true
    }

    private func addViewTo(using transitionContext: UIViewControllerContextTransitioning) {
        guard let viewControllerTo = transitionContext.viewController(forKey: .to), let viewTo = transitionContext.view(forKey: .to) else {
            return
        }
        let endFrame = transitionContext.finalFrame(for: viewControllerTo)
        viewTo.frame = endFrame
        transitionContext.containerView.addSubview(viewTo)
    }
}
