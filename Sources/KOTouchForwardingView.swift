//
//  KOTouchForwardingView.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 10/10/2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

/// View that forwards touches to the 'passthroughViews'
public class KOTouchForwardingView : UIView{
    
    /// Views that will get touches from this class
    public var passthroughViews : [UIView] = []
    
    public init(passthroughViews : [UIView] = []) {
        self.passthroughViews = passthroughViews
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for passthroughView in passthroughViews{
            if let viewTouched = passthroughView.hitTest(convert(point, to: passthroughView), with: event){
                return viewTouched
            }
        }
        return super.hitTest(point, with: event)
    }
}
