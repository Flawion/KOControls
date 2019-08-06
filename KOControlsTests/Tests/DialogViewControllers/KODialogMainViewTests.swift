//
//  KODialogMainViewTests.swift
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

final class KODialogMainViewTests: XCTestCase {
    private let contentPreferredSize = CGSize(width: 200, height: 200)
    private let contentInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

    private var windowSimulator: WindowSimulator!
    private var viewController: UIViewController!
    private var dialogMainView: KODialogMainView!

    override func setUp() {
        viewController = UIViewController()
        windowSimulator = WindowSimulator(rootViewController: viewController)
        setUpDialogMainView()
        super.setUp()
    }

    private func setUpDialogMainView() {
        dialogMainView = KODialogMainView(contentView: UIView(), withInsets: contentInsets)
        dialogMainView.translatesAutoresizingMaskIntoConstraints = false
        dialogMainView.contentWidth = contentPreferredSize.width
        dialogMainView.contentHeight = contentPreferredSize.height

        viewController.view.addSubview(dialogMainView)
        viewController.view.addConstraints([
            dialogMainView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            dialogMainView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
            ])
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
    }

    override func tearDown() {
        super.tearDown()
        dialogMainView = nil
        viewController = nil
        windowSimulator = nil
    }

    func testContentViewWithSizeAndInsets() {
        XCTAssertTrue(dialogMainView.bounds.width.almostEqualUI(to: contentPreferredSize.width + contentInsets.left + contentInsets.right))
        XCTAssertTrue(dialogMainView.bounds.height.almostEqualUI(to: contentPreferredSize.height + contentInsets.top + contentInsets.bottom + dialogMainView.barView.frame.height))
        XCTAssertTrue(dialogMainView.contentView.bounds.width.almostEqualUI(to: contentPreferredSize.width))
        XCTAssertTrue(dialogMainView.contentView.bounds.height.almostEqualUI(to: contentPreferredSize.height))
    }

    func testIsDefaultBarModeTop() {
        XCTAssertEqual(dialogMainView.barMode, .top)
    }

    func testBarModeTop() {
        dialogMainView.barMode = .top
        dialogMainView.layoutIfNeeded()

        XCTAssertTrue(dialogMainView.barView.frame.origin.y.almostEqualUI(to: 0))
        XCTAssertTrue(dialogMainView.barView.frame.origin.x.almostEqualUI(to: 0))
        XCTAssertTrue(dialogMainView.barView.frame.width.almostEqualUI(to: dialogMainView.frame.width))
    }

    func testBarModeBottom() {
        dialogMainView.barMode = .bottom
        dialogMainView.layoutIfNeeded()

        XCTAssertTrue((dialogMainView.barView.frame.origin.y + dialogMainView.barView.frame.height).almostEqualUI(to:  dialogMainView.frame.height))
        XCTAssertTrue(dialogMainView.barView.frame.origin.x.almostEqualUI(to: 0))
        XCTAssertTrue(dialogMainView.barView.frame.width.almostEqualUI(to: dialogMainView.frame.width))
    }

    func testBarModeHidden() {
        dialogMainView.barMode = .hidden
        dialogMainView.layoutIfNeeded()

        XCTAssertTrue(dialogMainView.bounds.height.almostEqualUI(to: contentPreferredSize.height + contentInsets.top + contentInsets.bottom))
    }

    func testBackgroundVisualEffect() {
        dialogMainView.backgroundVisualEffect = UIBlurEffect(style: .dark)
        dialogMainView.layoutIfNeeded()
        let backgroundVisualEffectView = dialogMainView.backgroundVisualEffectView

        XCTAssertEqual(dialogMainView.backgroundColor, UIColor.clear)
        XCTAssertNotNil(backgroundVisualEffectView)
        XCTAssertTrue((backgroundVisualEffectView?.frame.width ?? -1).almostEqualUI(to: dialogMainView.frame.width))
        XCTAssertTrue((backgroundVisualEffectView?.frame.height ?? -1).almostEqualUI(to: dialogMainView.frame.height))
    }
}
