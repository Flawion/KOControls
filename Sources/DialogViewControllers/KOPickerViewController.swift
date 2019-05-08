//
//  KOPickerViewController.swift
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

// MARK: - KODatePickerViewController

/// Date picker, you can use dateChangedEvent to get the new setted date
open class KODatePickerViewController: KODialogViewController {
    // MARK: Variables
    private weak var pDatePicker: UIDatePicker!

    //public
    public var datePickerTextColor: UIColor? {
        get {
            return datePicker.value(forKey: "textColor") as? UIColor
        }
        set {
            datePicker.setValue(newValue, forKey: "textColor")
        }
    }
    
    public var datePicker: UIDatePicker {
        loadViewIfNeeded()
        return pDatePicker
    }
    
    /// You can use it to get the new setted date
    public var dateChangedEvent: ((Date?) -> Void)?
    
    // MARK: Methods
    override open func createContentView() -> UIView {
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        self.pDatePicker = datePicker
        return datePicker
    }
    
    @objc private func dateChanged() {
        dateChangedEvent?(pDatePicker.date)
    }
}

// MARK: - KOOptionsPickerViewDelegates

/// Default used delegate, allows to show title or attributedTitle in a row of picker
open class KOOptionsPickerSimpleDelegate: NSObject, UIPickerViewDelegate {
    fileprivate weak var optionsPickerViewController: KOOptionsPickerViewController!
    
    /// It allows for create an attributed text for the row
    public var titleAttributesForRowInComponentsEvent : ((_ row: Int, _ component: Int) -> [NSAttributedString.Key: Any])?
    
    public init(optionsPickerViewController: KOOptionsPickerViewController) {
        self.optionsPickerViewController = optionsPickerViewController
        super.init()
    }
    
    // MARK: UIPickerViewDelegate
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return optionsPickerViewController.options[component][row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let optionsPickerTitleAttributes = titleAttributesForRowInComponentsEvent?(row, component) else {
            return nil
        }
        return NSAttributedString(string: optionsPickerViewController.options[component][row], attributes: optionsPickerTitleAttributes)
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        optionsPickerViewController.selectionChangedEvent?(row, component)
    }
}

/// More advanced version of simple delegate, allows additionally to change the height and width of the rows
open class KOOptionsPickerResizableDelegate: KOOptionsPickerSimpleDelegate {
    private let widthForComponent : (_ component: Int) -> CGFloat
    private let heightForComponent : (_ component: Int) -> CGFloat
    
    public init(optionsPickerViewController: KOOptionsPickerViewController, widthForComponent: @escaping (Int) -> CGFloat, heightForComponent: @escaping (Int) -> CGFloat) {
        self.widthForComponent = widthForComponent
        self.heightForComponent = heightForComponent
        super.init(optionsPickerViewController: optionsPickerViewController)
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return heightForComponent(component)
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return widthForComponent(component)
    }
}

/// Most advanced version of simple delegate, allows additionally to change the height and width of the rows and to return a custom view of the row
open class KOOptionsPickerCustomViewDelegate: KOOptionsPickerResizableDelegate {
    private let viewForRowInComponent : (_ row: Int, _ component: Int, _ title: String, _ reusableView: UIView?) -> UIView
    
    public init(optionsPickerViewController: KOOptionsPickerViewController, widthForComponent: @escaping (Int) -> CGFloat, heightForComponent: @escaping (Int) -> CGFloat, viewForRowInComponent: @escaping (Int, Int, String, UIView?) -> UIView) {
        self.viewForRowInComponent = viewForRowInComponent
        super.init(optionsPickerViewController: optionsPickerViewController, widthForComponent: widthForComponent, heightForComponent: heightForComponent)
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        return viewForRowInComponent(row, component, optionsPickerViewController.options[component][row], view)
    }
}

// MARK: - KOOptionsPickerViewController

/// Options picker, you can use selectionChangedEvent to get the new setted date
open class KOOptionsPickerViewController: KODialogViewController, UIPickerViewDataSource {
    // MARK: Variables
    private weak var pOptionsPicker: UIPickerView!
    
    //public
    public var optionsPicker: UIPickerView {
        loadViewIfNeeded()
        return pOptionsPicker
    }
    
    /// Instance of pickerview delegate that handles showing of options
    public var optionsPickerDelegateInstance: UIPickerViewDelegate! {
        didSet {
            guard isViewLoaded else {
                return
            }
            pOptionsPicker.delegate = optionsPickerDelegateInstance
        }
    }
    
    /// Grouped options to select
    public var options: [[String]] = [] {
        didSet {
            guard isViewLoaded else {
                return
            }
            optionsPicker.reloadAllComponents()
        }
    }
    
    public var selectionChangedEvent: ((_ row: Int, _ inComponent: Int) -> Void)?
    
    // MARK: Methods
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public init(options: [[String]]) {
        super.init(nibName: nil, bundle: nil)
        self.options = options
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
   override open func createContentView() -> UIView {
        let optionsPicker = UIPickerView()
        optionsPicker.dataSource = self
        self.pOptionsPicker = optionsPicker
        if let optionsPickerDelegate = optionsPickerDelegateInstance {
            optionsPicker.delegate = optionsPickerDelegate
        } else {
            optionsPickerDelegateInstance = KOOptionsPickerSimpleDelegate(optionsPickerViewController: self)
        }
        return optionsPicker
    }
    
    // MARK: UIPickerViewDataSource, UIPickerViewDelegate
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return options.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options[component].count
    }
}

// MARK: - KOItemsTablePickerViewController

/// Developer have to handle UITableViewDataSource. 'contentHeight' or 'contentWidth' parameters have to be setted depending on alignments of the main view. With default settings 'contentHeight' is needed to properly show the dialog.
open class KOItemsTablePickerViewController: KODialogViewController {
    // MARK: Variables
    private weak var pItemsTable: UITableView!
    
    //public
    public var itemsTable: UITableView {
        loadViewIfNeeded()
        return pItemsTable
    }
    
    // MARK: Methods
    override open func createContentView() -> UIView {
        let itemsTable = UITableView()
        itemsTable.tableFooterView = UIView()
        self.pItemsTable = itemsTable
        return itemsTable
    }
}

// MARK: - KOItemsCollectionPickerViewController

/// Developer have to handle UICollectionViewDataSource. 'contentHeight' or 'contentWidth' parameters have to be setted depending on alignments of the main view. With default settings 'contentHeight' is needed to properly show the dialog.
open class KOItemsCollectionPickerViewController: KODialogViewController {
    // MARK: Variables
    private weak var pItemsCollection: UICollectionView!
    
    private var itemsCollectionLayoutAtStart: UICollectionViewLayout!

    //public
    public var itemsCollection: UICollectionView {
        loadViewIfNeeded()
        return pItemsCollection
    }
    
    // MARK: Methods
    public init(itemsCollectionLayout: UICollectionViewLayout) {
        super.init(nibName: nil, bundle: nil)
        postInit(itemsCollectionLayout: itemsCollectionLayout)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        postInit(itemsCollectionLayout: UICollectionViewFlowLayout())
    }

    private func postInit(itemsCollectionLayout: UICollectionViewLayout) {
        itemsCollectionLayoutAtStart = itemsCollectionLayout
    }
    
    override open func createContentView() -> UIView {
        let itemsCollection = UICollectionView(frame: CGRect.zero, collectionViewLayout: itemsCollectionLayoutAtStart)
        self.pItemsCollection = itemsCollection
        itemsCollectionLayoutAtStart = nil
        return itemsCollection
    }
}
