//
//  KOScrollOffsetBasedView.swift
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

public enum KOScrollOffsetAxis {
    case vertical
    case horizontal
}

@objc public protocol KOScrollOffsetProgressControllerDelegate: NSObjectProtocol {
    func scrollOffsetProgressController(_: KOScrollOffsetProgressController, offsetProgress: CGFloat)
}

/// Mode of calculating progress
///
/// - contentOffsetBased: (default) progress is calculating from current contentOffset
/// - translationOffsetBased: progress is calculating based on difference between last content offset and new one
/// - scrollingBlockedUntilProgressMax: progress is calculating based on difference between touches (last and new one), scroll is completely blocked until the progress reaches value 1.0
public enum KOScrollOffsetProgressModes {
    case contentOffsetBased
    case translationOffsetBased
    case scrollingBlockedUntilProgressMax
}

/// Controller that calculates progress (0.0 to 1.0) from given range based on scroll view offset and selected calculating 'mode'.
open class KOScrollOffsetProgressController: NSObject, UIGestureRecognizerDelegate {
    // MARK: - Variables
    private weak var calculateOffsetGesture: UIPanGestureRecognizer?
    private var contentOffset: CGFloat = 0
    private var lastContentOffset: CGFloat = 0
    private var isScrollBlockedUntilProgressMax: Bool {
        return mode == .scrollingBlockedUntilProgressMax
    }
    
    private var scrollOffsetObserver: KOPropertyObserver<UIScrollView, CGPoint>?
    
    //public
    
    public weak var delegate: KOScrollOffsetProgressControllerDelegate? {
        didSet {
            calculateOffsetProgress()
        }
    }
    
    /// Scroll view based on which the progress will be calculated
    public var scrollView: UIScrollView? {
        set {
            attachToScrollView(newValue)
        }
        get {
            return scrollOffsetObserver?.subject
        }
    }
    
    /// Mode of calculating progress
    public var mode: KOScrollOffsetProgressModes = .contentOffsetBased {
        didSet {
            refreshMode()
        }
    }
    
    /// Indicates on which axis it will be doing a calculation
    public var scrollOffsetAxis: KOScrollOffsetAxis = .vertical {
        didSet {
            calculateOffsetProgress()
        }
    }
    
    /// Initial offset that must be reach to start the calculation
    public var minOffset: CGFloat = 0 {
        didSet {
            calculateOffsetProgress()
        }
    }
    
    /// End offset that must be reach to get maximum progress, must be greater than minOffset
    public var maxOffset: CGFloat = 0 {
        didSet {
            calculateOffsetProgress()
        }
    }
    
    /// Offset between max and min, where progress is changing
    public var offsetRange: CGFloat {
        return maxOffset - minOffset
    }
    
    /// Calculated progress
    public private(set) var progress: CGFloat = 0 {
        didSet {
            progressChangedEvent?(progress)
            delegate?.scrollOffsetProgressController(self, offsetProgress: progress)
        }
    }
    
    /// Event that will be invoked when progress was change. It is getting progress as parameter.
    public var progressChangedEvent : ((_ : CGFloat) -> Void)?
    
    // MARK: - Functions
    
    /// Init
    ///
    /// - Parameters:
    ///   - scrollView: scroll view based on which the progress will be calculated
    ///   - minOffset: initial offset that must be reach to start the calculation
    ///   - maxOffset: end offset that must be reach to get maximum progress, must be greater than minOffset
    public init(scrollView: UIScrollView?, minOffset: CGFloat, maxOffset: CGFloat) {
        super.init()

        self.minOffset = minOffset
        self.maxOffset = maxOffset
        attachToScrollView(scrollView)
    }
    
    private func refreshMode() {
        scrollView?.setContentOffset(CGPoint.zero, animated: false)
        calculateOffsetGesture?.isEnabled = mode == .scrollingBlockedUntilProgressMax
        resetOffsetParameters()
        calculateContentOffsetAndProgress()
    }

