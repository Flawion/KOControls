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

// MARK: - Settings

/// Dialog action
public class KODialogActionModel: NSObject {
    
    /// Title used for barView: left/right buttons or for titleLabel.text
    public let title: String
    
    /// Action that will be invoked
    public let action: (KODialogViewController) -> Void
    
    public init(title: String, action: @escaping (KODialogViewController) -> Void) {
        self.title = title
        self.action = action
        super.init()
    }
    
    /// Action that will dismiss the dialog
    ///
    /// - Parameter title: title used for barView: left/right buttons or for titleLabel.text
    public static func cancelAction(withTitle title: String = "Cancel") -> KODialogActionModel {
        return KODialogActionModel(title: title, action: { (dialog) in
            dialog.dismiss(animated: true, completion: nil)
        })
    }
    
    /// Action that will invoke a function and then dismiss the dialog
    ///
    /// - Parameter title: title used for barView: left/right buttons or for titleLabel.text
    public static func doneAction<Parameter: KODialogViewController>(withTitle title: String = "Done", action: @escaping (Parameter) -> Void) -> KODialogActionModel {
        return KODialogActionModel(title: title, action: { (dialog) in
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

@objc public protocol KODialogViewControllerDelegate: NSObjectProtocol {
    //developer is responsible for set a title on the button, after implemented one of these methods
    
    /// Developer can create a button manually by implementing this function. Button will be created after setted leftBarButtonAction.
    @objc optional func dialogViewControllerCreateLeftButton(_ dialogViewController: KODialogViewController) -> UIButton
    
    /// Developer can create a button manually by implementing this function. Button will be created after setted rightBarButtonAction.
    @objc optional func dialogViewControllerCreateRightButton(_ dialogViewController: KODialogViewController) -> UIButton

    @objc optional func dialogViewControllerLeftButtonClicked(_ dialogViewController: KODialogViewController)
    @objc optional func dialogViewControllerRightButtonClicked(_ dialogViewController: KODialogViewController)
    
    // You can use events instead
    @objc optional func dialogViewControllerInitialized(_ dialogViewController: KODialogViewController)
    @objc optional func dialogViewControllerViewWillDisappear(_ dialogViewController: KODialogViewController)
    @objc optional func dialogViewControllerViewDidDisappear(_ dialogViewController: KODialogViewController)
}

// MARK: - KODialogViewController

// swiftlint:disable type_body_length file_length

/// Dialog view with the bar and content view. Content can be changed by override function 'createContentView'. BarView title should be changed by assign text to the 'barView.titleLabel.text'. 'Left/Right BarButtonAction' should be used to get the result or dismiss.
open class KODialogViewController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - Variables
    
    //public
    @IBOutlet public weak var delegate: KODialogViewControllerDelegate?
    
    public var statusBarStyleWhenCapturesAppearance: UIStatusBarStyle = .lightContent
    
    /// Custom view transition used when modalPresentationStyle is set to '.custom'
    public var customTransition: KOCustomTransition? = KODimmingTransition() {
        didSet {
            transitioningDelegate = customTransition
        }
    }
    
    /// Events that will be invoke
    public var viewLoadedEvent: ((KODialogViewController) -> Void)?
    public var viewWillDisappearEvent: ((KODialogViewController) -> Void)?
    public var viewDidDisappearEvent: ((KODialogViewController) -> Void)?

    // MARK: Main view
    private weak var pMainView: KODialogMainView!
    
    private var mainViewAllHorizontalConsts: [NSLayoutConstraint] = []
    private var mainViewHorizontalConstraintsInsets: KOHorizontalConstraintsInsets!
    
    private var mainViewAllVerticalConsts: [NSLayoutConstraint] = []
    private var mainViewVerticalConstraintsInsets: KOVerticalConstraintsInsets!

    private var dismissOnTapRecognizer: UITapGestureRecognizer!

    //public

    /// Main view of dialog, the view of viewController is the container for that view that fills the background
    public var mainView: KODialogMainView! {
        loadViewIfNeeded()
        return pMainView
    }
    
    /// Is the dialog will be dismissed when user clicked at the view of viewController
    public var dismissWhenUserTapAtBackground: Bool = true {
        didSet {
            refreshDismissOnTapRecognizer()
        }
    }
    
    /// Vertical alignment of the main view in the view of viewController
    public var mainViewVerticalAlignment: UIControl.ContentVerticalAlignment = .bottom {
        didSet {
            refreshMainViewVerticalAlignment()
        }
    }
    
    /// Horizontal alignment of the main view in the view of viewController
    public var mainViewHorizontalAlignment: UIControl.ContentHorizontalAlignment = .fill {
        didSet {
            refreshMainViewHorizontalAlignment()
        }
    }
    
    /// This parameter will be reseted when alignments were refresh, so use it after viewDidLoad and refresh manually when you changed alignments
    public var mainViewEdgesConstraintsInsets: KOEdgesConstraintsInsets!

    /// After setted this action will be created the left button. This action should be setted to get the result or dismiss the dialog after button clicked.
    public var leftBarButtonAction: KODialogActionModel? {
        didSet {
            refreshLeftBarButtonAction()
        }
    }

    /// After setted this action will be created the right button. This action should be setted to get the result or dismiss the dialog after button clicked.
    public var rightBarButtonAction: KODialogActionModel? {
        didSet {
            refreshRightBarButtonAction()
        }
    }

    open var defaultBarButtonInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyleWhenCapturesAppearance
    }

    // MARK: - Functions
    // MARK: Initialization
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initTransition()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTransition()
    }
    
    private func initTransition() {
        modalPresentationStyle =  .custom
        transitioningDelegate = customTransition
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.dialogViewControllerViewWillDisappear?(self)
        viewWillDisappearEvent?(self)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.dialogViewControllerViewDidDisappear?(self)
        viewDidDisappearEvent?(self)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    private func initialize() {
        initializeView()
        initializeMainView()
        refreshLeftBarButtonAction()
        refreshRightBarButtonAction()
        initializeAppearance()
        
        delegate?.dialogViewControllerInitialized?(self)
        viewLoadedEvent?(self)
    }
    
    private func initializeView() {
        dismissOnTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissOnTapRecognizerTap(gesture:)))
        dismissOnTapRecognizer.delegate = self
        refreshDismissOnTapRecognizer()
        view.addGestureRecognizer(dismissOnTapRecognizer)
    }

