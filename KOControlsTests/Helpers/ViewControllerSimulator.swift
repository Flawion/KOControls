//
//  ViewControllerSimulator.swift
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

final class ViewControllerSimulator: UIViewController {
    fileprivate var overridePresentingViewController: UIViewController?
    fileprivate var overridePresentedViewController: UIViewController?

    override var presentingViewController: UIViewController? {
        return overridePresentingViewController
    }

    override var presentedViewController: UIViewController? {
        return overridePresentedViewController
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        overridePresentedViewController = viewControllerToPresent
        add(viewController: viewControllerToPresent, animated: flag)
        if let viewControllerSimulator = viewControllerToPresent as? ViewControllerSimulator {
            viewControllerSimulator.overridePresentingViewController = self
        }
        completion?()
    }

    private func add(viewController: UIViewController, animated: Bool) {
        viewController.view.frame = view.bounds
        //addChild(viewController) freezes tests
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        viewController.viewWillAppear(animated)
        viewController.viewDidAppear(animated)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        guard let presentedViewController = presentedViewController else {
            presentingViewController?.dismiss(animated: flag, completion: completion)
            return
        }
        remove(viewController: presentedViewController, animated: flag)
        overridePresentedViewController = nil
        if let viewControllerSimulator = presentedViewController as? ViewControllerSimulator {
            viewControllerSimulator.overridePresentingViewController = nil
        }
        completion?()
    }

    private func remove(viewController: UIViewController, animated: Bool) {
        viewController.viewWillDisappear(animated)
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        //viewController.removeFromParent() freezes tests
        viewController.viewDidDisappear(animated)
    }
}
