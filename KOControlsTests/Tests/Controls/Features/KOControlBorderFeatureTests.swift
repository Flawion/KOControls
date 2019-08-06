//
//  KOControlBorderFeatureTests.swift
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

final class KOControlBorderFeatureTests: XCTestCase {
    fileprivate var featureContainer: FeatureContainerView!

    override func setUp() {
        featureContainer = FeatureContainerView()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        featureContainer = nil
    }

    func testBorderColorNormal() {
        XCTAssertEqual(featureContainer.layer.borderColor, featureContainer.borderSettings.color)
    }

    func testBorderWidthNormal() {
        XCTAssertTrue(featureContainer.layer.borderWidth.almostEqualUI(to: featureContainer.borderSettings.width))
    }

    func testBorderColorError() {
        featureContainer.errorIsShowing = true
        XCTAssertEqual(featureContainer.layer.borderColor, featureContainer.borderSettings.errorColor)
    }

    func testBorderWidthError() {
        featureContainer.errorIsShowing = true
        XCTAssertTrue(featureContainer.layer.borderWidth.almostEqualUI(to: featureContainer.borderSettings.errorWidth ?? -1))
    }

    func testBorderColorFocused() {
        _ = featureContainer.becomeFirstResponder()
        XCTAssertEqual(featureContainer.layer.borderColor, featureContainer.borderSettings.focusedColor)
    }

    func testBorderWidthFocused() {
        _ = featureContainer.becomeFirstResponder()
        XCTAssertTrue(featureContainer.layer.borderWidth.almostEqualUI(to: featureContainer.borderSettings.focusedWidth ?? -1))
    }

    func testBorderColorErrorFocused() {
        featureContainer.errorIsShowing = true
        _ = featureContainer.becomeFirstResponder()
        XCTAssertEqual(featureContainer.layer.borderColor, featureContainer.borderSettings.errorFocusedColor)
    }

    func testBorderWidthErrorFocused() {
        featureContainer.errorIsShowing = true
        _ = featureContainer.becomeFirstResponder()
        XCTAssertTrue(featureContainer.layer.borderWidth.almostEqualUI(to: featureContainer.borderSettings.errorFocusedWidth ?? -1))
    }

    func testChangingBorderSettings() {
        let newBorderSettings = KOControlBorderSettings(color: UIColor.purple.cgColor, errorColor: UIColor.blue.cgColor, focusedColor: UIColor.green.cgColor, errorFocusedColor: UIColor.red.cgColor, width: 8, errorWidth: 6, focusedWidth: 4, errorFocusedWidth: 2)
        featureContainer.borderSettings = newBorderSettings

        testBorderColorNormal()
        testBorderWidthNormal()
    }

    func testRefreshFunction() {
        let colorNormal = UIColor.red.cgColor
        featureContainer.borderSettings.color = UIColor.red.cgColor
        XCTAssertEqual(featureContainer.layer.borderColor, colorNormal)
    }
}

fileprivate final class FeatureContainerView: FirstResponderSimulatorView {
    private(set) var borderFeature: KOControlBorderFeature!

    var borderSettings: KOControlBorderSettings = KOControlBorderSettings(color: UIColor.gray.cgColor, errorColor: UIColor.red.cgColor, focusedColor: UIColor.green.cgColor, errorFocusedColor: UIColor.blue.cgColor, width: 2, errorWidth: 4, focusedWidth: 6, errorFocusedWidth: 8) {
        didSet {
            borderFeature.settings = borderSettings
        }
    }

    var errorIsShowing: Bool = false {
        didSet {
            borderFeature.refresh()
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        borderFeature = KOControlBorderFeature(delegate: self)
        borderFeature.settings = borderSettings
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        let isFirstResponder = super.becomeFirstResponder()
        borderFeature.eventFirstResponderChanged()
        return isFirstResponder
    }

    override func resignFirstResponder() -> Bool {
        let isFirstResponder = super.resignFirstResponder()
        borderFeature.eventFirstResponderChanged()
        return isFirstResponder
    }
}

extension FeatureContainerView: KOControlBorderFeatureDelegate {
    var featureContainer: UIView {
        return self
    }
}
