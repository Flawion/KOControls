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
    
    public func presentDialog<DialogType : KODialogViewController>(_ dialogViewController : KODialogViewController, viewLoadedAction : KOActionModel<DialogType>, popoverSettings : KOPopoverSettings? = nil, animated : Bool = true, completion : (()->Void)? = nil){
        dialogViewController.viewLoadedEvent = {
            dialogViewController in
            dialogViewController.barView.titleLabel.text = viewLoadedAction.title
            viewLoadedAction.action(dialogViewController as! DialogType)
        }
        if let popoverSettings = popoverSettings{
            //main view must fill all size
            dialogViewController.mainViewVerticalAlignment = .fill
            dialogViewController.mainViewHorizontalAlignment = .fill
            present(dialogViewController, popoverSettings: popoverSettings, animated: animated, completion: completion)
        }else{
            present(dialogViewController, animated: animated, completion: completion)
        }
    }
    
    public func presentDatePicker(viewLoadedAction : KOActionModel<KODatePickerViewController>, postInit : ((KODatePickerViewController)->Void)? = nil, popoverSettings : KOPopoverSettings? = nil, animated : Bool = true, completion : (()->Void)? = nil){
        let datePickerViewController = KODatePickerViewController()
        postInit?(datePickerViewController)
        presentDialog(datePickerViewController, viewLoadedAction: viewLoadedAction, popoverSettings: popoverSettings, animated: animated, completion: completion)
    }
    
    public func presentOptionsPicker(withOptions options: [[String]], viewLoadedAction : KOActionModel<KOOptionsPickerViewController>, postInit : ((KOOptionsPickerViewController)->Void)? = nil, popoverSettings : KOPopoverSettings? = nil, animated : Bool = true, completion : (()->Void)? = nil){
        let optionsPickerViewController = KOOptionsPickerViewController(options: options)
        postInit?(optionsPickerViewController)
        presentDialog(optionsPickerViewController, viewLoadedAction: viewLoadedAction, popoverSettings: popoverSettings, animated: animated, completion: completion)
    }
    
    public func presentItemsTablePicker(viewLoadedAction : KOActionModel<KOItemsTablePickerViewController>, postInit : ((KOItemsTablePickerViewController)->Void)? = nil, popoverSettings : KOPopoverSettings? = nil, animated : Bool = true, completion : (()->Void)? = nil){
        let itemsTablePickerViewController = KOItemsTablePickerViewController()
        postInit?(itemsTablePickerViewController)
        presentDialog(KOItemsTablePickerViewController(), viewLoadedAction: viewLoadedAction, popoverSettings: popoverSettings, animated: animated, completion: completion)
    }
    
    public func presentItemsCollectionPicker(itemsCollectionLayout : UICollectionViewLayout, viewLoadedAction : KOActionModel<KOItemsCollectionPickerViewController>, postInit : ((KOItemsCollectionPickerViewController)->Void)? = nil, popoverSettings : KOPopoverSettings? = nil, animated : Bool = true, completion : (()->Void)? = nil){
        let itemsCollectionPickerViewController = KOItemsCollectionPickerViewController(itemsCollectionLayout: itemsCollectionLayout)
        postInit?(itemsCollectionPickerViewController)
        presentDialog(itemsCollectionPickerViewController, viewLoadedAction: viewLoadedAction, popoverSettings: popoverSettings, animated: animated, completion: completion)
    }
}
