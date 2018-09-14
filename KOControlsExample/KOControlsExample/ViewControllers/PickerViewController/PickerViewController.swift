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
        definesPresentationContext = true
    }
    
    @IBAction func showPickerClick(_ sender: Any) {
        let datePicker = KODatePickerViewController()
        datePicker.barView.titleLabel.text = "Date picker "
        datePicker.leftBarButtonAction = KODialogViewControllerActionModel.cancelAction
        
        /*
        datePicker.backgroundVisualEffect = UIBlurEffect(style: .extraLight)
        datePicker.mainView.layer.cornerRadius = 12
        datePicker.mainView.clipsToBounds = true
        
        datePicker.rightBarButtonAction = KOActionModel(title: "Done", action: {
            datePicker.dismiss(animated: true, completion: nil)
        })*/
        present(datePicker, animated: true, completion: nil)
    }
}
