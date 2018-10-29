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
open class KOCustomTransition :  NSObject, UIViewControllerTransitioningDelegate{
    
    /// Animation controller that will be used for presenting a view
    public var animationControllerPresenting : KOAnimationController?
    
    /// Animation controller that will be used for dismissing a view
    public var animationControllerDismissing : KOAnimationController?
    
    public init(animationControllerPresenting : KOAnimationController? = nil, animationControllerDismissing : KOAnimationController? = nil) {
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
open class KODimmingTransition : KOCustomTransition{
    
    /// Event that will be invoked after created a presentationController
    public var setupPresentationControllerEvent : ((KODimmingPresentationController)->Void)? = nil
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = KODimmingPresentationController(presentedViewController: presented, presenting: presenting)
        setupPresentationControllerEvent?(presentationController)
        return presentationController
    }
}

// Transition uses presentation with dimming view with visual effect
open class KOVisualEffectDimmingTransition : KOCustomTransition{
    private let effect : UIVisualEffect
    
    /// Event that will be invoked after created a presentationController
    public var setupPresentationControllerEvent : ((KOVisualEffectDimmingPresentationController)->Void)? = nil
    
    public init(effect: UIVisualEffect, animationControllerPresenting : KOAnimationController? = nil, animationControllerDismissing : KOAnimationController? = nil) {
        self.effect = effect
        super.init(animationControllerPresenting: animationControllerPresenting, animationControllerDismissing: animationControllerDismissing)
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = KOVisualEffectDimmingPresentationController(effect: effect, presentedViewController: presented, presenting: presenting)
        setupPresentationControllerEvent?(presentationController)
        return presentationController
    }
}

/// Manages animations of transition from and to views
open class KOAnimationController : NSObject, UIViewControllerAnimatedTransitioning{
    private var animatorTo : KOAnimator!
    private var animatorFrom : KOAnimator!
    
    public private(set) var duration : TimeInterval
    
    /// If it is a presenting animation, it will be a new view
    public private(set) var viewToAnimation : KOAnimation?
    
    /// If it is a presenting animation, it will be a presenting view. For dismissing animation it will be a current presented view.
    public private(set) var viewFromAnimation : KOAnimation?
    
    /// Duration of animations
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public init(duration : TimeInterval, viewToAnimation : KOAnimation?, viewFromAnimation : KOAnimation?) {
        self.duration = duration
        self.viewToAnimation = viewToAnimation
        self.viewFromAnimation = viewFromAnimation
        super.init()
    }
    
    private func addViewTo(using transitionContext: UIViewControllerContextTransitioning){
        guard let viewControllerTo = transitionContext.viewController(forKey: .to), let viewTo = transitionContext.view(forKey: .to) else {
            return
        }
        let endFrame = transitionContext.finalFrame(for: viewControllerTo)
        viewTo.frame = endFrame
        transitionContext.containerView.addSubview(viewTo)
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        addViewTo(using: transitionContext)
        
        let completeTransitionHandler : (UIViewAnimatingPosition)->Void = {
            _ in
            transitionContext.completeTransition(true)
        }
        guard viewToAnimation != nil || viewFromAnimation != nil else{
            transitionContext.completeTransition(true)
            return
        }
        
        var runInToAnimation = (viewToAnimation?.duration ?? -1) >= (viewFromAnimation?.duration ?? -1)
        if let viewToAnimation = viewToAnimation, let viewTo = transitionContext.view(forKey: .to){
            viewToAnimation.duration = min(duration, viewToAnimation.duration)
            animatorTo = KOAnimator(view: viewTo)
            animatorTo.runViewAnimation(viewToAnimation, completionHandler: runInToAnimation ? completeTransitionHandler : nil)
        }else{
            runInToAnimation = false
        }
        
        if let viewFromAnimation = viewFromAnimation, let viewFrom = transitionContext.view(forKey: .from){
            viewFromAnimation.duration = min(duration, viewFromAnimation.duration)
            animatorFrom = KOAnimator(view: viewFrom)
            animatorFrom.runViewAnimation(viewFromAnimation, completionHandler: !runInToAnimation ? completeTransitionHandler : nil)
        }else{
            if !runInToAnimation{
                transitionContext.completeTransition(true)
            }
        }
    }
}

/// Presentation that adds a 'dimmingView' before presented view
open class KODimmingPresentationController : UIPresentationController {
    //MARK: Variables
    private var dimmingShowAnimator : KOAnimator?
    private var dimmingHideAnimator : KOAnimator?
    
