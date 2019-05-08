//
//  KOControlErrorInfoFeature.swift
//  KOControls
//
//  Copyright (c) 2019 Kuba Ostrowski
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

/// Describes when it should be showed the view with the error information
///
/// - manual: developer have to manually shows/hides errorInfoView by changing 'isShowing' flag
/// - onFocus: (default) errorInfoView will be showing when field is first responder
/// - always: errorInfoView will be showing always when there is an error
public enum KOShowErrorInfoModes {
    case manual
    case onFocus //by default
    case always
}

@objc public protocol KOControlErrorInfoFeatureDelegate: NSObjectProtocol {
    var featureContainer: UIView { get }
    var errorIsShowing: Bool { get }
    var markerCenterXEualTo: NSLayoutXAxisAnchor { get }
    
    @objc optional func errorInfoStartingHideAnimation()
    @objc optional func errorInfoDidHide()
    @objc optional func errorInfoStartingShowAnimation()
    @objc optional func errorInfoDidShow()
}

// MARK: - KOControlErrorInfoFeature
public class KOControlErrorInfoFeature {
    // MARK: - Variables
    private weak var delegate: KOControlErrorInfoFeatureDelegate?
    
    private var containerForView: UIView!
    private var containerForViewConsts: [NSLayoutConstraint] = []
    private weak var containerForCustomView: UIView!
    private var customViewMarkerCenterXConst: NSLayoutConstraint?
    private weak var showedInView: UIView!
    private var isHideAnimationRunning: Bool = false
    
    private var isShowed: Bool {
        return showedInView != nil
    }
    
    /// It is changed based on 'showMode' and field state. Developer can manually try to change it this flag.
    public var isShowing: Bool = false {
        didSet {
            if isShowing && !(delegate?.errorIsShowing ?? false) {
                isShowing = false
                return
            }
            if oldValue != isShowing {
                refreshShowing(animated: true)
            }
        }
    }
    
    //public
    public private(set) var animator: KOAnimator!
    
    /// Error info view, can be well modificated to match to the app layout. The minimum needed change is to set 'descriptionLabel.text'.
    public private(set) weak var view: KOErrorInfoView!
    
    /// Developer can override the default parent for view. The default one will be superview.
    public weak var showInView: UIView?
    
    public var description: String? {
        get {
            return view.descriptionLabel.text
        }
        set {
            view.descriptionLabel.text = newValue
        }
    }
    
    public var showMode: KOShowErrorInfoModes = .onFocus {
        didSet {
            refresh()
        }
    }
    
    public var customView: (UIView & KOErrorInfoProtocol)? {
        didSet {
            refreshCustomView()
        }
    }
    
    public var insets: UIEdgeInsets = UIEdgeInsets(top: -4, left: 0, bottom: 0, right: 0)
    
    /// Flag that indicates if the field manages the visibility of view marker
    public var manageViewMarkerVisibility: Bool = true
    public var showAnimation: KOAnimation?
    public var hideAnimation: KOAnimation?
    
    // MARK: - Functions
    // MARK: Initializations
    public init(delegate: KOControlErrorInfoFeatureDelegate) {
        self.delegate = delegate

        initialize()
    }
    
    private func initialize() {
        initializeContainerForView()
        initializeContainerForCustomView()
        initializeView()
        initializeAnimations()
    }
    
