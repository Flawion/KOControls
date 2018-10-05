//
//  KOPickerView.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 03.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

public class KOActionModel<Parameter> : NSObject{
    public let title : String
    public let action : (Parameter)->Void
    
    public init(title : String, action : @escaping (Parameter)->Void) {
        self.title = title
        self.action = action
        super.init()
    }
}

public class KODialogViewControllerActionModel : KOActionModel<KODialogViewController>{
    public static func cancelAction(withTitle title: String = "Cancel")->KODialogViewControllerActionModel{
        return KODialogViewControllerActionModel(title: title, action: {
            (dialog) in
            dialog.dismiss(animated: true, completion: nil)
        })
    }
    
    public static func doneAction<controllerType : KODialogViewController>(withTitle title: String = "Done", action : @escaping (controllerType)->Void)->KODialogViewControllerActionModel{
        return KODialogViewControllerActionModel(title: title, action: {
            (dialog) in
            action(dialog as! controllerType)
            dialog.dismiss(animated: true, completion: nil)
        })
    }
}

public enum KODialogBarModes {
    case top
    case bottom
    case hidden
}

@objc public protocol KODialogViewControllerDelegate : NSObjectProtocol{
    //user is responsible for set a title on the button, after implemented one of these methods
    @objc optional func dialogViewControllerCreateLeftButton(_ dialogViewController : KODialogViewController)->UIButton
    @objc optional func dialogViewControllerCreateRightButton(_ dialogViewController : KODialogViewController)->UIButton
    
    @objc optional func dialogViewControllerLeftButtonClicked(_ dialogViewController : KODialogViewController)
    @objc optional func dialogViewControllerRightButtonClicked(_ dialogViewController : KODialogViewController)
    
    @objc optional func dialogViewControllerInitialized(_ dialogViewController : KODialogViewController)
    @objc optional func dialogViewControllerDone(_ dialogViewController : KODialogViewController)
}

open class KODialogViewController : UIViewController, UIGestureRecognizerDelegate{
    //MARK: - Variables
    private var allConstraints : [NSLayoutConstraint] = []
    
    //public
    @IBOutlet public weak var delegate : KODialogViewControllerDelegate?
    
    public let dimmingTransition = KODimmingTransition()
    public var viewLoadedEvent : ((KODialogViewController)->Void)?
    
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
    
    public var dismissWhenUserTapAtBackground : Bool = true{
        didSet{
            refreshDismissOnTapRecognizer()
        }
    }
    
    public var mainViewVerticalAlignment :  UIControl.ContentVerticalAlignment = .bottom{
        didSet{
            refreshMainViewVerticalAlignment()
        }
    }
    
    public var mainViewHorizontalAlignment :  UIControl.ContentHorizontalAlignment = .fill{
        didSet{
            refreshMainViewHorizontalAlignment()
        }
    }
    
    public var mainViewEdgesConstraintsInsets : KOEdgesConstraintsInsets!
    
    //MARK: Background visual effect view
    private var backgroundVisualEffectConsts : [NSLayoutConstraint] = []
    
    //public
    public private(set) weak var backgroundVisualEffectView : UIVisualEffectView?
    
    public var backgroundVisualEffect : UIVisualEffect?{
        didSet{
            refreshBackgroundVisualEffect()
        }
    }
    
    //MARK: Content view
    private var pContentView : UIView!
    
    private weak var contentWidthConst : NSLayoutConstraint!
    private weak var contentHeightConst : NSLayoutConstraint!
    
    //public
    public weak var contentView : UIView!{
        loadViewIfNeeded()
        return pContentView
    }
    
    public var contentEdgesConstraintsInsets : KOEdgesConstraintsInsets!
    
    public var contentHeight : CGFloat? = nil{
        didSet{
            refreshContentHeight()
        }
    }
    
    public var contentWidth : CGFloat? = nil{
        didSet{
            refreshContentWidth()
        }
    }
    
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
    
    public var leftBarButtonAction : KODialogViewControllerActionModel?{
        didSet{
            refreshLeftBarButtonAction()
        }
    }
    
    public var rightBarButtonAction : KODialogViewControllerActionModel?{
        didSet{
            refreshRightBarButtonAction()
        }
    }
    
    open var defaultBarButtonInsets : UIEdgeInsets{
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    //MARK: - Functions
    //MARK: Initialization
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initTransition()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTransition()
    }
    
    private func initTransition(){
        modalPresentationStyle =  .custom
        transitioningDelegate = dimmingTransition
    }
    
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
        refreshBackgroundVisualEffect()
        
