//
//  KOAnimationNew.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 05/10/2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import Foundation

open class nKOAnimator{
    private weak var view : UIView?
    
    public private(set) var currentViewAnimation : nKOAnimation?
    public private(set) var currentPropertyAnimator : UIViewPropertyAnimator?
    
    public var isRunning : Bool {
        return currentPropertyAnimator?.isRunning ?? false
    }
    
    public init(view : UIView){
        self.view = view
    }

    open func runViewAnimation(_ animation : nKOAnimation, completionHandler : ((UIViewAnimatingPosition)->Void)?){
        stopCurrentAnimation()
        
        currentViewAnimation = animation
        currentPropertyAnimator = UIViewPropertyAnimator(duration: animation.duration, timingParameters: animation.timingParameters)
        currentPropertyAnimator?.addAnimations {
            [weak self] in
            guard let view = self?.view else{
                return
            }
            animation.animation(view: view)
        }
        if let completionHandler = completionHandler{
            currentPropertyAnimator?.addCompletion(completionHandler)
        }
        playCurrentAnimation()
    }
    
    open func runAnimationAlongsideTransition(_ animation : nKOAnimation, coordinator : UIViewControllerTransitionCoordinator?, completionHandler : ((UIViewControllerTransitionCoordinatorContext?)->Void)?){
        guard let view = view else{
            return
        }
        animation.animateAlongsideTransition(view: view, coordinator: coordinator, completionHandler: completionHandler)
    }
    
    public func pauseCurrentAnimation(){
        guard let currentPropertyAnimator = currentPropertyAnimator else{
            print("KOControls-pauseCurrentAnimation error: animation is nil")
            return
        }
        currentPropertyAnimator.pauseAnimation()
    }
    
    public func stopCurrentAnimation(){
        guard let currentPropertyAnimator = currentPropertyAnimator else{
            print("KOControls-stopCurrentAnimation error: animation is nil")
            return
        }
        currentPropertyAnimator.stopAnimation(false)
    }
    
    public func playCurrentAnimation(){
        guard let currentViewAnimation = currentViewAnimation, let currentPropertyAnimator = currentPropertyAnimator else{
            print("KOControls-playCurrentAnimation error: animation is nil")
            return
        }
        currentPropertyAnimator.startAnimation(afterDelay: currentViewAnimation.delay)
    }
}

open class nKOAnimation{
    //MARK: Variables
    public var duration : TimeInterval
    public var delay : TimeInterval
    public var timingParameters : UITimingCurveProvider
    
    //MARK: Functions
    public init(duration: TimeInterval = 0.5, delay : TimeInterval = 0, timingParameters : UITimingCurveProvider = UICubicTimingParameters(animationCurve: .easeInOut)){
        self.duration = duration
        self.delay = delay
        self.timingParameters = timingParameters
    }
    
    public convenience init(duration: TimeInterval = 0.5, delay : TimeInterval = 0, animationCurve : UIView.AnimationCurve){
        self.init(duration: duration, delay: delay, timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))
    }
    
    public convenience init(duration: TimeInterval = 0.5, delay : TimeInterval = 0, dampingRatio : CGFloat){
        self.init(duration: duration, delay: delay, timingParameters: UISpringTimingParameters(dampingRatio: dampingRatio))
    }
    
    public func animate(view : UIView, options : UIView.AnimationOptions = [], springSettings : KOAnimationSpringSettings? = nil, completionHandler : ((Bool)->Void)? = nil){
        prepareViewForAnimation(view)
        guard let springSettings = springSettings else{
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
                [weak self] in
                self?.animation(view: view)
            }, completion: completionHandler)
            return
        }
        
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: springSettings.damping, initialSpringVelocity: springSettings.velocity, options: options, animations: {
            [weak self] in
            self?.animation(view: view)
        }, completion: completionHandler)
    }
    
    public func animateAlongsideTransition(view: UIView, coordinator: UIViewControllerTransitionCoordinator?, completionHandler: ((UIViewControllerTransitionCoordinatorContext?) -> Void)? = nil) {
        prepareViewForAnimation(view)
        guard let coordinator = coordinator else{
            animation(view: view)
            completionHandler?(nil)
            return
        }
        
        coordinator.animate(alongsideTransition: { [weak self](coordinatorContext) in
            self?.animation(view: view)
        }, completion: completionHandler)
    }
    
    //MARK: Functions to override
    open func prepareViewForAnimation(_ view: UIView){
        //to override
    }
    
    open func animation(view : UIView){
        //to override
    }
}