    private func initializeContainerForView() {
        containerForView = UIView()
        containerForView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func initializeContainerForCustomView() {
        let containerForCustomView = UIView()
        containerForCustomView.isHidden = true
        _ = containerForView.addAutoLayoutSubview(containerForCustomView)
        self.containerForCustomView = containerForCustomView
    }
    
    private func initializeView() {
        let errorInfoView = KOErrorInfoView()
        _ = containerForView.addAutoLayoutSubview(errorInfoView)
        self.view = errorInfoView
    }
    
    private func initializeAnimations() {
        animator = KOAnimator(view: containerForView)
        showAnimation = KOFadeInAnimation(fromValue: 0)
        hideAnimation = KOFadeOutAnimation()
    }
    
    // MARK: View
    public func refresh() {
        guard delegate?.errorIsShowing ?? false else {
            isShowing = false
            return
        }
        changeIsShowingBasedOnMode()
    }
    
    private func changeIsShowingBasedOnMode() {
        switch showMode {
        case .onFocus:
            isShowing = delegate?.featureContainer.isFirstResponder ?? false
            
        case .always:
            isShowing = true
            
        default:
            break
        }
    }
    
    private func refreshShowing(animated: Bool) {
        animated ?
            (isShowing ? showAnimated() : hideAnimated()) :
            (isShowing ? show() : hide())
    }
    
    private func showAnimated() {
        show()
        delegate?.errorInfoStartingShowAnimation?()
        if let showAnimation = showAnimation {
            animator.runViewAnimation(showAnimation, completionHandler: nil)
        } else {
            animator.stopViewAnimation()
        }
    }
    
    private func show() {
        guard let delegate = delegate, let showInView = self.showInView ?? delegate.featureContainer.superview else {
            return
        }
        
        if isShowed {
            //if is showed in the other superview than needs, it will have removed from old parent before add
            isHideAnimationRunning = false
            animator.stopViewAnimation()
            guard showInView != showedInView else {
                return
            }
            hide()
        }
        
        setViewMarkerHiddenIfCan(false)
        addContainerForView(toView: showInView)
        addCustomViewMarkerCenterXConst()
        delegate.errorInfoDidShow?()
    }
    
    private func addContainerForView(toView showInView: UIView) {
        guard let delegate = delegate else {
            return
        }

        var containerForViewConsts = showInView.addAutoLayoutSubview(containerForView, settings: createAddAutoLayoutSubviewSettingsForContainerForView(constraintsToView: delegate.featureContainer)).list
        let markerCenterXEqualTo = view.markerCenterXEqualTo(delegate.markerCenterXEualTo)!
        showInView.addConstraint(markerCenterXEqualTo)
        containerForViewConsts.append(markerCenterXEqualTo)
        
        self.containerForViewConsts = containerForViewConsts
        showedInView = showInView
    }

    private func createAddAutoLayoutSubviewSettingsForContainerForView(constraintsToView: UIView) -> KOAddAutoLayoutSubviewSettings {
        var addViewSettings = KOAddAutoLayoutSubviewSettings()
        addViewSettings.overrideAnchors = KOOAnchorsContainer(left: constraintsToView.leftAnchor, top: constraintsToView.bottomAnchor, right: constraintsToView.rightAnchor)
        addViewSettings.toAddConstraints = [.left, .top, .right]
        addViewSettings.insets = UIEdgeInsets(top: insets.top - insets.bottom, left: insets.left, bottom: 0, right: insets.right)
        addViewSettings.operations = [KOConstraintsDirections.left: KOConstraintsOperations.equalOrGreater]
        return addViewSettings
    }
    
    private func hideAnimated() {
        guard let hideAnimation = hideAnimation else {
            animator.stopViewAnimation()
            hide()
            return
        }
        
        //hide marker before animation to avoid strange behaviour
        setViewMarkerHiddenIfCan(!(delegate?.errorIsShowing ?? false))
        delegate?.errorInfoStartingHideAnimation?()
        isHideAnimationRunning = true
        animator.runViewAnimation(hideAnimation) { [weak self] _ in
            guard let self = self, self.isHideAnimationRunning  else {
                return
            }
            self.hide()
        }
    }
    
    private func hide() {
        guard isShowed else {
            return
        }
        
        defer {
            containerForView.removeFromSuperview()
            containerForViewConsts = []
            removeCustomViewMarkerCenterXConst()
            showedInView = nil
            delegate?.errorInfoDidHide?()
        }
        
        guard let showedInView = showedInView else {
            return
        }
        showedInView.removeConstraints(containerForViewConsts)
    }
    
    private func setViewMarkerHiddenIfCan(_ hidden: Bool) {
        if manageViewMarkerVisibility {
            view.isMarkerViewHidden = hidden
        }
    }
    
    // MARK: Custom view
    private func refreshCustomView() {
        containerForCustomView.fill(withView: customView)
        refreshCustomViewVisibility()
        refreshCustomViewMarkerCenterXConst()
        delegate?.featureContainer.layoutIfNeeded()
    }
    
    private func refreshCustomViewVisibility() {
        let isCustomViewHidden = customView == nil
        containerForCustomView.isHidden = isCustomViewHidden
        view.isHidden = !isCustomViewHidden
    }
    
    private func refreshCustomViewMarkerCenterXConst() {
        isShowing ? addCustomViewMarkerCenterXConst() : removeCustomViewMarkerCenterXConst()
    }
    
    private func addCustomViewMarkerCenterXConst() {
        guard let showedInView = showedInView, let customView = customView else {
            return
        }
        
        removeCustomViewMarkerCenterXConst()
        if let errorViewCenterXAnchor = delegate?.markerCenterXEualTo, let customViewMarkerCenterXConst = customView.markerCenterXEqualTo(errorViewCenterXAnchor) {
            showedInView.addConstraint(customViewMarkerCenterXConst)
        }
    }
    
    private func removeCustomViewMarkerCenterXConst() {
        guard let showedInView = showedInView, let customViewMarkerCenterXConst = customViewMarkerCenterXConst else {
            return
        }
        showedInView.removeConstraint(customViewMarkerCenterXConst)
    }
    
    // MARK: Must be invoked by parent container
    public func eventDidMoveToSuperview() {
        refreshShowing(animated: false)
    }
    
    public func eventFirstResponderChanged() {
        refresh()
    }
}