        delegate?.dialogViewControllerInitialized?(self)
        viewLoadedEvent?(self)
    }
    
    private func initializeView(){
        dismissOnTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissOnTapRecognizerTap(gesture:)))
        dismissOnTapRecognizer.delegate = self
        refreshDismissOnTapRecognizer()
        view.addGestureRecognizer(dismissOnTapRecognizer)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        //prevent from close dialog by touching child views
        return view.hitTest(touch.location(in: view), with: nil) == view
    }
    
    private func initializeMainView(){
        let mainView = UIView()
        mainView.translatesAutoresizingMaskIntoConstraints = false
        self.pMainView = mainView
        view.addSubview(mainView)
        
        refreshMainViewVerticalAlignment()
        refreshMainViewHorizontalAlignment()
    }
    
    private func initializeBarView(){
        let barView = KODialogBarView()
        barView.translatesAutoresizingMaskIntoConstraints = false
        self.pBarView = barView
        
        refreshLeftBarButtonAction()
        refreshRightBarButtonAction()
    }
    
    private func initializeContentView(){
        let contentView = createContentView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        pMainView.addSubview(contentView)
        self.pContentView = contentView
        
        refreshContentWidth()
        refreshContentHeight()
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
        guard isViewLoaded else{
            return
        }
        
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
        guard isViewLoaded else{
            return
        }
        
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
    
    private func refreshBackgroundVisualEffect(){
        guard isViewLoaded else{
            return
        }
        
        guard let backgroundVisualEffect = backgroundVisualEffect else{
            //remove visual effect view if need
            if let backgroundVisualEffectView = self.backgroundVisualEffectView{
                backgroundVisualEffectView.removeFromSuperview()
                pMainView.removeConstraints(backgroundVisualEffectConsts)
                backgroundVisualEffectConsts = []
                pMainView.backgroundColor = UIColor.white
            }
            return
        }
        
        //create visual effect
        let backgroundVisualEffectView = UIVisualEffectView(effect: backgroundVisualEffect)
        backgroundVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        pMainView.insertSubview(backgroundVisualEffectView, belowSubview: pContentView)
        self.backgroundVisualEffectView = backgroundVisualEffectView
        
        //create constraints
        backgroundVisualEffectConsts = [
            backgroundVisualEffectView.leftAnchor.constraint(equalTo: pMainView.leftAnchor),
            backgroundVisualEffectView.topAnchor.constraint(equalTo: pMainView.topAnchor),
            backgroundVisualEffectView.rightAnchor.constraint(equalTo: pMainView.rightAnchor),
            backgroundVisualEffectView.bottomAnchor.constraint(equalTo: pMainView.bottomAnchor)
        ]
        pMainView.addConstraints(backgroundVisualEffectConsts)
        pMainView.backgroundColor = UIColor.clear
    }
    
    //MARK: Content view
    private func refreshContentWidth(){
        guard isViewLoaded else{
            return
        }
        
        guard let contentWidth = contentWidth else{
            if let contentWidthConst = self.contentWidthConst{
                contentView.removeConstraint(contentWidthConst)
            }
            return
        }
        guard let contentWidthConst =  self.contentWidthConst else{
            let contentWidthConst = contentView.widthAnchor.constraint(equalToConstant: contentWidth)
            contentView.addConstraint(contentWidthConst)
            self.contentWidthConst = contentWidthConst
            return
        }
        contentWidthConst.constant = contentWidth
    }
    
    private func refreshContentHeight(){
        guard isViewLoaded else{
            return
        }
        
        guard let contentHeight = self.contentHeight else{
            if let contentHeightConst = self.contentHeightConst{
                contentView.removeConstraint(contentHeightConst)
            }
            return
        }
        guard let contentHeightConst = self.contentHeightConst else{
            let contentHeightConst = contentView.heightAnchor.constraint(equalToConstant: contentHeight)
            contentView.addConstraint(contentHeightConst)
            self.contentHeightConst = contentHeightConst
            return
        }
        contentHeightConst.constant = contentHeight
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
        
        //get main view anchors
        var mLeftAnchor : NSLayoutXAxisAnchor!
        var mRightAnchor : NSLayoutXAxisAnchor!
        var mTopAnchor : NSLayoutYAxisAnchor!
        var mBottomAnchor : NSLayoutYAxisAnchor!

        if #available(iOS 11.0, *) {
            mLeftAnchor = pMainView.safeAreaLayoutGuide.leftAnchor
            mRightAnchor = pMainView.safeAreaLayoutGuide.rightAnchor
            mTopAnchor = pMainView.safeAreaLayoutGuide.topAnchor
            mBottomAnchor = pMainView.safeAreaLayoutGuide.bottomAnchor
        } else {
            mLeftAnchor = pMainView.leftAnchor
            mRightAnchor = pMainView.rightAnchor
            mTopAnchor = pMainView.topAnchor
            mBottomAnchor = pMainView.bottomAnchor
        }
        
        //create new one
        let defaultContentInsets = self.defaultContentInsets
        let contentLeftConst : NSLayoutConstraint = pContentView.leftAnchor.constraint(equalTo: mLeftAnchor, constant: defaultContentInsets.left)
        let contentRightConst: NSLayoutConstraint = pContentView.rightAnchor.constraint(equalTo: mRightAnchor, constant: -defaultContentInsets.right)
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
            contentBottomConst = pContentView.bottomAnchor.constraint(equalTo: mBottomAnchor, constant: -defaultContentInsets.bottom)
            allConstraints = [pBarView.leftAnchor.constraint(equalTo: mLeftAnchor), pBarView.rightAnchor.constraint(equalTo: mRightAnchor), pBarView.topAnchor.constraint(equalTo: mTopAnchor), contentLeftConst, contentTopConst, contentRightConst, contentBottomConst]
            pMainView.addConstraints(allConstraints)
            
            
        case .bottom:
            contentTopConst = pContentView.topAnchor.constraint(equalTo: mTopAnchor, constant: defaultContentInsets.top)
            contentBottomConst = pContentView.bottomAnchor.constraint(equalTo: pBarView.topAnchor, constant: -defaultContentInsets.bottom)
            allConstraints = [pBarView.leftAnchor.constraint(equalTo: mLeftAnchor), pBarView.rightAnchor.constraint(equalTo: mRightAnchor), pBarView.bottomAnchor.constraint(equalTo: mBottomAnchor), contentLeftConst, contentTopConst, contentRightConst, contentBottomConst]
            pMainView.addConstraints(allConstraints)
            
        case .hidden:
            contentTopConst = pContentView.topAnchor.constraint(equalTo: mTopAnchor, constant: defaultContentInsets.top)
            contentBottomConst = pContentView.bottomAnchor.constraint(equalTo: mBottomAnchor, constant: -defaultContentInsets.bottom)
            allConstraints = [contentLeftConst, contentTopConst, contentRightConst, contentBottomConst]
            pMainView.addConstraints(allConstraints)
        }
        contentEdgesConstraintsInsets = KOEdgesConstraintsInsets(horizontal: KOHorizontalConstraintsInsets(leftConst: contentLeftConst, rightConst: contentRightConst), vertical: KOVerticalConstraintsInsets(topConst: contentTopConst, bottomConst: contentBottomConst))
    }
    
    private func refreshLeftBarButtonAction(){
        guard isViewLoaded else{
            return
        }
        
        guard let leftBarButtonAction = leftBarButtonAction else{
            barView.leftView = nil
            return
        }
        
        var leftBarButton : UIButton! = delegate?.dialogViewControllerCreateLeftButton?(self)
        if leftBarButton == nil{
            leftBarButton = UIButton(type: .system)
            leftBarButton.setTitle(leftBarButtonAction.title, for: .normal)
        }
        
        leftBarButton.addTarget(self, action: #selector(leftBarButtonClick), for: .touchUpInside)
        barView.leftView = leftBarButton
        barView.leftViewEdgesConstraintsInset.insets = defaultBarButtonInsets
    }
    
    private func refreshRightBarButtonAction(){
        guard isViewLoaded else{
            return
        }
        
        guard let rightBarButtonAction = rightBarButtonAction else{
            barView.rightView = nil
            return
        }
        
        var rightBarButton : UIButton! = delegate?.dialogViewControllerCreateRightButton?(self)
        if rightBarButton == nil{
            rightBarButton = UIButton(type: .system)
            rightBarButton.setTitle(rightBarButtonAction.title, for: .normal)
        }
        
        rightBarButton.addTarget(self, action: #selector(rightBarButtonClick), for: .touchUpInside)
        barView.rightView = rightBarButton
        barView.rightViewEdgesConstraintsInset.insets = defaultBarButtonInsets
    }
    
    @objc private func leftBarButtonClick(){
        leftBarButtonAction?.action(self)
        delegate?.dialogViewControllerLeftButtonClicked?(self)
    }
    
    @objc private func rightBarButtonClick(){
        rightBarButtonAction?.action(self)
        delegate?.dialogViewControllerRightButtonClicked?(self)
    }
    
    @objc private func dismissOnTapRecognizerTap(gesture : UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
}

