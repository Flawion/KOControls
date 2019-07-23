//
//  KODialogViewControllerTests.swift
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

final class KODialogViewControllerTests: XCTestCase {
    private var windowSimulator: WindowSimulator!
    private var presentingViewController: ViewControllerSimulator!

    override func setUp() {
        presentingViewController = ViewControllerSimulator()
        windowSimulator = WindowSimulator(rootViewController: presentingViewController)
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        presentingViewController = nil
        windowSimulator = nil
    }

    func testHorizontalAlignmentLeft() {
        let contentDialogViewController = ContentDialogViewController()
        contentDialogViewController.mainViewHorizontalAlignment = .left
        present(contentDialogViewController: contentDialogViewController)

        XCTAssertEqual(contentDialogViewController.mainView.frame.origin.x, 0)
        XCTAssertTrue(contentDialogViewController.mainView.frame.maxX < contentDialogViewController.view.frame.width)
    }

    func testHorizontalAlignmentCenter() {
        let contentDialogViewController = ContentDialogViewController()
        contentDialogViewController.mainViewHorizontalAlignment = .center
        present(contentDialogViewController: contentDialogViewController)

        XCTAssertTrue(contentDialogViewController.mainView.frame.origin.x > 0)
        XCTAssertTrue(contentDialogViewController.mainView.frame.maxX < contentDialogViewController.view.frame.width)
    }

    func testHorizontalAlignmentRight() {
        let contentDialogViewController = ContentDialogViewController()
        contentDialogViewController.mainViewHorizontalAlignment = .right
        present(contentDialogViewController: contentDialogViewController)

        XCTAssertTrue(contentDialogViewController.mainView.frame.origin.x > 0)
        XCTAssertEqual(contentDialogViewController.mainView.frame.maxX, contentDialogViewController.view.frame.width)
    }

    func testHorizontalAlignmentFill() {
        let contentDialogViewController = ContentDialogViewController()
        contentDialogViewController.mainViewHorizontalAlignment = .fill
        present(contentDialogViewController: contentDialogViewController)

        XCTAssertEqual(contentDialogViewController.mainView.frame.origin.x, 0)
        XCTAssertEqual(contentDialogViewController.mainView.frame.maxX, contentDialogViewController.view.frame.width)
    }

    func testVerticalAlignmentTop() {
        let contentDialogViewController = ContentDialogViewController()
        contentDialogViewController.mainViewVerticalAlignment = .top
        present(contentDialogViewController: contentDialogViewController)

        XCTAssertEqual(contentDialogViewController.mainView.frame.origin.y, 0)
        XCTAssertTrue(contentDialogViewController.mainView.frame.maxY < contentDialogViewController.view.frame.height)
    }

    func testVerticalAlignmentCenter() {
        let contentDialogViewController = ContentDialogViewController()
        contentDialogViewController.mainViewVerticalAlignment = .center
        present(contentDialogViewController: contentDialogViewController)

        XCTAssertTrue(contentDialogViewController.mainView.frame.origin.y > 0)
        XCTAssertTrue(contentDialogViewController.mainView.frame.maxY < contentDialogViewController.view.frame.height)
    }

    func testVerticalAlignmentBottom() {
        let contentDialogViewController = ContentDialogViewController()
        contentDialogViewController.mainViewVerticalAlignment = .bottom
        present(contentDialogViewController: contentDialogViewController)

        XCTAssertTrue(contentDialogViewController.mainView.frame.origin.y > 0)
        XCTAssertEqual(contentDialogViewController.mainView.frame.maxY, contentDialogViewController.view.frame.height)
    }

    func testVerticalAlignmentFill() {
        let contentDialogViewController = ContentDialogViewController()
        contentDialogViewController.mainViewVerticalAlignment = .fill
        present(contentDialogViewController: contentDialogViewController)

        XCTAssertEqual(contentDialogViewController.mainView.frame.origin.y, 0)
        XCTAssertEqual(contentDialogViewController.mainView.frame.maxY, contentDialogViewController.view.frame.height)
    }

    private func present(contentDialogViewController: ContentDialogViewController) {
        presentingViewController.present(contentDialogViewController, animated: false)
        contentDialogViewController.view.layoutIfNeeded()
    }
}

fileprivate final class ContentView: UIView {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300, height: 300)
    }
}

fileprivate final class ContentDialogViewController: KODialogViewController {
    private(set) var contentView: ContentView!

    override func createContentView() -> UIView {
        contentView = ContentView()
        return contentView
    }
}
