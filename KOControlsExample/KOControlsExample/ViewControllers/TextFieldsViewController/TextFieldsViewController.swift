//
//  TextFieldsViewController.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 04.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit
import KOControls

class UserNameErrorInfoView : UIView, KOTextFieldErrorInterface{
    func markerCenterXEqualTo(_ constraint: NSLayoutXAxisAnchor) -> NSLayoutConstraint? {
        return nil
    }
}

class TextFieldsViewController: UIViewController {
    @IBOutlet weak var emailField: KOTextField!
    @IBOutlet weak var passwordField: KOTextField!
    @IBOutlet weak var userNameField: KOTextField!
    @IBOutlet weak var userNameShowHideErrorBtt: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    private func initialize(){
        navigationItem.title = "KOTextField"
        initializeEmailField()
        initializePasswordField()
        initializeUserNameField()
    }

    private func initializeEmailField(){
        //- email field
        emailField.borderSettings = AppSettings.fieldBorder
        emailField.errorInfoView.descriptionLabel.text = "Email is incorrect"
        emailField.add(validator: KORegexTextValidator.mailValidator)
    }
    
    private func initializePasswordField(){
        //- password field
        passwordField.borderSettings = AppSettings.fieldBorder
        passwordField.errorInfoView.descriptionLabel.text = "Password should contains 8 to 20 chars"
        passwordField.validateMode = .validateOnTextChanged
        passwordField.add(validator: KOFunctionTextValidator(function: {
            (password) -> Bool in
            return password.count >= 8 && password.count <= 20
        }))
        
        //setting custom error view
        passwordField.errorInfoView.descriptionLabel.textColor = UIColor.black
        passwordField.errorInfoView.contentView.backgroundColor = UIColor.white
        passwordField.errorInfoView.layer.shadowColor = UIColor.black.cgColor
        passwordField.errorInfoView.layer.shadowOffset = CGSize(width: 0, height: -2)
        passwordField.errorInfoView.layer.shadowRadius = 5
        passwordField.errorInfoView.layer.shadowOpacity = 0.7
        passwordField.errorInfoView.markerColor = UIColor.white
        
        let passwordErrorLabel = UILabel()
        passwordErrorLabel.backgroundColor = UIColor.red
        passwordErrorLabel.textColor = UIColor.black
        passwordErrorLabel.textAlignment = .center
        passwordErrorLabel.text = "Incorrect"
        
        passwordField.customErrorView = passwordErrorLabel
        passwordField.errorWidth = 100
    }
    
    private func initializeUserNameField(){
        //- user name field
        userNameField.borderSettings = AppSettings.fieldBorder
        userNameField.validateMode = .manual
        userNameField.add(validator: KOFunctionTextValidator(function: {
            (password) -> Bool in
            return password.count >= 8 && password.count <= 20
        }))
        
        //setting custom error info view
        let userNameErrorInfoView = UserNameErrorInfoView()
        userNameErrorInfoView.backgroundColor = UIColor.gray.withAlphaComponent(0.85)
        
        let userNameErrorInfoLabel = UILabel()
        userNameErrorInfoLabel.textColor = UIColor.white
        userNameErrorInfoLabel.text = "Incorrect username try again"
        userNameErrorInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameErrorInfoView.addSubview(userNameErrorInfoLabel)
        userNameErrorInfoView.addConstraints([
            userNameErrorInfoLabel.leftAnchor.constraint(equalTo: userNameErrorInfoView.leftAnchor, constant: 12),
            userNameErrorInfoLabel.rightAnchor.constraint(equalTo: userNameErrorInfoView.rightAnchor, constant: -12),
            userNameErrorInfoLabel.bottomAnchor.constraint(equalTo: userNameErrorInfoView.bottomAnchor, constant: -8),
            userNameErrorInfoLabel.topAnchor.constraint(equalTo: userNameErrorInfoView.topAnchor, constant: 8)
            ])
        
        userNameField.customErrorInfoView = userNameErrorInfoView
    }
    
    @IBAction func showHideUserNameBttClick(_ sender: Any) {
        userNameField.isShowingError = !userNameField.isShowingError
    }
}
