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
    
    override open func initializeAppearance() {
        super.initializeAppearance()
        
        dismissWhenUserTapAtBackground = true
        modalPresentationStyle =  .custom
        transitioningDelegate = dimmingTransition
    }
}

//MARK - KODatePickerViewController
@objc public protocol KODatePickerViewControllerDelegate : KODialogViewControllerDelegate{
    @objc optional func datePickerViewController(_ datePickerViewController : KODialogViewController, dateChanged : Date?)
    
}

open class KODatePickerViewController : KOPickerViewController{
    //MARK: Variables
    private weak var pDatePicker : UIDatePicker!
    
    public weak var datePickerDelegate : KODatePickerViewControllerDelegate?{
        get{
            return delegate as? KODatePickerViewControllerDelegate
        }
        set{
            delegate = newValue
        }
    }
    
    //public
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
