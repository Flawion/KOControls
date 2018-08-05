//
//  TextFieldsViewController.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 04.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit
import KOControls

class TextFieldsViewController: UIViewController {
    @IBOutlet weak var emailTextField: KOTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "KOTextField"
        initialize()
    }

    private func initialize(){
        emailTextField.errorView.descriptionLabel.text = "Email is incorrect"
    }
}
