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
    private weak var leftButtonsPanel : UIStackView!
    private weak var rightButtonsPanel : UIStackView!
    
    //public
    public private(set) weak var titleLabel : UILabel!

    public var customView : UIView?{
        didSet{
            refreshCustomView()
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
            containerView.leftAnchor.constraint(equalTo: containerForCustomView.leftAnchor),
            containerView.topAnchor.constraint(equalTo: containerForCustomView.topAnchor),
            containerView.rightAnchor.constraint(equalTo: containerForCustomView.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: containerForCustomView.bottomAnchor)
            ])
        
        //for container for custom view
        addConstraints([
            containerForCustomView.leftAnchor.constraint(equalTo: containerForCustomView.leftAnchor),
            containerForCustomView.topAnchor.constraint(equalTo: containerForCustomView.topAnchor),
            containerForCustomView.rightAnchor.constraint(equalTo: containerForCustomView.rightAnchor),
            containerForCustomView.bottomAnchor.constraint(equalTo: containerForCustomView.bottomAnchor)
            ])
    }
    
    private func initializeContent(){
        //create views
        //create title
        let titleLabel = UILabel()
        titleLabel.backgroundColor = UIColor.red
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 900), for: .horizontal)
        //titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        addSubview(titleLabel)
        self.titleLabel = titleLabel
        
        //create left buttons panel
        let leftButtonsPanel = UIStackView()
        //leftButtonsPanel.setContentHuggingPriority(UILayoutPriority(rawValue: 100), for: .horizontal)
        leftButtonsPanel.axis = .horizontal
        leftButtonsPanel.distribution = .fillProportionally
        leftButtonsPanel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftButtonsPanel)
        self.leftButtonsPanel = leftButtonsPanel
        
        let leftButton = UIButton(type: .system)
        //leftButton.setContentHuggingPriority(UILayoutPriority(rawValue: 100), for: .horizontal)
        leftButton.setTitle("left", for: .normal)
        leftButtonsPanel.addArrangedSubview(leftButton)
       
        
        let leftButton2 = UIButton(type: .system)
       // leftButton2.setContentHuggingPriority(UILayoutPriority(rawValue: 100), for: .horizontal)
        leftButton2.setTitle("left2", for: .normal)
        leftButtonsPanel.addArrangedSubview(leftButton2)
        
        
        //create right buttons panel
        let rightButtonsPanel = UIStackView()
        rightButtonsPanel.axis = .horizontal
        rightButtonsPanel.distribution = .fillProportionally
        rightButtonsPanel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightButtonsPanel)
        self.rightButtonsPanel = rightButtonsPanel
        
        let rightButton = UIButton(type: .system)
        rightButton.setTitle("right", for: .normal)
        rightButtonsPanel.addArrangedSubview(rightButton)
        
        //create constraints
        addConstraints([
            leftButtonsPanel.leftAnchor.constraint(equalTo: leftAnchor),
            leftButtonsPanel.topAnchor.constraint(equalTo: topAnchor),
            leftButtonsPanel.bottomAnchor.constraint(equalTo: bottomAnchor),
            leftButtonsPanel.widthAnchor.constraint(equalTo: rightButtonsPanel.widthAnchor)
            ])
        
        addConstraints([
            //titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: leftButtonsPanel.rightAnchor),
            //titleLabel.rightAnchor.constraint(lessThanOrEqualTo: rightButtonsPanel.leftAnchor),
            titleLabel.leftAnchor.constraint(equalTo: leftButtonsPanel.rightAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightButtonsPanel.leftAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        addConstraints([
            rightButtonsPanel.rightAnchor.constraint(equalTo: rightAnchor),
            rightButtonsPanel.topAnchor.constraint(equalTo: topAnchor),
            rightButtonsPanel.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    private func refreshCustomView(){
        
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