    //public
    public private(set) var dimmingView : UIView!
    
    /// This view will be always at the bottom. It has a full screen frame, and can forward touches to the other views outside presentedViewController. It works well in mixed solution, when you cut the view by setting 'keepFrameOfView' and forwards touches to the viewController bellow presentedViewController by settings 'passthroughViews'
    public private(set) var touchForwardingView : KOTouchForwardingView!
    
    /// Frame of this view will be keeped for presented view, so you can cut the view at the bottom or where you want..
    public weak var keepFrameOfView : UIView? = nil
    
    /// Animation of showing 'dimmingView'
    public var dimmingShowAnimation : KOAnimation?
    
    /// Is animation is running alongside with the transition, this can make some rendering problems with the UIVisualEffect
    public var dimmingShowAnimationSyncWithTransition : Bool = true
    
    /// Animation of hidding 'dimmingView'
    public var dimmingHideAnimation : KOAnimation?
    
    /// Is animation is running alongside with the transition, this can make some rendering problems with the UIVisualEffect
    public var dimmingHideAnimationSyncWithTransition : Bool = true
    
    /// Event that will be invoked when user clicked at the 'dimmingView'
    public var dimmingViewTapEvent : (()->Void)? = nil
    
    override open var frameOfPresentedViewInContainerView: CGRect{
        guard let keepFrameOfView = keepFrameOfView else{
            return super.frameOfPresentedViewInContainerView
        }
        return keepFrameOfView.frame
    }
    
    //MARK: Functions
    override public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        initialize()
    }
    
    open func initialize(){
        touchForwardingView = KOTouchForwardingView()
        touchForwardingView.backgroundColor = UIColor.clear
        
        dimmingView = createDimmingView()
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingViewTap)))
    }
    
    override open func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        dimmingView.frame = frameOfPresentedViewInContainerView
        touchForwardingView.frame = containerView?.frame ?? frameOfPresentedViewInContainerView
    }
    
    override open func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let containerView = containerView else{
            return
        }
        dimmingView.frame = frameOfPresentedViewInContainerView
        containerView.insertSubview(dimmingView, at: 0)
        
        touchForwardingView.frame = containerView.frame
        containerView.insertSubview(touchForwardingView, at: 0)
    
        if dimmingShowAnimationSyncWithTransition{
            dimmingShowAnimation?.animateAlongsideTransition(view: dimmingView, coordinator: presentedViewController.transitionCoordinator, completionHandler: nil)
        }else if let dimmingShowAnimation = dimmingShowAnimation{
            dimmingShowAnimator = KOAnimator(view: dimmingView)
            dimmingShowAnimator!.runViewAnimation(dimmingShowAnimation, completionHandler: nil)
        }
    }
    
    override open func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        if dimmingShowAnimationSyncWithTransition{
              dimmingHideAnimation?.animateAlongsideTransition(view: dimmingView, coordinator: presentedViewController.transitionCoordinator, completionHandler: nil)
        }else if let dimmingHideAnimation = dimmingHideAnimation{
            dimmingShowAnimator?.stopViewAnimation()
            dimmingHideAnimator = KOAnimator(view: dimmingView)
            dimmingHideAnimator!.runViewAnimation(dimmingHideAnimation, completionHandler: nil)
        }
      
    }
    
    /// You can override this function to create your own dimmingView
    open func createDimmingView()->UIView{
        dimmingShowAnimation = KOFadeInAnimation(fromValue: 0)
        dimmingHideAnimation = KOFadeOutAnimation()

        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return dimmingView
    }
    
    @objc private func dimmingViewTap(){
        dimmingViewTapEvent?()
    }
}


/// Presentation that adds a 'dimmingView' with visual effect before presented view
public class KOVisualEffectDimmingPresentationController : KODimmingPresentationController {
    private let effect : UIVisualEffect
    
    //MARK: Functions
    public init(effect : UIVisualEffect, presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.effect = effect
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        initialize()
    }
    
    override public func createDimmingView() -> UIView {
        dimmingShowAnimation = KOVisualEffectAnimation(toValue: effect)
        dimmingShowAnimationSyncWithTransition = false
        dimmingHideAnimation = KOVisualEffectAnimation(toValue: nil)
        
        let dimmingView = UIVisualEffectView(effect: nil)
        return dimmingView
    }
    
}

