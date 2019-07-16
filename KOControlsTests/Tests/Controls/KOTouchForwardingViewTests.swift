//
//  KOTouchForwardingViewTests.swift
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

final class KOTouchForwardingViewTests: XCTestCase {
    private var windowSimulator: WindowSimulator!
    private var viewController: UIViewController!
    private var touchForwardingView: KOTouchForwardingView!
    private var viewToTouch1: UIView!
    private var viewToTouch2: UIView!
    private var viewToTouch3: UIView!
    private var viewToTouch4: UIView!

    override func setUp() {
        viewController = UIViewController()
        windowSimulator = WindowSimulator(rootViewController: viewController)
        setUpViewToTouch1()
        setUpViewToTouch2()
        setUpViewToTouch3()
        setUpViewToTouch4()
        setUpTouchForwardingView()
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
        super.setUp()
    }

    private func setUpViewToTouch1() {
        viewToTouch1 = UIView()
        viewToTouch1.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(viewToTouch1)
        viewController.view.addConstraints([
            viewToTouch1.leftAnchor.constraint(equalTo: viewController.view.leftAnchor),
            viewToTouch1.topAnchor.constraint(equalTo: viewController.view.topAnchor)
            ])
    }

    private func setUpViewToTouch2() {
        viewToTouch2 = UIView()
        viewToTouch2.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(viewToTouch2)
        viewController.view.addConstraints([
            viewToTouch2.rightAnchor.constraint(equalTo: viewController.view.rightAnchor),
            viewToTouch2.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            viewToTouch2.leftAnchor.constraint(equalTo: viewToTouch1.rightAnchor),
            viewToTouch2.widthAnchor.constraint(equalTo: viewToTouch1.widthAnchor),
            viewToTouch2.heightAnchor.constraint(equalTo: viewToTouch1.heightAnchor)
            ])
    }

    private func setUpViewToTouch3() {
        viewToTouch3 = UIView()
        viewToTouch3.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(viewToTouch3)
        viewController.view.addConstraints([
            viewToTouch3.leftAnchor.constraint(equalTo: viewController.view.leftAnchor),
            viewToTouch3.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            viewToTouch3.topAnchor.constraint(equalTo: viewToTouch1.bottomAnchor),
            viewToTouch3.widthAnchor.constraint(equalTo: viewToTouch1.widthAnchor),
            viewToTouch3.heightAnchor.constraint(equalTo: viewToTouch1.heightAnchor)
            ])
    }

    private func setUpViewToTouch4() {
        viewToTouch4 = UIView()
        viewToTouch4.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(viewToTouch4)
        viewController.view.addConstraints([
            viewToTouch4.rightAnchor.constraint(equalTo: viewController.view.rightAnchor),
            viewToTouch4.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            viewToTouch4.leftAnchor.constraint(equalTo: viewToTouch3.rightAnchor),
            viewToTouch4.topAnchor.constraint(equalTo: viewToTouch2.bottomAnchor),
            viewToTouch4.widthAnchor.constraint(equalTo: viewToTouch1.widthAnchor),
            viewToTouch4.heightAnchor.constraint(equalTo: viewToTouch1.heightAnchor)
            ])
    }

    private func setUpTouchForwardingView() {
        touchForwardingView = KOTouchForwardingView()
        touchForwardingView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(touchForwardingView)
        viewController.view.addConstraints([
            touchForwardingView.leftAnchor.constraint(equalTo: viewController.view.leftAnchor),
            touchForwardingView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            touchForwardingView.rightAnchor.constraint(equalTo: viewController.view.rightAnchor),
            touchForwardingView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        touchForwardingView.passthroughViews = [viewToTouch1, viewToTouch2, viewToTouch3, viewToTouch4]
    }

    override func tearDown() {
        super.tearDown()
        viewToTouch1 = nil
        viewToTouch2 = nil
        viewToTouch3 = nil
        viewToTouch4 = nil
        touchForwardingView = nil
        viewController = nil
        windowSimulator = nil
    }

    func testForwardingTouchToView1() {
        forwardTouchAndCheckResult(view: viewToTouch1)
    }

    func testForwardingTouchToView2() {
        forwardTouchAndCheckResult(view: viewToTouch2)
    }

    func testForwardingTouchToView3() {
        forwardTouchAndCheckResult(view: viewToTouch3)
    }

    func testForwardingTouchToView4() {
        forwardTouchAndCheckResult(view: viewToTouch4)
    }

    func testHitEmptySpace() {
        touchForwardingView.passthroughViews.remove(at: 3)
        XCTAssertEqual(touchForwardingView, forwardTouch(toView: viewToTouch4))
    }

    func forwardTouch(toView: UIView) -> UIView? {
        let point = CGPoint(x: toView.frame.midX, y: toView.frame.midY)
        return touchForwardingView.hitTest(point, with: UIEvent())
    }

    func forwardTouchAndCheckResult(view: UIView) {
        XCTAssertEqual(view, forwardTouch(toView: view))
    }
}
