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
        addToList(&list, ifNotNullConstraint: left)
        addToList(&list, ifNotNullConstraint: top)
        addToList(&list, ifNotNullConstraint: right)
        addToList(&list, ifNotNullConstraint: bottom)
        return list
    }

    private func addToList(_ list: inout [NSLayoutConstraint], ifNotNullConstraint constraint: NSLayoutConstraint?) {
        guard let constraint = constraint else {
            return
        }
        list.append(constraint)
    }
}

internal struct KOOAnchorsContainer {
    var left: NSLayoutXAxisAnchor?
    var top: NSLayoutYAxisAnchor?
    var right: NSLayoutXAxisAnchor?
    var bottom: NSLayoutYAxisAnchor?

    init(left: NSLayoutXAxisAnchor? = nil, top: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
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

extension NSLayoutConstraint {
    internal func withPriority(_ priority: Float) -> NSLayoutConstraint {
        return withPriority(UILayoutPriority(priority))
    }

    internal func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

internal struct KOAddAutoLayoutSubviewSettings {
    var overrideAnchors: KOOAnchorsContainer?
    var toAddConstraints: [KOConstraintsDirections]
    var insets: UIEdgeInsets
    var operations: [KOConstraintsDirections: KOConstraintsOperations]
    var priorities: [KOConstraintsDirections: Float]

    init(overrideAnchors: KOOAnchorsContainer? = nil, toAddConstraints: [KOConstraintsDirections] = [.left, .top, .right, .bottom], insets: UIEdgeInsets = UIEdgeInsets.zero, operations: [KOConstraintsDirections: KOConstraintsOperations] = [:], priorities: [KOConstraintsDirections: Float] = [:]) {
        self.overrideAnchors = overrideAnchors
        self.toAddConstraints = toAddConstraints
        self.insets = insets
        self.operations = operations
        self.priorities = priorities
    }
}

// MARK: Internal extensions, Constraints helpers
extension UIView {

     internal func addAutoLayoutSubview(_ view: UIView, overrideAnchors: KOOAnchorsContainer? = nil, toAddConstraints: [KOConstraintsDirections] = [.left, .top, .right, .bottom]) -> KOConstraintsContainer {
        return addAutoLayoutSubview(view, settings: KOAddAutoLayoutSubviewSettings(overrideAnchors: overrideAnchors, toAddConstraints: toAddConstraints))
    }

    internal func addAutoLayoutSubview(_ view: UIView, settings: KOAddAutoLayoutSubviewSettings = KOAddAutoLayoutSubviewSettings()) -> KOConstraintsContainer {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        let constraintsContainer = createConstraintsContainer(forAddingView: view, settings: settings)
        addConstraints(constraintsContainer.list)
        return constraintsContainer
    }

    private func createConstraintsContainer(forAddingView view: UIView, settings: KOAddAutoLayoutSubviewSettings) -> KOConstraintsContainer {
        var constraintsContainer = KOConstraintsContainer()
        constraintsContainer.left = tryToCreateLeftConstraint(addingView: view, settings: settings)
        constraintsContainer.top = tryToCreateTopConstraint(addingView: view, settings: settings)
        constraintsContainer.right = tryToCreateRightConstraint(addingView: view, settings: settings)
        constraintsContainer.bottom = tryToCreateBottomConstraint(addingView: view, settings: settings)
        return constraintsContainer
    }

    private func tryToCreateLeftConstraint(addingView view: UIView, settings: KOAddAutoLayoutSubviewSettings) -> NSLayoutConstraint? {
        guard settings.toAddConstraints.contains(.left) else {
            return nil
        }
        return createConstraints(fromAnchor: view.leftAnchor, toAnchor: (settings.overrideAnchors?.left ?? leftAnchor), operation: operation(settings.operations, forDirection: .left), priority: priority(settings.priorities, forDirection: .left), inset: settings.insets.left)
    }

    private func tryToCreateTopConstraint(addingView view: UIView, settings: KOAddAutoLayoutSubviewSettings) -> NSLayoutConstraint? {
        guard settings.toAddConstraints.contains(.top) else {
            return nil
        }
        return createConstraints(fromAnchor: view.topAnchor, toAnchor: (settings.overrideAnchors?.top ?? topAnchor), operation: operation(settings.operations, forDirection: .top), priority: priority(settings.priorities, forDirection: .top), inset: settings.insets.top)
    }

    private func tryToCreateRightConstraint(addingView view: UIView, settings: KOAddAutoLayoutSubviewSettings) -> NSLayoutConstraint? {
        guard settings.toAddConstraints.contains(.right) else {
            return nil
        }
        return createConstraints(fromAnchor: view.rightAnchor, toAnchor: (settings.overrideAnchors?.right ?? rightAnchor), operation: operation(settings.operations, forDirection: .right), priority: priority(settings.priorities, forDirection: .right), inset: -settings.insets.right)
    }

    private func tryToCreateBottomConstraint(addingView view: UIView, settings: KOAddAutoLayoutSubviewSettings) -> NSLayoutConstraint? {
        guard settings.toAddConstraints.contains(.bottom) else {
            return nil
        }
        return createConstraints(fromAnchor: view.bottomAnchor, toAnchor: (settings.overrideAnchors?.bottom ?? bottomAnchor), operation: operation(settings.operations, forDirection: .bottom), priority: priority(settings.priorities, forDirection: .bottom), inset: -settings.insets.bottom)
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

    private func operation(_ operations: [KOConstraintsDirections: KOConstraintsOperations], forDirection direction: KOConstraintsDirections) -> KOConstraintsOperations {
        if let operations = operations[.useForAll] {
            return operations
        }
        return operations[direction] ?? .equal
    }

    private func priority(_ priorities: [KOConstraintsDirections: Float], forDirection direction: KOConstraintsDirections) -> Float {
        if let priority = priorities[.useForAll] {
            return priority
        }
        return priorities[direction] ?? UILayoutPriority.required.rawValue
    }

    @available(iOS 11.0, *) internal func addSafeAutoLayoutSubview(_ view: UIView, settings: KOAddAutoLayoutSubviewSettings) -> KOConstraintsContainer {
        var newSettings = settings
        newSettings.overrideAnchors = KOOAnchorsContainer(left: settings.overrideAnchors?.left ?? safeAreaLayoutGuide.leftAnchor,
                                                        top: settings.overrideAnchors?.top ?? safeAreaLayoutGuide.topAnchor,
                                                        right: settings.overrideAnchors?.right ?? safeAreaLayoutGuide.rightAnchor,
                                                        bottom: settings.overrideAnchors?.bottom ?? safeAreaLayoutGuide.bottomAnchor)

        return addAutoLayoutSubview(view, settings: newSettings)
    }

    internal func fill(withView filingView: UIView?) {
        guard subviews.first != filingView else {
            //nothing changed
            return
        }
        
        removeSubviews()

        guard let filingView = filingView else {
            return
        }
        _ = addAutoLayoutSubview(filingView)
    }

    private func removeSubviews() {
        removeConstraints(constraints)
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
}
