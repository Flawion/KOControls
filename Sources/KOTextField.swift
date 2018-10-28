//
//  KOTextField.swift
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

//MARK: - Settings

/// Describes when it should be showed the view with the error information
///
/// - manual: developer have to manually shows/hides errorInfoView by changing flag 'isShowingError'
/// - onFocus: (default) errorInfoView will be showing when field is first responder
/// - always: errorInfoView will be showing always when there is an error
public enum KOTextFieldShowErrorInfoModes{
    case manual
    case onFocus //by default
    case always
}

/// Describes when field will be validating
///
/// - manual: developer have to manually validate field by invoke function validate
/// - validateOnTextChanged: (default) field will be validating at text changed
/// - validateOnLostFocus: field will be validating at lost focus, error will be hidding when text changed
/// - clearErrorOnTextChanged: errors will be hidding when text changed
public enum KOTextFieldValidateModes{
    case manual
    case validateOnTextChanged //by default
    case validateOnLostFocus
    case clearErrorOnTextChanged
}

/// Border settings
public struct KOTextFieldBorderSettings{
    public var color : CGColor?
    public var errorColor : CGColor?
    public var focusedColor : CGColor?
    public var errorFocusedColor : CGColor?
    
    public var width : CGFloat
    public var errorWidth : CGFloat?
    public var focusedWidth : CGFloat?
    public var errorFocusedWidth : CGFloat?
    
    public init(color : CGColor? = nil, errorColor : CGColor?  = nil, focusedColor : CGColor?  = nil, errorFocusedColor : CGColor? = nil, width : CGFloat = 0, errorWidth : CGFloat? = nil, focusedWidth : CGFloat? = nil, errorFocusedWidth : CGFloat? = nil){
        self.color = color
        self.errorColor = errorColor
        self.focusedColor = focusedColor
        self.errorFocusedColor = errorFocusedColor
        self.width = width
        self.errorWidth = errorWidth
        self.focusedWidth = focusedWidth
        self.errorFocusedWidth = errorFocusedWidth
    }
}

//MARK: - Validators

/// Developer can implement its own validator by implementing this protocol to the class
public protocol KOTextValidatorInterface : AnyObject{
    func validate(text : String)->Bool
}

/// Regexp validator
public class KORegexTextValidator : KOTextValidatorInterface{
    private let regex : NSPredicate
    
    /// Simple, easy to use mailValidator: field.add(validator: KORegexTextValidator.mailValidator)
    public static var mailValidator : KORegexTextValidator{
        return KORegexTextValidator(regexPattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    }
    
    public init(regexPattern : String){
        regex = NSPredicate(format: "SELF MATCHES %@", regexPattern)
    }
    
    public func validate(text : String)->Bool{
        return regex.evaluate(with: text)
    }
}

/// Simple way to create your own validator by passing a function
public class KOFunctionTextValidator : KOTextValidatorInterface{
    private let function : (String)->Bool
    
    public init(function : @escaping (String)->Bool){
        self.function = function
    }
    
    public func validate(text : String)->Bool{
        return function(text)
    }
}

@objc public protocol KOTextFieldDelegate : UITextFieldDelegate{
    @objc optional func textFieldDidShowError(_ textField: UITextField)
    @objc optional func textFieldDidHideError(_ textField: UITextField)
    
    @objc optional func textFieldStartingErrorInfoShowAnimation(_ textField: UITextField)
    @objc optional func textFieldStartingErrorInfoHideAnimation(_ textField: UITextField)
    
    @objc optional func textFieldDidShowErrorInfo(_ textField: UITextField)
    @objc optional func textFieldDidHideErrorInfo(_ textField: UITextField)
}

//MARK: - KOTextField

/// Field that supports showing an error to the user and managing field border based on state
open class KOTextField : UITextField{
    //MARK: - Variables
    
    //public
    @IBOutlet public weak var koDelegate : KOTextFieldDelegate?{
        get{
            return delegate as? KOTextFieldDelegate
        }
        set{
            delegate = newValue
        }
    }
    
    public private(set) var validators : [KOTextValidatorInterface] = []
    public var validateMode : KOTextFieldValidateModes = .validateOnLostFocus
    
    /// Flag that indicates whether is error or isn't
    public var isShowingError : Bool = false{
        didSet{
            if oldValue != isShowingError{
                refreshShowingError()
            }
        }
    }
    
    /// Border settings of layer will be changing to match that struct based on field state
    public var borderSettings : KOTextFieldBorderSettings?{
        didSet{
            refreshBorderSettings()
        }
    }
    
