//
//  KOControlErrorFeatureTests.swift
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

final class KOControlErrorFeatureTests: XCTestCase {
    private var windowSimulator: WindowSimulator!
    private var viewController: UIViewController!
    private var featureContainer: FeatureContainerView!

    override func setUp() {
        viewController = UIViewController()
        windowSimulator = WindowSimulator(rootViewController: viewController)
        featureContainer = FeatureContainerView()
        featureContainer.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(featureContainer)
        viewController.view.addConstraints([
            featureContainer.leftAnchor.constraint(equalTo: viewController.view.leftAnchor),
            featureContainer.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            featureContainer.rightAnchor.constraint(equalTo: viewController.view.rightAnchor),
            featureContainer.heightAnchor.constraint(equalToConstant: 50)
            ])
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        windowSimulator = nil
        viewController = nil
        featureContainer = nil
    }

    func testDefaultIsShowing() {
        XCTAssertEqual(featureContainer.errorDidShowCounter, 0)
        XCTAssertEqual(featureContainer.errorDidHideCounter, 0)
        XCTAssertEqual(featureContainer.errorFeature.iconView.bounds.size.width, 0)
        XCTAssertEqual(featureContainer.errorFeature.currentViewWidth, 0)
    }

    func testSettingTrueValueToIsShowing() {
        featureContainer.errorFeature.isShowing = true
        XCTAssertEqual(featureContainer.errorDidShowCounter, 1)
        XCTAssertEqual(featureContainer.errorDidHideCounter, 0)
        XCTAssertEqual(featureContainer.errorFeature.iconView.bounds.size.width, featureContainer.errorFeature.viewWidth)
        XCTAssertEqual(featureContainer.errorFeature.currentViewWidth, featureContainer.errorFeature.viewWidth)
    }

    func testSettingFalseValueToIsShowing() {
        testSettingTrueValueToIsShowing()
        featureContainer.errorFeature.isShowing = false
        XCTAssertEqual(featureContainer.errorDidShowCounter, 1)
        XCTAssertEqual(featureContainer.errorDidHideCounter, 1)
        XCTAssertEqual(featureContainer.errorFeature.iconView.bounds.size.width, 0)
        XCTAssertEqual(featureContainer.errorFeature.currentViewWidth, 0)
    }

    func testSettingTrueValueToIsShowingWithCustomView() {
        let customView = UIView()
        featureContainer.errorFeature.customView = customView
        featureContainer.errorFeature.isShowing = true
        XCTAssertEqual(featureContainer.errorDidShowCounter, 1)
        XCTAssertEqual(featureContainer.errorDidHideCounter, 0)
        XCTAssertEqual(customView.bounds.size.width, featureContainer.errorFeature.viewWidth)
        XCTAssertEqual(featureContainer.errorFeature.currentViewWidth, featureContainer.errorFeature.viewWidth)
    }

    func testSettingFalseValueToIsShowingWithCustomView() {
        testSettingTrueValueToIsShowingWithCustomView()
        featureContainer.errorFeature.isShowing = false
        XCTAssertEqual(featureContainer.errorDidShowCounter, 1)
        XCTAssertEqual(featureContainer.errorDidHideCounter, 1)
        XCTAssertEqual(featureContainer.errorFeature.customView?.bounds.size.width, 0)
        XCTAssertEqual(featureContainer.errorFeature.currentViewWidth, 0)
    }
}


fileprivate final class FeatureContainerView: UIView {
    private(set) var errorFeature: KOControlErrorFeature!

    private(set) var errorDidShowCounter: Int = 0
    private(set) var errorDidHideCounter: Int = 0

    init() {
        super.init(frame: CGRect.zero)
        errorFeature = KOControlErrorFeature(delegate: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FeatureContainerView: KOControlErrorFeatureDelegate {
    var featureContainer: UIView {
        return self
    }

    @objc func errorDidShow() {
        errorDidShowCounter += 1
    }

    @objc func errorDidHide() {
        errorDidHideCounter += 1
    }
}
