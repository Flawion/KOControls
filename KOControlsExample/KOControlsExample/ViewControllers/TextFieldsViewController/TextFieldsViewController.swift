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
    
    private let borderSettings = KOTextFieldBorderSettings(color: UIColor.lightGray.cgColor, errorColor: UIColor.red.cgColor, focusedColor: UIColor.blue.cgColor, errorFocusedColor : UIColor.red.cgColor,  width: 1, focusedWidth: 2)
    private let errorIcon =  UIImage(named: "field_error")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "KOTextField"
        initialize()
    }
    
    private func initialize(){
        initializeEmailField()
        initializePasswordField()
        initializeUserNameField()
    }

    private func initializeEmailField(){
        //- email field
        emailField.borderSettings = borderSettings
        emailField.errorInfoView.descriptionLabel.text = "Email is incorrect"
        emailField.add(validator: KORegexTextValidator.mailValidator)
        
        //setting error view
        emailField.errorIconView.image = errorIcon
        emailField.errorIconView.contentMode = .center
        emailField.errorWidth = 32
    }
    
    private func initializePasswordField(){
        //- password field
        passwordField.borderSettings = borderSettings
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
        userNameField.borderSettings = borderSettings
        userNameField.validateMode = .validateOnTextChanged
        userNameField.add(validator: KOFunctionTextValidator(function: {
            (password) -> Bool in
            return password.count >= 8 && password.count <= 20
        }))
        
        //setting error view
        userNameField.errorIconView.image = errorIcon
        userNameField.errorIconView.contentMode = .center
        userNameField.errorWidth = 32
        
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
