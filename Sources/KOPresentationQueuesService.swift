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

public class KOPresentationQueueItem : Equatable{
    public let id : String
    public let animated: Bool
    internal let animationCompletion : (()->Void)?
    
    internal weak var viewControllerPresenting : UIViewController?
    public var viewControllerToPresent : UIViewController
    
    public var isPresented : Bool{
        return viewControllerToPresent.view.window != nil && viewControllerToPresent.presentingViewController != nil
    }
    
    public init(viewControllerToPresent : UIViewController, onViewController : UIViewController, animated : Bool, animationCompletion : (()->Void)? = nil) {
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

public class KOPresentationQueuesService{
    //shared instance
    public static let shared : KOPresentationQueuesService = {
        return KOPresentationQueuesService()
    }()
    
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
    public subscript(queueIndex : Int, itemId : String)->KOPresentationQueueItem? {
        get {
            guard let queue = queues[queueIndex] else{
                return nil
            }
            guard let itemIndex = queue.items.index(where: {$0.id == itemId})  else{
                return nil
            }
            return queue.items[itemIndex]
        }
    }
    
    public func itemsCountForQueue(withIndex index: Int)->Int?{
        return queues[index]?.items.count
    }
    
    public func itemPresentedForQueue(withIndex index : Int)->KOPresentationQueueItem?{
        guard let queue = queues[index], let currentPresentedItem = queue.currentPresentedItem, currentPresentedItem.isPresented else{
            return nil
        }
        return currentPresentedItem
    }
    
    public func itemFromQueue(withIndex index: Int, itemIndex : Int)->KOPresentationQueueItem?{
        guard let queue = queues[index], queue.items.count > itemIndex else{
            return nil
        }
        return queue.items[itemIndex]
    }
    
    //MARK: Presents and processes functions
    //returns "true" if queue isn't empty and can be processed further
    public func processQueue(withIndex index : Int)->Bool{
        //checks if queue exists
        guard let queue = queues[index] else{
            return false
        }
        
        //checks if one of items, already presented
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
            
            //checks is current viewController is loaded and presenting something
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
    
    public func removeFromQueue(withIndex index: Int, itemWithIndex itemIndex : Int){
        guard let queue = queues[index], queue.items.count > itemIndex else{
            return
        }
        queue.items.remove(at: itemIndex)
        queueChangedEvent?(index)
    }
    
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

    public func deleteQueue(withIndex index : Int){
        queues.removeValue(forKey: index)
        queueChangedEvent?(index)
    }
}
