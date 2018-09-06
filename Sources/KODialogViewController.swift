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

public enum KODialogBarModes {
    case top
    case bottom
    case hidden
}

//MARK: - KODialogBarView
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

//MARK: - KODialogViewController
open class KODialogViewController : UIViewController{
    //MARK: - Variables
    private var allConstraints : [NSLayoutConstraint] = []
    
    //MARK: Main view
    private weak var pMainView : UIView!
    
    private var mainViewAllHorizontalConsts : [NSLayoutConstraint] = []
    private var mainViewHorizontalConstraintsInsets : KOHorizontalConstraintsInsets!
    
    private var mainViewAllVerticalConsts : [NSLayoutConstraint] = []
    private var mainViewVerticalConstraintsInsets : KOVerticalConstraintsInsets!
    
    private var dismissOnTapRecognizer : UITapGestureRecognizer!

    //public
    public weak var mainView : UIView!{
        loadViewIfNeeded()
        return pMainView
    }
    
    public var dismissWhenUserTapAtBackground : Bool = false{
        didSet{
            refreshDismissOnTapRecognizer()
        }
    }
    
    public var mainViewVerticalAlignment :  UIControlContentVerticalAlignment = .fill{
        didSet{
            refreshMainViewVerticalAlignment()
        }
    }
    
    public var mainViewHorizontalAlignment :  UIControlContentHorizontalAlignment = .fill{
        didSet{
            refreshMainViewHorizontalAlignment()
        }
    }
    
    public var mainViewEdgesConstraintsInsets : KOEdgesConstraintsInsets!
    
    open var defaultMainViewVerticalAlignment : UIControlContentVerticalAlignment{
        return .fill
    }
    
    open var defaultMainViewHorizontalAlignment : UIControlContentHorizontalAlignment{
        return .fill
    }
    
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
    private var pBarView : KODialogBarView!
    
    //public
    public var barView : KODialogBarView!{
        loadViewIfNeeded()
        return pBarView
    }

    public var barMode : KODialogBarModes = .top{
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
        initializeView()
        initializeMainView()
        initializeBarView()
        initializeContentView()
        initializeAppearance()
        refreshBarMode()
    }
    
