//
//  TextFieldsViewController.swift
//  KOControlsExample
//
//  Copyright (c) 2018 Kuba Ostrowski
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import KOControls

final class UserNameErrorInfoView: UIView, KOErrorInfoProtocol {
    func markerCenterXEqualTo(_ constraint: NSLayoutXAxisAnchor) -> NSLayoutConstraint? {
        return nil
    }
}

final class TextFieldsViewController: UIViewController {
    @IBOutlet weak var emailField: KOTextField!
    @IBOutlet weak var passwordField: KOTextField!
    @IBOutlet weak var userNameField: KOTextField!
    @IBOutlet weak var userNameShowHideErrorBtt: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    private func initialize() {
        navigationItem.title = "KOTextField"
        initializeEmailField()
        initializePasswordField()
        initializeUserNameField()
    }

    private func initializeEmailField() {
        //- email field
        emailField.border.settings = AppSettings.fieldBorder
        emailField.errorInfo.view.descriptionLabel.text = "Email is incorrect"
        emailField.validation.add(validator: KORegexTextValidator.mailValidator)
    }
    
    private func initializePasswordField() {
        //- password field
        passwordField.border.settings = AppSettings.fieldBorder
        passwordField.errorInfo.view.descriptionLabel.text = "Password should contains 8 to 20 chars"
        passwordField.validation.mode = .validateOnTextChanged
        
        //simple function validation
        passwordField.validation.add(validator: KOFunctionTextValidator(function: { password -> Bool in
            return password.count >= 8 && password.count <= 20
        }))
        
        //or regex validation
        //passwordField.add(validator: KORegexTextValidator(regexPattern: "^(?=.*[a-z]{1,}.*)(?=.*[A-Z]{1,}.*)(?=.*[0-9]{1,}.*)(?=.*[^a-zA-Z0-9]{1,}.*).{8,20}$"))
        
        //changes animations
        passwordField.errorInfo.hideAnimation = KOAnimationGroup(animations: [
            KOTranslationAnimation(toValue: CGPoint(x: -200, y: 20)),
            KOFadeOutAnimation()
            ])
        passwordField.errorInfo.showAnimation = KOAnimationGroup(animations: [
            KOTranslationAnimation(toValue: CGPoint.zero, fromValue: CGPoint(x: -200, y: 20)),
            KOFadeInAnimation(fromValue: 0)
            ], dampingRatio: 0.6)
        
        //adds additional icon
        passwordField.errorInfo.view.imageWidthConst.constant = 25
        passwordField.errorInfo.view.imageView.image = UIImage(named: "ico_account")
        passwordField.errorInfo.view.imageViewEdgesConstraintsInsets.insets =  UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        passwordField.errorInfo.view.imageView.contentMode = .scaleAspectFit
        
        //other adjustments
        passwordField.errorInfo.view.descriptionLabel.textColor = UIColor.black
        passwordField.errorInfo.view.contentView.backgroundColor = UIColor.white
        passwordField.errorInfo.view.layer.shadowColor = UIColor.black.cgColor
        passwordField.errorInfo.view.layer.shadowOffset = CGSize(width: 0, height: -2)
        passwordField.errorInfo.view.layer.shadowRadius = 5
        passwordField.errorInfo.view.layer.shadowOpacity = 0.7
        passwordField.errorInfo.view.markerColor = UIColor.white

         //sets custom error view
        let passwordErrorLabel = UILabel()
        passwordErrorLabel.backgroundColor = UIColor.red
        passwordErrorLabel.textColor = UIColor.black
        passwordErrorLabel.textAlignment = .center
        passwordErrorLabel.text = "Incorrect"
        
        passwordField.error.customView = passwordErrorLabel
        passwordField.error.viewWidth = 100
    }
    
    private func initializeUserNameField() {
        //- user name field
        userNameField.border.settings = AppSettings.fieldBorder
        userNameField.validation.mode = .manual
        userNameField.errorInfo.insets.top = 2
        
        //sets custom error info view
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
        
        userNameField.errorInfo.customView = userNameErrorInfoView
    }
    
    @IBAction func showHideUserNameBttClick(_ sender: Any) {
        userNameField.error.isShowing = !userNameField.error.isShowing
    }
}
