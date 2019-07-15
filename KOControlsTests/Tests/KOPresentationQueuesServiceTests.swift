//
//  KOPresentationQueuesServiceTests.swift
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

final class KOPresentationQueuesServiceTests: XCTestCase {
    private var windowSimulator: WindowSimulator!
    private var presentingViewController: ViewControllerSimulator!

    private let queueIndex: Int = 0
    private let createdViewControllerToPresentCount: Int = 5
    private var viewControllersPresentedInQueue: [ViewControllerSimulator] = []
    private var viewControllersIdsInQueue: [String] = []

    override func setUp() {
        KOPresentationQueuesService.shared.processQueuesTimerInterval = 0.1
        presentingViewController = ViewControllerSimulator()
        windowSimulator = WindowSimulator(rootViewController: presentingViewController)
        presentingViewController.view.setNeedsLayout()
        presentingViewController.view.layoutIfNeeded()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        presentingViewController = nil
        windowSimulator = nil
    }

    func testPresentingMultipleViewControllersInQueue() {
        createAndPresentViewControllersInQueue()
        checkPresentationQueueForEachItem()
    }

    func testRemovingItemsFromQueueByItemId() {
        createAndPresentViewControllersInQueue()

        let indexViewControllersPresentedInQueueToRemove = [2,1]
        for index in indexViewControllersPresentedInQueueToRemove {
            KOPresentationQueuesService.shared.removeFromQueue(withIndex: queueIndex, itemWithId: viewControllersIdsInQueue[index])
            removeViewControllerPresentedInQueue(withIndex: index)
        }

        checkPresentationQueueForEachItem()
    }

    func testRemovingItemsFromQueueByIndex() {
        createAndPresentViewControllersInQueue()

        let indexViewControllersPresentedInQueueToRemove = [2,1]
        for index in indexViewControllersPresentedInQueueToRemove {
            KOPresentationQueuesService.shared.removeFromQueue(withIndex: queueIndex, itemWithIndex: index - 1)
            removeViewControllerPresentedInQueue(withIndex: index)
        }

        checkPresentationQueueForEachItem()
    }

    func testRemovingAllItemsFromQueueForPresentingViewController() {
        createAndPresentViewControllersInQueue()

        let anotherPresentingViewController = ViewControllerSimulator()
        _ = KOPresentationQueuesService.shared.presentInQueue(ViewControllerSimulator(), onViewController: anotherPresentingViewController, queueIndex: queueIndex, animated: false, animationCompletion: nil)
        KOPresentationQueuesService.shared.removeAllItemsFromQueue(withIndex: queueIndex, forPresentingViewController: presentingViewController)

        XCTAssertEqual(KOPresentationQueuesService.shared.itemsCountForQueue(withIndex: queueIndex), 1)
    }

    func testRemovingCurrentVisibleItemFromQueue() {
        createAndPresentViewControllersInQueue()
        KOPresentationQueuesService.shared.removeCurrentVisibleItemForQueue(withIndex: 0, animated: false, animationCompletion: nil)
        checkPresentationQueueForEachItem(startIndex: 1)
    }

    func testGettingItemByIdFromQueue() {
        createAndPresentViewControllersInQueue()
        for index in 1..<viewControllersPresentedInQueue.count {
            let itemByMethod = KOPresentationQueuesService.shared.itemFromQueue(withIndex: queueIndex, itemId: viewControllersIdsInQueue[index])
            let itemBySubscript = KOPresentationQueuesService.shared[queueIndex, viewControllersIdsInQueue[index]]
            XCTAssertEqual(itemByMethod?.viewControllerToPresent.view.tag, index)
            XCTAssertEqual(itemByMethod, itemBySubscript)
        }
    }

