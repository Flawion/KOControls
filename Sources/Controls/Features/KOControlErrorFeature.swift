//
//  KOControlErrorFeature.swift
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

@objc public protocol KOControlErrorFeatureDelegate: NSObjectProtocol {
    var featureContainer: UIView { get }
    
    @objc optional func errorDidShow()
    @objc optional func errorDidHide()
}

public class KOControlErrorFeature {
    // MARK: - Variables
    private weak var delegate: KOControlErrorFeatureDelegate?
    private weak var containerForCustomView: UIView!
    
    private weak var view: UIView!
    private weak var viewWidthConst: NSLayoutConstraint!

    //public
    public private(set) weak var iconView: UIImageView!
    
    public var isShowing: Bool = false {
        didSet {
            if oldValue != isShowing {
                refreshShowing()
            }
        }
    }
    
    public var customView: UIView? {
        didSet {
            refreshCustomView()
        }
    }
    
    public var viewWidth: CGFloat = 32 {
        didSet {
            if oldValue != viewWidth {
                refreshShowing()
            }
        }
    }
    
    public var currentViewWidth: CGFloat? {
        return viewWidthConst?.constant
    }
    
    public var viewCenterXAnchor: NSLayoutXAxisAnchor {
        return view.centerXAnchor
    }
    
    // MARK: - Functions
    // MARK: Initializations
    public init(delegate: KOControlErrorFeatureDelegate) {
        self.delegate = delegate
        initialize()
    }
    
    private func initialize() {
        initializeView()
        initializeContainerForCustomView()
        initializeIconView()
    }
    
    private func initializeView() {
        guard let delegate = delegate else {
            return
        }
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.clear
        _ = delegate.featureContainer.addAutoLayoutSubview(view, toAddConstraints: [.top, .right, .bottom])
        self.view = view
        
        let viewWidthConst = view.widthAnchor.constraint(equalToConstant: 0)
        delegate.featureContainer.addConstraint(viewWidthConst)
        self.viewWidthConst = viewWidthConst
    }
    
    private func initializeContainerForCustomView() {
        let containerForCustomView = UIView()
        containerForCustomView.isHidden = true
        containerForCustomView.backgroundColor = UIColor.clear
        _ = view.addAutoLayoutSubview(containerForCustomView)
        self.containerForCustomView = containerForCustomView
    }
    
    private func initializeIconView() {
        let iconView = UIImageView(image: UIImage(named: "field_error", in: Bundle(for: type(of: self)), compatibleWith: nil))
        iconView.contentMode = .center
        _ = view.addAutoLayoutSubview(iconView)
        self.iconView = iconView
    }
    
    // MARK: View
    private func refreshShowing() {
        isShowing ? showError() : hideError()
    }
    
    private func showError() {
        viewWidthConst.constant = viewWidth
        view.isHidden = false
        delegate?.featureContainer.layoutIfNeeded()
        delegate?.errorDidShow?()
    }
    
    private func hideError() {
        viewWidthConst.constant = 0
        view.isHidden = true
        delegate?.featureContainer.layoutIfNeeded()
        delegate?.errorDidHide?()
    }
    
    private func refreshCustomView() {
        refreshCustomViewVisibility()
        containerForCustomView.fill(withView: customView)
        delegate?.featureContainer.layoutIfNeeded()
    }
    
    private func refreshCustomViewVisibility() {
        let isCustomViewHidden = customView == nil
        containerForCustomView.isHidden = isCustomViewHidden
        iconView.isHidden = !isCustomViewHidden
    }
}
