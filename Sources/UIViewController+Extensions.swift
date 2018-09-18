//
//  UIViewController+Extension.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 18.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

extension UIViewController{
    public func present(_ viewController : UIViewController, popoverSettings : KOPopoverSettings, animated : Bool = true, completion : (()->Void)? = nil){
        popoverSettings.prepareViewController(viewController, presentOnViewController: self)
        present(viewController, animated: animated, completion: completion)
    }
    
    public func presentDialog<DialogType : KODialogViewController>(_ dialogViewController : KODialogViewController, initializeAction : KOActionModel<DialogType>, popoverSettings : KOPopoverSettings? = nil, animated : Bool = true, completion : (()->Void)? = nil){
        dialogViewController.initializedEvent = {
            dialogViewController in
            dialogViewController.barView.titleLabel.text = initializeAction.title
            initializeAction.action(dialogViewController as! DialogType)
        }
        if let popoverSettings = popoverSettings{
            present(dialogViewController, popoverSettings: popoverSettings, animated: animated, completion: completion)
        }else{
            present(dialogViewController, animated: animated, completion: completion)
        }
        
    }
    
    public func presentDatePicker(initializeAction : KOActionModel<KODatePickerViewController>, popoverSettings : KOPopoverSettings? = nil, animated : Bool = true, completion : (()->Void)? = nil){
        presentDialog(KODatePickerViewController(), initializeAction: initializeAction, popoverSettings: popoverSettings, animated: animated, completion: completion)

    }
    
    public func presentOptionsPicker(withOptions options: [[String]], initializeAction : KOActionModel<KOOptionsPickerViewController>, popoverSettings : KOPopoverSettings? = nil, animated : Bool = true, completion : (()->Void)? = nil){
        presentDialog(KOOptionsPickerViewController(options: options), initializeAction: initializeAction, popoverSettings: popoverSettings, animated: animated, completion: completion)
    }
}
