//
//  KODialogBarViewTests.swift
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

final class KODialogBarViewTests: XCTestCase {
    private var windowSimulator: WindowSimulator!
    private var viewController: UIViewController!
    private var dialogBarView: KODialogBarView!
    
    override func setUp() {
        viewController = UIViewController()
        windowSimulator = WindowSimulator(rootViewController: viewController)
        dialogBarView = KODialogBarView()
        dialogBarView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(dialogBarView)
        viewController.view.addConstraints([
            viewController.view.leftAnchor.constraint(equalTo: dialogBarView.leftAnchor),
            viewController.view.topAnchor.constraint(equalTo: dialogBarView.topAnchor),
            viewController.view.rightAnchor.constraint(equalTo: dialogBarView.rightAnchor)
            ])
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        dialogBarView = nil
        viewController = nil
        windowSimulator = nil
    }
    
    func testIsTitleLabelCenteredDefaultTrue() {
        XCTAssertEqual(dialogBarView.isTitleLabelCentered, true)
    }
    
    func testIsTitleLabelCentered() {
        dialogBarView.isTitleLabelCentered = true
        dialogBarView.titleLabel.text = "text"
        dialogBarView.layoutIfNeeded()
        
        let titleBoundsConvertedToDialogBar = dialogBarView.convert(dialogBarView.titleLabel.bounds, from: dialogBarView.titleLabel)
        XCTAssertEqual(titleBoundsConvertedToDialogBar.midX, dialogBarView.frame.midX)
        XCTAssertTrue(titleBoundsConvertedToDialogBar.width < dialogBarView.frame.width)
    }
    
    func testIsTitleLabelNotCentered() {
        dialogBarView.isTitleLabelCentered = false
        dialogBarView.titleLabel.text = "text"
        dialogBarView.layoutIfNeeded()
        
        let titleBoundsConvertedToDialogBar = dialogBarView.convert(dialogBarView.titleLabel.bounds, from: dialogBarView.titleLabel)
        let titleInsets = dialogBarView.titleContainerEdgesConstraintsInsets.left + dialogBarView.titleContainerEdgesConstraintsInsets.right
        XCTAssertEqual(titleBoundsConvertedToDialogBar.origin.x, dialogBarView.titleContainerEdgesConstraintsInsets.left)
        XCTAssertEqual(titleBoundsConvertedToDialogBar.width, dialogBarView.frame.width - titleInsets)
    }
    
    func testTitleContainerEdgesConstraintsInsets() {
        dialogBarView.isTitleLabelCentered = false
        dialogBarView.titleLabel.text = "text"
        dialogBarView.layoutIfNeeded()
        let oldDialogBarHeight = dialogBarView.frame.height
        let oldTitleBoundsConvertedToDialogBar = dialogBarView.convert(dialogBarView.titleLabel.bounds, from: dialogBarView.titleLabel)
        
        let newEdgeInsets = UIEdgeInsets(top: dialogBarView.defaultTitleInsets.top * 2, left: dialogBarView.defaultTitleInsets.left * 2, bottom: dialogBarView.defaultTitleInsets.bottom * 2, right: dialogBarView.defaultTitleInsets.right * 2)
        dialogBarView.titleContainerEdgesConstraintsInsets.insets = newEdgeInsets
        dialogBarView.layoutIfNeeded()
        let newDialogBarHeight = dialogBarView.frame.height
        let newTitleBoundsConvertedToDialogBar = dialogBarView.convert(dialogBarView.titleLabel.bounds, from: dialogBarView.titleLabel)
        
        XCTAssertEqual(oldDialogBarHeight + dialogBarView.defaultTitleInsets.top + dialogBarView.defaultTitleInsets.bottom, newDialogBarHeight)
        XCTAssertEqual(oldTitleBoundsConvertedToDialogBar.origin.x + dialogBarView.defaultTitleInsets.left,  newTitleBoundsConvertedToDialogBar.origin.x)
        XCTAssertEqual(oldTitleBoundsConvertedToDialogBar.width - (dialogBarView.defaultTitleInsets.left + dialogBarView.defaultTitleInsets.right), newTitleBoundsConvertedToDialogBar.width)
    }
    