    private func initializeView(){
        dismissOnTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissOnTapRecognizerTap))
        refreshDismissOnTapRecognizer()
        view.addGestureRecognizer(dismissOnTapRecognizer)
    }
    
    private func initializeMainView(){
        let mainView = UIView()
        mainView.translatesAutoresizingMaskIntoConstraints = false
        self.pMainView = mainView
        view.addSubview(mainView)
        
        mainViewVerticalAlignment = defaultMainViewVerticalAlignment
        mainViewHorizontalAlignment = defaultMainViewHorizontalAlignment
    }
    
    private func initializeBarView(){
        let barView = KODialogBarView()
        barView.translatesAutoresizingMaskIntoConstraints = false
        self.pBarView = barView
    }
    
    private func initializeContentView(){
        let contentView = createContentView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        pMainView.addSubview(contentView)
        self.pContentView = contentView
    }
    
    private func refreshDismissOnTapRecognizer(){
        guard isViewLoaded else{
            return
        }
        dismissOnTapRecognizer.isEnabled = dismissWhenUserTapAtBackground
    }
    
    //public
    open func initializeAppearance(){
        pMainView.backgroundColor = UIColor.white
    }
    
    open func createContentView()->UIView{
        //method to overrride by subclasses
        return UIView()
    }
    
    //MARK: Main view
    private func refreshMainViewHorizontalAlignment(){
        view.removeConstraints(mainViewAllHorizontalConsts)
        
        var leftConst : NSLayoutConstraint!
        var rightConst : NSLayoutConstraint!
        var allConsts : [NSLayoutConstraint] = []
        
        switch mainViewHorizontalAlignment {
        case .left:
            leftConst = pMainView.leftAnchor.constraint(equalTo: view.leftAnchor)
            rightConst = pMainView.rightAnchor.constraint(lessThanOrEqualTo: view.rightAnchor)
            allConsts = [leftConst, rightConst]
            
        case .leading:
            leftConst = pMainView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            rightConst = pMainView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor)
            allConsts = [leftConst, rightConst]
            
        case .center:
            leftConst = pMainView.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor)
            rightConst = pMainView.rightAnchor.constraint(lessThanOrEqualTo: view.rightAnchor)
            allConsts = [leftConst, rightConst, pMainView.centerXAnchor.constraint(equalTo: view.centerXAnchor)]
            
        case .right:
            leftConst = pMainView.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor)
            rightConst = pMainView.rightAnchor.constraint(equalTo: view.rightAnchor)
            allConsts = [leftConst, rightConst]
            
        case .trailing:
            leftConst = pMainView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor)
            rightConst = pMainView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            allConsts = [leftConst, rightConst]
            
        //fill space
        default:
            leftConst = pMainView.leftAnchor.constraint(equalTo: view.leftAnchor)
            rightConst = pMainView.rightAnchor.constraint(equalTo: view.rightAnchor)
            allConsts = [leftConst, rightConst]
        }
        
        view.addConstraints(allConsts)
        mainViewAllHorizontalConsts = allConsts
        mainViewHorizontalConstraintsInsets = KOHorizontalConstraintsInsets(leftConst: leftConst, rightConst: rightConst)
        refreshMainViewEdgesConstraintsInsets()
    }
    
    private func refreshMainViewVerticalAlignment(){
        view.removeConstraints(mainViewAllVerticalConsts)
        
        var topConst : NSLayoutConstraint!
        var bottomConst : NSLayoutConstraint!
        var allConsts : [NSLayoutConstraint] = []
        
        switch mainViewVerticalAlignment {
            
        case .top:
            topConst = pMainView.topAnchor.constraint(equalTo: view.topAnchor)
            bottomConst = pMainView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
            allConsts = [topConst, bottomConst]
            
        case .center:
            topConst = pMainView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor)
            bottomConst = pMainView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
            allConsts = [topConst, bottomConst, pMainView.centerYAnchor.constraint(equalTo: view.centerYAnchor)]
            
        case .bottom:
            topConst = pMainView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor)
            bottomConst = pMainView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            allConsts = [topConst, bottomConst]
            
        //fill space
        default:
            topConst = pMainView.topAnchor.constraint(equalTo: view.topAnchor)
            bottomConst = pMainView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            allConsts = [topConst, bottomConst]
        }
        
        view.addConstraints(allConsts)
        mainViewAllVerticalConsts = allConsts
        mainViewVerticalConstraintsInsets = KOVerticalConstraintsInsets(topConst: topConst, bottomConst: bottomConst)
        refreshMainViewEdgesConstraintsInsets()
    }
    
    private func refreshMainViewEdgesConstraintsInsets(){
        guard mainViewHorizontalConstraintsInsets != nil && mainViewVerticalConstraintsInsets != nil else{
            return
        }
        mainViewEdgesConstraintsInsets = KOEdgesConstraintsInsets(horizontal: mainViewHorizontalConstraintsInsets, vertical: mainViewVerticalConstraintsInsets)
    }
    
    //MARK: Bar view and buttons
    private func refreshBarMode(){
        guard isViewLoaded else{
            return
        }
        
        //delete old constraints
        if allConstraints.count > 0{
            pMainView.removeConstraints(allConstraints)
            allConstraints = []
        }
        
        //create new one
        let defaultContentInsets = self.defaultContentInsets
        let contentLeftConst : NSLayoutConstraint = pContentView.leftAnchor.constraint(equalTo: pMainView.leftAnchor, constant: defaultContentInsets.left)
        let contentRightConst: NSLayoutConstraint = pContentView.bottomAnchor.constraint(equalTo: pMainView.bottomAnchor, constant: -defaultContentInsets.right)
        var contentTopConst : NSLayoutConstraint!
        var contentBottomConst : NSLayoutConstraint!
        
        //add or remove bar view
        if barMode != .hidden{
            if pBarView.superview != pMainView{
                pBarView.removeFromSuperview()
                pMainView.addSubview(barView)
            }
        }else{
            pBarView.removeFromSuperview()
        }
        
        //create bar constraints
        switch barMode {
        case .top:
            contentTopConst = pContentView.topAnchor.constraint(equalTo: pBarView.bottomAnchor, constant: defaultContentInsets.top)
            contentBottomConst = pContentView.rightAnchor.constraint(equalTo: pMainView.rightAnchor, constant: -defaultContentInsets.bottom)
            allConstraints = [pBarView.leftAnchor.constraint(equalTo: pMainView.leftAnchor), pBarView.rightAnchor.constraint(equalTo: pMainView.rightAnchor), pBarView.topAnchor.constraint(equalTo: pMainView.topAnchor), contentLeftConst, contentTopConst, contentRightConst, contentBottomConst]
            pMainView.addConstraints(allConstraints)
            
            
        case .bottom:
            contentTopConst = pContentView.topAnchor.constraint(equalTo: pMainView.topAnchor, constant: defaultContentInsets.top)
            contentBottomConst = pContentView.rightAnchor.constraint(equalTo: pMainView.rightAnchor, constant: -defaultContentInsets.bottom)
            allConstraints = [pBarView.leftAnchor.constraint(equalTo: pMainView.leftAnchor), pBarView.rightAnchor.constraint(equalTo: pMainView.rightAnchor), pBarView.bottomAnchor.constraint(equalTo: pMainView.bottomAnchor), contentLeftConst, contentTopConst, contentRightConst, contentBottomConst]
            pMainView.addConstraints(allConstraints)
            
        case .hidden:
            contentTopConst = pContentView.topAnchor.constraint(equalTo: pMainView.topAnchor, constant: defaultContentInsets.top)
            contentBottomConst = pContentView.rightAnchor.constraint(equalTo: pMainView.rightAnchor, constant: -defaultContentInsets.bottom)
            allConstraints = [contentLeftConst, contentTopConst, contentRightConst, contentBottomConst]
            pMainView.addConstraints(allConstraints)
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
        barView.leftViewEdgesConstraintsInset.insets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
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
        barView.rightViewEdgesConstraintsInset.insets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    @objc private func leftBarButtonClick(){
        leftBarButtonAction?.action()
    }
    
    @objc private func rightBarButtonClick(){
        rightBarButtonAction?.action()
    }
    
    @objc private func dismissOnTapRecognizerTap(){
        self.dismiss(animated: true, completion: nil)
    }
}

