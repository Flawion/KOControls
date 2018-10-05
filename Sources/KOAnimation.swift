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
    
    public init(damping : CGFloat, velocity : CGFloat){
        self.damping = damping
        self.velocity = velocity
    }
}

open class KOAnimator {
    public var duration : TimeInterval = 0.5
    public var delay : TimeInterval = 0
    public var options : UIView.AnimationOptions = []
    public var springSettings : KOAnimationSpringSettings? = nil
    
    public init(){
    }
    
    open func runViewAnimation(animationBlock : (()->Void)?, completionHandler : ((Bool)->Void)?){
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
    
    open func runAnimationAlongsideTransition(coordinator : UIViewControllerTransitionCoordinator?, animationBlock : ((UIViewControllerTransitionCoordinatorContext?)->Void)?, completionHandler : ((UIViewControllerTransitionCoordinatorContext?)->Void)?){
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
public class KOFadeAnimation : KOAnimator, KOAnimationInterface, KOAnimationAlongsideTransitionInterface{
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
        let maxProgress = min(1.0, progress)
        let oldProgress = 1.0 - progress
        runViewAnimation(animationBlock: {
            [weak self] in
            guard let sSelf = self else{
                return
            }
            view.alpha = view.alpha * oldProgress + sSelf.toValue * maxProgress
        }, completionHandler: completionHandler)
    }
    
    public func animateAlongsideTransition(view: UIView, coordinator: UIViewControllerTransitionCoordinator?, completionHandler: ((UIViewControllerTransitionCoordinatorContext?) -> Void)? = nil) {
        setStartingValue(ofView: view)
        runAnimationAlongsideTransition(coordinator: coordinator, animationBlock: {
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

public class KOTransformAnimation: KOAnimator, KOAnimationInterface, KOAnimationAlongsideTransitionInterface{
    public var toValue : CGAffineTransform
    public var fromValue : CGAffineTransform?
    
    public init(toValue : CGAffineTransform, fromValue : CGAffineTransform? = nil){
        self.toValue = toValue
        self.fromValue = fromValue
    }
    
    private func setStartingValue(ofView view: UIView){
        if let fromValue = fromValue{
            view.transform = fromValue
        }
    }
    
    public func animate(view : UIView, progress : CGFloat = 1.0, completionHandler : ((Bool)->Void)? = nil){
        setStartingValue(ofView: view)
        let maxProgress = min(1.0, progress)
        let oldProgress = 1.0 - progress
        runViewAnimation(animationBlock: {
            [weak self] in
            guard let sSelf = self else{
                return
            }
            let oldTransform = view.transform
            view.transform = CGAffineTransform(a: oldTransform.a * oldProgress + sSelf.toValue.a * maxProgress,
                b: oldTransform.b * oldProgress + sSelf.toValue.b * maxProgress,
                c: oldTransform.c * oldProgress + sSelf.toValue.c * maxProgress,
                d: oldTransform.d * oldProgress + sSelf.toValue.d * maxProgress,
                tx: oldTransform.tx * oldProgress + sSelf.toValue.tx * maxProgress,
                ty: oldTransform.ty * oldProgress + sSelf.toValue.ty * maxProgress)
        }, completionHandler: completionHandler)
 
    }
    
    public func animateAlongsideTransition(view: UIView, coordinator: UIViewControllerTransitionCoordinator?, completionHandler: ((UIViewControllerTransitionCoordinatorContext?) -> Void)? = nil) {
        setStartingValue(ofView: view)
        runAnimationAlongsideTransition(coordinator: coordinator, animationBlock: {
            [weak self] _ in
            guard let sSelf = self else{
                return
            }
            view.transform = sSelf.toValue
            }, completionHandler: completionHandler)
    }
}

public class KOScaleAnimation : KOTransformAnimation{
    public init(toValue: CGPoint, fromValue: CGPoint?) {
        var fromValueTransform : CGAffineTransform? = nil
        if let fromValuePoint = fromValue{
            fromValueTransform = CGAffineTransform(scaleX: fromValuePoint.x, y: fromValuePoint.y)
        }
        super.init(toValue: CGAffineTransform(scaleX: toValue.x, y: toValue.y), fromValue: fromValueTransform)
    }
}

public class KOTranslationAnimation : KOTransformAnimation{
    public init(toValue: CGPoint, fromValue: CGPoint?) {
        var fromValueTransform : CGAffineTransform? = nil
        if let fromValuePoint = fromValue{
            fromValueTransform = CGAffineTransform(translationX: fromValuePoint.x, y: fromValuePoint.y)
        }
        super.init(toValue: CGAffineTransform(translationX: toValue.x, y: toValue.y), fromValue: fromValueTransform)
    }
}

public class KORotationAnimation : KOTransformAnimation{
    public init(toValue: CGFloat, fromValue: CGFloat?) {
        var fromValueTransform : CGAffineTransform? = nil
        if let fromValueFloat = fromValue{
            fromValueTransform = CGAffineTransform(rotationAngle: fromValueFloat)
        }
        super.init(toValue: CGAffineTransform(rotationAngle: toValue), fromValue: fromValueTransform)
    }
}
