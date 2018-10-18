//
//  UIViewController+Extension.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 18.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

extension UIViewController{
    public func present(_ viewControllerToPresent : UIViewController, inQueueWithIndex queueIndex: Int?, popoverSettings : KOPopoverSettings? = nil, animated : Bool = true, completion : (()->Void)? = nil)->String?{
        if let popoverSettings = popoverSettings{
            popoverSettings.prepareViewController(viewControllerToPresent, presentOnViewController: self)
        }
        
        guard let queueIndex = queueIndex else{
            present(viewControllerToPresent, animated: animated, completion: completion)
            return nil
        }
        return KOPresentationQueuesService.shared.presentInQueue(viewControllerToPresent, onViewController: self, queueIndex: queueIndex, animated: animated, animationCompletion: completion)
    }
    
    public func presentDialog<DialogType : KODialogViewController>(_ dialogViewControllerToPresent : KODialogViewController, viewLoadedAction : KOActionModel<DialogType>, inQueueWithIndex : Int? = nil, popoverSettings : KOPopoverSettings? = nil, animated : Bool = true, completion : (()->Void)? = nil)->String?{
        dialogViewControllerToPresent.viewLoadedEvent = {
            dialogViewController in
            dialogViewController.barView.titleLabel.text = viewLoadedAction.title
            viewLoadedAction.action(dialogViewController as! DialogType)
        }
        if popoverSettings != nil{
            //main view must fill all size
            dialogViewControllerToPresent.mainViewVerticalAlignment = .fill
            dialogViewControllerToPresent.mainViewHorizontalAlignment = .fill
        }
        return present(dialogViewControllerToPresent, inQueueWithIndex : inQueueWithIndex, popoverSettings: popoverSettings, animated: animated, completion: completion)
    }
    
    public func presentDatePicker(viewLoadedAction : KOActionModel<KODatePickerViewController>, postInit : ((KODatePickerViewController)->Void)? = nil, inQueueWithIndex : Int? = nil, popoverSettings : KOPopoverSettings? = nil, animated : Bool = true, completion : (()->Void)? = nil)->String?{
        let datePickerViewController = KODatePickerViewController()
        postInit?(datePickerViewController)
        return presentDialog(datePickerViewController, viewLoadedAction: viewLoadedAction, inQueueWithIndex : inQueueWithIndex, popoverSettings: popoverSettings, animated: animated, completion: completion)
    }
    
    public func presentOptionsPicker(withOptions options: [[String]], viewLoadedAction : KOActionModel<KOOptionsPickerViewController>, postInit : ((KOOptionsPickerViewController)->Void)? = nil, inQueueWithIndex : Int? = nil, popoverSettings : KOPopoverSettings? = nil, animated : Bool = true, completion : (()->Void)? = nil)->String?{
        let optionsPickerViewController = KOOptionsPickerViewController(options: options)
        postInit?(optionsPickerViewController)
        return presentDialog(optionsPickerViewController, viewLoadedAction: viewLoadedAction, inQueueWithIndex : inQueueWithIndex, popoverSettings: popoverSettings, animated: animated, completion: completion)
    }
    
    public func presentItemsTablePicker(viewLoadedAction : KOActionModel<KOItemsTablePickerViewController>, postInit : ((KOItemsTablePickerViewController)->Void)? = nil, inQueueWithIndex : Int? = nil, popoverSettings : KOPopoverSettings? = nil, animated : Bool = true, completion : (()->Void)? = nil)->String?{
        let itemsTablePickerViewController = KOItemsTablePickerViewController()
        postInit?(itemsTablePickerViewController)
        return presentDialog(itemsTablePickerViewController, viewLoadedAction: viewLoadedAction, inQueueWithIndex : inQueueWithIndex, popoverSettings: popoverSettings, animated: animated, completion: completion)
    }
    
    public func presentItemsCollectionPicker(itemsCollectionLayout : UICollectionViewLayout, viewLoadedAction : KOActionModel<KOItemsCollectionPickerViewController>, postInit : ((KOItemsCollectionPickerViewController)->Void)? = nil, inQueueWithIndex : Int? = nil, popoverSettings : KOPopoverSettings? = nil, animated : Bool = true, completion : (()->Void)? = nil)->String?{
        let itemsCollectionPickerViewController = KOItemsCollectionPickerViewController(itemsCollectionLayout: itemsCollectionLayout)
        postInit?(itemsCollectionPickerViewController)
        return presentDialog(itemsCollectionPickerViewController, viewLoadedAction: viewLoadedAction, inQueueWithIndex : inQueueWithIndex, popoverSettings: popoverSettings, animated: animated, completion: completion)
    }
}
