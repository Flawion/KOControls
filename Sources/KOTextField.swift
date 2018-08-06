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

public class KOTextField : UITextField{
    //MARK: Variables
    public var hideErrorMode : KOTextFieldHideErrorModes = .none
    public var isShowingError : Bool = false{
        didSet{
            refreshShowingError()
        }
    }
    
    //error info view variables
    private var errorInfoViewConsts : [NSLayoutConstraint] = []
    private weak var errorInfoShowedInView : UIView!
    private var isShowingErrorInfo : Bool = false{
        didSet{
            refreshShowingErrorInfo()
        }
    }
    
    public private(set) var errorInfoView : KOTextFieldErrorView!
    public weak var showErrorInfoInView : UIView?
    public var showErrorInfoMode : KOTextFieldShowErrorInfoModes = .onFocus{
        didSet{
            refreshShowErrorInfoMode()
        }
    }
    
    //error icon variables
    private(set) weak var errorIconWidthConst : NSLayoutConstraint!
    
    public private(set) weak var errorIconView : UIImageView!
    public var errorIconWidth : CGFloat = 0{
        didSet{
            refreshShowingError()
        }
    }
    public var defaultErrorIconWidth : CGFloat{
        return  0
    }
    
    //overridden rects to avoid intersection with the error icon view
    override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rightViewRect = super.rightViewRect(forBounds: bounds)
        return rightViewRect.offsetBy(dx: -errorIconWidthConst.constant, dy: 0)
    }
    
    override public func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let clearButtonRect = super.clearButtonRect(forBounds: bounds)
        return clearButtonRect.offsetBy(dx: -errorIconWidthConst.constant, dy: 0)
    }
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.textRect(forBounds: bounds)
        textRect.size.width -= errorIconWidthConst.constant
        return textRect
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        var editingRect = super.editingRect(forBounds: bounds)
        editingRect.size.width -= errorIconWidthConst.constant
        return editingRect
    }
    
    //MARK: Functions
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
        //initialize error view
        errorInfoView = KOTextFieldErrorView()
        errorInfoView.translatesAutoresizingMaskIntoConstraints = false
        errorInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(errorViewTap)))
        
        //initialize error icon view
        let errorIconView = UIImageView()
        errorIconView.translatesAutoresizingMaskIntoConstraints = false
        errorIconView.isUserInteractionEnabled = true
        errorIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(errorIconViewTap)))
        addSubview(errorIconView)
        self.errorIconView = errorIconView
        
        let errorIconWidthConst = errorIconView.widthAnchor.constraint(equalToConstant: defaultErrorIconWidth)
        addConstraints([
            errorIconView.rightAnchor.constraint(equalTo: rightAnchor),
            errorIconView.topAnchor.constraint(equalTo: topAnchor),
            errorIconView.bottomAnchor.constraint(equalTo: bottomAnchor),
            errorIconWidthConst
            ])
        self.errorIconWidthConst = errorIconWidthConst
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
        return becomeFirstResponder
    }
    
    override public func resignFirstResponder() -> Bool {
        let resignFirstResponder = super.resignFirstResponder()
        if resignFirstResponder{
            if isShowingError && showErrorInfoMode == .onFocus{
                isShowingErrorInfo = false
            }
        }
        return resignFirstResponder
    }
    
    //MARK: Show/hide error view
    private func refreshShowingError(){
         isShowingError ? showError() : hideError()
    }
    
    private func showError(){
        errorIconWidthConst.constant = errorIconWidth
        errorIconView.isHidden = false
        refreshShowErrorInfoMode()
        layoutIfNeeded()
    }
    
    private func hideError(){
        errorIconWidthConst.constant = 0
        errorIconView.isHidden = true
        isShowingErrorInfo = false
        layoutIfNeeded()
    }
    
    //MARK: Show/hide error info view
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
            errorInfoView.topAnchor.constraint(equalTo: bottomAnchor, constant: 2)
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
