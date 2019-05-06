//
//  KOPresentationQueuesService.swift
//  KOControls
//
//  Copyright (c) 2018 Kuba Ostrowski
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

import Foundation
import UIKit

internal class KOPresentationQueue {
    internal var items: [KOPresentationQueueItem] = []
    internal var currentPresentedItem: KOPresentationQueueItem?

    internal var isEmpty: Bool {
        return items.count == 0 && currentPresentedItem == nil
    }

    internal var isItemAlreadyPresented: Bool {
        return currentPresentedItem?.isPresented ?? false
    }
}

/// Item of the KOPresentationQueue
public class KOPresentationQueueItem: Equatable {
    internal let animationCompletion: (() -> Void)?
    
    public let id: String
    public let animated: Bool
    public weak var viewControllerPresenting: UIViewController?
    public var viewControllerToPresent: UIViewController
    
    /// Returns whether the 'viewControllerToPresent' is currently presented on the screen
    public var isPresented: Bool {
        return viewControllerToPresent.view.window != nil && viewControllerToPresent.presentingViewController != nil
    }

    public var isReadyToPresent: Bool {
        guard let viewControllerPresenting = viewControllerPresenting else {
            return false
        }
        return viewControllerPresenting.isViewLoaded && viewControllerPresenting.presentedViewController == nil
    }

    public var isInvalid: Bool {
        return viewControllerPresenting?.view.window == nil
    }
    
    internal init(viewControllerToPresent: UIViewController, onViewController: UIViewController, animated: Bool, animationCompletion: (() -> Void)? = nil) {
        self.id = UUID().uuidString
        self.viewControllerToPresent = viewControllerToPresent
        self.viewControllerPresenting = onViewController
        self.animated = animated
        self.animationCompletion = animationCompletion
    }
    
    public static func == (lhs: KOPresentationQueueItem, rhs: KOPresentationQueueItem) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Service manages the queues of views to present. It presents next viewController after current dismissed for queue.
public class KOPresentationQueuesService {
    // MARK: - Variables
    private var queues: [Int: KOPresentationQueue] = [:]
    private var processQueuesTimer: Timer?
    
    public static let shared: KOPresentationQueuesService = {
        return KOPresentationQueuesService()
    }()
    
    /// This event will be invoked after some changes in queue: added/deleted item or delete queue. It takes the queueIndex as the parameter.
    public var queueChangedEvent: ((_ queueIndex: Int) -> Void)?
    
    /// Timer interval between processing the queues
    public var processQueuesTimerInterval: TimeInterval = 0.1 {
        didSet {
            refreshProcessQueuesTimer()
        }
    }
  
    // MARK: - Functions
    private init() {
        startProcessQueuesTimer()
    }
    
    deinit {
        stopProcessQueuesTimer()
    }
    
    private func refreshProcessQueuesTimer() {
        stopProcessQueuesTimer()
        startProcessQueuesTimer()
    }
    
