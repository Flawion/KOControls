//
//  KODimmingTransition.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 13.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

public class KODimmingPresentationController : UIPresentationController {
    //MARK: Variables
     //public
    public private(set) var dimmingView : UIView!
    
    public var dimmingShowAnimation : KOAnimationAlongsideTransitionInterface? = KOFadeInAnimation(fromValue: 0)
    public var dimmingHideAnimation : KOAnimationAlongsideTransitionInterface? = KOFadeOutAnimation()

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

public class KODimmingTransition :  NSObject, UIViewControllerTransitioningDelegate{
    public var setupPresentationControllerEvent : ((KODimmingPresentationController)->Void)? = nil
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = KODimmingPresentationController(presentedViewController: presented, presenting: presenting)
        setupPresentationControllerEvent?(presentationController)
        return presentationController
    }
}
