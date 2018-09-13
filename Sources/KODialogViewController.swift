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
  
    open var defaultBarButtonInsets : UIEdgeInsets{
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
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
        barView.leftViewEdgesConstraintsInset.insets = defaultBarButtonInsets
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
        barView.rightViewEdgesConstraintsInset.insets = defaultBarButtonInsets
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

