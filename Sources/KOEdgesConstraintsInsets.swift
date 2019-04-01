//
//  KOEdgesConstraintsInsets.swift
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

import UIKit

/// Helps to manage horizonstal constraints
public class KOHorizontalConstraintsInsets {
    private weak var leftConst: NSLayoutConstraint!
    private weak var rightConst: NSLayoutConstraint!
    private let leftMultipler: CGFloat
    private let rightMultipler: CGFloat
    
    /// Left constraint's constant
    public var left: CGFloat {
        get {
            return leftMultipler * leftConst.constant
        }
        set {
            leftConst.constant = newValue * leftMultipler
        }
    }
    
    /// Right constraint's constant
    public var right: CGFloat {
        get {
            return rightConst.constant * rightMultipler
        }
        set {
            rightConst.constant = newValue * rightMultipler
        }
    }
    
    init(leftConst: NSLayoutConstraint, rightConst: NSLayoutConstraint, leftMultipler: CGFloat = 1.0, rightMultipler: CGFloat = -1.0) {
        self.leftConst = leftConst
        self.rightConst = rightConst
        
        self.leftMultipler = leftMultipler
        self.rightMultipler = rightMultipler
    }
}

/// Helps to manage vertical constraints
public class KOVerticalConstraintsInsets {
    private weak var topConst: NSLayoutConstraint!
    private weak var bottomConst: NSLayoutConstraint!
    private let topMultipler: CGFloat
    private let bottomMultipler: CGFloat
    
    /// Top constraint's constant
    public var top: CGFloat {
        get {
            return topConst.constant * topMultipler
        }
        set {
            topConst.constant = newValue * topMultipler
        }
    }
    
    /// Bottom constraint's constant
    public var bottom: CGFloat {
        get {
            return bottomConst.constant * bottomMultipler
        }
        set {
            bottomConst.constant = newValue * bottomMultipler
        }
    }
    
    init(topConst: NSLayoutConstraint, bottomConst: NSLayoutConstraint, topMultipler: CGFloat = 1.0, bottomMultipler: CGFloat = -1.0) {
        self.topConst = topConst
        self.bottomConst = bottomConst
        
        self.topMultipler = topMultipler
        self.bottomMultipler = bottomMultipler
    }
}

public class KOEdgesConstraintsInsets {
    private var horizontal: KOHorizontalConstraintsInsets!
    private var vertical: KOVerticalConstraintsInsets!
    
    /// Left constraint's constant
    public var left: CGFloat {
        get {
            return horizontal.left
        }
        set {
            horizontal.left = newValue
        }
    }
    
    /// Top constraint's constant
    public var top: CGFloat {
        get {
            return vertical.top
        }
        set {
            vertical.top = newValue
        }
    }
    
    /// Right constraint's constant
    public var right: CGFloat {
        get {
            return horizontal.right
        }
        set {
            horizontal.right = newValue
        }
    }
    
    /// Bottom constraint's constant
    public var bottom: CGFloat {
        get {
            return vertical.bottom
        }
        set {
            vertical.bottom = newValue
        }
    }
    
    /// Changes all constants of the constraints to match the insets
    public var insets: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: vertical.top, left: horizontal.left, bottom: vertical.bottom, right: horizontal.right)
        }
        set {
            horizontal.left = newValue.left
            horizontal.right = newValue.right
            vertical.top = newValue.top
            vertical.bottom = newValue.bottom
        }
    }
    
    public init(horizontal: KOHorizontalConstraintsInsets, vertical: KOVerticalConstraintsInsets) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
}
