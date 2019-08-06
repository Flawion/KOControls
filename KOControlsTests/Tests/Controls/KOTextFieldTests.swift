//
//  KOTextFieldTests.swift
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

final class KOTextFieldTests: XCTestCase {
    private var windowSimulator: WindowSimulator!
    private var viewController: UIViewController!
    private var textFieldDelegateContainer: TextFieldDelegateContainer!
    private var textField: KOTextField!
    private var countValidator: KOFunctionTextValidator!

    override func setUp() {
        viewController = UIViewController()
        windowSimulator = WindowSimulator(rootViewController: viewController)
        textFieldDelegateContainer = TextFieldDelegateContainer()
        setUpTextField()
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
        super.setUp()
    }

    private func setUpTextField() {
        textField = KOTextField()
        textField.koDelegate = textFieldDelegateContainer
        textField.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(textField)
        viewController.view.addConstraints([
            textField.leftAnchor.constraint(equalTo: viewController.view.leftAnchor),
            textField.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            textField.rightAnchor.constraint(equalTo: viewController.view.rightAnchor),
            textField.heightAnchor.constraint(equalToConstant: 50)
            ])

        textField.errorInfo.showMode = .onFocus
        countValidator = KOFunctionTextValidator(function: { (text) -> Bool in
            return text.count >= 8 && text.count <= 20
        }, failureText: "text should contain from 8 to 20 chars")
        textField.validation.add(validator: countValidator)
    }

    override func tearDown() {
        super.tearDown()
        countValidator = nil
        textField = nil
        windowSimulator = nil
        viewController = nil
    }

    func testShowingErrorWhenValidationOnLostFocusFailed() {
        textField.validation.mode = .validateOnLostFocus
        textField.text = "1234567"
        _ = textField.becomeFirstResponder()
        XCTAssertFalse(textField.error.isShowing)
        XCTAssertEqual(textFieldDelegateContainer.didShowErrorCounter, 0)
        _ = textField.resignFirstResponder()
        XCTAssertTrue(textField.error.isShowing)
        XCTAssertEqual(textFieldDelegateContainer.didShowErrorCounter, 1)
        XCTAssertTrue(textField.error.currentViewWidth?.almostEqualUI(to: textField.error.viewWidth) ?? false)
    }

    func testHidingErrorWhenValidationOnLostFocusSuccess() {
        testShowingErrorWhenValidationOnLostFocusFailed()
        XCTAssertEqual(textFieldDelegateContainer.didHideErrorCounter, 0)
        textField.text = "12345678"
        XCTAssertFalse(textField.error.isShowing)
        XCTAssertEqual(textFieldDelegateContainer.didHideErrorCounter, 1)
        XCTAssertTrue(textField.error.currentViewWidth?.almostEqualUI(to: 0) ?? false)
    }

    func testShowingErrorWhenValidationOnTextChangedFailed() {
        textField.validation.mode = .validateOnTextChanged
        XCTAssertEqual(textFieldDelegateContainer.didShowErrorCounter, 0)
        XCTAssertFalse(textField.error.isShowing)
        textField.text = "1234567"
        XCTAssertTrue(textField.error.isShowing)
        XCTAssertEqual(textFieldDelegateContainer.didShowErrorCounter, 1)
        XCTAssertTrue(textField.error.currentViewWidth?.almostEqualUI(to: textField.error.viewWidth) ?? false)
    }

    func testShowingErrorWhenValidationOnTextChangedSuccess() {
        testShowingErrorWhenValidationOnTextChangedFailed()
        XCTAssertEqual(textFieldDelegateContainer.didHideErrorCounter, 0)
        textField.text = "12345678"
        XCTAssertFalse(textField.error.isShowing)
        XCTAssertEqual(textFieldDelegateContainer.didHideErrorCounter, 1)
        XCTAssertTrue(textField.error.currentViewWidth?.almostEqualUI(to: 0) ?? false)
    }

    func testShowingErrorInfoOnFocus() {
        testShowingErrorWhenValidationOnLostFocusFailed()
        _ = textField.becomeFirstResponder()
        XCTAssertTrue(textField.errorInfo.isShowing)
        XCTAssertEqual(textFieldDelegateContainer.startingErrorInfoShowAnimationCounter, 1)
        wait(timeout: textField.errorInfo?.showAnimation?.duration ?? 0)
        XCTAssertEqual(textFieldDelegateContainer.didShowErrorInfoCounter, 1)
    }

    func testShowingErrorInfoOnFocusWithoutError() {
        testHidingErrorWhenValidationOnLostFocusSuccess()
        _ = textField.becomeFirstResponder()
        XCTAssertFalse(textField.errorInfo.isShowing)
        XCTAssertEqual(textFieldDelegateContainer.startingErrorInfoShowAnimationCounter, 0)
    }

