//
//  KOControlErrorInfoFeatureTests.swift
//  KOControlsTests
//
//  Created by Kuba Ostrowski on 10/07/2019.
//  Copyright © 2019 Kuba Ostrowski. All rights reserved.
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
        windowSimulator = nil
        viewController = nil
        featureContainer = nil
    }

    func testSettingsTrueToIsShowingWithoutError() {
        featureContainer.errorInfoFeature.isShowing = true
        XCTAssertEqual(featureContainer.errorInfoStartingShowAnimationCounter, 0)
        XCTAssertEqual(featureContainer.errorInfoStartingHideAnimationCounter, 0)
        XCTAssertEqual(featureContainer.errorInfoFeature.isShowing, false)
    }

    func testSettingsTrueToIsShowing() {
        featureContainer.errorIsShowing = true
        featureContainer.errorInfoFeature.isShowing = true
        XCTAssertEqual(featureContainer.errorInfoStartingShowAnimationCounter, 1)
        XCTAssertEqual(featureContainer.errorInfoDidShowCounter, 1)
    }

    func testSettingsFalseToIsShowing() {
        testSettingsTrueToIsShowing()
        featureContainer.errorInfoFeature.isShowing = false
        XCTAssertEqual(featureContainer.errorInfoStartingHideAnimationCounter, 1)
        XCTAssertEqual(featureContainer.errorInfoDidHideCounter, 0)
        wait(timeout: featureContainer.errorInfoFeature.hideAnimation?.duration ?? 0)
        XCTAssertEqual(featureContainer.errorInfoDidHideCounter, 1)
    }

    func testDefaultShowMode() {
        XCTAssertEqual(featureContainer.errorInfoFeature.showMode, KOShowErrorInfoModes.onFocus)
    }

    func testShowModeOnFocus() {
        featureContainer.errorIsShowing = true
        featureContainer.errorInfoFeature.showMode = .onFocus
        XCTAssertEqual(featureContainer.errorInfoStartingShowAnimationCounter, 0)
        XCTAssertEqual(featureContainer.errorInfoDidShowCounter, 0)
        _ = featureContainer.becomeFirstResponder()
        XCTAssertEqual(featureContainer.errorInfoStartingShowAnimationCounter, 1)
        XCTAssertEqual(featureContainer.errorInfoDidShowCounter, 1)
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
