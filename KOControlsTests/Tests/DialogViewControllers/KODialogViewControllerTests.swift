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
    private var contentDialogViewController: ContentDialogViewController!
    private var contentDialogViewControllerDelegate: ContentDialogViewControllerDelegate!

    override func setUp() {
        presentingViewController = ViewControllerSimulator()
        windowSimulator = WindowSimulator(rootViewController: presentingViewController)
        contentDialogViewController = ContentDialogViewController()
        contentDialogViewControllerDelegate = ContentDialogViewControllerDelegate()
        contentDialogViewController.delegate = contentDialogViewControllerDelegate
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        presentingViewController = nil
        windowSimulator = nil
        contentDialogViewController = nil
        contentDialogViewControllerDelegate = nil
    }

    func testHorizontalAlignmentLeft() {
        contentDialogViewController.mainViewHorizontalAlignment = .left
        presentAndCheckIsInitialized(contentDialogViewController: contentDialogViewController)

        XCTAssertEqual(contentDialogViewController.mainView.frame.origin.x, 0)
        XCTAssertTrue(contentDialogViewController.mainView.frame.maxX < contentDialogViewController.view.frame.width)
    }

    func testHorizontalAlignmentCenter() {
        contentDialogViewController.mainViewHorizontalAlignment = .center
        presentAndCheckIsInitialized(contentDialogViewController: contentDialogViewController)

        XCTAssertTrue(contentDialogViewController.mainView.frame.origin.x > 0)
        XCTAssertTrue(contentDialogViewController.mainView.frame.maxX < contentDialogViewController.view.frame.width)
    }

    func testHorizontalAlignmentRight() {
        contentDialogViewController.mainViewHorizontalAlignment = .right
        presentAndCheckIsInitialized(contentDialogViewController: contentDialogViewController)

        XCTAssertTrue(contentDialogViewController.mainView.frame.origin.x > 0)
        XCTAssertEqual(contentDialogViewController.mainView.frame.maxX, contentDialogViewController.view.frame.width)
    }

    func testHorizontalAlignmentFill() {
        contentDialogViewController.mainViewHorizontalAlignment = .fill
        presentAndCheckIsInitialized(contentDialogViewController: contentDialogViewController)

        XCTAssertEqual(contentDialogViewController.mainView.frame.origin.x, 0)
        XCTAssertEqual(contentDialogViewController.mainView.frame.maxX, contentDialogViewController.view.frame.width)
    }

    func testVerticalAlignmentTop() {
        contentDialogViewController.mainViewVerticalAlignment = .top
        presentAndCheckIsInitialized(contentDialogViewController: contentDialogViewController)

        XCTAssertEqual(contentDialogViewController.mainView.frame.origin.y, 0)
        XCTAssertTrue(contentDialogViewController.mainView.frame.maxY < contentDialogViewController.view.frame.height)
    }

    func testVerticalAlignmentCenter() {
        contentDialogViewController.mainViewVerticalAlignment = .center
        presentAndCheckIsInitialized(contentDialogViewController: contentDialogViewController)

        XCTAssertTrue(contentDialogViewController.mainView.frame.origin.y > 0)
        XCTAssertTrue(contentDialogViewController.mainView.frame.maxY < contentDialogViewController.view.frame.height)
    }

    func testVerticalAlignmentBottom() {
        contentDialogViewController.mainViewVerticalAlignment = .bottom
        presentAndCheckIsInitialized(contentDialogViewController: contentDialogViewController)

        XCTAssertTrue(contentDialogViewController.mainView.frame.origin.y > 0)
        XCTAssertEqual(contentDialogViewController.mainView.frame.maxY, contentDialogViewController.view.frame.height)
    }

    func testVerticalAlignmentFill() {
        contentDialogViewController.mainViewVerticalAlignment = .fill
        presentAndCheckIsInitialized(contentDialogViewController: contentDialogViewController)

        XCTAssertEqual(contentDialogViewController.mainView.frame.origin.y, 0)
        XCTAssertEqual(contentDialogViewController.mainView.frame.maxY, contentDialogViewController.view.frame.height)
    }
    
    func testLeftBarButton() {
        let buttonTitle = "test"
        let expection = expectation(description: "leftBarButtonClicked")
        contentDialogViewController.leftBarButtonAction = KODialogActionModel(title: "test", action: { [weak self] (dialogViewController) in
            guard let self = self else {
                return
            }
            XCTAssertEqual(dialogViewController, self.contentDialogViewController)
            expection.fulfill()
        })
        presentAndCheckIsInitialized(contentDialogViewController: contentDialogViewController)
        
        guard let leftBarButton = contentDialogViewController.mainView.barView.leftView as? UIButton else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(leftBarButton.title(for: .normal), buttonTitle)
        contentDialogViewController.testLeftBarButtonClicked()
        XCTAssertEqual(contentDialogViewControllerDelegate.leftButtonClickedCounter, 1)
        waitForExpectations(timeout: 0, handler: nil)
    }
    
    func testRightBarButton() {
        let buttonTitle = "test"
        let expection = expectation(description: "rightBarButtonClicked")
        contentDialogViewController.rightBarButtonAction = KODialogActionModel(title: "test", action: {  [weak self] (dialogViewController) in
            guard let self = self else {
                return
            }
            XCTAssertEqual(dialogViewController, self.contentDialogViewController)
            expection.fulfill()
        })
        presentAndCheckIsInitialized(contentDialogViewController: contentDialogViewController)
        
        guard let rightBarButton = contentDialogViewController.mainView.barView.rightView as? UIButton else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(rightBarButton.title(for: .normal), buttonTitle)
        contentDialogViewController.testRightBarButtonClicked()
        XCTAssertEqual(contentDialogViewControllerDelegate.rightButtonClickedCounter, 1)
        waitForExpectations(timeout: 0, handler: nil)
    }

    func testDisappear() {
        presentAndCheckIsInitialized(contentDialogViewController: contentDialogViewController)
        XCTAssertFalse(contentDialogViewControllerDelegate.willDisappear)
        XCTAssertFalse(contentDialogViewControllerDelegate.didDisappear)
        presentingViewController.dismiss(animated: false)
        XCTAssertTrue(contentDialogViewControllerDelegate.willDisappear)
        XCTAssertTrue(contentDialogViewControllerDelegate.didDisappear)
    }

    func testCreatingButtonsByDelegate() {
        contentDialogViewControllerDelegate = ContentDialogViewControllerCreateButtonsDelegate()
        contentDialogViewController.delegate = contentDialogViewControllerDelegate
        contentDialogViewController.leftBarButtonAction = KODialogActionModel.dismissAction(withTitle: "left")
        contentDialogViewController.rightBarButtonAction = KODialogActionModel.dismissAction(withTitle: "right")
        present(contentDialogViewController: contentDialogViewController)
        XCTAssertTrue(contentDialogViewController.mainView.barView.leftView is LeftButton)
        XCTAssertTrue(contentDialogViewController.mainView.barView.rightView is RightButton)
    }

    private func presentAndCheckIsInitialized(contentDialogViewController: ContentDialogViewController) {
        present(contentDialogViewController: contentDialogViewController)
        XCTAssertTrue(contentDialogViewControllerDelegate.initialized)
    }

    private func present(contentDialogViewController: ContentDialogViewController)  {
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

fileprivate class ContentDialogViewControllerDelegate: NSObject, KODialogViewControllerDelegate {
    private(set) var initialized: Bool = false
    private(set) var willDisappear: Bool = false
    private(set) var didDisappear: Bool = false
    private(set) var leftButtonClickedCounter: Int = 0
    private(set) var rightButtonClickedCounter: Int = 0

    func dialogViewControllerLeftButtonClicked(_ dialogViewController: KODialogViewController) {
        leftButtonClickedCounter += 1
    }

    func dialogViewControllerRightButtonClicked(_ dialogViewController: KODialogViewController) {
        rightButtonClickedCounter += 1
    }

    func dialogViewControllerInitialized(_ dialogViewController: KODialogViewController) {
        initialized = true
    }

    func dialogViewControllerViewWillDisappear(_ dialogViewController: KODialogViewController) {
        willDisappear = true
    }

    func dialogViewControllerViewDidDisappear(_ dialogViewController: KODialogViewController) {
        didDisappear = true
    }
}

fileprivate final class LeftButton: UIButton {
}

fileprivate final class RightButton: UIButton {
}

fileprivate class ContentDialogViewControllerCreateButtonsDelegate: ContentDialogViewControllerDelegate {
    func dialogViewControllerCreateLeftButton(_ dialogViewController: KODialogViewController) -> UIButton {
        return LeftButton()
    }

    func dialogViewControllerCreateRightButton(_ dialogViewController: KODialogViewController) -> UIButton {
        return RightButton()
    }
}
