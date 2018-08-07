//
//  KOTextField.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 04.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

public enum KOTextFieldShowErrorInfoModes{
    case onFocus
    case onTapAtErrorIcon
    case always
}

public enum KOTextFieldHideErrorModes{
    case none
    case onTextChanged
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

public class KOTextField : UITextField{
    //MARK: - Variables
    //public
    public var hideErrorMode : KOTextFieldHideErrorModes = .none
    public var isShowingError : Bool = false{
        didSet{
            refreshShowingError()
        }
    }
    public var borderSettings : KOTextFieldBorderSettings?{
        didSet{
            refreshBorderSettings()
        }
    }
    
    //MARK: Error variables
    private weak var errorView : UIView!
    private weak var containerForCustomErrorView: UIView!
    private weak var errorWidthConst : NSLayoutConstraint!
    
    //public
    public var defaultErrorWidth : CGFloat{
        return  0
    }
    public var errorWidth : CGFloat = 0{
        didSet{
            refreshShowingError()
        }
    }
    public private(set) weak var errorIconView : UIImageView!
    public var customErrorView : UIView?{
        didSet{
            refreshCustomErrorView()
        }
    }
    
    //MARK: Error info variables
    private var errorInfoViewConsts : [NSLayoutConstraint] = []
    private weak var errorInfoShowedInView : UIView!
    private var isShowingErrorInfo : Bool = false{
        didSet{
            refreshShowingErrorInfo()
        }
    }
    
    //public
    public private(set) var errorInfoView : KOTextFieldErrorView!
    public weak var showErrorInfoInView : UIView?
    public var showErrorInfoMode : KOTextFieldShowErrorInfoModes = .onFocus{
        didSet{
            refreshShowErrorInfoMode()
        }
    }
   
    //MARK: - Functions
    //MARK: Overridden rects to avoid intersection with the error icon view
    override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rightViewRect = super.rightViewRect(forBounds: bounds)
        return rightViewRect.offsetBy(dx: -errorWidthConst.constant, dy: 0)
    }
    
    override public func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let clearButtonRect = super.clearButtonRect(forBounds: bounds)
        return clearButtonRect.offsetBy(dx: -errorWidthConst.constant, dy: 0)
    }
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.textRect(forBounds: bounds)
        textRect.size.width -= errorWidthConst.constant
        return textRect
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        var editingRect = super.editingRect(forBounds: bounds)
        editingRect.size.width -= errorWidthConst.constant
        return editingRect
    }
    
    //MARK: Initialization functions
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
    }
    
    private func initializeErrorView(){
        //create views
        //error view
        let errorView = UIView()
        errorView.backgroundColor = UIColor.clear
        errorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(errorView)
        self.errorView = errorView
        
        //container for custom error view
        let containerForCustomErrorView = UIView()
        containerForCustomErrorView.backgroundColor = UIColor.clear
        containerForCustomErrorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(containerForCustomErrorView)
        self.containerForCustomErrorView = containerForCustomErrorView
        
        //error icon view
        let errorIconView = UIImageView()
        errorIconView.translatesAutoresizingMaskIntoConstraints = false
        errorIconView.isUserInteractionEnabled = true
        errorIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(errorIconViewTap)))
        errorView.addSubview(errorIconView)
        self.errorIconView = errorIconView
        
        //create constraints
        //for error view
        let errorWidthConst = errorView.widthAnchor.constraint(equalToConstant: defaultErrorWidth)
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
        errorInfoView = KOTextFieldErrorView()
        errorInfoView.translatesAutoresizingMaskIntoConstraints = false
        errorInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(errorViewTap)))
    }
    
    override public func didMoveToSuperview() {
        refreshShowingErrorInfo()
    }
    
    //MARK: Responder functions
    override public func becomeFirstResponder() -> Bool {
        let becomeFirstResponder = super.becomeFirstResponder()
        if becomeFirstResponder{
            if isShowingError && showErrorInfoMode == .onFocus{
                isShowingErrorInfo = true
            }
        }
        refreshBorder(isFirstResponder: becomeFirstResponder)
        return becomeFirstResponder
    }
    
    override public func resignFirstResponder() -> Bool {
        let resignFirstResponder = super.resignFirstResponder()
        if resignFirstResponder{
            if isShowingError && showErrorInfoMode == .onFocus{
                isShowingErrorInfo = false
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
    }
    
    private func hideError(){
        errorWidthConst.constant = 0
        errorView.isHidden = true
        isShowingErrorInfo = false
        layoutIfNeeded()
    }
    
    private func refreshCustomErrorView(){
        guard containerForCustomErrorView.subviews.first != customErrorView else{
            //nothing changed
            return
        }
        
        //delete old ones
        containerForCustomErrorView.removeConstraints(containerForCustomErrorView.constraints)
        for subview in containerForCustomErrorView.subviews{
            subview.removeFromSuperview()
        }
        
        //add new one if need
        if let customErrorView = self.customErrorView{
            customErrorView.translatesAutoresizingMaskIntoConstraints = false
            containerForCustomErrorView.addSubview(customErrorView)
            containerForCustomErrorView.addConstraints([
                customErrorView.leftAnchor.constraint(equalTo: containerForCustomErrorView.leftAnchor),
                customErrorView.topAnchor.constraint(equalTo: containerForCustomErrorView.topAnchor),
                customErrorView.rightAnchor.constraint(equalTo: containerForCustomErrorView.rightAnchor),
                customErrorView.bottomAnchor.constraint(equalTo: containerForCustomErrorView.bottomAnchor)
                ])
        }
        
        layoutIfNeeded()
    }
    
    //MARK: Error info view
    private func refreshShowingErrorInfo(){
        isShowingErrorInfo ? showErrorInfo() : hideErrorInfo()
    }
    
    private func showErrorInfo(){
        guard let showInView = showErrorInfoInView ?? self.superview else{
            return
        }
        showInView.addSubview(errorInfoView)
        showInView.addConstraints([
            errorInfoView.rightAnchor.constraint(equalTo: rightAnchor),
            errorInfoView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor),
            errorInfoView.topAnchor.constraint(equalTo: bottomAnchor, constant: 2),
            errorInfoView.markerCenterXEqualTo(errorView.centerXAnchor)
            ])
        errorInfoShowedInView = showInView
    }
    
    private func hideErrorInfo(){
        defer {
            errorInfoView.removeFromSuperview()
            errorInfoViewConsts = []
            errorInfoShowedInView = nil
        }
        
        guard let errorViewShowedInView = errorInfoShowedInView else{
            return
        }
        errorViewShowedInView.removeConstraints(errorInfoViewConsts)
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
    
    //MARK: Public functions
    public func refreshBorderSettings(){
        refreshBorder()
    }
    
    //MARK: Actions
    @objc private func errorViewTap(){
        
    }
    
    @objc private func errorIconViewTap(){
        guard isShowingError, showErrorInfoMode == .onTapAtErrorIcon else{
            return
        }
        isShowingErrorInfo = !isShowingErrorInfo
    }
}
