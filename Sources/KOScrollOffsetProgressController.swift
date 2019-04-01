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

/// Indicates on which axis it will be doing a calculation
///
/// - vertical: vertical
/// - horizontal: horizontal
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
    public weak var scrollView: UIScrollView? {
        set {
            bindScrollView(newValue)
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
        bindScrollView(scrollView)
    }
    
    private func refreshMode() {
        scrollView?.setContentOffset(CGPoint.zero, animated: false)
        calculateOffsetGesture?.isEnabled = mode == .scrollingBlockedUntilProgressMax
        contentOffset = 0
        lastContentOffset = 0
        calculateContentOffsetAndProgress()
    }
    
    // MARK: Scroll view
    private func bindScrollView(_ scrollView: UIScrollView?) {
        guard let scrollView = scrollView else {
            return
        }
        
        scrollOffsetObserver = KOPropertyObserver<UIScrollView, CGPoint>(subject: scrollView, propertyPath: \UIScrollView.contentOffset, propertyChangedEvent: { [weak self](subject, property) in
            self?.scrollView(subject, newContentOffset: property.newValue ?? subject.contentOffset)
        })
        
        contentOffset = 0
        lastContentOffset = 0
        calculateContentOffsetAndProgress()
        
        //add gesture
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
            calculateContentOffsetFromScroll()
        }
        calculateOffsetProgress()
    }
    
    private func calculateContentOffsetFromScroll() {
        guard let scrollView = scrollView else {
            contentOffset = 0
            return
        }
        
        var offset: CGFloat = 0
        
        //calculate offset
        switch mode {
        case .contentOffsetBased:
            offset = scrollView.contentOffset.y
            if scrollOffsetAxis == .horizontal {
                offset = scrollView.contentOffset.x
            }
            contentOffset = offset
            
        case .translationOffsetBased:
            if scrollOffsetAxis == .horizontal {
                //prevents from bouncing
                guard scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x <= (scrollView.contentSize.width - scrollView.bounds.width) else {
                    return
                }
                offset = scrollView.contentOffset.x
            } else {
                //prevents from bouncing
                guard scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y <= (scrollView.contentSize.height - scrollView.bounds.height) else {
                    return
                }
                offset = scrollView.contentOffset.y
            }
        
            offset -= lastContentOffset
            contentOffset += offset
            contentOffset = min(offsetRange, max(0, contentOffset))
            lastContentOffset = scrollView.contentOffset.y
            
        default:
            break
        }
    }

    private func calculateContentOffsetFromGesture() {
        guard let scrollView = scrollView, let calculateOffsetGesture = calculateOffsetGesture else {
            contentOffset = 0
            return
        }
        
        defer {
            calculateOffsetGesture.setTranslation(CGPoint.zero, in: scrollView)
        }
        
        var offset: CGFloat = contentOffset
        let translation = calculateOffsetGesture.translation(in: scrollView)
        if scrollOffsetAxis == .horizontal {
            //dosen't adds new values until scroll contentOffset is attaching to the view
            guard scrollView.contentOffset.y <= 0 else {
                return
            }
            offset -= translation.x
        } else {
            //dosen't adds new values until scroll contentOffset is attaching to the view
            guard scrollView.contentOffset.y <= 0 else {
                return
            }
            offset -= translation.y
        }
        offset = max(0, offset)
        contentOffset = offset
    }
    
    private func calculateOffsetProgress() {
        guard maxOffset > minOffset, maxOffset > 0 else {
            progress = 0
            return
        }
        
        //calculate progress
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
            //prevent from scroll until progress is max
            if progress < 1 {
                switch scrollOffsetAxis {
                case .horizontal:
                    if contentOffset.x > 0 {
                        scrollView.setContentOffset(CGPoint(x: 0, y: contentOffset.y), animated: false)
                    }
                case .vertical:
                    if contentOffset.y > 0 {
                        scrollView.setContentOffset(CGPoint(x: contentOffset.x, y: 0), animated: false)
                    }
                }
            }
            return
        }
        calculateContentOffsetAndProgress()
    }
}
