//
//  KOControlValidationFeatureTests.swift
//  KOControlsTests
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

import XCTest
@testable import KOControls

final class KOControlValidationFeatureTests: XCTestCase {
    fileprivate var featureContainer: FeatureContainerView!

    private var defaultFailureTextSeparator: String = "\n"
    private var defaultFailureTextPrefixOfEnumeration: String = "∙ "
    private var defaultFailureTextPrefix: String = ""

    override func setUp() {
        featureContainer = FeatureContainerView()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        featureContainer = nil
    }

    // MARK: - Tests
    func testIsDefaultModeValidateOnLostFocus() {
        XCTAssertEqual(featureContainer.validationFeature.mode, KOTextValidateModes.validateOnLostFocus)
    }

    func testAddingValidator() {
        featureContainer.validationFeature.add(validator: createCountValidator())
        XCTAssertEqual(featureContainer.validationFeature.validators.count, 1)
    }

    func testRemovingValidator() {
        let validator = createCountValidator()
        featureContainer.validationFeature.add(validator: validator)
        featureContainer.validationFeature.remove(validator: validator)
        XCTAssertEqual(featureContainer.validationFeature.validators.count, 0)
    }

    func testIndexValidator() {
        let validator1 = createCountValidator()
        featureContainer.validationFeature.add(validator: validator1)
        let validator2 = createCountValidator()
        featureContainer.validationFeature.add(validator: validator2)
        XCTAssertEqual(featureContainer.validationFeature.index(validator: validator2), 1)
    }

    func testSuccessValidateOnTextChanged() {
        _ = createCountValidatorAndFillWithSuccessTextValidationFeature(withMode: .validateOnTextChanged)
        XCTAssertEqual(featureContainer.isValidationSuccess, true)
    }

    func testFailureValidateOnTextChanged() {
        let countValidation = createCountValidatorAndFillWithFailureTextValidationFeature(withMode: .validateOnTextChanged)
        XCTAssertEqual(featureContainer.isValidationSuccess, false)
        XCTAssertEqual(featureContainer.validationFailureText, countValidation.failureText?())
    }

    func testSuccessValidateOnLostFocus() {
        _ = createCountValidatorAndFillWithSuccessTextValidationFeature(withMode: .validateOnLostFocus)
        _ = featureContainer.becomeFirstResponder()
        _ = featureContainer.resignFirstResponder()
        XCTAssertEqual(featureContainer.isValidationSuccess, true)
    }

    func testFailureValidateOnLostFocus() {
        let countValidation = createCountValidatorAndFillWithFailureTextValidationFeature(withMode: .validateOnLostFocus)
        _ = featureContainer.becomeFirstResponder()
        _ = featureContainer.resignFirstResponder()
        XCTAssertEqual(featureContainer.isValidationSuccess, false)
        XCTAssertEqual(featureContainer.validationFailureText, countValidation.failureText?())
    }

    func testSuccessValidateManual() {
        _ = createCountValidatorAndFillWithSuccessTextValidationFeature(withMode: .manual)
        featureContainer.validationFeature.validate()
        XCTAssertEqual(featureContainer.isValidationSuccess, true)
    }

    func testFailureValidateManual() {
        let countValidation = createCountValidatorAndFillWithFailureTextValidationFeature(withMode: .manual)
        featureContainer.validationFeature.validate()
        XCTAssertEqual(featureContainer.isValidationSuccess, false)
        XCTAssertEqual(featureContainer.validationFailureText, countValidation.failureText?())
    }

    func testClearErrorOnTextChanged() {
        let countValidation = createCountValidatorAndFillWithFailureTextValidationFeature(withMode: .clearErrorOnTextChanged)
        featureContainer.validationFeature.validate()
        XCTAssertEqual(featureContainer.isValidationSuccess, false)
        XCTAssertEqual(featureContainer.validationFailureText, countValidation.failureText?())

        featureContainer.textToValidate = "123456"
        XCTAssertEqual(featureContainer.isValidationSuccess, true)
    }

    func testSuccessMultipleValidatorsOnTextChanged() {
        featureContainer.validationFeature.mode = .validateOnTextChanged
        let countValidator = createCountValidator()
        featureContainer.validationFeature.add(validator: countValidator)
        let oneUppercaseLetterValidator = createOneUppercaseLetterValidator()
        featureContainer.validationFeature.add(validator: oneUppercaseLetterValidator)
        let oneDigitValidator = createOneDigitValidator()
        featureContainer.validationFeature.add(validator: oneDigitValidator)

        featureContainer.textToValidate = "1234567D"
        XCTAssertEqual(featureContainer.isValidationSuccess, true)
    }

