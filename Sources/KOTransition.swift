//
//  KOTransition.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 13.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

open class KOCustomTransition :  NSObject, UIViewControllerTransitioningDelegate{
    public var animationControllerPresenting : KOAnimationController?
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


open class KOAnimationController : NSObject, UIViewControllerAnimatedTransitioning{
    private var animatorTo : KOAnimator!
    private var animatorFrom : KOAnimator!
    
    public private(set) var duration : TimeInterval
    public private(set) var viewToAnimation : KOAnimation?
    public private(set) var viewFromAnimation : KOAnimation?
    
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
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        addViewTo(using: transitionContext)
        
        let completeTransitionHandler : (UIViewAnimatingPosition)->Void = {
            _ in
            transitionContext.completeTransition(true)
        }
        guard viewToAnimation != nil || viewFromAnimation != nil else{
            transitionContext.completeTransition(true)
            return
        }
        
        let runInToAnimation = (viewToAnimation?.duration ?? -1) >= (viewFromAnimation?.duration ?? -1)
        if let viewToAnimation = viewToAnimation, let viewTo = transitionContext.view(forKey: .to){
            viewToAnimation.duration = min(duration, viewToAnimation.duration)
            animatorTo = KOAnimator(view: viewTo)
            animatorTo.runViewAnimation(viewToAnimation, completionHandler: runInToAnimation ? completeTransitionHandler : nil)
        }
        
        if let viewFromAnimation = viewFromAnimation, let viewFrom = transitionContext.view(forKey: .from){
            viewFromAnimation.duration = min(duration, viewFromAnimation.duration)
            animatorFrom = KOAnimator(view: viewFrom)
            animatorFrom.runViewAnimation(viewFromAnimation, completionHandler: !runInToAnimation ? completeTransitionHandler : nil)
        }
    }
}


public class KODimmingPresentationController : UIPresentationController {
    //MARK: Variables
     //public
    public private(set) var dimmingView : UIView!
    
    public var dimmingShowAnimation : KOAnimation? = KOFadeInAnimation(fromValue: 0)
    public var dimmingHideAnimation : KOAnimation? = KOFadeOutAnimation()

    public var dimmingViewTapEvent : (()->Void)? = nil
    
    //MARK: Functions
    override public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        initialize()
    }
    
    private func initialize(){
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingViewTap)))
    }
    
    override public func presentationTransitionWillBegin() {
        guard let containerView = containerView else{
            return
        }
        containerView.insertSubview(dimmingView, at: 0)
        containerView.addConstraints([
            dimmingView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            dimmingView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        
        dimmingShowAnimation?.animateAlongsideTransition(view: dimmingView, coordinator: presentedViewController.transitionCoordinator, completionHandler: nil)
    }
    
    override public func dismissalTransitionWillBegin() {
        dimmingHideAnimation?.animateAlongsideTransition(view: dimmingView, coordinator: presentedViewController.transitionCoordinator, completionHandler: nil)
    }
    
    @objc private func dimmingViewTap(){
        dimmingViewTapEvent?()
    }
}

open class KODimmingTransition : KOCustomTransition{
    public var setupPresentationControllerEvent : ((KODimmingPresentationController)->Void)? = nil
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = KODimmingPresentationController(presentedViewController: presented, presenting: presenting)
        setupPresentationControllerEvent?(presentationController)
        return presentationController
    }
}
