//
//  KODialogBarView.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 13.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

open class KODialogBarView : UIView{
    //MARK: - Variables
    private weak var containerView : UIView!
    private weak var containerForCustomView : UIView!
    
    //public
    public var customView : UIView?{
        didSet{
            refreshCustomView()
        }
    }
    
    
    //MARK: Title views
    private weak var titleContainerView : UIView!
    private var titleLabelInTitleContainerViewConsts : [NSLayoutConstraint] = []
    private var titleLabelInContainerViewConsts : [NSLayoutConstraint] = []
    
    //public
    public private(set) weak var titleLabel : UILabel!
    public private(set) var titleContainerEdgesConstraintsInset : KOEdgesConstraintsInsets!
    
    public var isTitleLabelCentered : Bool = true{
        didSet{
            refreshTitleLabelConstraints()
        }
    }
    
    open var defaultTitleInsets : UIEdgeInsets{
        return UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    }
    
    //MARK: Left view
    private weak var leftContainerForView : UIView!
    private weak var leftContainerForViewWidthConst : NSLayoutConstraint!
    
    //public
    public var leftView : UIView?{
        didSet{
            refreshLeftView()
        }
    }
    
    public var leftViewEdgesConstraintsInset : KOEdgesConstraintsInsets!
    
    open var defaultLeftViewWidth : CGFloat = 0{
        didSet{
            leftContainerForViewWidthConst.constant = defaultLeftViewWidth
            layoutIfNeeded()
        }
    }
    
    //MARK: Right view
    private weak var rightContainerForView : UIView!
    private weak var rightContainerForViewWidthConst : NSLayoutConstraint!
    
    //public
    public var rightView : UIView?{
        didSet{
            refreshRightView()
        }
    }
    
    public var rightViewEdgesConstraintsInset : KOEdgesConstraintsInsets!
    
    open var defaultRightViewWidth : CGFloat = 0{
        didSet{
            rightContainerForViewWidthConst.constant = defaultRightViewWidth
            layoutIfNeeded()
        }
    }
    
    
    //MARK: - Functions
    //MARK: Initialization
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
    
    private func initialize(){
        initializeView()
        initializeContent()
        refreshTitleLabelConstraints()
    }
    
    private func initializeView(){
        //create views
        //create container view
        let containerView = UIView()
        containerView.backgroundColor = UIColor.clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        self.containerView = containerView
        
        //create container for custom View
        let containerForCustomView = UIView()
        containerForCustomView.isHidden = true
        containerForCustomView.backgroundColor = UIColor.clear
        containerForCustomView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerForCustomView)
        self.containerForCustomView = containerForCustomView
        
