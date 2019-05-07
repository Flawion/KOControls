//
//  KOControlBorderFeature.swift
//  KOControls
//
//  Copyright (c) 2019 Kuba Ostrowski
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

public struct KOControlBorderSettings {
    public var color: CGColor?
    public var errorColor: CGColor?
    public var focusedColor: CGColor?
    public var errorFocusedColor: CGColor?
    
    public var width: CGFloat
    public var errorWidth: CGFloat?
    public var focusedWidth: CGFloat?
    public var errorFocusedWidth: CGFloat?
    
    public init(color: CGColor? = nil, errorColor: CGColor?  = nil, focusedColor: CGColor?  = nil, errorFocusedColor: CGColor? = nil, width: CGFloat = 0, errorWidth: CGFloat? = nil, focusedWidth: CGFloat? = nil, errorFocusedWidth: CGFloat? = nil) {
        self.color = color
        self.errorColor = errorColor
        self.focusedColor = focusedColor
        self.errorFocusedColor = errorFocusedColor
        self.width = width
        self.errorWidth = errorWidth
        self.focusedWidth = focusedWidth
        self.errorFocusedWidth = errorFocusedWidth
    }
}

public protocol KOControlBorderFeatureDelegate: NSObjectProtocol {
    var featureContainer: UIView { get }
    var errorIsShowing: Bool { get }
}

// MARK: - KOControlBorderFeature
public class KOControlBorderFeature {
    // MARK: - Variables
    private weak var delegate: KOControlBorderFeatureDelegate?
    
    public var settings: KOControlBorderSettings? {
        didSet {
            refresh()
        }
    }
    
    // MARK: - Functions
    public init(delegate: KOControlBorderFeatureDelegate) {
        self.delegate = delegate
    }

    /// It must be manually invoke if the parameters were changed directly from the struct 'borderSettings'.
    public func refresh() {
        guard let delegate = delegate, let borderSettings = settings else {
            return
        }
        
        let errorIsShowing = delegate.errorIsShowing
        let firstResponder = delegate.featureContainer.isFirstResponder
        let defaultColor = errorIsShowing ? (borderSettings.errorColor ?? borderSettings.color) : borderSettings.color
        let defaultWidth = errorIsShowing ? (borderSettings.errorWidth ?? borderSettings.width) : borderSettings.width
        let defaultFocusedColor = errorIsShowing ? (borderSettings.errorFocusedColor ?? borderSettings.focusedColor) : borderSettings.focusedColor
        let defaultFocusedWidth = errorIsShowing ? (borderSettings.errorFocusedWidth ?? borderSettings.focusedWidth) : borderSettings.focusedWidth
        
        if firstResponder {
            setContainer(delegate.featureContainer, borderColor: defaultFocusedColor ?? defaultColor, andWidth: defaultFocusedWidth ?? defaultWidth)
        } else {
            setContainer(delegate.featureContainer, borderColor: defaultColor, andWidth: defaultWidth)
        }
    }
    
    private func setContainer(_ container: UIView, borderColor color: CGColor?, andWidth width: CGFloat) {
        container.layer.borderColor = color
        container.layer.borderWidth = width
    }
    
    /// Must be invoked by parent container
    public func eventFirstResponderChanged() {
        refresh()
    }
}
