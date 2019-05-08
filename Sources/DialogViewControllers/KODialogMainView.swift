//
//  KODialogMainView.swift
//  KOControls
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

public final class KODialogMainView: UIView {
     // MARK: - Variables

    // MARK: Content view
    private weak var contentWidthConst: NSLayoutConstraint!
    private weak var contentHeightConst: NSLayoutConstraint!

    //public
    public private(set) weak var contentView: UIView!
    public let defaultContentInsets: UIEdgeInsets

    public var contentEdgesConstraintsInsets: KOEdgesConstraintsInsets!

    /// It should be setted if the height of the view can't be calculated from the constraints or intrinsic content size. If mainViewVerticalAlignment == .fill you dont need to set it.
    public var contentHeight: CGFloat? = nil {
        didSet {
            refreshContentHeight()
        }
    }

    /// It should be setted if the width of the view can't be calculated from the constraints or intrinsic content size. If mainViewHorizontalAlignment == .fill you dont need to set it.
    public var contentWidth: CGFloat? = nil {
        didSet {
            refreshContentWidth()
        }
    }

    // MARK: Bar view
    private var pBarView: KODialogBarView!

    //public

    /// BarView title should be changed by assign text to the 'barView.titleLabel.text'
    public var barView: KODialogBarView! {
        return pBarView
    }

    /// Mode of 'barView' visibility
    public var barMode: KODialogBarModes = .top {
        didSet {
            refreshBarMode()
        }
    }

    // MARK: Background visual effect view
    private var backgroundVisualEffectConsts: [NSLayoutConstraint] = []

    //public

    /// To get the background with the visual effect you have to set the parameter 'backgroundVisualEffect', if you want to have the rounded corners at the dialog you have to set clipBounds at 'mainView'
    public private(set) weak var backgroundVisualEffectView: UIVisualEffectView?

    /// This parameter can be setted to create background with the visual effect like blur, after setting it background of the main view will be changed to clear
    public var backgroundVisualEffect: UIVisualEffect? {
        didSet {
            refreshBackgroundVisualEffect()
        }
    }

    private var allConstraints: [NSLayoutConstraint] = []

