//
//  KOPropertyObserver.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 23/10/2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

/// Observes a property of type 'Value' from object of type 'Subject'
public class KOPropertyObserver<Subject : NSObject, Value> {
    private let options : NSKeyValueObservingOptions
    private var token : Any?
    
    /// object to observe
    public weak var subject: Subject?
    
    
    /// Initialize observer
    ///
    /// - Parameters:
    ///   - subject: object to observe
    ///   - propertyPath: keyPath to property of subject to observe
    ///   - propertyChangedEvent: event that will be invoking after property changed
    ///   - options: observing options
    public init(subject: Subject, propertyPath : KeyPath<Subject, Value>, propertyChangedEvent : @escaping (Subject, NSKeyValueObservedChange<Value>)->Void , options : NSKeyValueObservingOptions = [.new]) {
        self.options = options
        self.subject = subject
        
        token = subject.observe(propertyPath, options: options, changeHandler: propertyChangedEvent)
    }
}
