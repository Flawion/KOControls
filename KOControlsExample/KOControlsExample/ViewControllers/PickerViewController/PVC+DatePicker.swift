//
//  PickerViewController+DatePicker.swift
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

// MARK: - Date picker
extension PickerViewController {

    func showDatePicker() {
        isPresentPopover ? showDatePickerPopover() : showDatePickerNormal()
    }

    private func showDatePickerPopover() {
        popoverSettings = KOPopoverSettings(sourceView: birthdayField, sourceRect: birthdayField.bounds)
        customizeIfNeed(popoverSettings: popoverSettings!)

        _ = presentDatePicker(viewLoadedAction: KODialogActionModel(title: "Select your birthday", action: { [weak self](dialogViewController) in
            guard let sSelf = self else {
                return
            }

            let datePickerViewController = dialogViewController as! KODatePickerViewController
            datePickerViewController.mainView.backgroundColor = UIColor.clear
            sSelf.initializeDatePicker(datePickerViewController)
        }), popoverSettings: popoverSettings!)
    }

    private func showDatePickerNormal() {
        _ = presentDatePicker(viewLoadedAction: KODialogActionModel(title: "Select your birthday", action: { [weak self](dialogViewController) in
            self?.initializeDatePicker(dialogViewController as! KODatePickerViewController)
        }), postInit: { [weak self] datePickerViewController in
            self?.customizeTransitionIfNeed(dialogViewController: datePickerViewController)
        })
    }

    private func initializeDatePicker(_ datePicker: KODatePickerViewController) {
        datePicker.leftBarButtonAction = KODialogActionModel.cancelAction()
        datePicker.rightBarButtonAction = KODialogActionModel.doneAction(action: { [weak self](datePickerViewController: KODatePickerViewController) in
            self?.birthdayDate = datePickerViewController.datePicker.date
        })

        datePicker.datePicker.date = birthdayDate
        datePicker.datePicker.datePickerMode = .date
        datePicker.datePicker.maximumDate = Date()
        datePicker.datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -120, to: Date())
        customizeIfNeed(datePicker: datePicker)
    }

    // MARK: Customization
    private func customizeIfNeed(datePicker: KODatePickerViewController) {
        guard isStyleCustomize else {
            return
        }
        datePicker.datePickerTextColor = UIColor.orange
        customize(dialogViewController: datePicker)
    }
}
