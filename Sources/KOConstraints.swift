//
//  KOConstraints.swift
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

internal struct KOConstraintsContainer {
    var left: NSLayoutConstraint?
    var top: NSLayoutConstraint?
    var right: NSLayoutConstraint?
    var bottom: NSLayoutConstraint?

    var list: [NSLayoutConstraint] {
        var list: [NSLayoutConstraint] = []
        if let left = left {
            list.append(left)
        }
        if let top = top {
            list.append(top)
        }
        if let right = right {
            list.append(right)
        }
        if let bottom = bottom {
            list.append(bottom)
        }
        return list
    }
}

internal enum KOConstraintsDirections {
    case left
    case top
    case right
    case bottom

    case useForAll
}

internal enum KOConstraintsOperations {
    case equal
    case equalOrLess
    case equalOrGreater
}

final internal class KOOverrideAnchors {
    let left: NSLayoutXAxisAnchor?
    let top: NSLayoutYAxisAnchor?
    let right: NSLayoutXAxisAnchor?
    let bottom: NSLayoutYAxisAnchor?

    init(left: NSLayoutXAxisAnchor? = nil, top: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
    }
}

extension NSLayoutConstraint {
    internal func withPriority(_ priority: Float) -> NSLayoutConstraint {
        return withPriority(UILayoutPriority(priority))
    }

    internal func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

// MARK: Internal extensions
extension UIView {
    //- MARK: Constraints helpers
    // MARK: Private
    private func priority(_ priorities: [KOConstraintsDirections: Float], forDirection direction: KOConstraintsDirections) -> Float {
        if let priority = priorities[.useForAll] {
            return priority
        }
        return priorities[direction] ?? UILayoutPriority.required.rawValue
    }

    private func operation(_ operations: [KOConstraintsDirections: KOConstraintsOperations], forDirection direction: KOConstraintsDirections) -> KOConstraintsOperations {
        if let operations = operations[.useForAll] {
            return operations
        }
        return operations[direction] ?? .equal
    }

    private func createConstraints<Axis>(fromAnchor anchor: NSLayoutAnchor<Axis>, toAnchor: NSLayoutAnchor<Axis>, operation: KOConstraintsOperations, priority: Float, inset: CGFloat) -> NSLayoutConstraint {
        switch operation {
        case .equal:
            return anchor.constraint(equalTo: toAnchor, constant: inset).withPriority(priority)
        case .equalOrGreater:
            return anchor.constraint(greaterThanOrEqualTo: toAnchor, constant: inset).withPriority(priority)
        case .equalOrLess:
            return anchor.constraint(lessThanOrEqualTo: toAnchor, constant: inset).withPriority(priority)
        }
    }

    // MARK: Public
    internal func addAutoLayoutSubview(_ view: UIView, overrideAnchors: KOOverrideAnchors? = nil, toAddConstraints: [KOConstraintsDirections] = [.left, .top, .right, .bottom], insets: UIEdgeInsets = UIEdgeInsets.zero, operations: [KOConstraintsDirections: KOConstraintsOperations] = [:], priorities: [KOConstraintsDirections: Float] = [:]) -> KOConstraintsContainer {

        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        var constraintsContainer = KOConstraintsContainer()
        var constraints: [NSLayoutConstraint] = []
        if toAddConstraints.contains(.left) {
            let constraint = createConstraints(fromAnchor: view.leftAnchor, toAnchor: (overrideAnchors?.left ?? leftAnchor), operation: operation(operations, forDirection: .left), priority: priority(priorities, forDirection: .left), inset: insets.left)
            constraintsContainer.left = constraint
            constraints.append(constraint)
        }
        if toAddConstraints.contains(.top) {
            let constraint = createConstraints(fromAnchor: view.topAnchor, toAnchor: (overrideAnchors?.top ?? topAnchor), operation: operation(operations, forDirection: .top), priority: priority(priorities, forDirection: .top), inset: insets.top)
            constraintsContainer.top = constraint
            constraints.append(constraint)
        }
        if toAddConstraints.contains(.right) {
            let constraint = createConstraints(fromAnchor: view.rightAnchor, toAnchor: (overrideAnchors?.right ?? rightAnchor), operation: operation(operations, forDirection: .right), priority: priority(priorities, forDirection: .right), inset: -insets.right)
            constraintsContainer.right = constraint
            constraints.append(constraint)
        }
        if toAddConstraints.contains(.bottom) {
            let constraint = createConstraints(fromAnchor: view.bottomAnchor, toAnchor: (overrideAnchors?.bottom ?? bottomAnchor), operation: operation(operations, forDirection: .bottom), priority: priority(priorities, forDirection: .bottom), inset: -insets.bottom)
            constraintsContainer.bottom = constraint
            constraints.append(constraint)
        }

        addConstraints(constraints)
        return constraintsContainer
    }

    @available(iOS 11.0, *) internal func addSafeAutoLayoutSubview(_ view: UIView, overrideAnchors: KOOverrideAnchors? = nil, toAddConstraints: [KOConstraintsDirections] = [.left, .top, .right, .bottom], insets: UIEdgeInsets = UIEdgeInsets.zero, operations: [KOConstraintsDirections: KOConstraintsOperations] = [:], priorities: [KOConstraintsDirections: Float] = [:]) -> KOConstraintsContainer {
        return addAutoLayoutSubview(view, overrideAnchors: KOOverrideAnchors(left: overrideAnchors?.left ?? safeAreaLayoutGuide.leftAnchor, top: overrideAnchors?.top ?? safeAreaLayoutGuide.topAnchor, right: overrideAnchors?.right ?? safeAreaLayoutGuide.rightAnchor, bottom: overrideAnchors?.bottom ?? safeAreaLayoutGuide.bottomAnchor), toAddConstraints: toAddConstraints, insets: insets, operations: operations, priorities: priorities)
    }

    internal func fill(withView filingView: UIView?) {
        guard subviews.first != filingView else {
            //nothing changed
            return
        }
        
        //delete old ones
        removeConstraints(constraints)
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        //add new one if need
        guard let filingView = filingView else {
            return
        }
        _ = addAutoLayoutSubview(filingView)
    }
}
