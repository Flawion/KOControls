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
        emailTextField.errorWidth = 32
        emailTextField.borderSettings = KOTextFieldBorderSettings(color: UIColor.black.cgColor, errorColor: UIColor.red.cgColor, focusedColor: UIColor.blue.cgColor, errorFocusedColor : UIColor.red.cgColor,  width: 1, focusedWidth: 2)
        emailTextField.errorInfoInsets = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
    }
    
    @IBAction func onOffErrorClick(_ sender: Any) {
        emailTextField.isShowingError = !emailTextField.isShowingError
    }
    
}
