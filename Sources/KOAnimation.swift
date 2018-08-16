//
//  KOAnimation.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 13.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit


public protocol KOAnimationInterface {
    func animate(view : UIView, progress : CGFloat, completionHandler : ((Bool)->Void)?)
}

public struct KOAnimationSpringSettings{
    public var damping : CGFloat = 1.0
    public var velocity : CGFloat = 1.0
}

open class KOViewAnimator{
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
}

public class KOFadeAnimation : KOViewAnimator, KOAnimationInterface{
    public var toValue : CGFloat
    public var fromValue : CGFloat?
    
    public init(toValue : CGFloat, fromValue : CGFloat? = nil){
        self.toValue = toValue
        self.fromValue = fromValue
    }
    
    public func animate(view : UIView, progress : CGFloat = 1.0, completionHandler : ((Bool)->Void)? = nil){
        if let fromValue = fromValue{
            view.alpha = fromValue
        }
        runAnimation(onView: view, animationBlock: {
            [weak self] in
            guard let sSelf = self else{
                return
            }
            view.alpha = sSelf.toValue * progress
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

