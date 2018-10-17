//
//  KOAnimationNew.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 05/10/2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import Foundation

public struct KOAnimationSpringSettings{
    public var damping : CGFloat = 1.0
    public var velocity : CGFloat = 1.0
    
    public init(damping : CGFloat, velocity : CGFloat){
        self.damping = damping
        self.velocity = velocity
    }
}

open class KOAnimator{
    private weak var view : UIView?
    
    public private(set) var currentViewAnimation : KOAnimation?
    public private(set) var currentPropertyAnimator : UIViewPropertyAnimator?
    
    public var prepareViewForAnimationEvent : ((_ : UIView)->Void)?
    
    public var isRunning : Bool {
        return currentPropertyAnimator?.isRunning ?? false
    }
    
    public init(view : UIView){
        self.view = view
    }

    open func runViewAnimation(_ animation : KOAnimation, completionHandler : ((UIViewAnimatingPosition)->Void)?){
        stopViewAnimation()
        
        if let view = view{
            prepareViewForAnimationEvent?(view)
            animation.prepareViewForAnimation(view)
        }
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
        playViewAnimation()
    }
    
    open func runAnimationAlongsideTransition(_ animation : KOAnimation, coordinator : UIViewControllerTransitionCoordinator?, completionHandler : ((UIViewControllerTransitionCoordinatorContext?)->Void)?){
        guard let view = view else{
            return
        }
        animation.prepareViewForAnimation(view)
        animation.animateAlongsideTransition(view: view, coordinator: coordinator, completionHandler: completionHandler)
    }
    
    public func pauseViewAnimation(){
        guard let currentPropertyAnimator = currentPropertyAnimator else{
            return
        }
        currentPropertyAnimator.pauseAnimation()
    }
    
    public func stopViewAnimation(){
        guard let currentPropertyAnimator = currentPropertyAnimator, currentPropertyAnimator.state != .stopped else{
            return
        }
        currentPropertyAnimator.stopAnimation(false)
    }
    
    public func playViewAnimation(){
        guard let currentViewAnimation = currentViewAnimation, let currentPropertyAnimator = currentPropertyAnimator else{
            return
        }
        currentPropertyAnimator.startAnimation(afterDelay: currentViewAnimation.delay)
    }
}

open class KOAnimation{
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

open class KOAnimationGroup : KOAnimation{
    private let animations : [KOAnimation]
    
    public init(animations : [KOAnimation], duration: TimeInterval = 0.5, delay : TimeInterval = 0, timingParameters : UITimingCurveProvider = UICubicTimingParameters(animationCurve: .easeInOut)){
        self.animations = animations
        super.init(duration: duration, delay: delay, timingParameters: timingParameters)
    }
    
    public convenience init(animations : [KOAnimation], duration: TimeInterval = 0.5, delay : TimeInterval = 0, animationCurve : UIView.AnimationCurve){
        self.init(animations: animations, duration: duration, delay: delay, timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))
    }
    
    public convenience init(animations : [KOAnimation],duration: TimeInterval = 0.5, delay : TimeInterval = 0, dampingRatio : CGFloat){
        self.init(animations: animations, duration: duration, delay: delay, timingParameters: UISpringTimingParameters(dampingRatio: dampingRatio))
    }
    
    //MARK: Functions to override
    override open func prepareViewForAnimation(_ view: UIView){
        for animation in animations{
            animation.prepareViewForAnimation(view)
        }
    }
    
    override open func animation(view : UIView){
        for animation in animations{
            animation.animation(view: view)
        }
    }
}

open class KOCustomAnimation : KOAnimation{
    private var animationEvent : (UIView)->Void
    private var prepareViewForAnimationEvent : ((UIView)->Void)?
    
    public init(animation : @escaping (UIView)->Void, prepareViewForAnimation : ((UIView)->Void)?) {
        self.animationEvent = animation
        self.prepareViewForAnimationEvent = prepareViewForAnimation
        
        super.init()
    }
    
    override open func animation(view: UIView) {
        animationEvent(view)
    }
    
