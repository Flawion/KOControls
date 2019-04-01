//
//  PickerViewController+ItemsTablePicker.swift
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

// MARK: - Items table picker
extension PickerViewController {

    func showItemsTablePicker() {
        isPresentPopover ? showItemsTablePickerPopover() : showItemsTablePickerNormal()
    }

    private func showItemsTablePickerNormal() {
        _ = presentItemsTablePicker(viewLoadedAction: KODialogActionModel(title: "Select your country", action: { [weak self](dialogViewController) in
            let itemsTablePickerViewController = dialogViewController as! KOItemsTablePickerViewController
            itemsTablePickerViewController.contentHeight = 300
            self?.initializeItemsTablePicker(itemsTablePickerViewController)
        }), postInit: { [weak self] itemsTablePickerViewController in
            self?.customizeTransitionIfNeed(dialogViewController: itemsTablePickerViewController)
        })
    }

    private func showItemsTablePickerPopover() {
        popoverSettings = KOPopoverSettings(sourceView: countryField, sourceRect: countryField.bounds)
        popoverSettings!.preferredContentSize = CGSize(width: 320, height: 320)
        customizeIfNeed(popoverSettings: popoverSettings!)

        _ = presentItemsTablePicker( viewLoadedAction: KODialogActionModel(title: "Select your country", action: { [weak self](dialogViewController) in
            guard let sSelf = self else {
                return
            }
            let itemsTablePickerViewController = dialogViewController as! KOItemsTablePickerViewController
            itemsTablePickerViewController.mainView.backgroundColor = UIColor.clear
            sSelf.initializeItemsTablePicker(itemsTablePickerViewController)
        }), popoverSettings: popoverSettings!)
    }

    private func initializeItemsTablePicker(_ itemsTablePicker: KOItemsTablePickerViewController) {
        itemsTablePicker.leftBarButtonAction = KODialogActionModel.cancelAction()
        itemsTablePicker.rightBarButtonAction = KODialogActionModel.doneAction(action: { [weak self](itemsTablePickerViewController: KOItemsTablePickerViewController) in
            guard let sSelf = self else {
                return
            }
            if let countryIndex = itemsTablePickerViewController.itemsTable.indexPathForSelectedRow?.row {
                sSelf.countryIndex = countryIndex
            }
        })
        itemsTablePicker.itemsTable.allowsSelection = true
        countryCollectionsController.attach(tableView: itemsTablePicker.itemsTable)

        customizeIfNeed(itemsTablePicker: itemsTablePicker)
    }

    // MARK: Customization
    func customizeIfNeed(countryTableViewCell: CountryTableViewCell) {
        guard isStyleCustomize else {
            return
        }
        countryTableViewCell.backgroundColor = UIColor.clear
        countryTableViewCell.titleLabel.textColor = UIColor.orange
    }

    private func customizeIfNeed(itemsTablePicker: KOItemsTablePickerViewController) {
        guard isStyleCustomize else {
            return
        }
        itemsTablePicker.itemsTable.separatorColor = UIColor.white
        itemsTablePicker.itemsTable.backgroundColor = UIColor.clear
        /* If custom style horizontal alignment isn't equal to fill,
         picker must has to set contentWidth, to properly calculate sizes of view.
         We only need to do it in normal presentation mode because in popover presentation mode
         we already override  prefered content size
         */
        if presentMode.selectedSegmentIndex == 0 {
            itemsTablePicker.contentWidth = 320
        }
        customize(dialogViewController: itemsTablePicker)
    }
}

// MARK: - Custom items table picker
extension PickerViewController {

    func showCustomItemsTablePicker() {
        isPresentPopover ? showCustomItemsTablePickerPopover() : showCustomItemsTablePickerNormal()
    }

    private func showCustomItemsTablePickerNormal() {
        let searchItemsTablePicker = SearchItemsTablePickerViewController()
        customizeTransitionIfNeed(dialogViewController: searchItemsTablePicker)
        _ = presentDialog(searchItemsTablePicker, viewLoadedAction: KODialogActionModel(title: "Select your country", action: { [weak self](dialogViewController) in
            guard let sSelf = self else {
                return
            }
            let searchItemsTablePickerViewController = dialogViewController as! SearchItemsTablePickerViewController
            searchItemsTablePickerViewController.contentHeight = 300
            sSelf.initializeCustomItemsTablePicker(searchItemsTablePickerViewController)
        }))
    }

    private func showCustomItemsTablePickerPopover() {
        let searchItemsTablePicker = SearchItemsTablePickerViewController()

        popoverSettings = KOPopoverSettings(sourceView: customCountryField, sourceRect: customCountryField.bounds)
        popoverSettings!.preferredContentSize = CGSize(width: 320, height: 320)
        customizeIfNeed(popoverSettings: popoverSettings!)

        _ = presentDialog(searchItemsTablePicker, viewLoadedAction: KODialogActionModel(title: "Select your country", action: { [weak self](dialogViewController) in
            guard let sSelf = self else {
                return
            }

            let searchItemsTablePickerViewController = dialogViewController as! SearchItemsTablePickerViewController
            searchItemsTablePickerViewController.mainView.backgroundColor = UIColor.clear
            sSelf.initializeItemsTablePicker(searchItemsTablePickerViewController)
            sSelf.initializeCustomItemsTablePicker(searchItemsTablePickerViewController)
        }), popoverSettings: popoverSettings)
    }

    private func initializeCustomItemsTablePicker(_ itemsTablePicker: SearchItemsTablePickerViewController) {
        itemsTablePicker.leftBarButtonAction = KODialogActionModel.cancelAction()
        itemsTablePicker.rightBarButtonAction = KODialogActionModel.doneAction(action: { [weak self](itemsTablePickerViewController: KOItemsTablePickerViewController) in
            guard let sSelf = self else {
                return
            }
            if let countryIndex = itemsTablePickerViewController.itemsTable.indexPathForSelectedRow?.row {
                sSelf.customCountryIndex = countryIndex
            }
        })
        itemsTablePicker.itemsTable.allowsSelection = true
        customizeIfNeed(itemsTablePicker: itemsTablePicker)

        itemsTablePicker.searchField.addTarget(self, action: #selector(customItemsTablePickerSearchFieldChanged(_:)), for: .editingChanged)
        customCountryCollectionsController.searchForCountries(byName: "")
        customCountryCollectionsController.attach(tableView: itemsTablePicker.itemsTable)
    }

    @objc private func customItemsTablePickerSearchFieldChanged(_ sender: UITextField) {
        customCountryCollectionsController.searchForCountries(byName: sender.text ?? "")
    }
}

final class SearchItemsTablePickerViewController: KOItemsTablePickerViewController {
    private(set) weak var searchField: KOTextField!

    override func createContentView() -> UIView {
        let contentView = UIView()

        let itemsTable = super.createContentView()
        contentView.addSubview(itemsTable)
        itemsTable.translatesAutoresizingMaskIntoConstraints = false

        let searchField = KOTextField()
        searchField.borderStyle = .roundedRect
        searchField.borderSettings = AppSettings.fieldBorder
        searchField.placeholder = "Search country"
        contentView.addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        self.searchField = searchField

        contentView.addConstraints([
            searchField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            searchField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            searchField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            itemsTable.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 4),
            itemsTable.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            itemsTable.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            itemsTable.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])

        return contentView
    }
}
