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
    private var dimmingView : UIView!
    
    //open
    public var setupDimmingViewEvent : ((UIView)->Void)? = nil
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
        
        setupDimmingViewEvent?(dimmingView)
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
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override public func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
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
