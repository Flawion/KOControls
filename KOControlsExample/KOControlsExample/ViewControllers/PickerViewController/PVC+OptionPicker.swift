//
//  PickerViewController+OptionPicker.swift
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

// MARK: - Option picker
extension PickerViewController {
    
    func showOptionsPicker() {
        isPresentPopover ? showOptionsPickerPopover() : showOptionsPickerNormal()
    }

    private func showOptionsPickerPopover() {
        popoverSettings = KOPopoverSettings(sourceView: filmTypeField, sourceRect: filmTypeField.bounds)
        customizeIfNeed(popoverSettings: popoverSettings!)

        _ = presentOptionsPicker(withOptions: [filmTypes], viewLoadedAction: KODialogActionModel(title: "Select your favorite film type", action: { [weak self](dialogViewController) in
            guard let sSelf = self else {
                return
            }
            let optionsPickerViewController = dialogViewController as! KOOptionsPickerViewController
            optionsPickerViewController.mainView.backgroundColor = UIColor.clear
            sSelf.initializeOptionsPicker(optionsPickerViewController)
        }), popoverSettings: popoverSettings!)
    }

    private func showOptionsPickerNormal() {
        _ = presentOptionsPicker(withOptions: [filmTypes], viewLoadedAction: KODialogActionModel(title: "Select your favorite film type", action: { [weak self](dialogViewController) in
            self?.initializeOptionsPicker(dialogViewController as! KOOptionsPickerViewController)
        }), postInit: { [weak self] optionsPickerViewController in
            self?.customizeTransitionIfNeed(dialogViewController: optionsPickerViewController)
        })
    }

    private func initializeOptionsPicker(_ optionsPicker: KOOptionsPickerViewController) {
        optionsPicker.optionsPicker.selectRow(favoriteFilmTypeIndex, inComponent: 0, animated: false)
        optionsPicker.leftBarButtonAction = KODialogActionModel.cancelAction()
        optionsPicker.rightBarButtonAction = KODialogActionModel.doneAction(action: { [weak self](optionsPickerViewController: KOOptionsPickerViewController) in
            guard let sSelf = self else {
                return
            }
            sSelf.favoriteFilmTypeIndex = optionsPickerViewController.optionsPicker.selectedRow(inComponent: 0)
        })
        customizeIfNeed(optionsPicker: optionsPicker)
    }

    // MARK: Customization
    private func customizeIfNeed(optionsPicker: KOOptionsPickerViewController) {
        guard isStyleCustomize else {
            return
        }
        (optionsPicker.optionsPickerDelegateInstance as! KOOptionsPickerSimpleDelegate).titleAttributesForRowInComponentsEvent = { (_, _) in
            return [NSAttributedString.Key.foregroundColor: UIColor.orange]
        }
        optionsPicker.optionsPicker.reloadAllComponents()
        customize(dialogViewController: optionsPicker)
    }
}
