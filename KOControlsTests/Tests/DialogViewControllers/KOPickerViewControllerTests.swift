//
//  KOPickerViewControllerTests.swift
//  KOControlsTests
//
//  Copyright (c) 2019 Kuba Ostrowski
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

import XCTest
@testable import KOControls

final class KOPickerViewControllerTests: XCTestCase {
    private var windowSimulator: WindowSimulator!
    private var presentingViewController: ViewControllerSimulator!
    
    override func setUp() {
        presentingViewController = ViewControllerSimulator()
        windowSimulator = WindowSimulator(rootViewController: presentingViewController)
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        presentingViewController = nil
        windowSimulator = nil
    }
    
    func testDatePickerViewController() {
        let datePickerViewController = KODatePickerViewController()
        
        presentAndCheckFrame(ofDialogViewController: datePickerViewController, heightNeedToBeAbove: datePickerViewController.datePicker.intrinsicContentSize.height)
    }
    
    func testDatePickerViewControllerChangingTextColor() {
        let datePickerViewController = KODatePickerViewController()
        
        presentAndCheckFrame(ofDialogViewController: datePickerViewController, heightNeedToBeAbove: datePickerViewController.datePicker.intrinsicContentSize.height)
        datePickerViewController.datePickerTextColor = UIColor.red
        XCTAssertEqual(datePickerViewController.datePickerTextColor, UIColor.red)
    }
    
    func testOptionsPickerViewController() {
        let options: [[String]] = [["test1-1", "test1-2"], ["test1-1", "test1-2"]]
        let rowIndexToSelect: Int = 1
        let componentIndexToSelect: Int = 1
        let optionsPickerViewController = KOOptionsPickerViewController(options: options)
        
        presentAndCheckFrame(ofDialogViewController: optionsPickerViewController, heightNeedToBeAbove: optionsPickerViewController.optionsPicker.intrinsicContentSize.height)
        for index in 0..<options.count {
            XCTAssertEqual(optionsPickerViewController.optionsPicker.numberOfRows(inComponent: index), options[index].count)
        }
        optionsPickerViewController.optionsPicker.selectRow(rowIndexToSelect, inComponent: componentIndexToSelect, animated: false)
        XCTAssertEqual(rowIndexToSelect, optionsPickerViewController.optionsPicker.selectedRow(inComponent: componentIndexToSelect))
    }
    
    func testOptionsPickerViewControllerSimpleDelegate() {
        let options: [[String]] = [["test1-1", "test1-2"], ["test1-1", "test1-2"]]
        var pickedTitleAttributesForOptions: [String: Bool] = [:]
        let optionsPickerViewController = KOOptionsPickerViewController(options: options)
        let optionsPickerSimpleDelegate = KOOptionsPickerSimpleDelegate(optionsPickerViewController: optionsPickerViewController)
        optionsPickerSimpleDelegate.titleAttributesForRowInComponentsEvent = { (row: Int, component: Int) -> [NSAttributedString.Key: Any] in
            pickedTitleAttributesForOptions[options[component][row]] = true
            return [NSAttributedString.Key.foregroundColor: UIColor.red]
        }
        optionsPickerViewController.optionsPickerDelegateInstance = optionsPickerSimpleDelegate
        
        presentAndCheckFrame(ofDialogViewController: optionsPickerViewController, heightNeedToBeAbove: optionsPickerViewController.optionsPicker.intrinsicContentSize.height)
        for componentOption in options {
            for option in componentOption where !(pickedTitleAttributesForOptions[option] ?? false) {
                XCTAssertTrue(false, "title attributes didn't pick for option (\(option))")
            }
        }
    }

