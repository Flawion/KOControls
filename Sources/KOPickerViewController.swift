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
open class KODatePickerViewController : KOPickerViewController{
    public private(set) weak var datePicker : UIDatePicker?
    
    override open func createContentView() -> UIView {
        let datePicker = UIDatePicker()
        self.datePicker = datePicker
        return datePicker
    }
}
