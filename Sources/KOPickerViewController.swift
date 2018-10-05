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

//MARK: - KOOptionsPickerViewDelegates
open class KOOptionsPickerSimpleDelegate : NSObject, UIPickerViewDelegate{
    fileprivate weak var optionsPickerViewController : KOOptionsPickerViewController!
    
    public var titleAttributesForRowInComponents : ((_ row : Int, _ component : Int)->[NSAttributedString.Key : Any])?
    
    public init(optionsPickerViewController : KOOptionsPickerViewController){
        self.optionsPickerViewController = optionsPickerViewController
        super.init()
    }
    
    //MARK: UIPickerViewDelegate
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return optionsPickerViewController.options[component][row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let optionsPickerTitleAttributes = titleAttributesForRowInComponents?(row, component) else{
            return nil
        }
        return NSAttributedString(string: optionsPickerViewController.options[component][row], attributes: optionsPickerTitleAttributes)
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        optionsPickerViewController.selectionChangedEvent?(row,component)
    }
}

open class KOOptionsPickerResizableDelegate : KOOptionsPickerSimpleDelegate{
    private let widthForComponent : (_ component : Int)->CGFloat
    private let heightForComponent : (_ component : Int)->CGFloat
    
    public init(optionsPickerViewController : KOOptionsPickerViewController, widthForComponent : @escaping (Int)->CGFloat, heightForComponent : @escaping (Int)->CGFloat){
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

open class KOOptionsPickerCustomViewDelegate : KOOptionsPickerResizableDelegate{
    private let viewForRowInComponent : (_ row : Int, _ component : Int, _ title : String, _ reusableView : UIView?)->UIView
    
    public init(optionsPickerViewController : KOOptionsPickerViewController, widthForComponent : @escaping (Int)->CGFloat, heightForComponent : @escaping (Int)->CGFloat, viewForRowInComponent : @escaping (Int, Int, String, UIView?)->UIView){
        self.viewForRowInComponent = viewForRowInComponent
        super.init(optionsPickerViewController: optionsPickerViewController, widthForComponent: widthForComponent, heightForComponent: heightForComponent)
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        return viewForRowInComponent(row, component, optionsPickerViewController.options[component][row], view)
    }
}

//MARK: - KOOptionsPickerViewController
open class KOOptionsPickerViewController : KODialogViewController, UIPickerViewDataSource{
    //MARK: Variables
    private weak var pOptionsPicker : UIPickerView!
    
    //public
    public var optionsPicker : UIPickerView{
        loadViewIfNeeded()
        return pOptionsPicker
    }
    
    public var optionsPickerDelegateInstance : UIPickerViewDelegate!{
        didSet{
            guard isViewLoaded else{
                return
            }
            pOptionsPicker.delegate = optionsPickerDelegateInstance
        }
    }
    
    public var options : [[String]] = []{
        didSet{
            guard isViewLoaded else{
                return
            }
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
        self.pOptionsPicker = optionsPicker
        if let optionsPickerDelegate = optionsPickerDelegateInstance{
            optionsPicker.delegate = optionsPickerDelegate
        }else{
            optionsPickerDelegateInstance = KOOptionsPickerSimpleDelegate(optionsPickerViewController: self)
        }
        return optionsPicker
    }
    
    //MARK: UIPickerViewDataSource, UIPickerViewDelegate
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return options.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options[component].count
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
