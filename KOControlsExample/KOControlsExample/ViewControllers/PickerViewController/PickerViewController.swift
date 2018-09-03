//
//  PickerViewController.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 03.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit
import KOControls

class PickerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "KOPickerView"
    }
    
    @IBAction func showPickerClick(_ sender: Any) {
        let datePicker = KODatePickerViewController()
        datePicker.loadViewIfNeeded()
        datePicker.barView.titleLabel.text = "Date picker"
        
        present(datePicker, animated: true, completion: nil)
    }
}
