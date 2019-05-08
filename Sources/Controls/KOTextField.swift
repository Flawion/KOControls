//
//  KOTextField.swift
//  KOControls
//
//  Copyright (c) 2019 Kuba Ostrowski
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

@objc public protocol KOTextFieldDelegate: UITextFieldDelegate {
    @objc optional func textFieldDidShowError(_ textField: UITextField)
    @objc optional func textFieldDidHideError(_ textField: UITextField)
    
    @objc optional func textFieldStartingErrorInfoShowAnimation(_ textField: UITextField)
    @objc optional func textFieldStartingErrorInfoHideAnimation(_ textField: UITextField)
    
    @objc optional func textFieldDidShowErrorInfo(_ textField: UITextField)
    @objc optional func textFieldDidHideErrorInfo(_ textField: UITextField)
}

// MARK: - KOTextField
/// Field that supports features: showing an error, validable, managing borders
open class KOTextField: UITextField {
    // MARK: - Variables
    @IBOutlet public var koDelegate: KOTextFieldDelegate? {
        get {
            return delegate as? KOTextFieldDelegate
        }
        set {
            delegate = newValue
        }
    }
    
    public private(set) var error: KOControlErrorFeature!
    public private(set) var errorInfo: KOControlErrorInfoFeature!
    public private(set) var validation: KOControlValidationFeature!
    public private(set) var border: KOControlBorderFeature!
    
    // MARK: - Functions
    // MARK: Overridden rects to avoid intersection with the error icon view
    override open func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rightViewRect = super.rightViewRect(forBounds: bounds)
        guard let errorCurrentViewWidth = error.currentViewWidth, bounds.isEmpty else {
            return rightViewRect
        }
        return rightViewRect.offsetBy(dx: -errorCurrentViewWidth, dy: 0)
    }
    
    override open func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let clearButtonRect = super.clearButtonRect(forBounds: bounds)
        guard let errorCurrentViewWidth = error.currentViewWidth, bounds.isEmpty else {
            return clearButtonRect
        }
        return clearButtonRect.offsetBy(dx: -errorCurrentViewWidth, dy: 0)
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.textRect(forBounds: bounds)
        guard let errorCurrentViewWidth = error.currentViewWidth, bounds.isEmpty else {
            return textRect
        }
        textRect.size.width -= errorCurrentViewWidth
        return textRect
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        var editingRect = super.editingRect(forBounds: bounds)
        guard let errorCurrentViewWidth = error.currentViewWidth, bounds.isEmpty else {
            return editingRect
        }
        editingRect.size.width -= errorCurrentViewWidth
        return editingRect
    }
    
    // MARK: Initialization
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        initializeFeatures()
        initializeView()
    }
    
    private func initializeFeatures() {
        error = KOControlErrorFeature(delegate: self)
        errorInfo = KOControlErrorInfoFeature(delegate: self)
        validation = KOControlValidationFeature(delegate: self)
        border = KOControlBorderFeature(delegate: self)
    }
    
    private func initializeView() {
        addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    
    // MARK: Events
    @objc private func textChanged() {
        validation.eventTextChanged()
    }
    
    override open func didMoveToSuperview() {
        errorInfo.eventDidMoveToSuperview()
    }
    
    override open func becomeFirstResponder() -> Bool {
        let becomeFirstResponder = super.becomeFirstResponder()
        errorInfo.eventFirstResponderChanged()
        border.eventFirstResponderChanged()
        return becomeFirstResponder
    }
    
    override open func resignFirstResponder() -> Bool {
        let resignFirstResponder = super.resignFirstResponder()
        errorInfo.eventFirstResponderChanged()
        validation.eventResignFirstResponder()
        border.eventFirstResponderChanged()
        return resignFirstResponder
    }
}

// MARK: - KOControlBorderFeatureDelegate
extension KOTextField: KOControlBorderFeatureDelegate {
    public var featureContainer: UIView {
        return self
    }
    
    public var errorIsShowing: Bool {
        return error.isShowing
    }
}

// MARK: - KOControlValidationFeatureDelegate
extension KOTextField: KOControlValidationFeatureDelegate {
    public var textToValidate: String? {
        return text
    }
    
    public func validationSuccess() {
        error.isShowing = false
    }
    
    public func validationFailure() {
        error.isShowing = true
    }
}

// MARK: - KOControlErrorFeatureDelegate
extension KOTextField: KOControlErrorFeatureDelegate {
    public func errorDidShow() {
        border.refresh()
        errorInfo.refresh()
        koDelegate?.textFieldDidShowError?(self)
    }
    
    public func errorDidHide() {
        border.refresh()
        errorInfo.isShowing = false
        koDelegate?.textFieldDidHideError?(self)
    }
}

// MARK: - KOViewErrorInfoFeatureDelegate
extension KOTextField: KOControlErrorInfoFeatureDelegate {
    public var markerCenterXEualTo: NSLayoutXAxisAnchor {
        return error.viewCenterXAnchor
    }
    
    public func errorInfoStartingHideAnimation() {
        koDelegate?.textFieldStartingErrorInfoHideAnimation?(self)
    }
    
    public func errorInfoDidHide() {
        koDelegate?.textFieldDidHideError?(self)
    }
    
    public func errorInfoStartingShowAnimation() {
        koDelegate?.textFieldStartingErrorInfoShowAnimation?(self)
    }
    
    public func errorInfoDidShow() {
        koDelegate?.textFieldDidShowError?(self)
    }
}
