//
//  KOAnimationNew.swift
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

import Foundation

/// Spring animation settings
public struct KOAnimationSpringSettings {
    public var damping: CGFloat = 1.0
    public var velocity: CGFloat = 1.0
    
    public init(damping: CGFloat, velocity: CGFloat) {
        self.damping = damping
        self.velocity = velocity
    }
}

/// Base class for animation, it should be used only for inheritance
open class KOAnimation {
    // MARK: Variables
    public var duration: TimeInterval
    public var delay: TimeInterval
    public var timingParameters: UITimingCurveProvider
    
    // MARK: Functions
    public init(duration: TimeInterval = 0.5, delay: TimeInterval = 0, timingParameters: UITimingCurveProvider = UICubicTimingParameters(animationCurve: .easeInOut)) {
        self.duration = duration
        self.delay = delay
        self.timingParameters = timingParameters
    }
    
    public convenience init(duration: TimeInterval = 0.5, delay: TimeInterval = 0, animationCurve: UIView.AnimationCurve) {
        self.init(duration: duration, delay: delay, timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))
    }
    
    public convenience init(duration: TimeInterval = 0.5, delay: TimeInterval = 0, dampingRatio: CGFloat) {
        self.init(duration: duration, delay: delay, timingParameters: UISpringTimingParameters(dampingRatio: dampingRatio))
    }
    
    /// Old style animation, before iOS 10. This function just runs animation on view with the 'UIView.AnimationOptions' it doesn't use 'timingParameters'
    ///
    /// - Parameters:
    ///   - view: view associated with the animation
    ///   - options: animation options
    ///   - springSettings: dummping settings
    ///   - completionHandler: animation completion handler
    public func animate(view: UIView, options: UIView.AnimationOptions = [], springSettings: KOAnimationSpringSettings? = nil, completionHandler: ((Bool) -> Void)? = nil) {
        prepareViewForAnimation(view)
        guard let springSettings = springSettings else {
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
                [weak self] in
                self?.animation(view: view)
                }, completion: completionHandler)
            return
        }
        
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: springSettings.damping, initialSpringVelocity: springSettings.velocity, options: options, animations: { [weak self] in
            self?.animation(view: view)
            }, completion: completionHandler)
    }
    
    /// Runs animation at 'UIViewControllerTransitionCoordinator'
    ///
    /// - Parameters:
    ///   - view: view associated with the animation
    ///   - coordinator: coordinator of presented view
    ///   - completionHandler: animation completion handler
    public func animateAlongsideTransition(view: UIView, coordinator: UIViewControllerTransitionCoordinator?, completionHandler: ((UIViewControllerTransitionCoordinatorContext?) -> Void)? = nil) {
        prepareViewForAnimation(view)
        guard let coordinator = coordinator else {
            animation(view: view)
            completionHandler?(nil)
            return
        }
        
        coordinator.animate(alongsideTransition: { [weak self](_) in
            self?.animation(view: view)
            }, completion: completionHandler)
    }
    
    // MARK: Functions to override

    /// Used before start of view animation. Developer can override this function to set the initial parameters of the view.
    ///
    /// - Parameter view: view associated with the animation
    open func prepareViewForAnimation(_ view: UIView) {
        //to override
    }
    
    /// Animation block. This function should be overridden to set the view property in animation.
    ///
    /// - Parameter view: view associated with the animation
    open func animation(view: UIView) {
        //to override
    }
}

///  Group of animations, it will be treated like a one animation. Specific parameters for each animation will be avoided, only parameters setted for whole group will be used.
open class KOAnimationGroup: KOAnimation {
    private let animations: [KOAnimation]
    
    /// Init
    ///
    /// - Parameters:
    ///   - animations: grouped animations
    ///   - duration: total duration of animation
    ///   - delay: animation delay
    ///   - timingParameters: animation parameters
    public init(animations: [KOAnimation], duration: TimeInterval = 0.5, delay: TimeInterval = 0, timingParameters: UITimingCurveProvider = UICubicTimingParameters(animationCurve: .easeInOut)) {
        self.animations = animations
        super.init(duration: duration, delay: delay, timingParameters: timingParameters)
    }
    
    public convenience init(animations: [KOAnimation], duration: TimeInterval = 0.5, delay: TimeInterval = 0, animationCurve: UIView.AnimationCurve) {
        self.init(animations: animations, duration: duration, delay: delay, timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))
    }
    
    public convenience init(animations: [KOAnimation], duration: TimeInterval = 0.5, delay: TimeInterval = 0, dampingRatio: CGFloat) {
        self.init(animations: animations, duration: duration, delay: delay, timingParameters: UISpringTimingParameters(dampingRatio: dampingRatio))
    }
    
    // MARK: Functions to override
    override open func prepareViewForAnimation(_ view: UIView) {
        for animation in animations {
            animation.prepareViewForAnimation(view)
        }
    }
    
    override open func animation(view: UIView) {
        for animation in animations {
            animation.animation(view: view)
        }
    }
}

