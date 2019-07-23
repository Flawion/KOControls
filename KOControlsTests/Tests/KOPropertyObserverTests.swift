//
//  KOPropertyObserverTests.swift
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

final class KOPropertyObserverTests: XCTestCase {
    private var view: UIView!
    private var propertyObserver: KOPropertyObserver<UIView, Bool>!

    override func setUp() {
        view = UIView()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        view = nil
        propertyObserver = nil
    }

    func testViewHidding() {
        let promise = expectation(description: "propertyChangedEvent")
        propertyObserver = KOPropertyObserver<UIView, Bool>(subject: view, propertyPath: \UIView.isHidden, propertyChangedEvent: { (view, value) in
            promise.fulfill()
        })
        view.isHidden = false
        waitForExpectations(timeout: 0.1, handler: nil)
    }
}