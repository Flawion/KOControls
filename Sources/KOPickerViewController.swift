//
//  KOPickerView.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 03.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

public enum KOPickerBarModes {
    case top
    case bottom
    case hidden
}

open class KOPickerBarView : UIView{
    //MARK: - Variables
    private weak var containerView : UIView!
    private weak var containerForCustomView : UIView!
    
    private weak var leftContainerForView : UIView!
    private weak var leftContainerForViewWidthConst : NSLayoutConstraint!
    
    private weak var rightContainerForView : UIView!
    private weak var rightContainerForViewWidthConst : NSLayoutConstraint!
    
    //public
    public private(set) weak var titleLabel : UILabel!

    public var customView : UIView?{
        didSet{
            refreshCustomView()
        }
    }
    
    public var leftView : UIView?{
        didSet{
            refreshLeftView()
        }
    }
    
    public var leftViewWidth : CGFloat = 0{
        didSet{
            leftContainerForViewWidthConst.constant = leftViewWidth
            layoutIfNeeded()
        }
    }
    
    public var rightView : UIView?{
        didSet{
            refreshRightView()
        }
    }
    
    public var rightViewWidth : CGFloat = 0{
        didSet{
            rightContainerForViewWidthConst.constant = rightViewWidth
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
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        self.containerView = containerView
        
        //create container for custom View
        let containerForCustomView = UIView()
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
        titleLabel.backgroundColor = UIColor.red
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
        let leftContainerForViewWidthConst = leftContainerForView.widthAnchor.constraint(equalToConstant: leftViewWidth)
        leftContainerForViewWidthConst.priority = UILayoutPriority(rawValue: 900)
        leftContainerForView.addConstraint(leftContainerForViewWidthConst)
        self.leftContainerForViewWidthConst = leftContainerForViewWidthConst
        
        let rightContainerForViewWidthConst = rightContainerForView.widthAnchor.constraint(equalToConstant: rightViewWidth)
        rightContainerForViewWidthConst.priority = UILayoutPriority(rawValue: 900)
        rightContainerForView.addConstraint(rightContainerForViewWidthConst)
        self.rightContainerForViewWidthConst = rightContainerForViewWidthConst
        
        addConstraints([
            leftContainerForView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            leftContainerForView.topAnchor.constraint(equalTo: containerView.topAnchor),
            leftContainerForView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            titleLabel.leftAnchor.constraint(equalTo: leftContainerForView.rightAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightContainerForView.leftAnchor),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            rightContainerForView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            rightContainerForView.topAnchor.constraint(equalTo: containerView.topAnchor),
            rightContainerForView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
    }
    
    private func refreshCustomView(){
        containerForCustomView.fill(withView: customView)
        layoutIfNeeded()
    }
    
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
    private weak var contentTopConst : NSLayoutConstraint!
    private weak var contentLeftConst : NSLayoutConstraint!
    private weak var contentRightConst : NSLayoutConstraint!
    private weak var contentBottomConst : NSLayoutConstraint!
    
    //public
    public private(set) var barView : KOPickerBarView!
    public private(set) weak var contentView : UIView!
    
    public var barMode : KOPickerBarModes = .top{
        didSet{
            refreshBarMode()
        }
    }
    
    open var defaultContentInsets : UIEdgeInsets{
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
        self.barView = barView
    }
    
    private func initializeContentView(){
        let contentView = createContentView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        self.contentView = contentView
    }
    
    private func initializeAppearance(){
        view.backgroundColor = UIColor.white
    }
    
    private func refreshBarMode(){
        //delete old constraints
        if allConstraints.count > 0{
            view.removeConstraints(allConstraints)
            allConstraints = []
        }
        
        //create new one
        let defaultContentInsets = self.defaultContentInsets
        let contentLeftConst : NSLayoutConstraint = contentView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: defaultContentInsets.left)
        let contentRightConst: NSLayoutConstraint = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -defaultContentInsets.right)
        var contentTopConst : NSLayoutConstraint!
        var contentBottomConst : NSLayoutConstraint!
       
        //add or remove bar view
        if barMode != .hidden{
            if barView.superview != view{
                barView.removeFromSuperview()
                view.addSubview(barView)
            }
        }else{
            barView.removeFromSuperview()
        }
        
        //create bar constraints
        switch barMode {
        case .top:
            contentTopConst = contentView.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: defaultContentInsets.top)
            contentBottomConst = contentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -defaultContentInsets.bottom)
            allConstraints = [barView.leftAnchor.constraint(equalTo: view.leftAnchor), barView.rightAnchor.constraint(equalTo: view.rightAnchor), barView.topAnchor.constraint(equalTo: view.topAnchor), contentLeftConst, contentTopConst, contentRightConst, contentBottomConst]
            view.addConstraints(allConstraints)
       
            
        case .bottom:
            contentTopConst = contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: defaultContentInsets.top)
            contentBottomConst = contentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -defaultContentInsets.bottom)
            allConstraints = [barView.leftAnchor.constraint(equalTo: view.leftAnchor), barView.rightAnchor.constraint(equalTo: view.rightAnchor), barView.bottomAnchor.constraint(equalTo: view.bottomAnchor), contentLeftConst, contentTopConst, contentRightConst, contentBottomConst]
            view.addConstraints(allConstraints)
            
        case .hidden:
            contentTopConst = contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: defaultContentInsets.top)
            contentBottomConst = contentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -defaultContentInsets.bottom)
            allConstraints = [contentLeftConst, contentTopConst, contentRightConst, contentBottomConst]
            view.addConstraints(allConstraints)
        }
        
        self.contentLeftConst = contentLeftConst
        self.contentTopConst = contentTopConst
        self.contentRightConst = contentRightConst
        self.contentBottomConst = contentBottomConst
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