/// Custom animation class. Can be used to create keyframes animations etc.
open class KOCustomAnimation: KOAnimation {
    private var animationEvent: (UIView) -> Void
    private var prepareViewForAnimationEvent: ((UIView) -> Void)?
    
    /// Init
    ///
    /// - Parameters:
    ///   - animation: animation block, it has to set the final parameters of animation at the view. In example: view.alpha = 1.0.
    ///   - prepareViewForAnimation: it should be used to set the initial parameters of the view before animation
    public init(animation: @escaping (UIView) -> Void, prepareViewForAnimation: ((UIView) -> Void)?) {
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

/// Base class for animation that will set initial view parameters
open class KOFromToAnimation<ValueType>: KOAnimation {
    public var toValue: ValueType
    public var fromValue: ValueType?
    
    public init(toValue: ValueType, fromValue: ValueType? = nil) {
        self.toValue = toValue
        self.fromValue = fromValue
        
        super.init()
    }
}

open class KOFadeAnimation: KOFromToAnimation<CGFloat> {
    override open func animation(view: UIView) {
        view.alpha = toValue
    }
    
    override open func prepareViewForAnimation(_ view: UIView) {
        if let fromValue = fromValue {
            view.alpha = fromValue
        }
    }
}

public class KOFadeInAnimation: KOFadeAnimation {
    public init(fromValue: CGFloat? = nil) {
        super.init(toValue: 1.0, fromValue: fromValue)
    }
}

public class KOFadeOutAnimation: KOFadeAnimation {
    public init(fromValue: CGFloat? = nil) {
        super.init(toValue: 0, fromValue: fromValue)
    }
}

public class KOTransformAnimation: KOFromToAnimation<CGAffineTransform> {
    override public func prepareViewForAnimation(_ view: UIView) {
        if let fromValue = fromValue {
            view.transform = fromValue
        }
    }
    
    override public func animation(view: UIView) {
        view.transform = toValue
    }
}

public class KOScaleAnimation: KOTransformAnimation {
    public init(toValue: CGPoint, fromValue: CGPoint?  = nil) {
        var fromValueTransform: CGAffineTransform?
        if let fromValuePoint = fromValue {
            fromValueTransform = CGAffineTransform(scaleX: fromValuePoint.x, y: fromValuePoint.y)
        }
        super.init(toValue: CGAffineTransform(scaleX: toValue.x, y: toValue.y), fromValue: fromValueTransform)
    }
}

public class KOTranslationAnimation: KOTransformAnimation {
    public init(toValue: CGPoint, fromValue: CGPoint? = nil) {
        var fromValueTransform: CGAffineTransform?
        if let fromValuePoint = fromValue {
            fromValueTransform = CGAffineTransform(translationX: fromValuePoint.x, y: fromValuePoint.y)
        }
        super.init(toValue: CGAffineTransform(translationX: toValue.x, y: toValue.y), fromValue: fromValueTransform)
    }
}

public class KORotationAnimation: KOTransformAnimation {
    public init(toValue: CGFloat, fromValue: CGFloat? = nil) {
        var fromValueTransform: CGAffineTransform?
        if let fromValueFloat = fromValue {
            fromValueTransform = CGAffineTransform(rotationAngle: fromValueFloat)
        }
        super.init(toValue: CGAffineTransform(rotationAngle: toValue), fromValue: fromValueTransform)
    }
}

open class KOBackgroundColorAnimation: KOFromToAnimation<UIColor> {
    override open func animation(view: UIView) {
        view.backgroundColor = toValue
    }
    
    override open func prepareViewForAnimation(_ view: UIView) {
        if let fromValue = fromValue {
            view.backgroundColor = fromValue
        }
    }
}

open class KOFrameAnimation: KOFromToAnimation<CGRect> {
    override open func animation(view: UIView) {
        view.frame = toValue
    }
    
    override open func prepareViewForAnimation(_ view: UIView) {
        if let fromValue = fromValue {
            view.frame = fromValue
        }
    }
}

open class KOFrameFromToCurrentAnimation: KOAnimation {
    private var fromValue: CGRect
    private var toValue: CGRect?
    
    public init(fromValue: CGRect) {
        self.fromValue = fromValue
        super.init()
    }
    
    override open func animation(view: UIView) {
        if let toValue = toValue {
            view.frame = toValue
        }
    }
    
    override open func prepareViewForAnimation(_ view: UIView) {
        toValue = view.frame
        view.frame = fromValue
    }
}

open class KOVisualEffectAnimation: KOFromToAnimation<UIVisualEffect?> {
    override open func animation(view: UIView) {
        guard let visualEffectView = view as? UIVisualEffectView else {
            return
        }
        visualEffectView.effect = toValue
    }
    
    override open func prepareViewForAnimation(_ view: UIView) {
        if let visualEffectView = view as? UIVisualEffectView, let fromValue = fromValue {
            visualEffectView.effect = fromValue
        }
    }
}