    func testGettingItemByIndexFromQueue() {
        createAndPresentViewControllersInQueue()
        for index in 1..<viewControllersPresentedInQueue.count {
            let item = KOPresentationQueuesService.shared.itemFromQueue(withIndex: queueIndex, itemIndex: index - 1)
            XCTAssertEqual(item?.viewControllerToPresent.view.tag, index)
        }
    }

    func testGettingItemPresentedForQueue() {
        createAndPresentViewControllersInQueue()
        checkPresentationQueueForEachItem { [weak self] (indexOfPresentedViewController) in
            guard let self = self else {
                XCTAssertTrue(false)
                return
            }
            XCTAssertEqual(KOPresentationQueuesService.shared.itemPresentedForQueue(withIndex: self.queueIndex)?.viewControllerToPresent, self.viewControllersPresentedInQueue[indexOfPresentedViewController])
        }
    }

    func testDeletingQueue() {
        createAndPresentViewControllersInQueue()
        KOPresentationQueuesService.shared.deleteQueue(withIndex: queueIndex)
        XCTAssertNil(KOPresentationQueuesService.shared.itemsCountForQueue(withIndex: queueIndex))
    }

    func testChangingProcessQueuesTimeInterval() {
        let oldTimeInterval = KOPresentationQueuesService.shared.processQueuesTimerInterval
        KOPresentationQueuesService.shared.processQueuesTimerInterval = 1.0
        createAndPresentViewControllersInQueue()

        let itemsCountBeforeDismiss = KOPresentationQueuesService.shared.itemsCountForQueue(withIndex: 0) ?? 0
        let itemsCountAfterDismiss = itemsCountBeforeDismiss - 1
        viewControllersPresentedInQueue[0].dismiss(animated: false, completion: nil)
        wait(timeout: oldTimeInterval)
        XCTAssertEqual(KOPresentationQueuesService.shared.itemsCountForQueue(withIndex: 0), itemsCountBeforeDismiss)
        wait(timeout: KOPresentationQueuesService.shared.processQueuesTimerInterval - oldTimeInterval)
        XCTAssertEqual(KOPresentationQueuesService.shared.itemsCountForQueue(withIndex: 0), itemsCountAfterDismiss)
    }

    private func createAndPresentViewControllersInQueue() {
        for index in 0..<createdViewControllerToPresentCount {
            viewControllersPresentedInQueue.append(createViewControllerToPresent(withIndex: index))
            viewControllersIdsInQueue.append(KOPresentationQueuesService.shared.presentInQueue(viewControllersPresentedInQueue[index], onViewController: presentingViewController, queueIndex: queueIndex, animated: false, animationCompletion: nil))
        }
    }

    private func removeViewControllerPresentedInQueue(withIndex index: Int) {
        viewControllersPresentedInQueue.remove(at: index)
        viewControllersIdsInQueue.remove(at: index)
    }

    private func checkPresentationQueueForEachItem(startIndex: Int = 0, indexOfPresentedViewController: ((_ : Int) -> Void)? = nil) {
        for index in startIndex..<viewControllersPresentedInQueue.count {
            XCTAssertEqual(KOPresentationQueuesService.shared.itemsCountForQueue(withIndex: queueIndex), viewControllersPresentedInQueue.count - 1 - index)
            checkIsPresented(viewControllerIndex: index)
            indexOfPresentedViewController?(index)
            viewControllersPresentedInQueue[index].dismiss(animated: false, completion: nil)
            wait(timeout: KOPresentationQueuesService.shared.processQueuesTimerInterval)
        }
    }

    private func checkIsPresented(viewControllerIndex: Int) {
        XCTAssertEqual(presentingViewController.presentedViewController, viewControllersPresentedInQueue[viewControllerIndex])
        XCTAssertEqual(viewControllersPresentedInQueue[viewControllerIndex].presentingViewController, presentingViewController)
    }

    private func createViewControllerToPresent(withIndex index: Int) -> ViewControllerSimulator {
        let viewController = ViewControllerSimulator()
        viewController.view.tag = index
        return viewController
    }
}