    func testHidingErrorInfoOnLostFocus() {
        testShowingErrorInfoOnFocus()
        XCTAssertEqual(textFieldDelegateContainer.startingErrorInfoHideAnimationCounter, 0)
        _ = textField.resignFirstResponder()
        XCTAssertEqual(textFieldDelegateContainer.startingErrorInfoHideAnimationCounter, 1)
        wait(timeout: (textField.errorInfo?.showAnimation?.duration ?? 0) + (textField.errorInfo.hideAnimation?.duration ?? 0))
        XCTAssertEqual(textFieldDelegateContainer.didHideErrorInfoCounter, 1)
        XCTAssertFalse(textField.errorInfo.isShowing)
    }

    func testIsFieldRectsShiftedWhenErrorIsShowing() {
        let bounds = textField.bounds
        textField.placeholder = "testPlaceholder"
        textField.text = "testClearButton"
        textField.clearButtonMode = .always
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        textField.rightView = rightView
        textField.rightViewMode = .always

        let rightViewRect = textField.rightViewRect(forBounds: bounds)
        let clearButtonRect = textField.clearButtonRect(forBounds: bounds)
        let textRect = textField.textRect(forBounds: bounds)
        let editingRect = textField.editingRect(forBounds: bounds)
        let placeholderRect = textField.placeholderRect(forBounds: bounds)
        testShowingErrorWhenValidationOnLostFocusFailed()

        let rightViewRectOnError = textField.rightViewRect(forBounds: bounds)
        let clearButtonRectOnError = textField.clearButtonRect(forBounds: bounds)
        let textRectOnError = textField.textRect(forBounds: bounds)
        let editingRectOnError = textField.editingRect(forBounds: bounds)
        let placeholderRectOnError = textField.placeholderRect(forBounds: bounds)

        XCTAssertTrue(rightViewRectOnError.almostEqualUI(to: rightViewRect.offsetBy(dx: -textField.error.viewWidth, dy: 0)))
        XCTAssertTrue(clearButtonRectOnError.almostEqualUI(to: clearButtonRect.offsetBy(dx: -textField.error.viewWidth, dy: 0)))
        XCTAssertTrue(textRectOnError.width.almostEqualUI(to: textRect.width - textField.error.viewWidth))
        XCTAssertTrue(editingRectOnError.width.almostEqualUI(to: editingRect.width - textField.error.viewWidth))
        XCTAssert(placeholderRect.width > placeholderRectOnError.width)
    }

    func testValidationFailureText() {
        testShowingErrorWhenValidationOnLostFocusFailed()
        XCTAssertEqual(textFieldDelegateContainer.validationFailureText, countValidator.failureText())
        XCTAssertEqual(textFieldDelegateContainer.failureValidators.count, 1)
        XCTAssertEqual(textFieldDelegateContainer.validationFailureText, textField.errorInfo.description)
    }

    func testOverrideValidationFailureText() {
        textFieldDelegateContainer.overrideValidationFailureText = "test"
        testShowingErrorWhenValidationOnLostFocusFailed()
        XCTAssertEqual(textFieldDelegateContainer.validationFailureText, textFieldDelegateContainer.overrideValidationFailureText)
        XCTAssertEqual(textFieldDelegateContainer.failureValidators.count, 1)
        XCTAssertEqual(textFieldDelegateContainer.overrideValidationFailureText, textField.errorInfo.description)
    }
}

fileprivate final class TextFieldDelegateContainer: NSObject, KOTextFieldDelegate {
    private(set) var didShowErrorCounter: Int = 0
    private(set) var didHideErrorCounter: Int = 0
    private(set) var startingErrorInfoShowAnimationCounter: Int = 0
    private(set) var startingErrorInfoHideAnimationCounter: Int = 0
    private(set) var didShowErrorInfoCounter: Int = 0
    private(set) var didHideErrorInfoCounter: Int = 0
    private(set) var validationFailureText: String?
    private(set) var failureValidators: [KOTextValidatorProtocol] = []

    var overrideValidationFailureText: String?

    @objc func textFieldDidShowError(_ textField: UITextField) {
        didShowErrorCounter += 1
    }
    @objc func textFieldDidHideError(_ textField: UITextField) {
        didHideErrorCounter += 1
    }

    @objc func textFieldStartingErrorInfoShowAnimation(_ textField: UITextField) {
        startingErrorInfoShowAnimationCounter += 1
    }
    @objc func textFieldStartingErrorInfoHideAnimation(_ textField: UITextField) {
        startingErrorInfoHideAnimationCounter += 1
    }

    @objc func textFieldDidShowErrorInfo(_ textField: UITextField) {
        didShowErrorInfoCounter += 1
    }
    @objc func textFieldDidHideErrorInfo(_ textField: UITextField) {
        didHideErrorInfoCounter += 1
    }

    @objc func textField(_ textField: UITextField, overrideValidationFailureText: String, fromValidators: [KOTextValidatorProtocol]) -> String? {
        failureValidators = fromValidators
        validationFailureText = self.overrideValidationFailureText ?? overrideValidationFailureText
        return validationFailureText
    }
}
