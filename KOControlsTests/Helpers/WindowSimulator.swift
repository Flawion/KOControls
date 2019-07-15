//
//  WindowSimulator.swift
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

import UIKit
import XCTest

final class WindowSimulator {
    private(set) var window: UIWindow!

    init(rootViewController: UIViewController?) {
        window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        guard let rootViewController = rootViewController else {
            return
        }
        showRootViewController(rootViewController)
    }

    func showRootViewController(_ viewController: UIViewController) {
        hideRootViewControllerIfCan()
        window.rootViewController = viewController
        _ = viewController.view
        viewController.viewWillAppear(false)
        viewController.viewDidAppear(false)
    }

    func hideRootViewControllerIfCan() {
        guard let viewController = window.rootViewController else {
            return
        }
        hideRootViewController(viewController)
    }

    private func hideRootViewController(_ viewController: UIViewController) {
        viewController.viewWillDisappear(false)
        viewController.viewDidDisappear(false)
        window.rootViewController = nil
    }

    deinit {
        hideRootViewControllerIfCan()
        window.isHidden = true
        window = nil
    }
}