    override open func prepareViewForAnimation(_ view: UIView) {
        prepareViewForAnimationEvent?(view)
    }
}

open class KOFromToAnimation<ValueType> : KOAnimation{
    public var toValue : ValueType
    public var fromValue : ValueType?
    
    public init(toValue : ValueType, fromValue : ValueType? = nil){
        self.toValue = toValue
        self.fromValue = fromValue
        
        super.init()
    }
}

open class KOFadeAnimation : KOFromToAnimation<CGFloat>{
    override open func animation(view: UIView) {
        view.alpha = toValue
    }
    
    override open func prepareViewForAnimation(_ view: UIView) {
        if let fromValue = fromValue{
            view.alpha = fromValue
        }
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

public class KOTransformAnimation: KOFromToAnimation<CGAffineTransform>{
    override public func prepareViewForAnimation(_ view: UIView) {
        if let fromValue = fromValue{
            view.transform = fromValue
        }
    }
    
    override public func animation(view: UIView) {
        view.transform = toValue
    }
}

public class KOScaleAnimation : KOTransformAnimation{
    public init(toValue: CGPoint, fromValue: CGPoint?  = nil) {
        var fromValueTransform : CGAffineTransform? = nil
        if let fromValuePoint = fromValue{
            fromValueTransform = CGAffineTransform(scaleX: fromValuePoint.x, y: fromValuePoint.y)
        }
        super.init(toValue: CGAffineTransform(scaleX: toValue.x, y: toValue.y), fromValue: fromValueTransform)
    }
}

public class KOTranslationAnimation : KOTransformAnimation{
    public init(toValue: CGPoint, fromValue: CGPoint? = nil) {
        var fromValueTransform : CGAffineTransform? = nil
        if let fromValuePoint = fromValue{
            fromValueTransform = CGAffineTransform(translationX: fromValuePoint.x, y: fromValuePoint.y)
        }
        super.init(toValue: CGAffineTransform(translationX: toValue.x, y: toValue.y), fromValue: fromValueTransform)
    }
}

public class KORotationAnimation : KOTransformAnimation{
    public init(toValue: CGFloat, fromValue: CGFloat? = nil) {
        var fromValueTransform : CGAffineTransform? = nil
        if let fromValueFloat = fromValue{
            fromValueTransform = CGAffineTransform(rotationAngle: fromValueFloat)
        }
        super.init(toValue: CGAffineTransform(rotationAngle: toValue), fromValue: fromValueTransform)
    }
}

open class KOBackgroundColorAnimation : KOFromToAnimation<UIColor>{
    override open func animation(view: UIView) {
        view.backgroundColor = toValue
    }
    
    override open func prepareViewForAnimation(_ view: UIView) {
        if let fromValue = fromValue{
            view.backgroundColor = fromValue
        }
    }
}

open class KOFrameAnimation : KOFromToAnimation<CGRect>{
    override open func animation(view: UIView) {
        view.frame = toValue
    }
    
    override open func prepareViewForAnimation(_ view: UIView) {
        if let fromValue = fromValue{
            view.frame = fromValue
        }
    }
}

open class KOFrameFromToCurrentAnimation : KOAnimation{
    private var fromValue : CGRect
    private var toValue : CGRect?
    
    public init(fromValue: CGRect) {
        self.fromValue = fromValue
        super.init()
    }
    
    override open func animation(view: UIView) {
        if let toValue = toValue{
            view.frame = toValue
        }
    }
    
    override open func prepareViewForAnimation(_ view: UIView) {
        toValue = view.frame
        view.frame = fromValue
    }
}

open class KOVisualEffectAnimation : KOFromToAnimation<UIVisualEffect?>{
    override open func animation(view: UIView) {
        guard let visualEffectView = view as? UIVisualEffectView else{
            return
        }
        visualEffectView.effect = toValue
    }
    
    override open func prepareViewForAnimation(_ view: UIView) {
        if let visualEffectView = view as? UIVisualEffectView, let fromValue = fromValue{
            visualEffectView.effect = fromValue
        }
    }
}
