//
//  KOPopoverSettings.swift
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

/// Settings of popover presentation
open class KOPopoverSettings: NSObject, UIPopoverPresentationControllerDelegate {
    // MARK: Variables
    
    //base needed variables
    public private(set) weak var barButtonItem: UIBarButtonItem?
    //or
    public private(set) weak var sourceView: UIView?
    public private(set) var sourceRect: CGRect?
    
    //others
    
    /// Preferred content size can be calculated automatically if this variable isn't nil. But view size must be calculable.
    public var preferredContentSizeByLayoutSizeFitting: CGSize? = UIView.layoutFittingCompressedSize
    
    public var preferredContentSize: CGSize?
    
    /// This event will be invoked before view presented
    public var setupPopoverPresentationControllerEvent: ((UIPopoverPresentationController) -> Void)?
    
    // MARK: Functions
    public init(barButtonItem: UIBarButtonItem) {
        super.init()
        self.barButtonItem = barButtonItem
    }
    
    public init(sourceView: UIView, sourceRect: CGRect) {
        super.init()
        self.sourceView = sourceView
        self.sourceRect = sourceRect
    }
    
    /// If you use overriden 'present' function with parameter 'popoverSettings' this function will be invoked before view presented
    public func prepareViewController(_ viewController: UIViewController, presentOnViewController: UIViewController ) {
        calculatePreferedContentSize(forViewController: viewController)
        setPopoverSettings(forViewController: viewController)
    }

    private func calculatePreferedContentSize(forViewController viewController: UIViewController) {
        if let overridePreferredContentSize = preferredContentSize {
            viewController.preferredContentSize = overridePreferredContentSize
        } else if let preferredContentSizeByLayoutSizeFitting = preferredContentSizeByLayoutSizeFitting {
            viewController.loadViewIfNeeded()
            let size = viewController.view.systemLayoutSizeFitting(preferredContentSizeByLayoutSizeFitting)
            viewController.preferredContentSize = size
        }
    }

    private func setPopoverSettings(forViewController viewController: UIViewController) {
        viewController.modalPresentationStyle = .popover
        guard let popoverPresentationController = viewController.popoverPresentationController else {
            return
        }
        setPopoverSettings(forPopoverPresentationController: popoverPresentationController)
    }

    private func setPopoverSettings(forPopoverPresentationController popoverPresentationController: UIPopoverPresentationController) {
        if let barButtonItem = barButtonItem {
            popoverPresentationController.barButtonItem = barButtonItem
        } else if let sourceView = sourceView, let sourceRect = sourceRect {
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = sourceRect
        }
        popoverPresentationController.delegate = self
        setupPopoverPresentationControllerEvent?(popoverPresentationController)
    }
    
    /// Override this function if you don't want to show popover over iPhone and return other 'UIModalPresentationStyle'
    ///
    /// - Parameter controller: presentation controller
    open func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    /// Override this function if you don't want to show popover over iPhone and return other 'UIModalPresentationStyle'
    ///
    /// - Parameter controller: presentation controller
    open func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
