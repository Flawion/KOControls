//
//  UIViewController+Extension.swift
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

extension UIViewController {
    
    /// Presents viewController with the additional parameters
    ///
    /// - Parameters:
    ///   - viewControllerToPresent: viewController that will be presenting
    ///   - queueIndex: developer can add the presenting view to the queue by set this parameter
    ///   - popoverSettings: if presentation has to be shown as popover
    ///   - animated: if presenting should be animated
    ///   - completion: animation completion handler
    /// - Returns: id of view in the queue
    public func present(_ viewControllerToPresent: UIViewController, inQueueWithIndex queueIndex: Int?, popoverSettings: KOPopoverSettings? = nil, animated: Bool = true, completion: (() -> Void)? = nil) -> String? {
        if let popoverSettings = popoverSettings {
            popoverSettings.prepareViewController(viewControllerToPresent, presentOnViewController: self)
        }
        
        guard let queueIndex = queueIndex else {
            present(viewControllerToPresent, animated: animated, completion: completion)
            return nil
        }
        return KOPresentationQueuesService.shared.presentInQueue(viewControllerToPresent, onViewController: self, queueIndex: queueIndex, animated: animated, animationCompletion: completion)
    }
    
    /// Presents dialogViewController with the additional parameters
    ///
    /// - Parameters:
    ///   - dialogViewControllerToPresent: viewController that will be presenting
    ///   - viewLoadedAction: action that sets the barView.title and invokes action after viewDidLoaded
    ///   - inQueueWithIndex: developer can add the presenting view to the queue by set this parameter
    ///   - popoverSettings: if presentation has to be shown as popover
    ///   - animated: if presenting should be animated
    ///   - completion: animation completion handler
    /// - Returns: id of view in the queue
    public func presentDialog(_ dialogViewControllerToPresent: KODialogViewController, viewLoadedAction: KODialogActionModel, inQueueWithIndex: Int? = nil, popoverSettings: KOPopoverSettings? = nil, animated: Bool = true, completion: (() -> Void)? = nil) -> String? {
        dialogViewControllerToPresent.viewLoadedEvent = {
            dialogViewController in
            dialogViewController.mainView.barView.titleLabel.text = viewLoadedAction.title
            viewLoadedAction.action(dialogViewController)
        }
        if popoverSettings != nil {
            //main view must fill all size
            dialogViewControllerToPresent.mainViewVerticalAlignment = .fill
            dialogViewControllerToPresent.mainViewHorizontalAlignment = .fill
        }
        return present(dialogViewControllerToPresent, inQueueWithIndex: inQueueWithIndex, popoverSettings: popoverSettings, animated: animated, completion: completion)
    }
    
    /// Presents datePickerViewController with the additional parameters
    ///
    /// - Parameters:
    ///   - viewLoadedAction: action that sets the barView.title and invokes action after viewDidLoaded
    ///   - postInit: handler that will be invoked after initialize a object
    ///   - inQueueWithIndex: developer can add the presenting view to the queue by set this parameter
    ///   - popoverSettings: if presentation has to be shown as popover
    ///   - animated: if presenting should be animated
    ///   - completion: animation completion handler
    /// - Returns: id of view in the queue
    public func presentDatePicker(viewLoadedAction: KODialogActionModel, postInit: ((KODatePickerViewController) -> Void)? = nil, inQueueWithIndex: Int? = nil, popoverSettings: KOPopoverSettings? = nil, animated: Bool = true, completion: (() -> Void)? = nil) -> String? {
        let datePickerViewController = KODatePickerViewController()
        postInit?(datePickerViewController)
        return presentDialog(datePickerViewController, viewLoadedAction: viewLoadedAction, inQueueWithIndex: inQueueWithIndex, popoverSettings: popoverSettings, animated: animated, completion: completion)
    }
    