    @objc private func dismissOnTapRecognizerTap(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }

    private func refreshDismissOnTapRecognizer() {
        guard isViewLoaded else {
            return
        }
        dismissOnTapRecognizer.isEnabled = dismissWhenUserTapAtBackground
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //prevent from close dialog by touching child views
        return view.hitTest(touch.location(in: view), with: nil) == view
    }
    
    private func initializeMainView() {
        let mainView = KODialogMainView(contentView: createContentView(), withInsets: defaultContentInsets)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        self.pMainView = mainView
        view.addSubview(mainView)
        
        refreshMainViewVerticalAlignment()
        refreshMainViewHorizontalAlignment()
    }

    //public
    open func createContentView() -> UIView {
        //method to overrride by subclasses
        return UIView()
    }
    
    open var defaultContentInsets: UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    open func initializeAppearance() {
        pMainView.backgroundColor = UIColor.white
    }
    
    // MARK: Main view
    private func refreshMainViewHorizontalAlignment() {
        guard isViewLoaded else {
            return
        }
        
        view.removeConstraints(mainViewAllHorizontalConsts)
        
        switch mainViewHorizontalAlignment {
        case .left:
           createMainViewConstraintsForLeftHorizontalAllignment()
            
        case .leading:
            createMainViewConstraintsForLeadingHorizontalAllignment()
            
        case .center:
            createMainViewConstraintsForCenterHorizontalAllignment()
            
        case .right:
            createMainViewConstraintsForRightHorizontalAllignment()
            
        case .trailing:
            createMainViewConstraintsForTrailingHorizontalAllignment()

        default:
            createMainViewConstraintsForFillHorizontalAllignment()
        }
    }

