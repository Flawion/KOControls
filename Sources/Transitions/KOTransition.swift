//
//  KOTransition.swift
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

/// Custom view transition, set it in 'transitioningDelegate' of viewController or like a 'customTransition' of 'DialogViewController'
open class KOCustomTransition: NSObject, UIViewControllerTransitioningDelegate {
    public var animationControllerPresenting: KOAnimatedTransitioningController?
    public var animationControllerDismissing: KOAnimatedTransitioningController?
    
    public init(animationControllerPresenting: KOAnimatedTransitioningController? = nil, animationControllerDismissing: KOAnimatedTransitioningController? = nil) {
        self.animationControllerPresenting = animationControllerPresenting
        self.animationControllerDismissing = animationControllerDismissing
        super.init()
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationControllerPresenting
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationControllerDismissing
    }
}

/// Transition that uses presentation with dimming view
open class KODimmingTransition: KOCustomTransition {
    
    /// Event that will be invoked after created a presentationController
    public var setupPresentationControllerEvent: ((KODimmingPresentationController) -> Void)?
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = KODimmingPresentationController(presentedViewController: presented, presenting: presenting)
        setupPresentationControllerEvent?(presentationController)
        return presentationController
    }
}

// Transition uses presentation with dimming view with visual effect
open class KOVisualEffectDimmingTransition: KOCustomTransition {
    private let effect: UIVisualEffect
    
    /// Event that will be invoked after created a presentationController
    public var setupPresentationControllerEvent: ((KOVisualEffectDimmingPresentationController) -> Void)?
    
    public init(effect: UIVisualEffect, animationControllerPresenting: KOAnimatedTransitioningController? = nil, animationControllerDismissing: KOAnimatedTransitioningController? = nil) {
        self.effect = effect
        super.init(animationControllerPresenting: animationControllerPresenting, animationControllerDismissing: animationControllerDismissing)
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = KOVisualEffectDimmingPresentationController(effect: effect, presentedViewController: presented, presenting: presenting)
        setupPresentationControllerEvent?(presentationController)
        return presentationController
    }
}
