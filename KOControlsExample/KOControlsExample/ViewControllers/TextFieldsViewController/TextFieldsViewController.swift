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
        emailTextField.errorInfoView.descriptionLabel.text = "Email is incorrect"
        emailTextField.errorIconView.image = UIImage(named: "field_error")
        emailTextField.errorIconView.contentMode = .center
        emailTextField.errorIconWidth = 32
        
    }
    
    @IBAction func onOffErrorClick(_ sender: Any) {
        emailTextField.isShowingError = !emailTextField.isShowingError
    }
    
}
