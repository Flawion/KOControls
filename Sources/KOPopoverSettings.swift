//
//  KOPopoverSettings.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 18.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

/// Settings of popover presentation
open class KOPopoverSettings : NSObject, UIPopoverPresentationControllerDelegate{
    //MARK: Variables
    
    //base needed variables
    public private(set) weak var barButtonItem : UIBarButtonItem?
    //or
    public private(set) weak var sourceView : UIView?
    public private(set) var sourceRect : CGRect?
    
    //others
    
    /// Preferred content size can be calculated automatically if this variable isn't nil. But view size must be calculable.
    public var calculatePreferredContentSizeByLayoutSizeFitting : CGSize? = UIView.layoutFittingCompressedSize
    
    /// Preferred content size of view
    public var preferredContentSize : CGSize? = nil
    
    /// This event will be invoked before view presented
    public var setupPopoverPresentationControllerEvent : ((UIPopoverPresentationController)->Void)? = nil
    
    //MARK: Functions
    public init(barButtonItem : UIBarButtonItem){
        super.init()
        self.barButtonItem = barButtonItem
    }
    
    public init(sourceView : UIView, sourceRect : CGRect){
        super.init()
        self.sourceView = sourceView
        self.sourceRect = sourceRect
    }
    
    /// If you use overriden 'present' function with parameter 'popoverSettings' this function will be invoked before view presented
    ///
    /// - Parameters:
    ///   - viewController: presented view controller
    ///   - presentOnViewController: presenting view controller
    public func prepareViewController(_ viewController : UIViewController, presentOnViewController : UIViewController ){
        viewController.modalPresentationStyle = .popover
        
        //calculate preferred content size
        if let overridePreferredContentSize = preferredContentSize{
            viewController.preferredContentSize = overridePreferredContentSize
        }else if let calculatePreferredContentSizeByLayoutSizeFitting = calculatePreferredContentSizeByLayoutSizeFitting{
            viewController.loadViewIfNeeded()
            let size = viewController.view.systemLayoutSizeFitting(calculatePreferredContentSizeByLayoutSizeFitting)
            viewController.preferredContentSize = size
        }
        
        //set popover settings
        if let popoverPresentationController = viewController.popoverPresentationController{
            if let barButtonItem = barButtonItem{
                popoverPresentationController.barButtonItem = barButtonItem
            }else if let sourceView = sourceView, let sourceRect = sourceRect{
                popoverPresentationController.sourceView = sourceView
                popoverPresentationController.sourceRect = sourceRect
            }
            popoverPresentationController.delegate = self
            setupPopoverPresentationControllerEvent?(popoverPresentationController)
        }
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
