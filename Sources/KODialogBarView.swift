//
//  KODialogBarView.swift
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

/// Dialog bar
open class KODialogBarView: UIView {
    // MARK: - Variables
    private weak var containerView: UIView!
    private weak var containerForCustomView: UIView!
    
    //public
    
    /// View that can replaces standard bar view
    public var customView: UIView? {
        didSet {
            refreshCustomView()
        }
    }
    
    // MARK: Title views
    private weak var titleContainerView: UIView!
    private var titleLabelInTitleContainerViewConsts: [NSLayoutConstraint] = []
    private var titleLabelInContainerViewConsts: [NSLayoutConstraint] = []
    private var titleContainerVerticalConstraintsInsets: KOVerticalConstraintsInsets!

    //public
    
    /// 'Text' parameter should be changed to match the dialog
    public private(set) weak var titleLabel: UILabel!
    public private(set) var titleContainerEdgesConstraintsInsets: KOEdgesConstraintsInsets!
    
    /// Is title view will be always centered between the left and right views
    public var isTitleLabelCentered: Bool = true {
        didSet {
            refreshTitleLabelConstraints()
        }
    }
    
    open var defaultTitleInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    }
    
    // MARK: Left view
    private weak var leftContainerForView: UIView!
    private weak var leftContainerForViewWidthConst: NSLayoutConstraint!
    private weak var leftContainerForViewRightConst: NSLayoutConstraint!

    //public
    
    /// View positioned at left of titleLabel
    public var leftView: UIView? {
        didSet {
            refreshLeftView()
        }
    }
    
    public var leftViewEdgesConstraintsInset: KOEdgesConstraintsInsets!
    
    /// Width will be considered, if size of the left view can't be calculated
    open var defaultLeftViewContainerWidth: CGFloat = 0 {
        didSet {
            leftContainerForViewWidthConst.constant = defaultLeftViewContainerWidth
            layoutIfNeeded()
        }
    }
    
    // MARK: Right view
    private weak var rightContainerForView: UIView!
    private weak var rightContainerForViewWidthConst: NSLayoutConstraint!
    private weak var rightContainerForViewLeftConst: NSLayoutConstraint!

    //public
    
    /// View positioned at right of titleLabel
    public var rightView: UIView? {
        didSet {
            refreshRightView()
        }
    }
    
    public var rightViewEdgesConstraintsInset: KOEdgesConstraintsInsets!
    
    /// Width will be considered, if size of the right view can't be calculated
    open var defaultRightViewContainerWidth: CGFloat = 0 {
        didSet {
            rightContainerForViewWidthConst.constant = defaultRightViewContainerWidth
            layoutIfNeeded()
        }
    }
    
    // MARK: - Functions
    // MARK: Initialization
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        // initialize views
        initializeContainerView()
        initializeContainerForCustomView()
        initializeTitleContainerView()
        initializeTitleLabel()
        initializeLeftContainerForView()
        initializeRightContainerForView()
        createTitleContainerEdgesConstraintsInsets()
        refreshTitleLabelConstraints()
    }

    private func initializeContainerView() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.clear
        _ = addAutoLayoutSubview(containerView)
        self.containerView = containerView
    }

    private func initializeContainerForCustomView() {
        let containerForCustomView = UIView()
        containerForCustomView.isHidden = true
        containerForCustomView.backgroundColor = UIColor.clear
        _ = addAutoLayoutSubview(containerForCustomView)
        self.containerForCustomView = containerForCustomView
    }

    private func initializeTitleContainerView() {
        let titleContainerView = UIView()
        let titleContainerConstraints = containerView.addAutoLayoutSubview(titleContainerView, toAddConstraints: [.top, .bottom])
        self.titleContainerView = titleContainerView
        self.titleContainerVerticalConstraintsInsets = KOVerticalConstraintsInsets(topConst: titleContainerConstraints.top!, bottomConst: titleContainerConstraints.bottom!)
    }

    private func initializeTitleLabel() {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 200), for: .horizontal)
        titleContainerView.addSubview(titleLabel)
        self.titleLabel = titleLabel
    }

    private func initializeLeftContainerForView() {
        let leftContainerForView = UIView()
        let leftContainerConstraints = containerView.addAutoLayoutSubview(leftContainerForView, overrideAnchors: KOOverrideAnchors(right: titleContainerView.leftAnchor))
        leftContainerForViewRightConst = leftContainerConstraints.right!
        self.leftContainerForView = leftContainerForView

        leftViewEdgesConstraintsInset = KOEdgesConstraintsInsets(horizontal: KOHorizontalConstraintsInsets(leftConst: leftContainerConstraints.left!, rightConst: leftContainerConstraints.right!), vertical: KOVerticalConstraintsInsets(topConst: leftContainerConstraints.top!, bottomConst: leftContainerConstraints.bottom!))

        let leftContainerForViewWidthConst = leftContainerForView.widthAnchor.constraint(equalToConstant: defaultLeftViewContainerWidth).withPriority(900)
        leftContainerForView.addConstraint(leftContainerForViewWidthConst)
        self.leftContainerForViewWidthConst = leftContainerForViewWidthConst
    }

    private func initializeRightContainerForView() {
        let rightContainerForView = UIView()
        let rightContainerConstraints = containerView.addAutoLayoutSubview(rightContainerForView, overrideAnchors: KOOverrideAnchors(left: titleContainerView.rightAnchor))
        rightContainerForViewLeftConst = rightContainerConstraints.left!
        self.rightContainerForView = rightContainerForView

        rightViewEdgesConstraintsInset = KOEdgesConstraintsInsets(horizontal: KOHorizontalConstraintsInsets(leftConst: rightContainerConstraints.left!, rightConst: rightContainerConstraints.right!), vertical: KOVerticalConstraintsInsets(topConst: rightContainerConstraints.top!, bottomConst: rightContainerConstraints.bottom!))

        let rightContainerForViewWidthConst = rightContainerForView.widthAnchor.constraint(equalToConstant: defaultRightViewContainerWidth).withPriority(900)
        rightContainerForView.addConstraint(rightContainerForViewWidthConst)
        self.rightContainerForViewWidthConst = rightContainerForViewWidthConst
    }

    private func createTitleContainerEdgesConstraintsInsets() {
        titleContainerEdgesConstraintsInsets = KOEdgesConstraintsInsets(horizontal: KOHorizontalConstraintsInsets(leftConst: leftContainerForViewRightConst, rightConst: rightContainerForViewLeftConst, rightMultipler: 1.0), vertical: titleContainerVerticalConstraintsInsets)
        titleContainerEdgesConstraintsInsets.insets = defaultTitleInsets
    }

    // MARK: View and custom view
    private func refreshCustomView() {
        containerForCustomView.fill(withView: customView)
        refreshCustomViewVisbility()
        layoutIfNeeded()
    }

    private func refreshCustomViewVisbility() {
        let isCustomViewHidden = customView == nil
        containerForCustomView.isHidden = isCustomViewHidden
        containerView.isHidden = !isCustomViewHidden
    }
    
    private func refreshTitleLabelConstraints() {
        titleContainerView.removeConstraints(self.titleLabelInTitleContainerViewConsts)
        containerView.removeConstraints(self.titleLabelInContainerViewConsts)
        
        var titleLabelInTitleContainerViewConsts: [NSLayoutConstraint] = []
        var titleLabelInContainerViewConsts: [NSLayoutConstraint] = []
        
        titleLabelInTitleContainerViewConsts.append(contentsOf: [
            titleLabel.topAnchor.constraint(equalTo: titleContainerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor)
            ])
        
        if isTitleLabelCentered {
            titleLabelInTitleContainerViewConsts.append(contentsOf: [
                titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: titleContainerView.leftAnchor),
                titleLabel.rightAnchor.constraint(lessThanOrEqualTo: titleContainerView.rightAnchor)
                ])
            
            let titleLabelCenterConst = titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
            titleLabelCenterConst.priority = UILayoutPriority(rawValue: 180)
            titleLabelInContainerViewConsts.append(titleLabelCenterConst)
        } else {
            titleLabelInTitleContainerViewConsts.append(contentsOf: [
                titleLabel.leftAnchor.constraint(equalTo: titleContainerView.leftAnchor),
                titleLabel.rightAnchor.constraint(equalTo: titleContainerView.rightAnchor)
                ])
        }
        
        titleContainerView.addConstraints(titleLabelInTitleContainerViewConsts)
        containerView.addConstraints(titleLabelInContainerViewConsts)
        self.titleLabelInTitleContainerViewConsts = titleLabelInTitleContainerViewConsts
        self.titleLabelInContainerViewConsts = titleLabelInContainerViewConsts
    }
    
    // MARK: Left/Right views
    private func refreshLeftView() {
        leftContainerForView.fill(withView: leftView)
        layoutIfNeeded()
    }
    
    private func refreshRightView() {
        rightContainerForView.fill(withView: rightView)
        layoutIfNeeded()
    }
}
