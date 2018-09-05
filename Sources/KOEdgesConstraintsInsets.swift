//
//  KOEdgesConstraintsInsets.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 05.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

public class KOHorizontalConstraintsInsets{
    private weak var leftConst : NSLayoutConstraint!
    private weak var rightConst : NSLayoutConstraint!
    private let leftMultipler : CGFloat
    private let rightMultipler : CGFloat
    
    public var left : CGFloat{
        get{
            return leftMultipler * leftConst.constant
        }
        set{
            leftConst.constant = newValue * leftMultipler
        }
    }
    
    public var right : CGFloat{
        get{
            return rightConst.constant * rightMultipler
        }
        set{
            rightConst.constant = newValue * rightMultipler
        }
    }
    
    init(leftConst : NSLayoutConstraint, rightConst : NSLayoutConstraint, leftMultipler : CGFloat = 1.0, rightMultipler : CGFloat = -1.0){
        self.leftConst = leftConst
        self.rightConst = rightConst
        
        self.leftMultipler = leftMultipler
        self.rightMultipler = rightMultipler
    }
}

public class KOVerticalConstraintsInsets{
    private weak var topConst : NSLayoutConstraint!
    private weak var bottomConst : NSLayoutConstraint!
    private let topMultipler : CGFloat
    private let bottomMultipler : CGFloat
    
    public var top : CGFloat{
        get{
            return topConst.constant * topMultipler
        }
        set{
            topConst.constant = newValue * topMultipler
        }
    }
    
    public var bottom : CGFloat{
        get{
            return bottomConst.constant * bottomMultipler
        }
        set{
            bottomConst.constant = newValue * bottomMultipler
        }
    }
    
    init(topConst : NSLayoutConstraint, bottomConst : NSLayoutConstraint, topMultipler : CGFloat = 1.0, bottomMultipler : CGFloat = -1.0){
        self.topConst = topConst
        self.bottomConst = bottomConst
        
        self.topMultipler = topMultipler
        self.bottomMultipler = bottomMultipler
    }
}

public class KOEdgesConstraintsInsets{
    private var horizontal : KOHorizontalConstraintsInsets!
    private var vertical : KOVerticalConstraintsInsets!
    
    public var left : CGFloat{
        get{
            return horizontal.left
        }
        set{
            horizontal.left = newValue
        }
    }
    
    public var top : CGFloat{
        get{
            return vertical.top
        }
        set{
            vertical.top = newValue
        }
    }
    
    public var right : CGFloat{
        get{
            return horizontal.right
        }
        set{
            horizontal.right = newValue
        }
    }
    
    public var bottom : CGFloat{
        get{
            return vertical.bottom
        }
        set{
            vertical.bottom = newValue
        }
    }
    
    public var insets : UIEdgeInsets {
        get{
            return UIEdgeInsets(top: vertical.top, left: horizontal.left, bottom: vertical.bottom, right: horizontal.right)
        }
        set{
            horizontal.left = newValue.left
            horizontal.right = newValue.right
            vertical.top = newValue.top
            vertical.bottom = newValue.bottom
        }
    }
    
    public init(horizontal : KOHorizontalConstraintsInsets, vertical : KOVerticalConstraintsInsets){
        self.horizontal = horizontal
        self.vertical = vertical
    }
}
