//
//  KOPickerViewController.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 06.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

//MARK: - KOPickerViewController
open class KOPickerViewController : KODialogViewController{
    public let dimmingTransition = KODimmingTransition()

    override open var defaultMainViewVerticalAlignment: UIControlContentVerticalAlignment{
        return .bottom
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        constructor()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        constructor()
    }
    
    private func constructor(){
        modalPresentationStyle =  .custom
        transitioningDelegate = dimmingTransition
        dismissWhenUserTapAtBackground = true
    }
}

//MARK - KODatePickerViewController
@objc public protocol KODatePickerViewControllerDelegate : KODialogViewControllerDelegate{
    @objc optional func datePickerViewController(_ datePickerViewController : KODialogViewController, dateChanged : Date?)
    
}

open class KODatePickerViewController : KOPickerViewController{
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
open class KOOptionsPickerViewController : KOPickerViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    //MARK: Variables
    private weak var pPicker : UIPickerView!
    
    //public
    public var picker : UIPickerView{
        loadViewIfNeeded()
        return pPicker
    }
    
    public var options : [[String]] = []{
        didSet{
            picker.reloadAllComponents()
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
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        self.pPicker = picker
        return picker
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return options.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options[component].count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[component][row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectionChangedEvent?(row,component)
    }
}