    func testOptionsPicerViewControllerResizableDelegate() {
        let options: [[String]] = [["test1-1", "test1-2"], ["test1-1", "test1-2"]]
        var pickedWidthForOptions: [Int: Bool] = [:]
        var pickedHeightForOptions: [Int: Bool] = [:]
        let optionsPickerViewController = KOOptionsPickerViewController(options: options)
        let optionsPickerResizableDelegate = KOOptionsPickerResizableDelegate(optionsPickerViewController: optionsPickerViewController, widthForComponent: { component -> CGFloat in
            pickedWidthForOptions[component] = true
            return 100
        }, heightForComponent: { component -> CGFloat in
            pickedHeightForOptions[component] = true
            return 50
        })
        optionsPickerViewController.optionsPickerDelegateInstance = optionsPickerResizableDelegate

        presentAndCheckFrame(ofDialogViewController: optionsPickerViewController, heightNeedToBeAbove: optionsPickerViewController.optionsPicker.intrinsicContentSize.height)
        for index in 0..<options.count where !(pickedWidthForOptions[index] ?? false) || !(pickedHeightForOptions[index] ?? false) {
            XCTAssertTrue(false, "size didn't pick for component (\(index))")
        }
    }

    func testOptionsPicerViewControllerCustomViewDelegate() {
        let options: [[String]] = [["test1-1", "test1-2"], ["test1-1", "test1-2"]]
        var pickedWidthForOptions: [Int: Bool] = [:]
        var pickedHeightForOptions: [Int: Bool] = [:]
        let optionsPickerViewController = KOOptionsPickerViewController(options: options)
        let optionsPickerCustomViewDelegate = KOOptionsPickerCustomViewDelegate(optionsPickerViewController: optionsPickerViewController, widthForComponent: { component -> CGFloat in
            pickedWidthForOptions[component] = true
            return 100
        }, heightForComponent: { component -> CGFloat in
            pickedHeightForOptions[component] = true
            return 50
        }, viewForRowInComponent: {(row, component, option, viewToReuse) -> UIView in
            var customView: UILabel! = viewToReuse as? UILabel
            if customView == nil {
                customView = UILabel()
            }
            customView.text = options[component][row]
            customView.sizeToFit()
            return customView
        })
        optionsPickerViewController.optionsPickerDelegateInstance = optionsPickerCustomViewDelegate

        presentAndCheckFrame(ofDialogViewController: optionsPickerViewController, heightNeedToBeAbove: optionsPickerViewController.optionsPicker.intrinsicContentSize.height)
        for index in 0..<options.count where !(pickedWidthForOptions[index] ?? false) || !(pickedHeightForOptions[index] ?? false) {
            XCTAssertTrue(false, "size didn't pick for component (\(index))")
        }
        for component in 0..<options.count {
            for row in 0..<options[component].count{
                guard let view = optionsPickerViewController.optionsPicker.view(forRow: row, forComponent: component) as? UILabel, view.text == options[component][row] else{
                    XCTAssertTrue(false, "view wasn't returned correctly")
                    return
                }

            }
        }
    }

    func testItemsTablePickerViewController() {
        let itemsTablePickerViewController = KOItemsTablePickerViewController()
        let contentHeight: CGFloat = 200
        itemsTablePickerViewController.mainView.contentHeight = contentHeight

        presentAndCheckFrame(ofDialogViewController: itemsTablePickerViewController, heightNeedToBeAbove: contentHeight)
        XCTAssertTrue(itemsTablePickerViewController.itemsTable.bounds.height >= contentHeight)
    }

    func testItemsCollectionPickerViewController() {
        let itemsCollectionPickerViewController = KOItemsCollectionPickerViewController(itemsCollectionLayout: UICollectionViewFlowLayout())
        let contentHeight: CGFloat = 200
        itemsCollectionPickerViewController.mainView.contentHeight = contentHeight

        presentAndCheckFrame(ofDialogViewController: itemsCollectionPickerViewController, heightNeedToBeAbove: contentHeight)
        XCTAssertTrue(itemsCollectionPickerViewController.itemsCollection.bounds.height >= contentHeight)
    }
    
    private func presentAndCheckFrame(ofDialogViewController dialogViewController: KODialogViewController, heightNeedToBeAbove height: CGFloat) {
        present(dialogViewController: dialogViewController)
        XCTAssertTrue(dialogViewController.mainView.frame.origin.y > 0)
        XCTAssertTrue(dialogViewController.mainView.frame.height > height)
        XCTAssertTrue(dialogViewController.mainView.frame.maxX.almostEqualUI(to: presentingViewController.view.frame.width))
    }
    
    private func present(dialogViewController: KODialogViewController) {
        presentingViewController.present(dialogViewController, animated: false)
        dialogViewController.view.layoutIfNeeded()
    }
}
