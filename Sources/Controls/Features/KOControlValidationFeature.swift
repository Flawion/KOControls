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

/// Developer can implement its own validator by implementing this protocol to the class
public protocol KOTextValidatorProtocol: AnyObject {
    func validate(text: String) -> Bool
}

/// Regexp validator
public class KORegexTextValidator: KOTextValidatorProtocol {
    private let regex: NSPredicate
    
    /// Simple, easy to use mailValidator: field.add(validator: KORegexTextValidator.mailValidator)
    public static var mailValidator: KORegexTextValidator {
        return KORegexTextValidator(regexPattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    }
    
    public init(regexPattern: String) {
        regex = NSPredicate(format: "SELF MATCHES %@", regexPattern)
    }
    
    public func validate(text: String) -> Bool {
        return regex.evaluate(with: text)
    }
}

/// Simple way to create your own validator by passing a function
public class KOFunctionTextValidator: KOTextValidatorProtocol {
    private let function: (String) -> Bool
    
    public init(function: @escaping (String) -> Bool) {
        self.function = function
    }
    
    public func validate(text: String) -> Bool {
        return function(text)
    }
}

public protocol KOControlValidationFeatureDelegate: NSObjectProtocol {
    var isFirstResponder: Bool { get }
    var textToValidate: String? { get }
    func validationSuccess()
    func validationFailure()
}

// MARK: - KOControlValidationFeature
public class KOControlValidationFeature {
    // MARK: - Variables
    private weak var delegate: KOControlValidationFeatureDelegate?
    
    public private(set) var validators: [KOTextValidatorProtocol] = []
    public var mode: KOTextValidateModes = .validateOnLostFocus
    
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
        for validator in validators {
            if !validator.validate(text: text) {
                delegate.validationFailure()
                return
            }
        }
        delegate.validationSuccess()
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