    private func startProcessQueuesTimer() {
        processQueuesTimer = Timer.scheduledTimer(timeInterval: processQueuesTimerInterval, target: self, selector: #selector(processQueues), userInfo: nil, repeats: true)
    }
    
    private func stopProcessQueuesTimer() {
        processQueuesTimer?.invalidate()
        processQueuesTimer = nil
    }
    
    @objc private func processQueues() {
        var idsToDelete: [Int] = []
        
        //process queues
        for queue in queues {
            if !processQueue(withIndex: queue.key) {
                idsToDelete.append(queue.key)
            }
        }
        
        //deletes empty queues
        for idToDelete in idsToDelete {
            deleteQueue(withIndex: idToDelete)
        }
    }

    // MARK: Presents and processes functions

    /// Creates and adds to the queue KOPresentationQueueItem with the viewControllerToPresent
    ///
    /// - Parameters:
    ///   - viewControllerToPresent: presented viewController
    ///   - onViewController: presenting viewController
    ///   - queueIndex: index's queue
    ///   - animated: if presenting should be animated
    ///   - animationCompletion: completion handler for the animation
    /// - Returns: a unique id of KOPresentationQueueItem
    public func presentInQueue(_ viewControllerToPresent: UIViewController, onViewController: UIViewController, queueIndex: Int, animated: Bool, animationCompletion: (() -> Void)?) -> String {

        let item = KOPresentationQueueItem(viewControllerToPresent: viewControllerToPresent, onViewController: onViewController, animated: animated, animationCompletion: animationCompletion)

        if queues[queueIndex] == nil {
            queues[queueIndex] = KOPresentationQueue()
        }
        queues[queueIndex]!.items.append(item)
        queueChangedEvent?(queueIndex)

        //force process queue
        _ = processQueue(withIndex: queueIndex)

        return item.id
    }

    /// Processes queue to show next item if current one was dismiss
    ///
    /// - Parameter index: queue's index
    /// - Returns: returns "true" if queue isn't empty and can be processed further
    public func processQueue(withIndex queueIndex: Int) -> Bool {
        guard let queue = queues[queueIndex] else {
            return false
        }

        return processQueue(queue, withIndex: queueIndex)
    }

    private func processQueue(_ queue: KOPresentationQueue, withIndex queueIndex: Int) -> Bool {
        guard !queue.isItemAlreadyPresented else {
            return true
        }
        queue.currentPresentedItem = nil
        removeInvalidItems(fromQueue: queue, withIndex: queueIndex)
        presentFirstReadyItem(fromQueue: queue, withIndex: queueIndex)
        return !queue.isEmpty
    }

    private func removeInvalidItems(fromQueue queue: KOPresentationQueue, withIndex queueIndex: Int) {
        let idsToDelete: [String] = queue.items.filter({ $0.isInvalid }).map({ $0.id })
        removeFromQueue(queue, withIndex: queueIndex, itemsWithIds: idsToDelete)
    }

    private func presentFirstReadyItem(fromQueue queue: KOPresentationQueue, withIndex queueIndex: Int) {
        if let queueItem = queue.items.first(where: { $0.isReadyToPresent }) {
            presentQueueItem(queueItem, fromQueue: queue, withIndex: queueIndex)
        }
    }

    private func presentQueueItem(_ queueItem: KOPresentationQueueItem, fromQueue queue: KOPresentationQueue, withIndex queueIndex: Int) {
        guard let viewControllerPresenting = queueItem.viewControllerPresenting else {
            return
        }
        viewControllerPresenting.present(queueItem.viewControllerToPresent, animated: queueItem.animated, completion: queueItem.animationCompletion)
        queue.currentPresentedItem = queueItem
        removeFromQueue(withIndex: queueIndex, itemWithId: queueItem.id)
    }

    // MARK: Indexing
    public subscript(queueIndex: Int, itemId: String) -> KOPresentationQueueItem? {
        return itemFromQueue(withIndex: queueIndex, itemId: itemId)
    }

    public func itemsCountForQueue(withIndex index: Int) -> Int? {
        return queues[index]?.items.count
    }

    public func itemPresentedForQueue(withIndex index: Int) -> KOPresentationQueueItem? {
        guard let queue = queues[index], let currentPresentedItem = queue.currentPresentedItem, currentPresentedItem.isPresented else {
            return nil
        }
        return currentPresentedItem
    }

    public func itemFromQueue(withIndex index: Int, itemIndex: Int) -> KOPresentationQueueItem? {
        guard let queue = queues[index], queue.items.count > itemIndex else {
            return nil
        }
        return queue.items[itemIndex]
    }

    public func itemFromQueue(withIndex index: Int, itemId: String) -> KOPresentationQueueItem? {
        guard let queue = queues[index] else {
            return nil
        }
        guard let itemIndex = queue.items.firstIndex(where: {$0.id == itemId}) else {
            return nil
        }
        return queue.items[itemIndex]
    }

    // MARK: Removing items and queues
    public func removeFromQueue(withIndex index: Int, itemWithId itemId: String) {
        //checks if queue exists, and item
        guard let queue = queues[index] else {
            return
        }
        guard let itemIndex = queue.items.firstIndex(where: {$0.id == itemId}) else {
            return
        }
        removeFromQueue(queue, withIndex: index, itemWithIndex: itemIndex)
    }

    public func removeFromQueue(withIndex index: Int, itemWithIndex itemIndex: Int) {
        guard let queue = queues[index] else {
            return
        }
        removeFromQueue(queue, withIndex: index, itemWithIndex: itemIndex)
    }

    public func removeAllItemsFromQueue(withIndex index: Int, forPresentingViewController presentingViewController: UIViewController) {
        guard let queue = queues[index] else {
            return
        }
        
        var idsToDelete: [String] = []
        for queueItem in queue.items {
            if queueItem.viewControllerPresenting == presentingViewController || queueItem.viewControllerPresenting == nil {
                idsToDelete.append(queueItem.id)
            }
        }

        removeFromQueue(queue, withIndex: index, itemsWithIds: idsToDelete)
    }
    
    public func removeCurrentVisibleItemForQueue(withIndex index: Int, animated: Bool, animationCompletion: (() -> Void)?) {
        guard let queue = queues[index], let currentItem = queue.currentPresentedItem else {
            return
        }
        guard currentItem.isPresented else {
            queue.currentPresentedItem = nil
            _ = processQueue(withIndex: index)
            return
        }
        
        currentItem.viewControllerToPresent.dismiss(animated: animated, completion: {
            [unowned self] in
            _ = self.processQueue(withIndex: index)
            animationCompletion?()
        })
    }

    public func deleteQueue(withIndex index: Int) {
        queues.removeValue(forKey: index)
        queueChangedEvent?(index)
    }

    private func removeFromQueue(_ queue: KOPresentationQueue, withIndex queueIndex: Int, itemsWithIds idsToDelete: [String]) {
        guard idsToDelete.count > 0 else {
            return
        }
        queue.items = queue.items.filter({!idsToDelete.contains($0.id)})
        queueChangedEvent?(queueIndex)
    }

    private func removeFromQueue(_ queue: KOPresentationQueue, withIndex queueIndex: Int, itemWithIndex itemIndex: Int) {
        guard queue.items.count > itemIndex else {
            return
        }
        queue.items.remove(at: itemIndex)
        queueChangedEvent?(queueIndex)
    }
}