        //create constraints
        //for container
        addConstraints([
            containerView.leftAnchor.constraint(equalTo: leftAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.rightAnchor.constraint(equalTo: rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        //for container for custom view
        addConstraints([
            containerForCustomView.leftAnchor.constraint(equalTo: leftAnchor),
            containerForCustomView.topAnchor.constraint(equalTo: topAnchor),
            containerForCustomView.rightAnchor.constraint(equalTo: rightAnchor),
            containerForCustomView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    private func initializeContent(){
        //create views
        //create title
        let titleContainerView = UIView()
        titleContainerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleContainerView)
        self.titleContainerView = titleContainerView
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 200), for: .horizontal)
        titleContainerView.addSubview(titleLabel)
        self.titleLabel = titleLabel
        
        //create left container for view
        let leftContainerForView = UIView()
        leftContainerForView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(leftContainerForView)
        self.leftContainerForView = leftContainerForView
        
        //create right container for view
        let rightContainerForView = UIView()
        rightContainerForView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(rightContainerForView)
        self.rightContainerForView = rightContainerForView
        
        //create constraints
        //for left view
        let leftContainerForViewLeftConst = leftContainerForView.leftAnchor.constraint(equalTo: containerView.leftAnchor)
        let leftContainerForViewTopConst = leftContainerForView.topAnchor.constraint(equalTo: containerView.topAnchor)
        let leftContainerForViewRightConst = leftContainerForView.rightAnchor.constraint(equalTo: titleContainerView.leftAnchor)
        let leftContainerForViewBottomtConst = leftContainerForView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        leftViewEdgesConstraintsInset = KOEdgesConstraintsInsets(horizontal: KOHorizontalConstraintsInsets(leftConst: leftContainerForViewLeftConst, rightConst: leftContainerForViewRightConst), vertical: KOVerticalConstraintsInsets(topConst: leftContainerForViewTopConst, bottomConst: leftContainerForViewBottomtConst))
        
        let leftContainerForViewWidthConst = leftContainerForView.widthAnchor.constraint(equalToConstant: defaultLeftViewWidth)
        leftContainerForViewWidthConst.priority = UILayoutPriority(rawValue: 900)
        leftContainerForView.addConstraint(leftContainerForViewWidthConst)
        self.leftContainerForViewWidthConst = leftContainerForViewWidthConst
        
        //for right view
        let rightContainerForViewLeftConst = rightContainerForView.leftAnchor.constraint(equalTo: titleContainerView.rightAnchor)
        let rightContainerForViewTopConst = rightContainerForView.topAnchor.constraint(equalTo: containerView.topAnchor)
        let rightContainerForViewRightConst = rightContainerForView.rightAnchor.constraint(equalTo: containerView.rightAnchor)
        let rightContainerForViewBottomConst = rightContainerForView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        rightViewEdgesConstraintsInset = KOEdgesConstraintsInsets(horizontal: KOHorizontalConstraintsInsets(leftConst: rightContainerForViewLeftConst, rightConst: rightContainerForViewRightConst), vertical: KOVerticalConstraintsInsets(topConst: rightContainerForViewTopConst, bottomConst: rightContainerForViewBottomConst))
        
        let rightContainerForViewWidthConst = rightContainerForView.widthAnchor.constraint(equalToConstant: defaultRightViewWidth)
        rightContainerForViewWidthConst.priority = UILayoutPriority(rawValue: 900)
        rightContainerForView.addConstraint(rightContainerForViewWidthConst)
        self.rightContainerForViewWidthConst = rightContainerForViewWidthConst
        
        //for title container
        let titleContainerTopConst = titleContainerView.topAnchor.constraint(equalTo: containerView.topAnchor)
        let titleContainerBottomConst = titleContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        titleContainerEdgesConstraintsInset = KOEdgesConstraintsInsets(horizontal: KOHorizontalConstraintsInsets(leftConst: leftContainerForViewRightConst, rightConst: rightContainerForViewLeftConst, rightMultipler: 1.0), vertical: KOVerticalConstraintsInsets(topConst: titleContainerTopConst, bottomConst: titleContainerBottomConst))
        titleContainerEdgesConstraintsInset.insets = defaultTitleInsets
        
        addConstraints([
            leftContainerForViewLeftConst,
            leftContainerForViewTopConst,
            leftContainerForViewRightConst,
            leftContainerForViewBottomtConst,
            titleContainerTopConst,
            titleContainerBottomConst,
            rightContainerForViewLeftConst,
            rightContainerForViewTopConst,
            rightContainerForViewRightConst,
            rightContainerForViewBottomConst
            ])
    }
    
    private func refreshCustomView(){
        containerForCustomView.isHidden = customView == nil
        containerForCustomView.fill(withView: customView)
        layoutIfNeeded()
    }
    
    private func refreshTitleLabelConstraints(){
        titleContainerView.removeConstraints(self.titleLabelInTitleContainerViewConsts)
        containerView.removeConstraints(self.titleLabelInContainerViewConsts)
        
        var titleLabelInTitleContainerViewConsts : [NSLayoutConstraint] = []
        var titleLabelInContainerViewConsts : [NSLayoutConstraint] = []
        
        titleLabelInTitleContainerViewConsts.append(contentsOf: [
            titleLabel.topAnchor.constraint(equalTo: titleContainerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor),
            ])
        
        if isTitleLabelCentered{
            titleLabelInTitleContainerViewConsts.append(contentsOf: [
                titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: titleContainerView.leftAnchor),
                titleLabel.rightAnchor.constraint(lessThanOrEqualTo: titleContainerView.rightAnchor)
                ])
            
            let titleLabelCenterConst = titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
            titleLabelCenterConst.priority = UILayoutPriority(rawValue: 180)
            titleLabelInContainerViewConsts.append(titleLabelCenterConst)
        }else{
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
    
    //MARK: Left/Right views
    private func refreshLeftView(){
        leftContainerForView.fill(withView: leftView)
        layoutIfNeeded()
    }
    
    private func refreshRightView(){
        rightContainerForView.fill(withView: rightView)
        layoutIfNeeded()
    }
}
