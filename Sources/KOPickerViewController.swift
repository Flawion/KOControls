//
//  KOPickerViewController.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 06.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

//MARK - KODatePickerViewController
@objc public protocol KODatePickerViewControllerDelegate : KODialogViewControllerDelegate{
    @objc optional func datePickerViewController(_ datePickerViewController : KODialogViewController, dateChanged : Date?)
    
}

open class KODatePickerViewController : KODialogViewController{
    //MARK: Variables
    private weak var pDatePicker : UIDatePicker!

    //public
    @IBOutlet public weak var datePickerDelegate : KODatePickerViewControllerDelegate?{
        get{
            return delegate as? KODatePickerViewControllerDelegate
        }
        set{
            delegate = newValue
        }
    }
    
    public var datePickerTextColor : UIColor?{
        get{
            return datePicker.value(forKey: "textColor") as? UIColor
        }
        set{
            datePicker.setValue(UIColor.orange, forKey: "textColor")
        }
    }
    
    public var datePicker : UIDatePicker{
        loadViewIfNeeded()
        return pDatePicker
    }
    
    public var dateChangedEvent : ((Date?)->Void)?
    
    //MARK: Methods
    override open func createContentView() -> UIView {
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        self.pDatePicker = datePicker
        return datePicker
    }
    
    @objc private func dateChanged(){
        datePickerDelegate?.datePickerViewController?(self, dateChanged: pDatePicker.date)
        dateChangedEvent?(pDatePicker.date)
    }
}

//MARK: - KOOptionsPickerViewController
open class KOOptionsPickerViewController : KODialogViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    //MARK: Variables
    private weak var pOptionsPicker : UIPickerView!
    
    //public
    public var optionsPickerTitleAttributes : [NSAttributedStringKey : Any]?
    
    public var optionsPicker : UIPickerView{
        loadViewIfNeeded()
        return pOptionsPicker
    }
    
    public var options : [[String]] = []{
        didSet{
            optionsPicker.reloadAllComponents()
        }
    }
    
    public var selectionChangedEvent : ((_ row : Int, _ inComponent : Int)->Void)?
    
    //MARK: Methods
    public init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    public init(options : [[String]]) {
        super.init(nibName: nil, bundle: nil)
        self.options = options
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func createContentView() -> UIView {
        let optionsPicker = UIPickerView()
        optionsPicker.dataSource = self
        optionsPicker.delegate = self
        self.pOptionsPicker = optionsPicker
        return optionsPicker
    }
    
    //MARK: UIPickerViewDataSource, UIPickerViewDelegate
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return options.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options[component].count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[component][row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let optionsPickerTitleAttributes = optionsPickerTitleAttributes else{
            return nil
        }
        return NSAttributedString(string: options[component][row], attributes: optionsPickerTitleAttributes)
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectionChangedEvent?(row,component)
    }
}

//MARK: - KOItemsTablePickerViewController
open class KOItemsTablePickerViewController : KODialogViewController{
    //MARK: Variables
    private weak var pItemsTable : UITableView!
    
    //public
    public var itemsTable : UITableView{
        loadViewIfNeeded()
        return pItemsTable
    }
    
    //MARK: Methods
    override open func createContentView() -> UIView {
        let itemsTable = UITableView()
        itemsTable.tableFooterView = UIView()
        self.pItemsTable = itemsTable
        return itemsTable
    }
}


//MARK: - KOItemsCollectionPickerViewController
open class KOItemsCollectionPickerViewController : KODialogViewController{
    //MARK: Variables
    private weak var pItemsCollection : UICollectionView!
    
    private var itemsCollectionLayoutAtStart : UICollectionViewLayout!

    
    //public
    public var itemsCollection : UICollectionView{
        loadViewIfNeeded()
        return pItemsCollection
    }
    
    //MARK: Methods
    public init(itemsCollectionLayout : UICollectionViewLayout) {
        super.init(nibName: nil, bundle: nil)
        postInit(itemsCollectionLayout: itemsCollectionLayout)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        postInit(itemsCollectionLayout: UICollectionViewFlowLayout())
    }

    private func postInit(itemsCollectionLayout : UICollectionViewLayout){
        itemsCollectionLayoutAtStart = itemsCollectionLayout
    }
    
    override open func createContentView() -> UIView {
        let itemsCollection = UICollectionView(frame: CGRect.zero, collectionViewLayout: itemsCollectionLayoutAtStart)
        self.pItemsCollection = itemsCollection
        itemsCollectionLayoutAtStart = nil
        return itemsCollection
    }
}