    //MARK: Error
    private weak var errorView : UIView!
    private weak var containerForCustomErrorView: UIView!
    private weak var errorWidthConst : NSLayoutConstraint!
    
    //public / open
    
    /// Icon that indicates there is an error
    public private(set) weak var errorIconView : UIImageView!
    
    
    /// View that can replaces errorIconView
    public var customErrorView : UIView?{
        didSet{
            refreshCustomErrorView()
        }
    }
    
    /// ErrorView width
    public var errorWidth : CGFloat = 32{
        didSet{
            if oldValue != errorWidth{
                refreshShowingError()
            }
        }
    }
    
    //MARK: Error info
    private var containerForErrorInfoView: UIView!
    private var containerForErrorInfoConsts : [NSLayoutConstraint] = []
    private var customErrorInfoMarkerCenterXConst : NSLayoutConstraint?
    private weak var errorInfoShowedInView : UIView!
    private weak var containerForCustomErrorInfoView: UIView!
    private var isShowedErrorInfo : Bool = false
    private var isErrorInfoHideAnimationRunning : Bool = false
    
    /// Flag that indicates whether is showing 'errorInfoView' or isn't. It is changed based on 'showErrorInfoMode' and field state. Developer can manually try to change it by invoke showErrorInfoIfCan() or hideErrorInfoIfCan().
    private var isShowingErrorInfo : Bool = false{
        didSet{
            if oldValue != isShowingErrorInfo{
                refreshShowingErrorInfo(animated: true)
            }
        }
    }
    
    //public
    public private(set) var errorInfoAnimator : KOAnimator!
    
    /// Error info view, can be well modificated to match to the app layout. The minimum needed change is to set 'descriptionLabel.text'.
    public private(set) weak var errorInfoView : KOTextFieldErrorInfoView!
    
    /// Developer can override the default parent for 'errorInfoInView'. The default one will be superview.
    public weak var showErrorInfoInView : UIView?
    
    /// Parameter that indicates when 'errorInfoView' will be showing
    public var showErrorInfoMode : KOTextFieldShowErrorInfoModes = .onFocus{
        didSet{
            refreshShowErrorInfoMode()
        }
    }

    /// View that can replaces default 'errorInfoView'
    public var customErrorInfoView : (UIView & KOTextFieldErrorInfoInterface)?{
        didSet{
            refreshCustomErrorInfoView()
        }
    }
    public var errorInfoInsets : UIEdgeInsets = UIEdgeInsets(top: -4, left: 0, bottom: 0, right: 0)
    
    /// Flag that indicates if the field manages the visibility of 'errorInfoView' marker
    public var manageErrorInfoMarkerVisibility : Bool = true
    
    /// Can be used to override animation of showing 'errorInfoView'
    public var errorInfoShowAnimation : KOAnimation?
    
    /// Can be used to override animation of hidding 'errorInfoView'
    public var errorInfoHideAnimation : KOAnimation?
   
    //MARK: - Functions
    //MARK: Overridden rects to avoid intersection with the error icon view
    override open func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rightViewRect = super.rightViewRect(forBounds: bounds)
        guard errorWidthConst != nil, bounds.isEmpty else{ return rightViewRect}
        return rightViewRect.offsetBy(dx: -errorWidthConst.constant, dy: 0)
    }
    