    func testDefaultFailureTextSeparator() {
        XCTAssertEqual(featureContainer.validationFeature.failureTextSeparator, defaultFailureTextSeparator)
    }

    func testFailureTextSeparator() {
        let testFailureTextSeparator = ","
        featureContainer.validationFeature.mode = .validateOnTextChanged
        featureContainer.validationFeature.failureTextSeparator = testFailureTextSeparator
        let countValidator = createCountValidator()
        featureContainer.validationFeature.add(validator: countValidator)
        let oneDigitValidator = createOneDigitValidator()
        featureContainer.validationFeature.add(validator: oneDigitValidator)

        let failureTextToCompare = "\(defaultFailureTextPrefixOfEnumeration)\(countValidator.failureText?() ?? "")\(testFailureTextSeparator)\(defaultFailureTextPrefixOfEnumeration)\(oneDigitValidator.failureText?() ?? "")"
        featureContainer.textToValidate = "abcdef"
        XCTAssertEqual(featureContainer.validationFailureText, failureTextToCompare)
        XCTAssertEqual(featureContainer.isValidationSuccess, false)
    }

    func testDefaultFailureTextPrefixOfEnumeration() {
        XCTAssertEqual(featureContainer.validationFeature.failureTextPrefixOfEnumeration, defaultFailureTextPrefixOfEnumeration)
    }

    func testFailureTextPrefixOfEnumeration() {
        let testFailureTextPrefixOfEnumeration = "+ "
        featureContainer.validationFeature.failureTextPrefixOfEnumeration = testFailureTextPrefixOfEnumeration
        featureContainer.validationFeature.failureTextEnumerationMode = .always
        let validator = createCountValidatorAndFillWithFailureTextValidationFeature(withMode: .validateOnTextChanged)
        let failureTextToCompare = "\(testFailureTextPrefixOfEnumeration)\(validator.failureText?() ?? "")"
        XCTAssertEqual(featureContainer.validationFailureText, failureTextToCompare)
    }

    func testDefaultFailureTextPrefix() {
        XCTAssertEqual(featureContainer.validationFeature.failureTextPrefix, defaultFailureTextPrefix)
    }

    func testFailureTextPrefix() {
        let testFailureTextPrefix = "Prefix test:"
        featureContainer.validationFeature.failureTextPrefix = testFailureTextPrefix
        _ = createCountValidatorAndFillWithFailureTextValidationFeature(withMode: .validateOnTextChanged)
        XCTAssertEqual(featureContainer.validationFailureText?.starts(with: testFailureTextPrefix), true)
    }

    func testFailureMultipleValidatorsOnTextChanged() {
        featureContainer.validationFeature.mode = .validateOnTextChanged
        let countValidator = createCountValidator()
        featureContainer.validationFeature.add(validator: countValidator)
        let oneUppercaseLetterValidator = createOneUppercaseLetterValidator()
        featureContainer.validationFeature.add(validator: oneUppercaseLetterValidator)
        let oneDigitValidator = createOneDigitValidator()
        featureContainer.validationFeature.add(validator: oneDigitValidator)

        let failureTextToCompare = "\(defaultFailureTextPrefixOfEnumeration)\(oneUppercaseLetterValidator.failureText?() ?? "")\(defaultFailureTextSeparator)\(defaultFailureTextPrefixOfEnumeration)\(oneDigitValidator.failureText?() ?? "")"
        featureContainer.textToValidate = "abcdefgh"
        XCTAssertEqual(featureContainer.validationFailureText, failureTextToCompare)
        XCTAssertEqual(featureContainer.isValidationSuccess, false)
    }

    func testFailureTextEnumerationModeAlways() {
        featureContainer.validationFeature.failureTextEnumerationMode = .always
        let validator = createCountValidatorAndFillWithFailureTextValidationFeature(withMode: .validateOnTextChanged)
        let failureTextToCompare = "\(defaultFailureTextPrefixOfEnumeration)\(validator.failureText?() ?? "")"
        XCTAssertEqual(featureContainer.validationFailureText, failureTextToCompare)
        XCTAssertEqual(featureContainer.isValidationSuccess, false)
    }

