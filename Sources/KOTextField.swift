//
//  KOTextField.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 04.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

public class KOTextField : UITextField{
    private var errorViewConsts : [NSLayoutConstraint] = []
    private weak var errorViewShowedInView : UIView!
    
    public private(set) var errorView : KOTextFieldErrorView!
    
    public weak var showErrorInView : UIView?
    public var isShowingError : Bool = false{
        didSet{
            refreshShowingError()
        }
    }
    
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
        errorView = KOTextFieldErrorView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        //to test
        isShowingError = true
        refreshShowingError()
    }
    
    override public func didMoveToSuperview() {
        refreshShowingError()
    }
    
    //MARK: Show/hide error
    private func refreshShowingError(){
        isShowingError ? showError() : hideError()
    }
    
    private func showError(){
        guard let showInView = showErrorInView ?? self.superview else{
            return
        }
        showInView.addSubview(errorView)
        showInView.addConstraints([
            errorView.rightAnchor.constraint(equalTo: rightAnchor),
            errorView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor),
            errorView.topAnchor.constraint(equalTo: bottomAnchor, constant: 2)
            ])
        errorViewShowedInView = showInView
    }
    
    private func hideError(){
        defer {
            errorView.removeFromSuperview()
            errorViewConsts = []
            errorViewShowedInView = nil
        }
        
        guard let errorViewShowedInView = errorViewShowedInView else{
            return
        }
        errorViewShowedInView.removeConstraints(errorViewConsts)
    }
}
