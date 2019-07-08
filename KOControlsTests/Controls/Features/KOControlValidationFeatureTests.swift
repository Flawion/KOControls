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

    override func setUp() {
        featureContainer = FeatureContainerView()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        featureContainer = nil
    }

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
        _ = createCountValidatorAndFillWithSuccessText(featureContainerView: featureContainer, withMode: .validateOnTextChanged)
        XCTAssertEqual(featureContainer.isValidationSuccess, true)
    }

    func testFailureValidateOnTextChanged() {
        let countValidation = createCountValidatorAndFillWithFailureText(featureContainerView: featureContainer, withMode: .validateOnTextChanged)
        XCTAssertEqual(featureContainer.isValidationSuccess, false)
        XCTAssertEqual(featureContainer.validationFailureText, countValidation.failureText?())
    }

    func testSuccessValidateOnLostFocus() {
        _ = createCountValidatorAndFillWithSuccessText(featureContainerView: featureContainer, withMode: .validateOnLostFocus)
        _ = featureContainer.becomeFirstResponder()
        _ = featureContainer.resignFirstResponder()
        XCTAssertEqual(featureContainer.isValidationSuccess, true)
    }

    func testFailureValidateOnLostFocus() {
        let countValidation = createCountValidatorAndFillWithFailureText(featureContainerView: featureContainer, withMode: .validateOnLostFocus)
        _ = featureContainer.becomeFirstResponder()
        _ = featureContainer.resignFirstResponder()
        XCTAssertEqual(featureContainer.isValidationSuccess, false)
        XCTAssertEqual(featureContainer.validationFailureText, countValidation.failureText?())
    }

    func testSuccessValidateManual() {
        _ = createCountValidatorAndFillWithSuccessText(featureContainerView: featureContainer, withMode: .manual)
        featureContainer.validationFeature.validate()
        XCTAssertEqual(featureContainer.isValidationSuccess, true)
    }

    func testFailureValidateManual() {
        let countValidation = createCountValidatorAndFillWithFailureText(featureContainerView: featureContainer, withMode: .manual)
        featureContainer.validationFeature.validate()
        XCTAssertEqual(featureContainer.isValidationSuccess, false)
        XCTAssertEqual(featureContainer.validationFailureText, countValidation.failureText?())
    }

    func testClearErrorOnTextChanged() {
        let countValidation = createCountValidatorAndFillWithFailureText(featureContainerView: featureContainer, withMode: .clearErrorOnTextChanged)
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

    /*func testFailureMultipleValidatorsOnTextChanged() {
        featureContainer.validationFeature.mode = .validateOnTextChanged
        let countValidator = createCountValidator()
        featureContainer.validationFeature.add(validator: countValidator)
        let oneUppercaseLetterValidator = createOneUppercaseLetterValidator()
        featureContainer.validationFeature.add(validator: oneUppercaseLetterValidator)
        let oneDigitValidator = createOneDigitValidator()
        featureContainer.validationFeature.add(validator: oneDigitValidator)

        let failureTextToCompare = createFailureTextFrom(validators: [oneUppercaseLetterValidator, oneDigitValidator], separator: "\n")
        featureContainer.textToValidate = "abcdefgh"
        XCTAssertEqual(featureContainer.validationFailureText, failureTextToCompare)
        XCTAssertEqual(featureContainer.isValidationSuccess, false)
    }*/

    private func createFailureTextFrom(validators: [KOTextValidatorProtocol], separator: String) -> String {
        var failureText = ""
        for i in 0..<validators.count {
            if let textToAdd = validators[i].failureText?() {
                if !failureText.isEmpty {
                    failureText += separator
                }
                failureText += textToAdd
            }
        }
        return failureText
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

    private func createCountValidator() -> KOTextValidatorProtocol {
        return KOFunctionTextValidator(function: { (text) -> Bool in
            return text.count >= 8 && text.count <= 20
        }, failureText: "text should contain from 8 to 20 chars")
    }

    private func createCountValidatorAndFill(validationFeature: KOControlValidationFeature, withMode mode: KOTextValidateModes) -> KOTextValidatorProtocol {
        let countValidation = createCountValidator()
        featureContainer.validationFeature.mode = mode
        featureContainer.validationFeature.add(validator: countValidation)
        return countValidation
    }

    private func createCountValidatorAndFillWithSuccessText(featureContainerView: FeatureContainerView, withMode mode: KOTextValidateModes) -> KOTextValidatorProtocol {
        let validator = createCountValidatorAndFill(validationFeature: featureContainerView.validationFeature, withMode: mode)
        featureContainerView.textToValidate = "12345678"
        return validator
    }

    private func createCountValidatorAndFillWithFailureText(featureContainerView: FeatureContainerView, withMode mode: KOTextValidateModes) -> KOTextValidatorProtocol {
        let validator = createCountValidatorAndFill(validationFeature: featureContainerView.validationFeature, withMode: mode)
        featureContainerView.textToValidate = "1234567"
        return validator
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
