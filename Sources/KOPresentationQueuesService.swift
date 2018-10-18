//
//  KOPresentationQueuesService.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 10.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import Foundation
import UIKit

internal class KOPresentationQueue{
    internal var items : [KOPresentationQueueItem] = []
    internal var currentPresentedItem : KOPresentationQueueItem?
}

/// Item of the KOPresentationQueue
public class KOPresentationQueueItem : Equatable{
    internal let animationCompletion : (()->Void)?
    
    /// Unique item's id
    public let id : String

    /// If presenting should be animated
    public let animated: Bool
    
    /// Presenting viewController
    public weak var viewControllerPresenting : UIViewController?
    
    /// Presented viewController
    public var viewControllerToPresent : UIViewController
    
    /// Returns whether the 'viewControllerToPresent' is currently presented on the screen
    public var isPresented : Bool{
        return viewControllerToPresent.view.window != nil && viewControllerToPresent.presentingViewController != nil
    }
    
    internal init(viewControllerToPresent : UIViewController, onViewController : UIViewController, animated : Bool, animationCompletion : (()->Void)? = nil) {
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


/// A queue of views to present. It presents next viewController after current dismissed.
public class KOPresentationQueuesService{
    /// Shared instance
    public static let shared : KOPresentationQueuesService = {
        return KOPresentationQueuesService()
    }()
    
    /// This event will be invoked after some changes in queue: added/deleted item or delete queue. It takes the queueIndex as the parameter.
    public var queueChangedEvent : ((_ queueIndex : Int)->Void)?
    
    private var queues : [Int : KOPresentationQueue] = [:]
    private var processQueuesTimer : Timer?
    
    private init(){
        startProcessQueuesTimer()
    }
    
    deinit {
        stopProcessQueuesTimer()
    }
    
    private func startProcessQueuesTimer(){
        processQueuesTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(processQueues), userInfo: nil, repeats: true)
    }
    
    private func stopProcessQueuesTimer(){
        processQueuesTimer?.invalidate()
        processQueuesTimer = nil
    }
    
    @objc private func processQueues(){
        var idsToDelete : [Int] = []
        
        //process queues
        for queue in queues{
            if !processQueue(withIndex: queue.key){
                idsToDelete.append(queue.key)
            }
        }
        
        //deletes empty queues
        for idToDelete in idsToDelete{
            deleteQueue(withIndex: idToDelete)
        }
    }
    
    //MARK: - Public functions
    
    /// Returns item of the queue
    ///
    /// - Parameters:
    ///   - queueIndex: queue's index
    ///   - itemId: unique item's id to return
    public subscript(queueIndex : Int, itemId : String)->KOPresentationQueueItem? {
        get {
           return itemFromQueue(withIndex: queueIndex, itemId: itemId)
        }
    }
    
    /// Returns items count in queue
    ///
    /// - Parameter index: queue's index
    public func itemsCountForQueue(withIndex index: Int)->Int?{
        return queues[index]?.items.count
    }
    
    
    /// Returns current presented item for the queue
    ///
    /// - Parameter index: queue's index
    public func itemPresentedForQueue(withIndex index : Int)->KOPresentationQueueItem?{
        guard let queue = queues[index], let currentPresentedItem = queue.currentPresentedItem, currentPresentedItem.isPresented else{
            return nil
        }
        return currentPresentedItem
    }
    
    
    /// Returns item of the queue
    ///
    /// - Parameters:
    ///   - index: queue's index
    ///   - itemIndex: index of item in queue
    public func itemFromQueue(withIndex index: Int, itemIndex : Int)->KOPresentationQueueItem?{
        guard let queue = queues[index], queue.items.count > itemIndex else{
            return nil
        }
        return queue.items[itemIndex]
    }
    
    /// Returns item of the queue
    ///
    /// - Parameters:
    ///   - queueIndex: queue's index
    ///   - itemId: unique item's id to return
    public func itemFromQueue(withIndex index: Int, itemId : String)->KOPresentationQueueItem?{
        guard let queue = queues[index] else{
            return nil
        }
        guard let itemIndex = queue.items.index(where: {$0.id == itemId})  else{
            return nil
        }
        return queue.items[itemIndex]
    }
    
    //MARK: Presents and processes functions

    /// Processes queue to show next item if current one was dismiss
    ///
    /// - Parameter index: queue's index
    /// - Returns: returns "true" if queue isn't empty and can be processed further
    public func processQueue(withIndex index : Int)->Bool{
        //checks if queue exists
        guard let queue = queues[index] else{
            return false
        }
        
        //checks whether one of items, already presented
        if let currentItem = queue.currentPresentedItem{
            guard !currentItem.isPresented else{
                return true
            }
        }
        queue.currentPresentedItem = nil
        
        var idsToDelete : [String] = []
        for queueItem in queue.items{
            //checks if viewControllerPresenting exists and is in the view hierarchy
            guard let viewControllerPresenting = queueItem.viewControllerPresenting, viewControllerPresenting.view.window != nil else{
                idsToDelete.append(queueItem.id)
                continue
            }
            
            //checks if current viewController is loaded and presenting something
            guard viewControllerPresenting.isViewLoaded && viewControllerPresenting.presentedViewController == nil else{
                //try another time, when view will be loaded or isn't presenting anything
                continue
            }
            
            viewControllerPresenting.present(queueItem.viewControllerToPresent, animated: queueItem.animated, completion: queueItem.animationCompletion)
            queue.currentPresentedItem = queueItem
            idsToDelete.append(queueItem.id)
            break
        }
        //delete unnecessary items from queue
        if idsToDelete.count > 0{
            queue.items = queue.items.filter({!idsToDelete.contains($0.id)})
            queueChangedEvent?(index)
        }
        return !(queue.items.count == 0 && queue.currentPresentedItem == nil)
    }
    
    
    /// Creates and adds to the queue KOPresentationQueueItem with the viewControllerToPresent
    ///
    /// - Parameters:
    ///   - viewControllerToPresent: presented viewController
    ///   - onViewController: presenting viewController
    ///   - queueIndex: index's queue
    ///   - animated: if presenting should be animated
    ///   - animationCompletion: completion handler for the animation
    /// - Returns: a unique id of KOPresentationQueueItem
    public func presentInQueue(_ viewControllerToPresent : UIViewController, onViewController : UIViewController, queueIndex : Int, animated: Bool, animationCompletion : (()->Void)?)->String{
        //create presentation queue item
        let item = KOPresentationQueueItem(viewControllerToPresent: viewControllerToPresent, onViewController: onViewController, animated: animated, animationCompletion: animationCompletion)
        
        if queues[queueIndex] == nil{
            queues[queueIndex] = KOPresentationQueue()
        }
        queues[queueIndex]!.items.append(item)
        queueChangedEvent?(queueIndex)
        
        //force process queue
        _ = processQueue(withIndex: queueIndex)
        
        return item.id
    }
    
    //MARK: Removes functions
    
    /// Removes item to present from queue
    ///
    /// - Parameters:
    ///   - index: queue's index
    ///   - itemId: unique item's id
    public func removeFromQueue(withIndex index: Int, itemWithId itemId : String){
        //checks if queue exists, and item
        guard let queue = queues[index] else{
            return
        }
        guard let itemIndex = queue.items.index(where: {$0.id == itemId})  else{
            return
        }
        queue.items.remove(at: itemIndex)
        queueChangedEvent?(index)
    }
    
    /// Removes item to present from queue
    ///
    /// - Parameters:
    ///   - index: queue's index
    ///   - itemIndex: item's index from the queue to delete
    public func removeFromQueue(withIndex index: Int, itemWithIndex itemIndex : Int){
        guard let queue = queues[index], queue.items.count > itemIndex else{
            return
        }
        queue.items.remove(at: itemIndex)
        queueChangedEvent?(index)
    }
    
    /// Removes all items from the queue that will be presenting for the presentingViewController
    ///
    /// - Parameters:
    ///   - index: queue's index
    ///   - presentingViewController: viewController for which will be deleting all viewControllers from the queue, that are want to present on it
    public func removeAllItemsFromQueue(withIndex index: Int, forPresentingViewController presentingViewController : UIViewController){
        guard let queue = queues[index] else{
            return
        }
        
        var idsToDelete : [String] = []
        for queueItem in queue.items{
            if queueItem.viewControllerPresenting == presentingViewController || queueItem.viewControllerPresenting == nil{
                idsToDelete.append(queueItem.id)
            }
        }
        
        //delete items from queue
        queue.items = queue.items.filter({!idsToDelete.contains($0.id)})
        queueChangedEvent?(index)
    }
    
    /// Removes current presented view controller for the queue
    ///
    /// - Parameters:
    ///   - index: queue's index
    ///   - animated: if dismiss should be animated
    ///   - animationCompletion: animation completion handler
    public func removeCurrentVisibleItemForQueue(withIndex index : Int, animated: Bool, animationCompletion : (()->Void)?){
        guard let queue = queues[index], let currentItem = queue.currentPresentedItem else{
            return
        }
        guard currentItem.isPresented else{
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

    /// Delete queue
    ///
    /// - Parameter index: queue's index
    public func deleteQueue(withIndex index : Int){
        queues.removeValue(forKey: index)
        queueChangedEvent?(index)
    }
}
