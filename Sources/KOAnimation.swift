//
//  KOAnimation.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 13.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

public protocol KOAnimationInterface {
    func animate(view : UIView,  progress : CGFloat, completionHandler : ((Bool)->Void)?)
}

public protocol KOAnimationAlongsideTransitionInterface {
    func animateAlongsideTransition(view : UIView, coordinator : UIViewControllerTransitionCoordinator?, completionHandler : ((UIViewControllerTransitionCoordinatorContext?)->Void)?)
}

//MARK: - Animator
public struct KOAnimationSpringSettings{
    public var damping : CGFloat = 1.0
    public var velocity : CGFloat = 1.0
}

open class KOViewAnimator {
    public var duration : TimeInterval = 0.5
    public var delay : TimeInterval = 0
    public var options : UIViewAnimationOptions = []
    public var springSettings : KOAnimationSpringSettings? = nil
    
    open func runAnimation(onView : UIView, animationBlock : (()->Void)?, completionHandler : ((Bool)->Void)?){
        guard let springSettings = springSettings else{
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
                animationBlock?()
            }, completion: completionHandler)
            return
        }
        
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: springSettings.damping, initialSpringVelocity: springSettings.velocity, options: options, animations: {
            animationBlock?()
        }, completion: completionHandler)
    }
    
    open func runAnimationAlongsideTransition(onView : UIView, coordinator : UIViewControllerTransitionCoordinator?, animationBlock : ((UIViewControllerTransitionCoordinatorContext?)->Void)?, completionHandler : ((UIViewControllerTransitionCoordinatorContext?)->Void)?){
        guard let coordinator = coordinator else{
            animationBlock?(nil)
            completionHandler?(nil)
            return
        }
        
        coordinator.animate(alongsideTransition: { (coordinatorContext) in
            animationBlock?(coordinatorContext)
        }, completion: completionHandler)
    }
}

//MARK: - Animations
public class KOFadeAnimation : KOViewAnimator, KOAnimationInterface, KOAnimationAlongsideTransitionInterface{
    public var toValue : CGFloat
    public var fromValue : CGFloat?
    
    public init(toValue : CGFloat, fromValue : CGFloat? = nil){
        self.toValue = toValue
        self.fromValue = fromValue
    }
    
    private func setStartingValue(ofView view: UIView){
        if let fromValue = fromValue{
            view.alpha = fromValue
        }
    }
    
    public func animate(view : UIView, progress : CGFloat = 1.0, completionHandler : ((Bool)->Void)? = nil){
        setStartingValue(ofView: view)
        runAnimation(onView: view, animationBlock: {
            [weak self] in
            guard let sSelf = self else{
                return
            }
            view.alpha = sSelf.toValue * progress
        }, completionHandler: completionHandler)
    }
    
    public func animateAlongsideTransition(view: UIView, coordinator: UIViewControllerTransitionCoordinator?, completionHandler: ((UIViewControllerTransitionCoordinatorContext?) -> Void)? = nil) {
        setStartingValue(ofView: view)
        runAnimationAlongsideTransition(onView: view, coordinator: coordinator, animationBlock: {
            [weak self] _ in
            guard let sSelf = self else{
                return
            }
            view.alpha = sSelf.toValue
        }, completionHandler: completionHandler)
    }
}

public class KOFadeInAnimation : KOFadeAnimation{
    public init(fromValue : CGFloat? = nil) {
        super.init(toValue: 1.0, fromValue: fromValue)
    }
}

public class KOFadeOutAnimation : KOFadeAnimation{
    public init(fromValue : CGFloat? = nil) {
        super.init(toValue: 0, fromValue: fromValue)
    }
}