open class nKOCustomAnimation : nKOAnimation{
    private var animationEvent : (UIView)->Void
    private var prepareViewForAnimationEvent : ((UIView)->Void)?
    
    init(animation : @escaping (UIView)->Void, prepareViewForAnimation : ((UIView)->Void)?) {
        self.animationEvent = animation
        self.prepareViewForAnimationEvent = prepareViewForAnimation
    }
    
    override open func animation(view: UIView) {
        animationEvent(view)
    }
    
    override open func prepareViewForAnimation(_ view: UIView) {
        prepareViewForAnimationEvent?(view)
    }
}

open class nKOFadeAnimation : nKOAnimation{
    public var toValue : CGFloat
    public var fromValue : CGFloat?
    
    public init(toValue : CGFloat, fromValue : CGFloat? = nil){
        self.toValue = toValue
        self.fromValue = fromValue
        
        super.init()
    }
    
    override open func animation(view: UIView) {
        view.alpha = toValue
    }
    
    override open func prepareViewForAnimation(_ view: UIView) {
        if let fromValue = fromValue{
            view.alpha = fromValue
        }
    }
}

public class nKOFadeInAnimation : nKOFadeAnimation{
    public init(fromValue : CGFloat? = nil) {
        super.init(toValue: 1.0, fromValue: fromValue)
    }
}

public class nKOFadeOutAnimation : nKOFadeAnimation{
    public init(fromValue : CGFloat? = nil) {
        super.init(toValue: 0, fromValue: fromValue)
    }
}

public class nKOTransformAnimation: nKOAnimation{
    public var toValue : CGAffineTransform
    public var fromValue : CGAffineTransform?
    
    public init(toValue : CGAffineTransform, fromValue : CGAffineTransform? = nil){
        self.toValue = toValue
        self.fromValue = fromValue
        super.init()
    }
    
    override public func prepareViewForAnimation(_ view: UIView) {
        if let fromValue = fromValue{
            view.transform = fromValue
        }
    }
    
    override public func animation(view: UIView) {
        view.transform = toValue
    }
}

public class nKOScaleAnimation : nKOTransformAnimation{
    public init(toValue: CGPoint, fromValue: CGPoint?) {
        var fromValueTransform : CGAffineTransform? = nil
        if let fromValuePoint = fromValue{
            fromValueTransform = CGAffineTransform(scaleX: fromValuePoint.x, y: fromValuePoint.y)
        }
        super.init(toValue: CGAffineTransform(scaleX: toValue.x, y: toValue.y), fromValue: fromValueTransform)
    }
}

public class nKOTranslationAnimation : nKOTransformAnimation{
    public init(toValue: CGPoint, fromValue: CGPoint?) {
        var fromValueTransform : CGAffineTransform? = nil
        if let fromValuePoint = fromValue{
            fromValueTransform = CGAffineTransform(translationX: fromValuePoint.x, y: fromValuePoint.y)
        }
        super.init(toValue: CGAffineTransform(translationX: toValue.x, y: toValue.y), fromValue: fromValueTransform)
    }
}

public class nKORotationAnimation : nKOTransformAnimation{
    public init(toValue: CGFloat, fromValue: CGFloat?) {
        var fromValueTransform : CGAffineTransform? = nil
        if let fromValueFloat = fromValue{
            fromValueTransform = CGAffineTransform(rotationAngle: fromValueFloat)
        }
        super.init(toValue: CGAffineTransform(rotationAngle: toValue), fromValue: fromValueTransform)
    }
}
