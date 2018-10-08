//
//  KOTextField.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 04.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

//MARK: - Settings
public enum KOTextFieldShowErrorInfoModes{
    case manual
    case onFocus //by default
    case onTapAtErrorView
    case always
}

public enum KOTextFieldValidateModes{
    case manual
    case validateOnTextChanged //by default
    case validateOnLostFocus //and hide error on text changed
    case clearErrorOnTextChanged
}

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
public protocol KOTextValidatorInterface : AnyObject{
    func validate(text : String)->Bool
}

public class KORegexTextValidator : KOTextValidatorInterface{
    private let regex : NSPredicate
    
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
    public var isShowingError : Bool = false{
        didSet{
            if oldValue != isShowingError{
                refreshShowingError()
            }
        }
    }
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
    public private(set) weak var errorIconView : UIImageView!
    public var customErrorView : UIView?{
        didSet{
            refreshCustomErrorView()
        }
    }
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
    
    private var isShowingErrorInfo : Bool = false{
        didSet{
            if oldValue != isShowingErrorInfo{
                refreshShowingErrorInfo(animated: true)
            }
        }
    }
    
    //public
    public private(set) var errorInfoAnimator : KOAnimator!
    public private(set) weak var errorInfoView : KOTextFieldErrorView!
    public weak var showErrorInfoInView : UIView? //default will be a superview
    public var showErrorInfoMode : KOTextFieldShowErrorInfoModes = .onFocus{
        didSet{
            refreshShowErrorInfoMode()
        }
    }
    public var customErrorInfoView : (UIView & KOTextFieldErrorInterface)?{
        didSet{
            refreshCustomErrorInfoView()
        }
    }
    public var errorInfoInsets : UIEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
    
    public var errorInfoShowAnimation : KOAnimation?
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
        errorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(errorViewTap)))
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
        
        let errorInfoView = KOTextFieldErrorView()
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
            //if error info is showing in the other superview than needs, it will be removed from old parent before add
            isErrorInfoHideAnimationRunning = false
            errorInfoAnimator.stopViewAnimation()
            guard showInView != errorInfoShowedInView else{
                return
            }
            hideErrorInfo()
        }
        
        errorInfoView.isMarkerViewHidden = false
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
        errorInfoView.isMarkerViewHidden = !isShowingError
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
        defer {
            let result = customErrorInfoView != nil
            containerForCustomErrorInfoView.isHidden = !result
            errorInfoView.isHidden = result
        }
        
        containerForCustomErrorInfoView.fill(withView: customErrorInfoView)
        refreshCustomErrorInfoMarkerCenterXConst()
        layoutIfNeeded()
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
    open func add(validator : KOTextValidatorInterface){
        guard index(validator: validator) == nil else{
            return
        }
        validators.append(validator)
    }
    
    open func remove(validator : KOTextValidatorInterface){
        guard let index = index(validator: validator) else{
            return
        }
        validators.remove(at: index)
    }

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
    
    open func refreshBorderSettings(){
        refreshBorder()
    }
    
    open func showErrorInfoIfCan(){
        guard isShowingError else{
            return
        }
        isShowingErrorInfo = true
    }
    
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
    
    @objc private func errorViewTap(){
        guard isShowingError, showErrorInfoMode == .onTapAtErrorView else{
            return
        }
        isShowingErrorInfo = !isShowingErrorInfo
    }
}
