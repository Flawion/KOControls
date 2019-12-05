//
//  PickerViewController+ItemsCollectionPicker.swift
//  KOControlsExample
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
import KOControls

// MARK: - Items collection picker
extension PickerViewController {

    func showItemsCollectionPicker() {
        isPresentPopover ? showItemsCollectionPickerPopover() : showItemsCollectionPickerNormal()
    }

    private func showItemsCollectionPickerNormal() {
        _ = presentItemsCollectionPicker(itemsCollectionLayout: UICollectionViewFlowLayout(), viewLoadedAction: KODialogActionModel(title: "Select your country", action: { [weak self](dialogViewController) in
            guard let self = self else {
                return
            }

            let itemsCollectionPickerViewController = dialogViewController as! KOItemsCollectionPickerViewController
            itemsCollectionPickerViewController.mainView.contentHeight = 300
            self.initializeItemsCollectionPicker(itemsCollectionPickerViewController, availableWidth: self.view.bounds.width, itemMaxWidth: 120)
        }), postInit: { [weak self] itemsCollectionPickerViewController in
            self?.customizeTransitionIfNeed(dialogViewController: itemsCollectionPickerViewController)
        })
    }

    private func showItemsCollectionPickerPopover() {
        //creates popover's settings
        popoverSettings = KOPopoverSettings(sourceView: countryField, sourceRect: countryField.bounds)
        popoverSettings!.preferredContentSize = CGSize(width: 320, height: 320)
        customizeIfNeed(popoverSettings: popoverSettings!)

        _ = presentItemsCollectionPicker(itemsCollectionLayout: UICollectionViewFlowLayout(), viewLoadedAction: KODialogActionModel(title: "Select your country", action: { [weak self](dialogViewController) in
            guard let self = self else {
                return
            }
            let itemsCollectionPickerViewController =  dialogViewController as! KOItemsCollectionPickerViewController
            itemsCollectionPickerViewController.mainView.backgroundColor = UIColor.clear
            self.initializeItemsCollectionPicker(itemsCollectionPickerViewController, availableWidth: 320, itemMaxWidth: 80)
        }), popoverSettings: popoverSettings!)
    }

    private func initializeItemsCollectionPicker(_ itemsCollectionPicker: KOItemsCollectionPickerViewController, availableWidth: CGFloat, itemMaxWidth: Double) {
        itemsCollectionPicker.leftBarButtonAction = KODialogActionModel.dismissAction(withTitle: "Cancel")
        itemsCollectionPicker.rightBarButtonAction = KODialogActionModel.dismissAction(withTitle: "Done", action: { [weak self](itemsCollectionPicker: KOItemsCollectionPickerViewController) in
            guard let self = self else {
                return
            }
            if let countryIndex = itemsCollectionPicker.itemsCollection.indexPathsForSelectedItems?.first?.row {
                self.countryIndex = countryIndex
            }
        })

        itemsCollectionPicker.itemsCollection.allowsSelection = true
        itemsCollectionPicker.itemsCollection.backgroundColor = UIColor.lightGray
        countryCollectionsController.attach(collectionView: itemsCollectionPicker.itemsCollection)

        customizeIfNeed(itemsCollectionPickerViewController: itemsCollectionPicker)
        countryCollectionsController.calculateCollectionSize(itemsCollectionPicker.itemsCollection, availableWidth: itemsCollectionPicker.mainView.contentWidth ?? availableWidth, itemMaxWidth: itemMaxWidth)
    }

    // MARK: Customization
    func customizeIfNeed(countryCollectionViewCell: CountryCollectionViewCell) {
        guard isStyleCustomize else {
            return
        }
        countryCollectionViewCell.backgroundColor = UIColor.clear
        countryCollectionViewCell.titleLabel.textColor = UIColor.orange
    }

    private func customizeIfNeed(itemsCollectionPickerViewController: KOItemsCollectionPickerViewController) {
        guard isStyleCustomize else {
            return
        }
        /* If custom style horizontal alignment isn't equal to fill,
         picker must has to set contentWidth, to properly calculate sizes of view.
         We only need to do it in normal presentation mode because in popover presentation mode
         we already override  prefered content size
         */
        if !isPresentPopover {
            itemsCollectionPickerViewController.mainView.contentWidth = 320
        }
        customize(dialogViewController: itemsCollectionPickerViewController)
    }
}
