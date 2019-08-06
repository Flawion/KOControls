//
//  KOControlErrorInfoFeatureTests.swift
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

final class KOControlErrorInfoFeatureTests: XCTestCase {
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
        featureContainer = nil
        viewController = nil
        windowSimulator = nil
    }

    func testSettingTrueToIsShowingWithoutError() {
        featureContainer.errorInfoFeature.isShowing = true
        XCTAssertEqual(featureContainer.errorInfoStartingShowAnimationCounter, 0)
        XCTAssertEqual(featureContainer.errorInfoStartingHideAnimationCounter, 0)
        XCTAssertEqual(featureContainer.errorInfoFeature.isShowing, false)
    }

    func testSettingTrueToIsShowing() {
        featureContainer.errorIsShowing = true
        showErrorInfo(operation: { [weak self] in
            self?.featureContainer.errorInfoFeature.isShowing = true
        })
        checkIsDefaultViewShowed()
    }

    func testSettingFalseToIsShowing() {
        testSettingTrueToIsShowing()
        hideErrorInfo { [weak self] in
            self?.featureContainer.errorInfoFeature.isShowing = false
        }
    }

    func testIsDefaultShowModeOnFocus() {
        XCTAssertEqual(featureContainer.errorInfoFeature.showMode, KOShowErrorInfoModes.onFocus)
    }

    func testShowingOnShowModeOnFocus() {
        featureContainer.errorIsShowing = true
        featureContainer.errorInfoFeature.showMode = .onFocus
        showErrorInfo { [weak self] in
            _ = self?.featureContainer.becomeFirstResponder()
        }
        checkIsDefaultViewShowed()
    }

    func testHidingOnShowModeOnFocus() {
        testShowingOnShowModeOnFocus()
        hideErrorInfo { [weak self] in
            _ = self?.featureContainer.resignFirstResponder()
        }
    }

    func testShowingOnShowModeOnAlways() {
        featureContainer.errorInfoFeature.showMode = .always
        showErrorInfo { [weak self] in
            self?.featureContainer.errorIsShowing = true
        }
        checkIsDefaultViewShowed()
    }

    func testHidingOnShowModeOnAlways() {
        testShowingOnShowModeOnAlways()
        hideErrorInfo { [weak self] in
            self?.featureContainer.errorIsShowing = false
        }
    }

    func testShowingOnShowModeOnManual() {
        featureContainer.errorIsShowing = true
        featureContainer.errorInfoFeature.showMode = .manual
        showErrorInfo { [weak self] in
            self?.featureContainer.errorInfoFeature.isShowing = true
        }
        checkIsDefaultViewShowed()
    }

    func testHidingOnShowModeOnManual() {
        testShowingOnShowModeOnManual()
        hideErrorInfo { [weak self] in
            self?.featureContainer.errorInfoFeature.isShowing = false
        }
    }

    func testSettingFalseToManageViewMarkerVisibility() {
        featureContainer.errorInfoFeature.view.isMarkerViewHidden = true
        featureContainer.errorInfoFeature.manageViewMarkerVisibility = false
        testSettingTrueToIsShowing()
        XCTAssertEqual(featureContainer.errorInfoFeature.view.isMarkerViewHidden, true)
    }

    func testHidingMarkerWhenErrorGoneBeforeHidingErrorInfo() {
        featureContainer.errorInfoFeature.showMode = .always
        showErrorInfo { [weak self] in
            self?.featureContainer.errorIsShowing = true
        }
        featureContainer.errorIsShowing = false
        XCTAssertEqual(featureContainer.errorInfoStartingHideAnimationCounter, 1)
        XCTAssertEqual(featureContainer.errorInfoDidHideCounter, 0)
        XCTAssertEqual(featureContainer.errorInfoFeature.view.isMarkerViewHidden, true)
    }

    func testShowingCustomView() {
        let customErrorInfoView = CustomErrorInfoView()
        featureContainer.errorInfoFeature.customView = customErrorInfoView
        featureContainer.errorIsShowing = true
        featureContainer.errorInfoFeature.isShowing = true
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
        XCTAssertTrue(customErrorInfoView.bounds.size.width > 0)
        XCTAssertTrue(customErrorInfoView.bounds.size.height > 0)
        XCTAssertEqual(customErrorInfoView.markerCenterXConst?.isActive, true)
    }

    func testHidingCustomView() {
        testShowingCustomView()
        guard let customErrorInfoView = featureContainer.errorInfoFeature.customView as? CustomErrorInfoView else {
            XCTAssertTrue(false)
            return
        }
        featureContainer.errorIsShowing = false
        wait(timeout: featureContainer.errorInfoFeature.hideAnimation?.duration ?? 0)
        XCTAssertEqual(customErrorInfoView.markerCenterXConst?.isActive ?? false, false)
    }

    private func showErrorInfo(operation: () -> Void) {
        XCTAssertEqual(featureContainer.errorInfoStartingShowAnimationCounter, 0)
        XCTAssertEqual(featureContainer.errorInfoDidShowCounter, 0)
        operation()
        XCTAssertEqual(featureContainer.errorInfoStartingShowAnimationCounter, 1)
        XCTAssertEqual(featureContainer.errorInfoDidShowCounter, 1)
        XCTAssertEqual(featureContainer.errorInfoFeature.isShowing, true)
    }

    private func checkIsDefaultViewShowed() {
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
        XCTAssertTrue(featureContainer.errorInfoFeature.view.bounds.size.width > 0)
        XCTAssertTrue(featureContainer.errorInfoFeature.view.bounds.size.height > 0)
    }

    private func hideErrorInfo(operation: () -> Void) {
        operation()
        XCTAssertEqual(featureContainer.errorInfoStartingHideAnimationCounter, 1)
        XCTAssertEqual(featureContainer.errorInfoDidHideCounter, 0)
        wait(timeout: featureContainer.errorInfoFeature.hideAnimation?.duration ?? 0)
        XCTAssertEqual(featureContainer.errorInfoDidHideCounter, 1)
        XCTAssertEqual(featureContainer.errorInfoFeature.isShowing, false)
    }
}

