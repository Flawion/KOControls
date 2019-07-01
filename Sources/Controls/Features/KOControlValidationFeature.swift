//
//  KOControlValidationFeature.swift
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

/// Describes when field will be validating
///
/// - manual: developer have to manually validate field by invoke function validate
/// - validateOnTextChanged: (default) field will be validating at text changed
/// - validateOnLostFocus: field will be validating at lost focus, error will be hidding when text changed
/// - clearErrorOnTextChanged: errors will be hidding when text changed
public enum KOTextValidateModes {
    case manual
    case validateOnTextChanged //by default
    case validateOnLostFocus
    case clearErrorOnTextChanged
}

public enum KOFailureTextEnumerationMode {
    case moreFailureThanOne
    case always
    case disabled
}

/// Developer can implement its own validator by implementing this protocol to the class
@objc public protocol KOTextValidatorProtocol: AnyObject {
    func validate(text: String) -> Bool
    @objc optional func failureText() -> String?
}

public class KOBaseTextValidator: KOTextValidatorProtocol {
    private let pFailureText: String?
    
    init(failureText: String? = nil) {
        pFailureText = failureText
    }
    
    public func validate(text: String) -> Bool {
        fatalError("not implemented")
    }
    
    public func failureText() -> String? {
        return pFailureText
    }
}

/// Regexp validator
public class KORegexTextValidator: KOBaseTextValidator {
    private let regex: NSPredicate
    
    /// Simple, easy to use mailValidator: field.add(validator: KORegexTextValidator.mailValidator)
    public static func mailValidator(failureText: String? = nil) -> KORegexTextValidator {
        return KORegexTextValidator(regexPattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", failureText: failureText)
    }
    
    public init(regexPattern: String, failureText: String? = nil) {
        regex = NSPredicate(format: "SELF MATCHES %@", regexPattern)
        super.init(failureText: failureText)
    }
    
    public override func validate(text: String) -> Bool {
        return regex.evaluate(with: text)
    }
}

/// Simple way to create your own validator by passing a function
public class KOFunctionTextValidator: KOBaseTextValidator {
    private let function: (String) -> Bool
    
    public init(function: @escaping (String) -> Bool, failureText: String? = nil) {
        self.function = function
        super.init(failureText: failureText)
    }
    
    public override func validate(text: String) -> Bool {
        return function(text)
    }
}

public protocol KOControlValidationFeatureDelegate: NSObjectProtocol {
    var isFirstResponder: Bool { get }
    var textToValidate: String? { get }
    func validationSuccess()
    func validationFailure()
    func validationFailureTextComposed(_ failureText: String, fromValidators: [KOTextValidatorProtocol] )
}

// MARK: - KOControlValidationFeature
public class KOControlValidationFeature {
    // MARK: - Variables
    private weak var delegate: KOControlValidationFeatureDelegate?
    
    public private(set) var validators: [KOTextValidatorProtocol] = []
    public private(set) var failureText: String = ""
    public var mode: KOTextValidateModes = .validateOnLostFocus
    
    public var failureTextPrefix: String = ""
    public var failureTextSeparator: String = "\n"
    public var failureTextPrefixOfEnumeration: String = "∙ "
    public var failureTextEnumerationMode: KOFailureTextEnumerationMode = .moreFailureThanOne
    
    // MARK: - Functions
    public init(delegate: KOControlValidationFeatureDelegate) {
        self.delegate = delegate
    }
    
    public func index(validator: KOTextValidatorProtocol) -> Int? {
        return validators.firstIndex(where: {$0 === validator})
    }
    
    public func add(validator: KOTextValidatorProtocol) {
        guard index(validator: validator) == nil else {
            return
        }
        validators.append(validator)
    }
    
    public func remove(validator: KOTextValidatorProtocol) {
        guard let index = index(validator: validator) else {
            return
        }
        validators.remove(at: index)
    }
    
    public func validate() {
        guard let delegate = delegate else {
            return
        }
        guard validators.count > 0 else {
            delegate.validationSuccess()
            return
        }
        let text = delegate.textToValidate ?? ""
        
        var failuresValidators: [KOTextValidatorProtocol] = []
        for validator in validators {
            if !validator.validate(text: text) {
                failuresValidators.append(validator)
            }
        }
        validationCompleted(withDelegate: delegate, failuresValidators: failuresValidators)
    }
    
    private func validationCompleted(withDelegate delegate: KOControlValidationFeatureDelegate, failuresValidators: [KOTextValidatorProtocol]) {
        guard failuresValidators.count > 0 else {
            delegate.validationSuccess()
            return
        }
        composeValidationFailureTextIfCan(withDelegate: delegate, fromValidators: failuresValidators)
        delegate.validationFailure()
    }
    
    private func composeValidationFailureTextIfCan(withDelegate delegate: KOControlValidationFeatureDelegate, fromValidators validators: [KOTextValidatorProtocol]) {
        failureText = ""
        for index in 0..<validators.count {
            appendToFailureTextIfCan(textFromValidatorAtIndex: index, validators: validators)
        }
        if !failureText.isEmpty {
            if !failureTextPrefix.isEmpty {
                failureText.insert(contentsOf: failureTextPrefix, at: failureText.startIndex)
            }
            delegate.validationFailureTextComposed(failureText, fromValidators: validators)
        }
    }
    
    private func appendToFailureTextIfCan(textFromValidatorAtIndex validatorIndex: Int, validators: [KOTextValidatorProtocol]) {
        let validator = validators[validatorIndex]
        guard let failureText = validator.failureText?() else {
            return
        }
    
        appendSeparatorToFailureTextIfNeed()
        switch failureTextEnumerationMode {
        case .moreFailureThanOne:
            if validators.count > 1 {
                appendEnumeratedTextToFailureText(failureText)
            } else {
                appendTextToFailureText(failureText)
            }
            
        case .always:
            appendEnumeratedTextToFailureText(failureText)
            
        case .disabled:
            appendTextToFailureText(failureText)
        }
    }
    
    private func appendSeparatorToFailureTextIfNeed() {
        guard !failureText.isEmpty else {
            return
        }
        failureText += failureTextSeparator
    }
    
    private func appendEnumeratedTextToFailureText(_ textToAppend: String) {
        appendEnumerationToFailureText()
        appendTextToFailureText(textToAppend)
    }
    
    private func appendEnumerationToFailureText() {
        failureText += failureTextPrefixOfEnumeration
    }
    
    private func appendTextToFailureText(_ textToAppend: String) {
        failureText += textToAppend
    }
    
    // MARK: Must be invoked by parent container
    public func eventTextChanged() {
        switch mode {
        case .validateOnLostFocus, .clearErrorOnTextChanged:
            delegate?.validationSuccess()
            
        case .validateOnTextChanged:
            validate()
            
        default:
            break
        }
    }
    
    public func eventResignFirstResponder() {
        if mode == .validateOnLostFocus {
            validate()
        }
    }
}
