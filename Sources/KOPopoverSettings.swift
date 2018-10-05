//
//  KOPopoverSettings.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 18.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

open class KOPopoverSettings : NSObject, UIPopoverPresentationControllerDelegate{
    //MARK: Variables
    
    //base needed variables
    public private(set) weak var barButtonItem : UIBarButtonItem?
    //or
    public private(set) weak var sourceView : UIView?
    public private(set) var sourceRect : CGRect?
    
    //others
    public var calculatePreferredContentSizeByLayoutSizeFitting : CGSize? = UIView.layoutFittingCompressedSize
    public var overridePreferredContentSize : CGSize? = nil
    
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
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    public func prepareViewController(_ viewController : UIViewController, presentOnViewController : UIViewController ){
        viewController.modalPresentationStyle = .popover
        
        //calculate preferred content size
        if let overridePreferredContentSize = overridePreferredContentSize{
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
}