    override open func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let clearButtonRect = super.clearButtonRect(forBounds: bounds)
        guard errorWidthConst != nil, bounds.isEmpty else{ return clearButtonRect}
        return clearButtonRect.offsetBy(dx: -errorWidthConst.constant, dy: 0)
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.textRect(forBounds: bounds)
        guard errorWidthConst != nil, bounds.isEmpty else{ return textRect}
        textRect.size.width -= errorWidthConst.constant
        return textRect
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        var editingRect = super.editingRect(forBounds: bounds)
        guard errorWidthConst != nil, bounds.isEmpty else{ return editingRect}
        editingRect.size.width -= errorWidthConst.constant
        return editingRect
    }
    
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
        initializeErrorView()
        initializeErrorInfoView()
        addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    
    private func initializeErrorView(){
        //create views
        //error view
        let errorView = UIView()
        errorView.isHidden = true
        errorView.backgroundColor = UIColor.clear
        errorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(errorView)
        self.errorView = errorView
        
        //container for custom error view
        let containerForCustomErrorView = UIView()
        containerForCustomErrorView.isHidden = true
        containerForCustomErrorView.backgroundColor = UIColor.clear
        containerForCustomErrorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(containerForCustomErrorView)
        self.containerForCustomErrorView = containerForCustomErrorView
        
        //error icon view
        let errorIconView = UIImageView(image: UIImage(named: "field_error", in: Bundle(for: type(of: self)), compatibleWith: nil))
        errorIconView.contentMode = .center
        errorIconView.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(errorIconView)
        self.errorIconView = errorIconView
        
        //create constraints
        //for error view
        let errorWidthConst = errorView.widthAnchor.constraint(equalToConstant: 0)
        addConstraints([
            errorView.topAnchor.constraint(equalTo: topAnchor),
            errorView.rightAnchor.constraint(equalTo: rightAnchor),
            errorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            errorWidthConst
            ])
        self.errorWidthConst = errorWidthConst
        
        //for container
        errorView.addConstraints([
            containerForCustomErrorView.leftAnchor.constraint(equalTo: errorView.leftAnchor),
            containerForCustomErrorView.topAnchor.constraint(equalTo: errorView.topAnchor),
            containerForCustomErrorView.rightAnchor.constraint(equalTo: errorView.rightAnchor),
            containerForCustomErrorView.bottomAnchor.constraint(equalTo: errorView.bottomAnchor)
            ])
        
        //for error icon view
        errorView.addConstraints([
            errorIconView.leftAnchor.constraint(equalTo: errorView.leftAnchor),
            errorIconView.topAnchor.constraint(equalTo: errorView.topAnchor),
            errorIconView.rightAnchor.constraint(equalTo: errorView.rightAnchor),
            errorIconView.bottomAnchor.constraint(equalTo: errorView.bottomAnchor)
            ])
    }
    
    private func initializeErrorInfoView(){
        //create views
        containerForErrorInfoView = UIView()
        containerForErrorInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        let containerForCustomErrorInfoView = UIView()
        containerForCustomErrorInfoView.translatesAutoresizingMaskIntoConstraints = false
        containerForCustomErrorInfoView.isHidden = true
        self.containerForCustomErrorInfoView = containerForCustomErrorInfoView
        
        let errorInfoView = KOTextFieldErrorInfoView()
        errorInfoView.translatesAutoresizingMaskIntoConstraints = false
        self.errorInfoView = errorInfoView
        
        //animations
        errorInfoAnimator = KOAnimator(view: containerForErrorInfoView)
        errorInfoShowAnimation = KOFadeInAnimation(fromValue: 0)
        errorInfoHideAnimation = KOFadeOutAnimation()
        
        //create constraints
        //for containerForCustomErrorInfoView
        containerForErrorInfoView.addSubview(containerForCustomErrorInfoView)
        containerForErrorInfoView.addConstraints([
            containerForCustomErrorInfoView.leftAnchor.constraint(equalTo: containerForErrorInfoView.leftAnchor),
            containerForCustomErrorInfoView.rightAnchor.constraint(equalTo: containerForErrorInfoView.rightAnchor),
            containerForCustomErrorInfoView.topAnchor.constraint(equalTo: containerForErrorInfoView.topAnchor),
            containerForCustomErrorInfoView.bottomAnchor.constraint(equalTo: containerForErrorInfoView.bottomAnchor)
            ])
        
        //for errorInfoView
        containerForErrorInfoView.addSubview(errorInfoView)
        containerForErrorInfoView.addConstraints([
            errorInfoView.leftAnchor.constraint(equalTo: containerForErrorInfoView.leftAnchor),
            errorInfoView.rightAnchor.constraint(equalTo: containerForErrorInfoView.rightAnchor),
            errorInfoView.topAnchor.constraint(equalTo: containerForErrorInfoView.topAnchor),
            errorInfoView.bottomAnchor.constraint(equalTo: containerForErrorInfoView.bottomAnchor)
            ])
    }
    
    override open func didMoveToSuperview() {
        refreshShowingErrorInfo(animated: false)
    }
    
    //MARK: Responder
    override open func becomeFirstResponder() -> Bool {
        let becomeFirstResponder = super.becomeFirstResponder()
        if becomeFirstResponder{
            if isShowingError && showErrorInfoMode == .onFocus{
                isShowingErrorInfo = true
            }
        }
        refreshBorder(isFirstResponder: becomeFirstResponder)
        return becomeFirstResponder
    }
    
    override open func resignFirstResponder() -> Bool {
        let resignFirstResponder = super.resignFirstResponder()
        if resignFirstResponder{
            if isShowingError && showErrorInfoMode == .onFocus{
                isShowingErrorInfo = false
            }
            if validateMode == .validateOnLostFocus{
                validate()
            }
        }
        refreshBorder(isFirstResponder: !resignFirstResponder)
        return resignFirstResponder
    }
    
    //MARK: Error view
    private func refreshShowingError(){
        isShowingError ? showError() : hideError()
        refreshBorder()
    }
    
    private func showError(){
        errorWidthConst.constant = errorWidth
        errorView.isHidden = false
        refreshShowErrorInfoMode()
        layoutIfNeeded()
        koDelegate?.textFieldDidShowError?(self)
    }
    
    private func hideError(){
        errorWidthConst.constant = 0
        errorView.isHidden = true
        isShowingErrorInfo = false
        layoutIfNeeded()
        koDelegate?.textFieldDidHideError?(self)
    }
    
    private func refreshCustomErrorView(){
        let isCustomErrorViewHidden = customErrorView == nil
        containerForCustomErrorView.isHidden = isCustomErrorViewHidden
        errorIconView.isHidden = !isCustomErrorViewHidden
        containerForCustomErrorView.fill(withView: customErrorView)
        layoutIfNeeded()
    }
    
    //MARK: Error info view
    private func refreshShowingErrorInfo(animated : Bool){
        animated ? (isShowingErrorInfo ? showErrorInfoAnimated() : hideErrorInfoAnimated()) : (isShowingErrorInfo ? showErrorInfo() : hideErrorInfo())
    }
    
    private func showErrorInfoAnimated(){
        showErrorInfo()
        koDelegate?.textFieldStartingErrorInfoShowAnimation?(self)
        if let errorInfoShowAnimation = errorInfoShowAnimation{
            errorInfoAnimator.runViewAnimation(errorInfoShowAnimation, completionHandler: nil)
        }else{
            errorInfoAnimator.stopViewAnimation()
        }
    }
    
    private func showErrorInfo(){
        guard let showInView = showErrorInfoInView ?? self.superview else{
            return
        }
        
        if isShowedErrorInfo{
            //if error info is showing in the other superview than needs, it will have removed from old parent before add
            isErrorInfoHideAnimationRunning = false
            errorInfoAnimator.stopViewAnimation()
            guard showInView != errorInfoShowedInView else{
                return
            }
            hideErrorInfo()
        }
        
        if manageErrorInfoMarkerVisibility{
            errorInfoView.isMarkerViewHidden = false
        }
        showInView.addSubview(containerForErrorInfoView)
        containerForErrorInfoConsts = [
            containerForErrorInfoView.rightAnchor.constraint(equalTo: rightAnchor, constant: -errorInfoInsets.right),
            containerForErrorInfoView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: errorInfoInsets.left),
            containerForErrorInfoView.topAnchor.constraint(equalTo: bottomAnchor, constant: (errorInfoInsets.top - errorInfoInsets.bottom)),
            errorInfoView.markerCenterXEqualTo(errorView.centerXAnchor)!
        ]
        showInView.addConstraints(containerForErrorInfoConsts)
        errorInfoShowedInView = showInView
        addCustomErrorInfoMarkerCenterXConst()
        isShowedErrorInfo = true
        koDelegate?.textFieldDidShowErrorInfo?(self)
    }

    private func hideErrorInfoAnimated(){
        guard let hideErrorInfoAnimation = errorInfoHideAnimation else{
            errorInfoAnimator.stopViewAnimation()
            hideErrorInfo()
            return
        }
        
        //hide marker before animation to avoid strange behaviour
        if manageErrorInfoMarkerVisibility{
            errorInfoView.isMarkerViewHidden = !isShowingError
        }
        koDelegate?.textFieldStartingErrorInfoHideAnimation?(self)
        isErrorInfoHideAnimationRunning = true
        errorInfoAnimator.runViewAnimation(hideErrorInfoAnimation) {
            [weak self] _ in
            guard let sSelf = self, sSelf.isErrorInfoHideAnimationRunning  else{
                return
            }
            sSelf.hideErrorInfo()
        }
    }
    
    private func hideErrorInfo(){
        guard isShowedErrorInfo else{
            return
        }
        
        defer {
            containerForErrorInfoView.removeFromSuperview()
            containerForErrorInfoConsts = []
            removeCustomErrorInfoMarkerCenterXConst()
            errorInfoShowedInView = nil
            isShowedErrorInfo = false
        }
        
        guard let errorViewShowedInView = errorInfoShowedInView else{
            return
        }
        errorViewShowedInView.removeConstraints(containerForErrorInfoConsts)
        koDelegate?.textFieldDidHideErrorInfo?(self)
    }
    
    private func refreshShowErrorInfoMode(){
        guard isShowingError else{
            return
        }
        
        switch showErrorInfoMode {
        case .onFocus:
            isShowingErrorInfo = isFirstResponder
            
        case .always:
            isShowingErrorInfo = true
            
        default:
            break
        }
    }
    
    //MARK: Custom error info view
    private func refreshCustomErrorInfoMarkerCenterXConst(){
        isShowingErrorInfo ? addCustomErrorInfoMarkerCenterXConst() : removeCustomErrorInfoMarkerCenterXConst()
    }
    
    private func removeCustomErrorInfoMarkerCenterXConst(){
        guard let errorInfoShowedInView = errorInfoShowedInView, let customErrorInfoMarkerCenterXConst = customErrorInfoMarkerCenterXConst else{
            return
        }
        errorInfoShowedInView.removeConstraint(customErrorInfoMarkerCenterXConst)
    }
    
    private func addCustomErrorInfoMarkerCenterXConst(){
        guard let errorInfoShowedInView = errorInfoShowedInView, let customErrorInfoView = customErrorInfoView else{
            return
        }
        
        //removes old one if need
        if let customErrorInfoMarkerCenterXConst = customErrorInfoMarkerCenterXConst{
            errorInfoShowedInView.removeConstraint(customErrorInfoMarkerCenterXConst)
        }
        
        //adds new one
        if let customErrorInfoMarkerCenterXConst = customErrorInfoView.markerCenterXEqualTo(errorView.centerXAnchor){
            errorInfoShowedInView.addConstraint(customErrorInfoMarkerCenterXConst)
        }
    }
    
    private func refreshCustomErrorInfoView(){
        containerForCustomErrorInfoView.fill(withView: customErrorInfoView)
        refreshCustomErrorInfoMarkerCenterXConst()
        layoutIfNeeded()
        
        let result = customErrorInfoView != nil
        containerForCustomErrorInfoView.isHidden = !result
        errorInfoView.isHidden = result
    }
    
    private func refreshBorder(isFirstResponder : Bool? = nil){
        guard let borderSettings = borderSettings else{
            return
        }
        
        let firstResponder = isFirstResponder ?? self.isFirstResponder
        let defaultColor = isShowingError ? (borderSettings.errorColor ?? borderSettings.color) : borderSettings.color
        let defaultWidth = isShowingError ? (borderSettings.errorWidth ?? borderSettings.width) : borderSettings.width
        let defaultFocusedColor = isShowingError ? (borderSettings.errorFocusedColor ?? borderSettings.focusedColor) : borderSettings.focusedColor
        let defaultFocusedWidth = isShowingError ? (borderSettings.errorFocusedWidth ?? borderSettings.focusedWidth) : borderSettings.focusedWidth
        
        if firstResponder{
            layer.borderColor = defaultFocusedColor ?? defaultColor
            layer.borderWidth = defaultFocusedWidth ?? defaultWidth
        }else{
            layer.borderColor = defaultColor
            layer.borderWidth = defaultWidth
        }
    }
    
    private func index(validator : KOTextValidatorInterface)->Int?{
        return validators.index(where: {$0 === validator})
    }
    
    //MARK: Open functions
    
    /// Adds the new validator
    ///
    /// - Parameter validator: validator to add
    open func add(validator : KOTextValidatorInterface){
        guard index(validator: validator) == nil else{
            return
        }
        validators.append(validator)
    }
    
    /// Removes the validator
    ///
    /// - Parameter validator: validator to remove
    open func remove(validator : KOTextValidatorInterface){
        guard let index = index(validator: validator) else{
            return
        }
        validators.remove(at: index)
    }

    /// Validates error based on validators collection
    open func validate(){
        guard validators.count > 0 else{
            isShowingError = false
            return
        }
        let text = self.text ?? ""
        for validator in validators{
            if !validator.validate(text: text){
                isShowingError = true
                return
            }
        }
        isShowingError = false
    }
    
    /// Refreshes layer's border. It must be manually invoke if the parameters were changed directly from the struct 'borderSettings'.
    open func refreshBorderSettings(){
        refreshBorder()
    }
    
    /// Shows 'errorInfoView' if there is an error
    open func showErrorInfoIfCan(){
        guard isShowingError else{
            return
        }
        isShowingErrorInfo = true
    }
    
    /// Hides 'errorInfoView' if there is an error
    open func hideErrorInfoIfCan(){
        guard isShowingError else{
            return
        }
        isShowingErrorInfo = false
    }
    
    //MARK: Actions
    @objc private func textChanged(){
        switch validateMode {
        case .validateOnLostFocus, .clearErrorOnTextChanged:
            isShowingError = false
            
        case .validateOnTextChanged:
            validate()
            
        default:
            break
        }
    }
}