    func testCustomView() {
        let customView = UIView()
        dialogBarView.customView = customView
        dialogBarView.layoutIfNeeded()
        XCTAssertEqual(customView.frame.origin.x, 0)
        XCTAssertEqual(customView.frame.maxX, dialogBarView.frame.width)
    }

    func testLeftView() {
        dialogBarView.isTitleLabelCentered = false
        dialogBarView.layoutIfNeeded()
        let oldTitleBoundsConvertedToDialogBar = dialogBarView.convert(dialogBarView.titleLabel.bounds, from: dialogBarView.titleLabel)

        let leftView = UIView()
        let leftViewWidth: CGFloat = 40
        leftView.addConstraints([
            leftView.widthAnchor.constraint(equalToConstant: leftViewWidth)
            ])
        dialogBarView.leftView = leftView
        let newTitleBoundsConvertedToDialogBar = dialogBarView.convert(dialogBarView.titleLabel.bounds, from: dialogBarView.titleLabel)

        XCTAssertEqual(dialogBarView.leftView?.frame.width, leftViewWidth)
        XCTAssertEqual(newTitleBoundsConvertedToDialogBar.width, oldTitleBoundsConvertedToDialogBar.width - leftViewWidth)
    }

    func testDefaultLeftViewContainerWidth() {
        dialogBarView.isTitleLabelCentered = false
        dialogBarView.layoutIfNeeded()
        let oldTitleBoundsConvertedToDialogBar = dialogBarView.convert(dialogBarView.titleLabel.bounds, from: dialogBarView.titleLabel)

        let leftViewWidth: CGFloat = 40
        dialogBarView.defaultLeftViewContainerWidth = leftViewWidth
        let newTitleBoundsConvertedToDialogBar = dialogBarView.convert(dialogBarView.titleLabel.bounds, from: dialogBarView.titleLabel)

        XCTAssertEqual(newTitleBoundsConvertedToDialogBar.width, oldTitleBoundsConvertedToDialogBar.width - leftViewWidth)
    }

    func testRightView() {
        dialogBarView.isTitleLabelCentered = false
        dialogBarView.layoutIfNeeded()
        let oldTitleBoundsConvertedToDialogBar = dialogBarView.convert(dialogBarView.titleLabel.bounds, from: dialogBarView.titleLabel)

        let rightView = UIView()
        let rightViewWidth: CGFloat = 40
        rightView.addConstraints([
            rightView.widthAnchor.constraint(equalToConstant: rightViewWidth)
            ])
        dialogBarView.rightView = rightView
        let newTitleBoundsConvertedToDialogBar = dialogBarView.convert(dialogBarView.titleLabel.bounds, from: dialogBarView.titleLabel)

        XCTAssertEqual(dialogBarView.rightView?.frame.width, rightViewWidth)
        XCTAssertEqual(newTitleBoundsConvertedToDialogBar.width, oldTitleBoundsConvertedToDialogBar.width - rightViewWidth)
    }

    func testDefaultRightViewContainerWidth() {
        dialogBarView.isTitleLabelCentered = false
        dialogBarView.layoutIfNeeded()
        let oldTitleBoundsConvertedToDialogBar = dialogBarView.convert(dialogBarView.titleLabel.bounds, from: dialogBarView.titleLabel)

        let rightViewWidth: CGFloat = 40
        dialogBarView.defaultRightViewContainerWidth = rightViewWidth
        let newTitleBoundsConvertedToDialogBar = dialogBarView.convert(dialogBarView.titleLabel.bounds, from: dialogBarView.titleLabel)

        XCTAssertEqual(newTitleBoundsConvertedToDialogBar.width, oldTitleBoundsConvertedToDialogBar.width - rightViewWidth)
    }
}
