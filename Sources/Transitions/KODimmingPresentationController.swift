//
//  KOPresentationController.swift
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

/// Presentation that adds a 'dimmingView' before presented view
open class KODimmingPresentationController: UIPresentationController {
    // MARK: Variables
    private var dimmingShowAnimator: KOAnimator?
    private var dimmingHideAnimator: KOAnimator?

    //public
    public private(set) var dimmingView: UIView!

    /// This view will be always at the bottom. It has a full screen frame, and can forward touches to the other views outside presentedViewController. It works well in mixed solution, when you cut the view by setting 'keepFrameOfView' and forwards touches to the viewController bellow presentedViewController by settings 'passthroughViews'
    public private(set) var touchForwardingView: KOTouchForwardingView!

    /// Frame of this view will be keeped for presented view, so you can cut the view at the bottom or where you want..
    public weak var keepFrameOfView: UIView?

    /// Animation of showing 'dimmingView'
    public var dimmingShowAnimation: KOAnimation?

    /// Is animation is running alongside with the transition, this can make some rendering problems with the UIVisualEffect
    public var dimmingShowAnimationSyncWithTransition: Bool = true

    /// Animation of hidding 'dimmingView'
    public var dimmingHideAnimation: KOAnimation?

    /// Is animation is running alongside with the transition, this can make some rendering problems with the UIVisualEffect
    public var dimmingHideAnimationSyncWithTransition: Bool = true

    /// Event that will be invoked when user clicked at the 'dimmingView'
    public var dimmingViewTapEvent: (() -> Void)?

    override open var frameOfPresentedViewInContainerView: CGRect {
        guard let keepFrameOfView = keepFrameOfView else {
            return super.frameOfPresentedViewInContainerView
        }
        return keepFrameOfView.frame
    }

    // MARK: Functions
    override public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        initialize()
    }

    open func initialize() {
        initializeTouchForwardingView()
        initializeDimmingView()
    }

    private func initializeTouchForwardingView() {
        touchForwardingView = KOTouchForwardingView()
        touchForwardingView.backgroundColor = UIColor.clear
    }

    private func initializeDimmingView() {
        dimmingView = createDimmingView()
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingViewTap)))
    }

    /// You can override this function to create your own dimmingView
    open func createDimmingView() -> UIView {
        createDimmingAnimations()

        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return dimmingView
    }

    private func createDimmingAnimations() {
        dimmingShowAnimation = KOFadeInAnimation(fromValue: 0)
        dimmingHideAnimation = KOFadeOutAnimation()
    }

    @objc private func dimmingViewTap() {
        dimmingViewTapEvent?()
    }

    override open func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        dimmingView.frame = frameOfPresentedViewInContainerView
        touchForwardingView.frame = containerView?.frame ?? frameOfPresentedViewInContainerView
    }

    override open func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        insetViews()
        runDimmingShowAnimation()
    }

    private func insetViews() {
        guard let containerView = containerView else {
            return
        }
        dimmingView.frame = frameOfPresentedViewInContainerView
        containerView.insertSubview(dimmingView, at: 0)

        touchForwardingView.frame = containerView.frame
        containerView.insertSubview(touchForwardingView, at: 0)
    }

    private func runDimmingShowAnimation() {
        if dimmingShowAnimationSyncWithTransition {
            dimmingShowAnimation?.animateAlongsideTransition(view: dimmingView, coordinator: presentedViewController.transitionCoordinator, completionHandler: nil)
        } else if let dimmingShowAnimation = dimmingShowAnimation {
            dimmingShowAnimator = KOAnimator(view: dimmingView)
            dimmingShowAnimator!.runViewAnimation(dimmingShowAnimation, completionHandler: nil)
        }
    }

    override open func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        runDimmingHideAnimation()
    }

    private func runDimmingHideAnimation() {
        if dimmingShowAnimationSyncWithTransition {
            dimmingHideAnimation?.animateAlongsideTransition(view: dimmingView, coordinator: presentedViewController.transitionCoordinator, completionHandler: nil)
        } else if let dimmingHideAnimation = dimmingHideAnimation {
            dimmingShowAnimator?.stopViewAnimation()
            dimmingHideAnimator = KOAnimator(view: dimmingView)
            dimmingHideAnimator!.runViewAnimation(dimmingHideAnimation, completionHandler: nil)
        }
    }
}

/// Presentation that adds a 'dimmingView' with visual effect before presented view
public class KOVisualEffectDimmingPresentationController: KODimmingPresentationController {
    private let effect: UIVisualEffect

    // MARK: Functions
    public init(effect: UIVisualEffect, presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.effect = effect
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        initialize()
    }

    override public func createDimmingView() -> UIView {
        createDimmingAnimations()

        let dimmingView = UIVisualEffectView(effect: nil)
        return dimmingView
    }

    private func createDimmingAnimations() {
        dimmingShowAnimation = KOVisualEffectAnimation(toValue: effect)
        dimmingShowAnimationSyncWithTransition = false
        dimmingHideAnimation = KOVisualEffectAnimation(toValue: nil)
    }
}
