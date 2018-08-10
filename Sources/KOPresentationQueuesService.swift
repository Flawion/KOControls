//
//  KOPresentationQueuesService.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 10.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import Foundation
import UIKit

internal class KOPresentationQueueItem : Equatable{
    internal let id : String
    internal let animated: Bool
    internal let completion : (()->Void)?
    
    internal weak var viewControllerPresenting : UIViewController?
    internal var viewControllerToPresent : UIViewController
    
    internal init(viewControllerToPresent : UIViewController, onViewController : UIViewController, animated : Bool, completion : (()->Void)? = nil) {
        self.id = UUID().uuidString
        self.viewControllerToPresent = viewControllerToPresent
        self.viewControllerPresenting = onViewController
        self.animated = animated
        self.completion = completion
    }
    
    static func == (lhs: KOPresentationQueueItem, rhs: KOPresentationQueueItem) -> Bool {
        return lhs.id == rhs.id
    }
}

internal class KOPresentationQueue{
    internal var items : [KOPresentationQueueItem] = []
    internal var currentPresentedItem : KOPresentationQueueItem?
}

public class KOPresentationQueuesService{
    //shared instance
    public static let shared : KOPresentationQueuesService = {
        return KOPresentationQueuesService()
    }()
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
        //delete empty queues
        for idToDelete in idsToDelete{
            deleteQueue(withIndex: idToDelete)
        }
    }
    
    //MARK: Public functions

    //returns "true" if queue can be process
    public func processQueue(withIndex index : Int)->Bool{
        //check if queue exists
        guard let queue = queues[index] else{
            return false
        }
        //check if one of items, already presenting
        if let currentItem = queue.currentPresentedItem{
            guard currentItem.viewControllerToPresent.presentingViewController == nil else{
                return true
            }
        }
        queue.currentPresentedItem = nil
        
        var idsToDelete : [String] = []
        for i in 0..<queue.items.count{
            let item = queue.items[i]
            //check is the viewControllers exists
            guard let vcPresenting = item.viewControllerPresenting, !item.viewControllerToPresent.isBeingPresented else{
                idsToDelete.append(item.id)
                continue
            }
            
            //check is current viewController is in view hierarchy and presents something
            guard vcPresenting.isViewLoaded && vcPresenting.view.window != nil && vcPresenting.presentedViewController == nil else{
                continue
            }
            
            let completionHandler = item.completion
            vcPresenting.present(item.viewControllerToPresent, animated: item.animated, completion:{
                [unowned self] in
                completionHandler?()
                _ = self.processQueue(withIndex: index)
            })
            queue.currentPresentedItem = item

            idsToDelete.append(item.id)
            break
        }
        //delete unnecessary items from queue
        queue.items = queue.items.filter({!idsToDelete.contains($0.id)})
        return !(queue.items.count == 0 && queue.currentPresentedItem == nil)
    }
    
    public func presentInQueue(_ viewControllerToPresent : UIViewController, onViewController : UIViewController, queueIndex : Int, animated: Bool, completion : (()->Void)?)->String{
        //create presentation queue item
        let item = KOPresentationQueueItem(viewControllerToPresent: viewControllerToPresent, onViewController: onViewController, animated: animated, completion: completion)
        
        if queues[queueIndex] == nil{
            queues[queueIndex] = KOPresentationQueue()
        }
        queues[queueIndex]!.items.append(item)
        //force process queue
        _ = processQueue(withIndex: queueIndex)
        
        return item.id
    }
    
    public func removeFromQueue(withIndex index: Int, itemWithId itemId : String, animated: Bool, completion : (()->Void)?){
        //check if queue exists, and item
        guard let queue = queues[index], let itemIndex = queue.items.index(where: {$0.id == itemId}) else{
            return
        }
        
        var forceProcessQueue : Bool = false
        //check if one of items, already presenting
        if let currentPresentedItem = queue.currentPresentedItem, queue.items[itemIndex] == currentPresentedItem{
            if currentPresentedItem.viewControllerToPresent.presentingViewController == nil{
                currentPresentedItem.viewControllerToPresent.dismiss(animated: animated, completion: completion)
            }
            queue.currentPresentedItem = nil
            forceProcessQueue = true
        }
        
        queue.items.remove(at: itemIndex)
        if forceProcessQueue{
            _ = processQueue(withIndex: index)
        }
    }
    
    public func deleteQueue(withIndex index : Int){
        queues.removeValue(forKey: index)
    }
}