    private func resetOffsetParameters() {
        contentOffset = 0
        lastContentOffset = 0
    }

    // MARK: Scroll view
    private func attachToScrollView(_ scrollView: UIScrollView?) {
        guard let scrollView = scrollView else {
            return
        }
        bindScrollView(scrollView)
        createCalculateOffsetGesture(forScrollView: scrollView)
        resetOffsetParameters()
        calculateContentOffsetAndProgress()
    }

    private func bindScrollView(_ scrollView: UIScrollView) {
        scrollOffsetObserver = KOPropertyObserver<UIScrollView, CGPoint>(subject: scrollView, propertyPath: \UIScrollView.contentOffset, propertyChangedEvent: { [weak self](subject, property) in
            self?.scrollView(subject, newContentOffset: property.newValue ?? subject.contentOffset)
        })
    }

    private func createCalculateOffsetGesture(forScrollView scrollView: UIScrollView) {
        let calculateOffsetGesture = UIPanGestureRecognizer(target: self, action: #selector(calculateOffsetGestureAction(_:)))
        calculateOffsetGesture.delegate = self
        calculateOffsetGesture.isEnabled = isScrollBlockedUntilProgressMax
        scrollView.addGestureRecognizer(calculateOffsetGesture)
        self.calculateOffsetGesture = calculateOffsetGesture
    }
    
    // MARK: Gesture
    @objc private func calculateOffsetGestureAction(_ panGesture: UIPanGestureRecognizer) {
        calculateContentOffsetAndProgress()
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: Calculate content and progress
    private func calculateContentOffsetAndProgress() {
        if isScrollBlockedUntilProgressMax {
            calculateContentOffsetFromGesture()
        } else {
            calculateContentOffsetFromScrollView()
        }
        calculateOffsetProgress()
    }

    private func calculateContentOffsetFromScrollView() {
        guard let scrollView = scrollView else {
            contentOffset = 0
            return
        }

        switch mode {
        case .contentOffsetBased:
            calculateContentOffsetFromScrollViewContentOffset(scrollView)
            
        case .translationOffsetBased:
            calculateContentOffsetFromScrollViewTranslationOffset(scrollView)
            
        default:
            break
        }
    }

    private func calculateContentOffsetFromScrollViewContentOffset(_ scrollView: UIScrollView) {
        var offset: CGFloat = scrollView.contentOffset.y
        if scrollOffsetAxis == .horizontal {
            offset = scrollView.contentOffset.x
        }
        contentOffset = offset
    }

    private func calculateContentOffsetFromScrollViewTranslationOffset(_ scrollView: UIScrollView) {
        guard var offset: CGFloat = getContentOffsetIfNotBouncing(fromScrollView: scrollView) else {
            // prevents from jumping
            return
        }
        offset -= lastContentOffset
        contentOffset += offset
        contentOffset = min(offsetRange, max(0, contentOffset))
        lastContentOffset = scrollView.contentOffset.y
    }

    private func getContentOffsetIfNotBouncing(fromScrollView scrollView: UIScrollView) -> CGFloat? {
        return scrollOffsetAxis == .horizontal ? getContentOffsetHorizontalIfNotBouncing(fromScrollView: scrollView) : getContentOffsetVerticalIfNotBouncing(fromScrollView: scrollView)
    }

    private func getContentOffsetHorizontalIfNotBouncing(fromScrollView scrollView: UIScrollView) -> CGFloat? {
        guard isScrollViewNotBouncingHorizontal(scrollView) else {
            return nil
        }
        return scrollView.contentOffset.x
    }

    private func isScrollViewNotBouncingHorizontal(_ scrollView: UIScrollView) -> Bool {
        return scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x <= (scrollView.contentSize.width - scrollView.bounds.width)
    }

    private func getContentOffsetVerticalIfNotBouncing(fromScrollView scrollView: UIScrollView) -> CGFloat? {
        guard isScrollViewNotBouncingVertical(scrollView) else {
            return nil
        }
        return scrollView.contentOffset.y
    }

    private func isScrollViewNotBouncingVertical(_ scrollView: UIScrollView) -> Bool {
        return scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y <= (scrollView.contentSize.height - scrollView.bounds.height)
    }

    private func calculateContentOffsetFromGesture() {
        guard let scrollView = scrollView, let calculateOffsetGesture = calculateOffsetGesture else {
            contentOffset = 0
            return
        }
        
        defer {
            calculateOffsetGesture.setTranslation(CGPoint.zero, in: scrollView)
        }

        guard let translation = getTranslationOnAxisIfContentOffsetGreaterThanZero(fromGesture: calculateOffsetGesture, scrollView: scrollView) else {
            return
        }

        var offset: CGFloat = contentOffset
        offset -= translation
        offset = max(0, offset)
        contentOffset = offset
    }

    private func  getTranslationOnAxisIfContentOffsetGreaterThanZero(fromGesture gesture: UIPanGestureRecognizer, scrollView: UIScrollView) -> CGFloat? {
        let translation = gesture.translation(in: scrollView)
        return scrollOffsetAxis == .horizontal ? getTranslationVerticalIfContentOffsetGreaterThanZero(fromTranslation: translation, scrollView: scrollView) :
        getTranslationVerticalIfContentOffsetGreaterThanZero(fromTranslation: translation, scrollView: scrollView)
    }

    private func  getTranslationHorizontalIfContentOffsetGreaterThanZero(fromTranslation translation: CGPoint, scrollView: UIScrollView) -> CGFloat? {
        guard scrollView.contentOffset.x <= 0 else {
            return nil
        }
        return translation.x
    }

    private func  getTranslationVerticalIfContentOffsetGreaterThanZero(fromTranslation translation: CGPoint, scrollView: UIScrollView) -> CGFloat? {
        guard scrollView.contentOffset.y <= 0 else {
            return nil
        }
        return translation.y
    }

    private func calculateOffsetProgress() {
        guard maxOffset > minOffset, maxOffset > 0 else {
            progress = 0
            return
        }

        var offset: CGFloat = contentOffset
        offset -= minOffset
        guard offset > 0 else {
            progress = 0
            return
        }
        offset /= offsetRange
        progress = min(max(offset, 0.0), 1.0)
    }
    
    private func scrollView(_ scrollView: UIScrollView, newContentOffset contentOffset: CGPoint) {
        guard !isScrollBlockedUntilProgressMax else {
            preventFromScrollUntilProgressIsMax(scrollView, contentOffset: contentOffset)

            return
        }
        calculateContentOffsetAndProgress()
    }

    private func preventFromScrollUntilProgressIsMax(_ scrollView: UIScrollView, contentOffset: CGPoint) {
        guard progress < 1 else {
            return
        }
        preventFromScroll(scrollView, contentOffset: contentOffset)
    }

    private func preventFromScroll(_ scrollView: UIScrollView, contentOffset: CGPoint) {
        switch scrollOffsetAxis {
        case .horizontal:
            preventFromScrollHorizontal(scrollView, contentOffset: contentOffset)

        case .vertical:
            preventFromScrollVertical(scrollView, contentOffset: contentOffset)
        }
    }

    private func preventFromScrollHorizontal(_ scrollView: UIScrollView, contentOffset: CGPoint) {
        guard contentOffset.x > 0 else {
            return
        }
        scrollView.setContentOffset(CGPoint(x: 0, y: contentOffset.y), animated: false)
    }

    private func preventFromScrollVertical(_ scrollView: UIScrollView, contentOffset: CGPoint) {
        guard contentOffset.y > 0 else {
            return
        }
        scrollView.setContentOffset(CGPoint(x: contentOffset.x, y: 0), animated: false)
    }
}