    func testFailureTextEnumerationModeMoreThanOne() {
        featureContainer.validationFeature.failureTextEnumerationMode = .moreFailureThanOne
        let countValidator = createCountValidatorAndFillWithFailureTextValidationFeature(withMode: .validateOnTextChanged)
        var failureTextToCompare = "\(countValidator.failureText?() ?? "")"
        XCTAssertEqual(featureContainer.validationFailureText, failureTextToCompare)
        XCTAssertEqual(featureContainer.isValidationSuccess, false)

        let oneUppercaseLetter = createOneUppercaseLetterValidator()
        featureContainer.validationFeature.add(validator: oneUppercaseLetter)
        featureContainer.validationFeature.validate()
        failureTextToCompare = "\(defaultFailureTextPrefixOfEnumeration)\(countValidator.failureText?() ?? "")\(defaultFailureTextSeparator)\(defaultFailureTextPrefixOfEnumeration)\(oneUppercaseLetter.failureText?() ?? "")"
        XCTAssertEqual(featureContainer.validationFailureText, failureTextToCompare)
        XCTAssertEqual(featureContainer.isValidationSuccess, false)
    }

    func testFailureTextEnumerationModeDisabled() {
        featureContainer.validationFeature.failureTextEnumerationMode = .disabled
        featureContainer.validationFeature.mode = .validateOnTextChanged
        let countValidator = createCountValidator()
        featureContainer.validationFeature.add(validator: countValidator)
        let oneUppercaseLetterValidator = createOneUppercaseLetterValidator()
        featureContainer.validationFeature.add(validator: oneUppercaseLetterValidator)
        featureContainer.textToValidate = "1234"

        let failureTextToCompare = "\(countValidator.failureText?() ?? "")\(defaultFailureTextSeparator)\(oneUppercaseLetterValidator.failureText?() ?? "")"
        XCTAssertEqual(featureContainer.validationFailureText, failureTextToCompare)
        XCTAssertEqual(featureContainer.isValidationSuccess, false)
    }

    // MARK: - Helpers
    private func createCountValidatorAndFillWithSuccessTextValidationFeature(withMode mode: KOTextValidateModes) -> KOTextValidatorProtocol {
        let validator = createCountValidatorAndFillValidationFeature(withMode: mode)
        featureContainer.textToValidate = "12345678"
        return validator
    }

    private func createCountValidatorAndFillWithFailureTextValidationFeature(withMode mode: KOTextValidateModes) -> KOTextValidatorProtocol {
        let validator = createCountValidatorAndFillValidationFeature(withMode: mode)
        featureContainer.textToValidate = "1234567"
        return validator
    }

    private func createCountValidatorAndFillValidationFeature(withMode mode: KOTextValidateModes) -> KOTextValidatorProtocol {
        let countValidation = createCountValidator()
        featureContainer.validationFeature.mode = mode
        featureContainer.validationFeature.add(validator: countValidation)
        return countValidation
    }

    private func createCountValidator() -> KOTextValidatorProtocol {
        return KOFunctionTextValidator(function: { (text) -> Bool in
            return text.count >= 8 && text.count <= 20
        }, failureText: "text should contain from 8 to 20 chars")
    }

    private func createOneDigitValidator() -> KOTextValidatorProtocol {
        return KOFunctionTextValidator(function: { password -> Bool in
            return password.rangeOfCharacter(from: .decimalDigits) != nil
        }, failureText: "one digit")
    }

    private func createOneUppercaseLetterValidator() -> KOTextValidatorProtocol {
        return KOFunctionTextValidator(function: { password -> Bool in
            return password.rangeOfCharacter(from: .uppercaseLetters) != nil
        }, failureText: "one uppercase letter")
    }
}

fileprivate final class FeatureContainerView: FirstResponderSimulatorView {
    private(set) var validationFeature: KOControlValidationFeature!
    private(set) var isValidationSuccess: Bool?
    private(set) var validationFailureText: String?

    var textToValidate: String? {
        didSet {
            validationFeature.eventTextChanged()
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        validationFeature = KOControlValidationFeature(delegate: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func resignFirstResponder() -> Bool {
        let isFirstResponder = false
        validationFeature.eventResignFirstResponder()
        return isFirstResponder
    }
}

extension FeatureContainerView: KOControlValidationFeatureDelegate {
    func validationSuccess() {
        isValidationSuccess = true
    }

    func validationFailure() {
        isValidationSuccess = false
    }

    func validationFailureTextComposed(_ failureText: String, fromValidators: [KOTextValidatorProtocol]) {
        validationFailureText = failureText
    }
}
