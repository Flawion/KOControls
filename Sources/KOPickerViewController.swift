//
//  KOPickerView.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 03.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

public class KOActionModel{
    public let title : String
    public let action : ()->Void
    
    public init(title : String, action : @escaping ()->Void) {
        self.title = title
        self.action = action
    }
}

public enum KOPickerBarModes {
    case top
    case bottom
    case hidden
}

open class KOPickerBarView : UIView{
    //MARK: - Variables
    private weak var containerView : UIView!
    private weak var containerForCustomView : UIView!
    
    //public
    public private(set) weak var titleLabel : UILabel!

    public var customView : UIView?{
        didSet{
            refreshCustomView()
        }
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
    
    public var defaultLeftViewWidth : CGFloat = 0{
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
    
    public var defaultRightViewWidth : CGFloat = 0{
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
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 100), for: .horizontal)
        containerView.addSubview(titleLabel)
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
        let leftContainerForViewRightConst = leftContainerForView.rightAnchor.constraint(equalTo: titleLabel.leftAnchor)
        let leftContainerForViewBottomtConst = leftContainerForView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        leftViewEdgesConstraintsInset = KOEdgesConstraintsInsets(horizontal: KOHorizontalConstraintsInsets(leftConst: leftContainerForViewLeftConst, rightConst: leftContainerForViewRightConst), vertical: KOVerticalConstraintsInsets(topConst: leftContainerForViewTopConst, bottomConst: leftContainerForViewBottomtConst))
        
        let leftContainerForViewWidthConst = leftContainerForView.widthAnchor.constraint(equalToConstant: defaultLeftViewWidth)
        leftContainerForViewWidthConst.priority = UILayoutPriority(rawValue: 900)
        leftContainerForView.addConstraint(leftContainerForViewWidthConst)
        self.leftContainerForViewWidthConst = leftContainerForViewWidthConst
        
        //for right view
        let rightContainerForViewLeftConst = rightContainerForView.leftAnchor.constraint(equalTo: titleLabel.rightAnchor)
        let rightContainerForViewTopConst = rightContainerForView.topAnchor.constraint(equalTo: containerView.topAnchor)
        let rightContainerForViewRightConst = rightContainerForView.rightAnchor.constraint(equalTo: containerView.rightAnchor)
        let rightContainerForViewBottomConst = rightContainerForView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        rightViewEdgesConstraintsInset = KOEdgesConstraintsInsets(horizontal: KOHorizontalConstraintsInsets(leftConst: rightContainerForViewLeftConst, rightConst: rightContainerForViewRightConst), vertical: KOVerticalConstraintsInsets(topConst: rightContainerForViewTopConst, bottomConst: rightContainerForViewBottomConst))
        
        let rightContainerForViewWidthConst = rightContainerForView.widthAnchor.constraint(equalToConstant: defaultRightViewWidth)
        rightContainerForViewWidthConst.priority = UILayoutPriority(rawValue: 900)
        rightContainerForView.addConstraint(rightContainerForViewWidthConst)
        self.rightContainerForViewWidthConst = rightContainerForViewWidthConst
        
        addConstraints([
            leftContainerForViewLeftConst,
            leftContainerForViewTopConst,
            leftContainerForViewRightConst,
            leftContainerForViewBottomtConst,
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
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

open class KOPickerViewController : UIViewController{
    //MARK: - Variables
    private var allConstraints : [NSLayoutConstraint] = []
    
    //MARK: Content view
    private var pContentView : UIView!
    
    //public
    public weak var contentView : UIView!{
        loadViewIfNeeded()
        return pContentView
    }
    
    public var contentEdgesConstraintsInsets : KOEdgesConstraintsInsets!
    
    open var defaultContentInsets : UIEdgeInsets{
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //MARK: Bar view
    private var pBarView : KOPickerBarView!
    
    //public
    public var barView : KOPickerBarView!{
        loadViewIfNeeded()
        return pBarView
    }

    public var barMode : KOPickerBarModes = .top{
        didSet{
            refreshBarMode()
        }
    }
    
    public var leftBarButtonAction : KOActionModel?{
        didSet{
            refreshLeftBarButtonAction()
        }
    }
    
    public var rightBarButtonAction : KOActionModel?{
        didSet{
            refreshRightBarButtonAction()
        }
    }
    
    //MARK: - Functions
    //MARK: Initialization
    override open func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    private func initialize(){
        initializeBar()
        initializeContentView()
        initializeAppearance()
        refreshBarMode()
    }
    
    private func initializeBar(){
        let barView = KOPickerBarView()
        barView.translatesAutoresizingMaskIntoConstraints = false
        self.pBarView = barView
    }
    
    private func initializeContentView(){
        let contentView = createContentView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        self.pContentView = contentView
    }
    
    private func initializeAppearance(){
        view.backgroundColor = UIColor.white
    }
    
    private func refreshBarMode(){
        guard isViewLoaded else{
            return
        }
        
        //delete old constraints
        if allConstraints.count > 0{
            view.removeConstraints(allConstraints)
            allConstraints = []
        }
        
        //create new one
        let defaultContentInsets = self.defaultContentInsets
        let contentLeftConst : NSLayoutConstraint = pContentView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: defaultContentInsets.left)
        let contentRightConst: NSLayoutConstraint = pContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -defaultContentInsets.right)
        var contentTopConst : NSLayoutConstraint!
        var contentBottomConst : NSLayoutConstraint!
       
        //add or remove bar view
        if barMode != .hidden{
            if pBarView.superview != view{
                pBarView.removeFromSuperview()
                view.addSubview(barView)
            }
        }else{
            pBarView.removeFromSuperview()
        }
        
        //create bar constraints
        switch barMode {
        case .top:
            contentTopConst = pContentView.topAnchor.constraint(equalTo: pBarView.bottomAnchor, constant: defaultContentInsets.top)
            contentBottomConst = pContentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -defaultContentInsets.bottom)
            allConstraints = [pBarView.leftAnchor.constraint(equalTo: view.leftAnchor), pBarView.rightAnchor.constraint(equalTo: view.rightAnchor), pBarView.topAnchor.constraint(equalTo: view.topAnchor), contentLeftConst, contentTopConst, contentRightConst, contentBottomConst]
            view.addConstraints(allConstraints)
       
            
        case .bottom:
            contentTopConst = pContentView.topAnchor.constraint(equalTo: view.topAnchor, constant: defaultContentInsets.top)
            contentBottomConst = pContentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -defaultContentInsets.bottom)
            allConstraints = [pBarView.leftAnchor.constraint(equalTo: view.leftAnchor), pBarView.rightAnchor.constraint(equalTo: view.rightAnchor), pBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor), contentLeftConst, contentTopConst, contentRightConst, contentBottomConst]
            view.addConstraints(allConstraints)
            
        case .hidden:
            contentTopConst = pContentView.topAnchor.constraint(equalTo: view.topAnchor, constant: defaultContentInsets.top)
            contentBottomConst = pContentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -defaultContentInsets.bottom)
            allConstraints = [contentLeftConst, contentTopConst, contentRightConst, contentBottomConst]
            view.addConstraints(allConstraints)
        }
        contentEdgesConstraintsInsets = KOEdgesConstraintsInsets(horizontal: KOHorizontalConstraintsInsets(leftConst: contentLeftConst, rightConst: contentRightConst), vertical: KOVerticalConstraintsInsets(topConst: contentTopConst, bottomConst: contentBottomConst))
    }
    
    private func refreshLeftBarButtonAction(){
        guard let leftBarButtonAction = leftBarButtonAction else{
            barView.leftView = nil
            return
        }
        let leftBarButton = UIButton(type: .system)
        leftBarButton.setTitle(leftBarButtonAction.title, for: .normal)
        leftBarButton.addTarget(self, action: #selector(leftBarButtonClick), for: .touchUpInside)
        barView.leftView = leftBarButton
    }
    
    private func refreshRightBarButtonAction(){
        guard let rightBarButtonAction = rightBarButtonAction else{
            barView.rightView = nil
            return
        }
        let rightBarButton = UIButton(type: .system)
        rightBarButton.setTitle(rightBarButtonAction.title, for: .normal)
        rightBarButton.addTarget(self, action: #selector(rightBarButtonClick), for: .touchUpInside)
        barView.rightView = rightBarButton
    }
    
    @objc private func leftBarButtonClick(){
        leftBarButtonAction?.action()
    }
    
    @objc private func rightBarButtonClick(){
        rightBarButtonAction?.action()
    }
    
    open func createContentView()->UIView{
        //method to overrride by subclasses
        return UIView()
    }
}

open class KODatePickerViewController : KOPickerViewController{
    public private(set) weak var datePicker : UIDatePicker?
    
    override open func createContentView() -> UIView {
        let datePicker = UIDatePicker()
        self.datePicker = datePicker
        return datePicker
    }
}