    /// Presents optionsPickerViewController with the additional parameters
    ///
    /// - Parameters:
    ///   - options: grouped options to select
    ///   - viewLoadedAction: action that sets the barView.title and invokes action after viewDidLoaded
    ///   - postInit: handler that will be invoked after initialize a object
    ///   - inQueueWithIndex: developer can add the presenting view to the queue by set this parameter
    ///   - popoverSettings: if presentation has to be shown as popover
    ///   - animated: if presenting should be animated
    ///   - completion: animation completion handler
    /// - Returns: id of view in the queue
    public func presentOptionsPicker(withOptions options: [[String]], viewLoadedAction: KODialogActionModel, postInit: ((KOOptionsPickerViewController) -> Void)? = nil, inQueueWithIndex: Int? = nil, popoverSettings: KOPopoverSettings? = nil, animated: Bool = true, completion: (() -> Void)? = nil) -> String? {
        let optionsPickerViewController = KOOptionsPickerViewController(options: options)
        postInit?(optionsPickerViewController)
        return presentDialog(optionsPickerViewController, viewLoadedAction: viewLoadedAction, inQueueWithIndex: inQueueWithIndex, popoverSettings: popoverSettings, animated: animated, completion: completion)
    }
    
    // Presents itemsTablePickerViewController with the additional parameters. Developer have to handle UITableViewDataSource. 'contentHeight' or 'contentWidth' parameters have to be setted depending on alignments of the main view. With default settings 'contentHeight' is needed to properly show the dialog.
    ///
    /// - Parameters:
    ///   - viewLoadedAction: action that sets the barView.title and invokes action after viewDidLoaded
    ///   - postInit: handler that will be invoked after initialize a object
    ///   - inQueueWithIndex: developer can add the presenting view to the queue by set this parameter
    ///   - popoverSettings: if presentation has to be shown as popover
    ///   - animated: if presenting should be animated
    ///   - completion: animation completion handler
    /// - Returns: id of view in the queue
    public func presentItemsTablePicker(viewLoadedAction: KODialogActionModel, postInit: ((KOItemsTablePickerViewController) -> Void)? = nil, inQueueWithIndex: Int? = nil, popoverSettings: KOPopoverSettings? = nil, animated: Bool = true, completion: (() -> Void)? = nil) -> String? {
        let itemsTablePickerViewController = KOItemsTablePickerViewController()
        postInit?(itemsTablePickerViewController)
        return presentDialog(itemsTablePickerViewController, viewLoadedAction: viewLoadedAction, inQueueWithIndex: inQueueWithIndex, popoverSettings: popoverSettings, animated: animated, completion: completion)
    }
    
    // Presents itemsCollectionPickerViewController with the additional parameters. Developer have to handle UICollectionViewDataSource. 'contentHeight' or 'contentWidth' parameters have to be setted depending on alignments of the main view. With default settings 'contentHeight' is needed to properly show the dialog.
    ///
    /// - Parameters:
    ///   - itemsCollectionLayout: collection layout
    ///   - viewLoadedAction: action that sets the barView.title and invokes action after viewDidLoaded
    ///   - postInit: handler that will be invoked after initialize a object
    ///   - inQueueWithIndex: developer can add the presenting view to the queue by set this parameter
    ///   - popoverSettings: if presentation has to be shown as popover
    ///   - animated: if presenting should be animated
    ///   - completion: animation completion handler
    /// - Returns: id of view in the queue
    public func presentItemsCollectionPicker(itemsCollectionLayout: UICollectionViewLayout, viewLoadedAction: KODialogActionModel, postInit: ((KOItemsCollectionPickerViewController) -> Void)? = nil, inQueueWithIndex: Int? = nil, popoverSettings: KOPopoverSettings? = nil, animated: Bool = true, completion: (() -> Void)? = nil) -> String? {
        let itemsCollectionPickerViewController = KOItemsCollectionPickerViewController(itemsCollectionLayout: itemsCollectionLayout)
        postInit?(itemsCollectionPickerViewController)
        return presentDialog(itemsCollectionPickerViewController, viewLoadedAction: viewLoadedAction, inQueueWithIndex: inQueueWithIndex, popoverSettings: popoverSettings, animated: animated, completion: completion)
    }
}