fileprivate final class FeatureContainerView: FirstResponderSimulatorView {
    private(set) var errorInfoFeature: KOControlErrorInfoFeature!

    private(set) var errorInfoStartingHideAnimationCounter: Int = 0
    private(set) var errorInfoDidHideCounter: Int = 0
    private(set) var errorInfoStartingShowAnimationCounter: Int = 0
    private(set) var errorInfoDidShowCounter: Int = 0

    var errorIsShowing: Bool = false {
        didSet {
            errorInfoFeature.refresh()
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        errorInfoFeature = KOControlErrorInfoFeature(delegate: self)
        errorInfoFeature.description = "test"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        errorInfoFeature.eventDidMoveToSuperview()
    }

    override func becomeFirstResponder() -> Bool {
        let firstResponder = super.becomeFirstResponder()
        errorInfoFeature.eventFirstResponderChanged()
        return firstResponder
    }

    override func resignFirstResponder() -> Bool {
        let firstResponder = super.resignFirstResponder()
        errorInfoFeature.eventFirstResponderChanged()
        return firstResponder
    }
}

extension FeatureContainerView: KOControlErrorInfoFeatureDelegate {
    var featureContainer: UIView {
        return self
    }

    var markerCenterXEualTo: NSLayoutXAxisAnchor {
        return rightAnchor
    }

    @objc func errorInfoStartingHideAnimation() {
        errorInfoStartingHideAnimationCounter += 1
    }

    @objc func errorInfoDidHide() {
        errorInfoDidHideCounter += 1
    }

    @objc func errorInfoStartingShowAnimation() {
        errorInfoStartingShowAnimationCounter += 1
    }

    @objc func errorInfoDidShow() {
        errorInfoDidShowCounter += 1
    }
}

fileprivate final class CustomErrorInfoView: UIView, KOErrorInfoProtocol {
    weak var markerCenterXConst: NSLayoutConstraint?

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 80, height: 80)
    }

    func markerCenterXEqualTo(_ constraint: NSLayoutXAxisAnchor) -> NSLayoutConstraint? {
        let markerCenterXConst = centerXAnchor.constraint(equalTo: constraint)
        markerCenterXConst.priority = UILayoutPriority(900)
        self.markerCenterXConst = markerCenterXConst
        return markerCenterXConst
    }
}
