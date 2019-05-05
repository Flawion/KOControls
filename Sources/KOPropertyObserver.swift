//
//  KOPropertyObserver.swift
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

import UIKit

/// Observes a property of type 'Value' from object of type 'Subject'
public class KOPropertyObserver<Subject: NSObject, Value> {
    private let options: NSKeyValueObservingOptions
    private var token: Any?
    
    /// object to observe
    public weak var subject: Subject?
    
    /// Initialize observer
    ///
    /// - Parameters:
    ///   - subject: object to observe
    ///   - propertyPath: keyPath to property of subject to observe
    ///   - propertyChangedEvent: event that will be invoking after property changed
    ///   - options: observing options
    public init(subject: Subject, propertyPath: KeyPath<Subject, Value>, propertyChangedEvent: @escaping (Subject, NSKeyValueObservedChange<Value>) -> Void, options: NSKeyValueObservingOptions = [.new]) {
        self.options = options
        self.subject = subject
       
        token = subject.observe(propertyPath, options: options, changeHandler: propertyChangedEvent)
    }
}