    private func createMainViewConstraintsForLeftHorizontalAllignment() {
        let leftConst = pMainView.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConst = pMainView.rightAnchor.constraint(lessThanOrEqualTo: view.rightAnchor)
        let allConsts = [leftConst, rightConst]
        setMainViewConstraintsForHorizontalAllignment(leftConst: leftConst, rightConst: rightConst, allConsts: allConsts)
    }

    private func createMainViewConstraintsForLeadingHorizontalAllignment() {
        let leftConst = pMainView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let rightConst = pMainView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor)
        let allConsts = [leftConst, rightConst]
        setMainViewConstraintsForHorizontalAllignment(leftConst: leftConst, rightConst: rightConst, allConsts: allConsts)
    }

    private func createMainViewConstraintsForCenterHorizontalAllignment() {
        let leftConst = pMainView.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor)
        let rightConst = pMainView.rightAnchor.constraint(lessThanOrEqualTo: view.rightAnchor)
        let allConsts = [leftConst, rightConst, pMainView.centerXAnchor.constraint(equalTo: view.centerXAnchor)]
        setMainViewConstraintsForHorizontalAllignment(leftConst: leftConst, rightConst: rightConst, allConsts: allConsts)
    }

    private func createMainViewConstraintsForRightHorizontalAllignment() {
        let leftConst = pMainView.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor)
        let rightConst = pMainView.rightAnchor.constraint(equalTo: view.rightAnchor)
        let allConsts = [leftConst, rightConst]
        setMainViewConstraintsForHorizontalAllignment(leftConst: leftConst, rightConst: rightConst, allConsts: allConsts)
    }

    private func createMainViewConstraintsForTrailingHorizontalAllignment() {
        let leftConst = pMainView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor)
        let rightConst = pMainView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let allConsts = [leftConst, rightConst]
        setMainViewConstraintsForHorizontalAllignment(leftConst: leftConst, rightConst: rightConst, allConsts: allConsts)
    }

    private func createMainViewConstraintsForFillHorizontalAllignment() {
        let leftConst = pMainView.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConst = pMainView.rightAnchor.constraint(equalTo: view.rightAnchor)
        let allConsts = [leftConst, rightConst]
        setMainViewConstraintsForHorizontalAllignment(leftConst: leftConst, rightConst: rightConst, allConsts: allConsts)
    }

    private func setMainViewConstraintsForHorizontalAllignment(leftConst: NSLayoutConstraint, rightConst: NSLayoutConstraint, allConsts: [NSLayoutConstraint]) {
        view.addConstraints(allConsts)
        mainViewAllHorizontalConsts = allConsts
        mainViewHorizontalConstraintsInsets = KOHorizontalConstraintsInsets(leftConst: leftConst, rightConst: rightConst)
        refreshMainViewEdgesConstraintsInsets()
    }
    
    private func refreshMainViewVerticalAlignment() {
        guard isViewLoaded else {
            return
        }
        
        view.removeConstraints(mainViewAllVerticalConsts)
        
        switch mainViewVerticalAlignment {
        case .top:
            createMainViewConstraintsForTopVerticalAllignment()
            
        case .center:
            createMainViewConstraintsForCenterVerticalAllignment()
            
        case .bottom:
            createMainViewConstraintsForBottomVerticalAllignment()

        default:
            createMainViewConstraintsForDefaultVerticalAllignment()
        }
    }

    private func createMainViewConstraintsForTopVerticalAllignment() {
        let topConst = pMainView.topAnchor.constraint(equalTo: view.topAnchor)
        let bottomConst = pMainView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        let allConsts = [topConst, bottomConst]
        setMainViewConstraintsForVerticalAllignment(topConst: topConst, bottomConst: bottomConst, allConsts: allConsts)
    }

    private func createMainViewConstraintsForCenterVerticalAllignment() {
        let topConst = pMainView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor)
        let bottomConst = pMainView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        let allConsts = [topConst, bottomConst, pMainView.centerYAnchor.constraint(equalTo: view.centerYAnchor)]
        setMainViewConstraintsForVerticalAllignment(topConst: topConst, bottomConst: bottomConst, allConsts: allConsts)
    }

    private func createMainViewConstraintsForBottomVerticalAllignment() {
        let topConst = pMainView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor)
        let bottomConst = pMainView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let allConsts = [topConst, bottomConst]
        setMainViewConstraintsForVerticalAllignment(topConst: topConst, bottomConst: bottomConst, allConsts: allConsts)
    }

    private func createMainViewConstraintsForDefaultVerticalAllignment() {
        let topConst = pMainView.topAnchor.constraint(equalTo: view.topAnchor)
        let bottomConst = pMainView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let allConsts = [topConst, bottomConst]
        setMainViewConstraintsForVerticalAllignment(topConst: topConst, bottomConst: bottomConst, allConsts: allConsts)
    }

    private func setMainViewConstraintsForVerticalAllignment(topConst: NSLayoutConstraint, bottomConst: NSLayoutConstraint, allConsts: [NSLayoutConstraint]) {
        view.addConstraints(allConsts)
        mainViewAllVerticalConsts = allConsts
        mainViewVerticalConstraintsInsets = KOVerticalConstraintsInsets(topConst: topConst, bottomConst: bottomConst)
        refreshMainViewEdgesConstraintsInsets()
    }

    private func refreshMainViewEdgesConstraintsInsets() {
        guard mainViewHorizontalConstraintsInsets != nil && mainViewVerticalConstraintsInsets != nil else {
            return
        }
        mainViewEdgesConstraintsInsets = KOEdgesConstraintsInsets(horizontal: mainViewHorizontalConstraintsInsets, vertical: mainViewVerticalConstraintsInsets)
    }

    // MARK: Bar Buttons
    private func refreshRightBarButtonAction() {
        guard isViewLoaded else {
            return
        }
        guard let rightBarButtonAction = rightBarButtonAction else {
            pMainView.barView.rightView = nil
            return
        }

        createRightBarButton(fromAction: rightBarButtonAction)
    }

    private func createRightBarButton(fromAction action: KODialogActionModel) {
        let rightBarButton: UIButton = (delegate?.dialogViewControllerCreateRightButton?(self)) ?? createDefaultBarButton(withTitle: action.title)
        rightBarButton.addTarget(self, action: #selector(rightBarButtonClick), for: .touchUpInside)
        pMainView.barView.rightView = rightBarButton
        pMainView.barView.rightViewEdgesConstraintsInset.insets = defaultBarButtonInsets
    }

    private func refreshLeftBarButtonAction() {
        guard isViewLoaded else {
            return
        }
        guard let leftBarButtonAction = leftBarButtonAction else {
            pMainView.barView.leftView = nil
            return
        }

        createLeftBarButton(fromAction: leftBarButtonAction)
    }

    private func createLeftBarButton(fromAction action: KODialogActionModel) {
        let leftBarButton: UIButton = (delegate?.dialogViewControllerCreateLeftButton?(self)) ?? createDefaultBarButton(withTitle: action.title)
        leftBarButton.addTarget(self, action: #selector(leftBarButtonClick), for: .touchUpInside)
        pMainView.barView.leftView = leftBarButton
        pMainView.barView.leftViewEdgesConstraintsInset.insets = defaultBarButtonInsets
    }

    private func createDefaultBarButton(withTitle title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        return button
    }

    @objc private func leftBarButtonClick() {
        leftBarButtonAction?.action(self)
        delegate?.dialogViewControllerLeftButtonClicked?(self)
    }

    @objc private func rightBarButtonClick() {
        rightBarButtonAction?.action(self)
        delegate?.dialogViewControllerRightButtonClicked?(self)
    }
}