    private var safeAnchorsContainer: KOOAnchorsContainer {
        var leftAnchor: NSLayoutXAxisAnchor = self.leftAnchor
        var topAnchor: NSLayoutYAxisAnchor = self.topAnchor
        var rightAnchor: NSLayoutXAxisAnchor = self.rightAnchor
        var bottomAnchor: NSLayoutYAxisAnchor = self.bottomAnchor

        if #available(iOS 11.0, *) {
            leftAnchor = safeAreaLayoutGuide.leftAnchor
            topAnchor = safeAreaLayoutGuide.topAnchor
            rightAnchor = safeAreaLayoutGuide.rightAnchor
            bottomAnchor = safeAreaLayoutGuide.bottomAnchor
        }
        return KOOAnchorsContainer(left: leftAnchor, top: topAnchor, right: rightAnchor, bottom: bottomAnchor)
    }

    // MARK: - Functions
    // MARK: Initialization
    public init(contentView: UIView, withInsets contentInsets: UIEdgeInsets) {
        self.contentView = contentView
        self.defaultContentInsets = contentInsets
        
        super.init(frame: CGRect.zero)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("this view can be only used with the KODialogViewController")
    }

    private func initialize() {
        initializeBarView()
        initializeContentView()
        refreshBarMode()
        refreshBackgroundVisualEffect()
    }

    private func initializeBarView() {
        let barView = KODialogBarView()
        barView.translatesAutoresizingMaskIntoConstraints = false
        self.pBarView = barView
    }

    private func initializeContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        refreshContentWidth()
        refreshContentHeight()
    }

    // MARK: Content view
    private func refreshContentWidth() {
        guard let contentWidth = contentWidth else {
            removeContentWidthConstraint()
            return
        }
        refreshContentWidthConstraint(constant: contentWidth)
    }

    private func removeContentWidthConstraint() {
        guard let contentWidthConst = self.contentWidthConst else {
            return
        }
        contentView.removeConstraint(contentWidthConst)
    }

    private func refreshContentWidthConstraint(constant: CGFloat) {
        guard let contentWidthConst =  self.contentWidthConst else {
            createContentWidthConstraint(constant: constant)
            return
        }
        contentWidthConst.constant = constant
    }

    private func createContentWidthConstraint(constant: CGFloat) {
        let contentWidthConst = contentView.widthAnchor.constraint(equalToConstant: constant)
        contentView.addConstraint(contentWidthConst)
        self.contentWidthConst = contentWidthConst
    }

    private func refreshContentHeight() {
        guard let contentHeight = self.contentHeight else {
            removeContentHeightConstraint()
            return
        }
        refreshContentHeightConstraint(constant: contentHeight)
    }

    private func removeContentHeightConstraint() {
        guard let contentHeightConst = self.contentHeightConst else {
            return
        }
        contentView.removeConstraint(contentHeightConst)
    }

    private func refreshContentHeightConstraint(constant: CGFloat) {
        guard let contentHeightConst = self.contentHeightConst else {
            createContentHeightConstraint(constant: constant)
            return
        }
        contentHeightConst.constant = constant
    }

    private func createContentHeightConstraint(constant: CGFloat) {
        let contentHeightConst = contentView.heightAnchor.constraint(equalToConstant: constant)
        contentView.addConstraint(contentHeightConst)
        self.contentHeightConst = contentHeightConst
    }

    // MARK: Background visual effect
    private func refreshBackgroundVisualEffect() {
        guard let backgroundVisualEffect = backgroundVisualEffect else {
            removeBackgroundVisualEffectView()
            return
        }
        addBackgroundVisualEffectView(forEffect: backgroundVisualEffect)
    }

    private func removeBackgroundVisualEffectView() {
        guard let backgroundVisualEffectView = self.backgroundVisualEffectView else {
            return
        }
        backgroundVisualEffectView.removeFromSuperview()
        removeConstraints(backgroundVisualEffectConsts)
        backgroundVisualEffectConsts = []
        backgroundColor = UIColor.white
    }

    private func addBackgroundVisualEffectView(forEffect backgroundVisualEffect: UIVisualEffect) {
        let backgroundVisualEffectView = UIVisualEffectView(effect: backgroundVisualEffect)
        backgroundVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(backgroundVisualEffectView, belowSubview: contentView)
        self.backgroundVisualEffectView = backgroundVisualEffectView

        backgroundVisualEffectConsts = [
            backgroundVisualEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundVisualEffectView.topAnchor.constraint(equalTo: topAnchor),
            backgroundVisualEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            backgroundVisualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        addConstraints(backgroundVisualEffectConsts)
        backgroundColor = UIColor.clear
    }

    // MARK: Bar view
    private func refreshBarMode() {
        deleteBarConstraints()
        addOrRemoveBarView()
        createBarConstraints()
    }

    private func deleteBarConstraints() {
        if allConstraints.count > 0 {
            removeConstraints(allConstraints)
            allConstraints = []
        }
    }

    private func addOrRemoveBarView() {
        if barMode != .hidden {
            addBarView()
        } else {
            pBarView.removeFromSuperview()
        }
    }

    private func addBarView() {
        guard pBarView.superview != self else {
            return
        }
        pBarView.removeFromSuperview()
        addSubview(barView)
    }

    private func createBarConstraints() {
        let mainViewAnchors: KOOAnchorsContainer = self.safeAnchorsContainer
        let defaultContentInsets = self.defaultContentInsets
        let contentLeftConstraint: NSLayoutConstraint = contentView.leftAnchor.constraint(equalTo: mainViewAnchors.left!, constant: defaultContentInsets.left)
        let contentRightConstraint: NSLayoutConstraint = contentView.rightAnchor.constraint(equalTo: mainViewAnchors.right!, constant: -defaultContentInsets.right)
        var contentViewConstraints = KOConstraintsContainer(left: contentLeftConstraint, top: nil, right: contentRightConstraint, bottom: nil)

        switch barMode {
        case .top:
            contentViewConstraints.top = contentView.topAnchor.constraint(equalTo: pBarView.bottomAnchor, constant: defaultContentInsets.top)
            contentViewConstraints.bottom = contentView.bottomAnchor.constraint(equalTo: mainViewAnchors.bottom!, constant: -defaultContentInsets.bottom)
            allConstraints = [pBarView.leftAnchor.constraint(equalTo: mainViewAnchors.left!), pBarView.rightAnchor.constraint(equalTo: mainViewAnchors.right!), pBarView.topAnchor.constraint(equalTo: mainViewAnchors.top!), contentViewConstraints.left!, contentViewConstraints.top!, contentViewConstraints.right!, contentViewConstraints.bottom!]
            addConstraints(allConstraints)

        case .bottom:
            contentViewConstraints.top = contentView.topAnchor.constraint(equalTo: mainViewAnchors.top!, constant: defaultContentInsets.top)
            contentViewConstraints.bottom = contentView.bottomAnchor.constraint(equalTo: pBarView.topAnchor, constant: -defaultContentInsets.bottom)
            allConstraints = [pBarView.leftAnchor.constraint(equalTo: mainViewAnchors.left!), pBarView.rightAnchor.constraint(equalTo: mainViewAnchors.right!), pBarView.bottomAnchor.constraint(equalTo: mainViewAnchors.bottom!), contentViewConstraints.left!, contentViewConstraints.top!, contentViewConstraints.right!, contentViewConstraints.bottom!]
            addConstraints(allConstraints)

        case .hidden:
            contentViewConstraints.top = contentView.topAnchor.constraint(equalTo: mainViewAnchors.top!, constant: defaultContentInsets.top)
            contentViewConstraints.bottom = contentView.bottomAnchor.constraint(equalTo: mainViewAnchors.bottom!, constant: -defaultContentInsets.bottom)
            allConstraints = [contentViewConstraints.left!, contentViewConstraints.top!, contentViewConstraints.right!, contentViewConstraints.bottom!]
            addConstraints(allConstraints)
        }
        refreshContentEdgesConstraintsInsets(constraints: contentViewConstraints)
    }

    private func refreshContentEdgesConstraintsInsets(constraints: KOConstraintsContainer) {
        contentEdgesConstraintsInsets = KOEdgesConstraintsInsets(horizontal: KOHorizontalConstraintsInsets(leftConst: constraints.left!, rightConst: constraints.right!), vertical: KOVerticalConstraintsInsets(topConst: constraints.top!, bottomConst: constraints.bottom!))
    }
}
