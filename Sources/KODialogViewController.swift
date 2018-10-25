//
//  KOPickerView.swift
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

/// Dialog action
public class KODialogActionModel : NSObject{
    
    /// Title used for barView: left/right buttons or for titleLabel.text
    public let title : String
    
    /// Action that will be invoked
    public let action : (KODialogViewController)->Void
    
    public init(title : String, action : @escaping (KODialogViewController)->Void) {
        self.title = title
        self.action = action
        super.init()
    }
    
    /// Action that will dismiss the dialog
    ///
    /// - Parameter title: title used for barView: left/right buttons or for titleLabel.text
    public static func cancelAction(withTitle title: String = "Cancel")->KODialogActionModel{
        return KODialogActionModel(title: title, action: {
            (dialog) in
            dialog.dismiss(animated: true, completion: nil)
        })
    }
    
    /// Action that will invoke a function and then dismiss the dialog
    ///
    /// - Parameter title: title used for barView: left/right buttons or for titleLabel.text
    public static func doneAction<Parameter : KODialogViewController>(withTitle title: String = "Done", action : @escaping (Parameter)->Void)->KODialogActionModel{
        return KODialogActionModel(title: title, action: {
            (dialog) in
            action(dialog as! Parameter)
            dialog.dismiss(animated: true, completion: nil)
        })
    }
}

/// Mode of 'barView' visibility
public enum KODialogBarModes {
    case top
    case bottom
    case hidden
}

@objc public protocol KODialogViewControllerDelegate : NSObjectProtocol{
    //developer is responsible for set a title on the button, after implemented one of these methods
    
    /// Developer can create a button manually by implementing this function. Button will be created after setted leftBarButtonAction.
    @objc optional func dialogViewControllerCreateLeftButton(_ dialogViewController : KODialogViewController)->UIButton
    
    /// Developer can create a button manually by implementing this function. Button will be created after setted rightBarButtonAction.
    @objc optional func dialogViewControllerCreateRightButton(_ dialogViewController : KODialogViewController)->UIButton
    
    @objc optional func dialogViewControllerLeftButtonClicked(_ dialogViewController : KODialogViewController)
    @objc optional func dialogViewControllerRightButtonClicked(_ dialogViewController : KODialogViewController)
    
    /// This function will be invoked at the of viewDidLoad, you can use 'viewLoadedEvent' instead
    @objc optional func dialogViewControllerInitialized(_ dialogViewController : KODialogViewController)
}

/// Dialog view with the bar and content view. Content can be changed by override function 'createContentView'. BarView title should be changed by assign text to the 'barView.titleLabel.text'. 'Left/Right BarButtonAction' should be used to get the result or dismiss.
open class KODialogViewController : UIViewController, UIGestureRecognizerDelegate{
    //MARK: - Variables
    private var allConstraints : [NSLayoutConstraint] = []
    
    //public
    @IBOutlet public weak var delegate : KODialogViewControllerDelegate?
    
    public var statusBarStyleWhenCapturesAppearance : UIStatusBarStyle = .lightContent
    
    /// Custom view transition used when modalPresentationStyle is set to '.custom'
    public var customTransition : KOCustomTransition? = KODimmingTransition() {
        didSet{
            transitioningDelegate = customTransition
        }
    }
    
    /// Event that will be invoked when view is loaded
    public var viewLoadedEvent : ((KODialogViewController)->Void)?
    
    //MARK: Main view
    private weak var pMainView : UIView!
    
    private var mainViewAllHorizontalConsts : [NSLayoutConstraint] = []
    private var mainViewHorizontalConstraintsInsets : KOHorizontalConstraintsInsets!
    
    private var mainViewAllVerticalConsts : [NSLayoutConstraint] = []
    private var mainViewVerticalConstraintsInsets : KOVerticalConstraintsInsets!
    
    private var dismissOnTapRecognizer : UITapGestureRecognizer!

    //public
    
    /// Main view of dialog, the view of viewController is the container for that view that fills the background
    public weak var mainView : UIView!{
        loadViewIfNeeded()
        return pMainView
    }
    
    /// Is the dialog will be dismissed when user clicked at the view of viewController
    public var dismissWhenUserTapAtBackground : Bool = true{
        didSet{
            refreshDismissOnTapRecognizer()
        }
    }
    
    /// Vertical alignment of the main view in the view of viewController
    public var mainViewVerticalAlignment :  UIControl.ContentVerticalAlignment = .bottom{
        didSet{
            refreshMainViewVerticalAlignment()
        }
    }
    
    /// Horizontal alignment of the main view in the view of viewController
    public var mainViewHorizontalAlignment :  UIControl.ContentHorizontalAlignment = .fill{
        didSet{
            refreshMainViewHorizontalAlignment()
        }
    }
    
    /// This parameter will be reseted when alignments were refresh, so use it after viewDidLoad and refresh manually when you changed alignments
    public var mainViewEdgesConstraintsInsets : KOEdgesConstraintsInsets!
    
    //MARK: Background visual effect view
    private var backgroundVisualEffectConsts : [NSLayoutConstraint] = []
    
    //public
    
    /// To get the background with the visual effect you have to set the parameter 'backgroundVisualEffect', if you want to have the rounded corners at the dialog you have to set clipBounds at 'mainView'
    public private(set) weak var backgroundVisualEffectView : UIVisualEffectView?
    
    /// This parameter can be setted to create background with the visual effect like blur, after setting it background of the main view will be changed to clear
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
    
    /// The main content of the view, developer should override 'createContentView' to change it
    public weak var contentView : UIView!{
        loadViewIfNeeded()
        return pContentView
    }
    
    public var contentEdgesConstraintsInsets : KOEdgesConstraintsInsets!
    
    /// It should be setted if the height of the view can't be calculated from the constraints or intrinsic content size. If mainViewVerticalAlignment == .fill you dont need to set it.
    public var contentHeight : CGFloat? = nil{
        didSet{
            refreshContentHeight()
        }
    }
    
    /// It should be setted if the width of the view can't be calculated from the constraints or intrinsic content size. If mainViewHorizontalAlignment == .fill you dont need to set it.
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
    
    /// BarView title should be changed by assign text to the 'barView.titleLabel.text'
    public var barView : KODialogBarView!{
        loadViewIfNeeded()
        return pBarView
    }
    
    /// Mode of 'barView' visibility
    public var barMode : KODialogBarModes = .top{
        didSet{
            refreshBarMode()
        }
    }
    
    /// After setted this action will be created the left button. This action should be setted to get the result or dismiss the dialog after button clicked.
    public var leftBarButtonAction : KODialogActionModel?{
        didSet{
            refreshLeftBarButtonAction()
        }
    }
    
    /// After setted this action will be created the right button. This action should be setted to get the result or dismiss the dialog after button clicked.
    public var rightBarButtonAction : KODialogActionModel?{
        didSet{
            refreshRightBarButtonAction()
        }
    }
    
    open var defaultBarButtonInsets : UIEdgeInsets{
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle{
        return statusBarStyleWhenCapturesAppearance
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
        transitioningDelegate = customTransition
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

