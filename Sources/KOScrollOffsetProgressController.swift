//
//  KOScrollOffsetBasedView.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 16.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

public enum KOScrollOffsetAxis{
    case vertical
    case horizontal
}

@objc public protocol KOScrollOffsetProgressControllerDelegate : NSObjectProtocol{
    func scrollOffsetProgressController(_ : KOScrollOffsetProgressController, offsetProgress : CGFloat)
}

public enum KOScrollOffsetProgressModes{
    case contentOffsetBased
    case translationOffsetBased
    case scrollingBlockedUntilProgressMax
}

open class KOScrollOffsetProgressController : NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate{
    //MARK: - Variables
    private weak var calculateOffsetGesture : UIPanGestureRecognizer?
    private var contentOffset : CGFloat = 0
    private var lastContentOffset : CGFloat = 0
    private var isScrollBlockedUntilProgressMax : Bool{
        return mode == .scrollingBlockedUntilProgressMax
    }
    
    public weak var koDelegate : KOScrollOffsetProgressControllerDelegate?{
        didSet{
            calculateOffsetProgress()
        }
    }
    
    public weak var scrollView : UIScrollView?{
        didSet{
            refreshScrollView()
        }
    }
    
    public var mode : KOScrollOffsetProgressModes = .contentOffsetBased{
        didSet{
            refreshMode()
        }
    }
    
    public var scrollOffsetAxis : KOScrollOffsetAxis = .vertical{
        didSet{
            calculateOffsetProgress()
        }
    }
    
    public var minOffset : CGFloat = 0{
        didSet{
            calculateOffsetProgress()
        }
    }
    
    public var maxOffset: CGFloat = 0{
        didSet{
            calculateOffsetProgress()
        }
    }
    
    public var offsetRange : CGFloat{
        return maxOffset - minOffset
    }
    
    public private(set) var progress : CGFloat = 0{
        didSet{
            koDelegate?.scrollOffsetProgressController(self, offsetProgress: progress)
        }
    }
    
    //MARK: - Functions
    private func refreshMode(){
        scrollView?.setContentOffset(CGPoint.zero, animated: false)
        calculateOffsetGesture?.isEnabled = mode == .scrollingBlockedUntilProgressMax
        contentOffset = 0
        lastContentOffset = 0
        calculateContentOffsetAndProgress()
    }
    
    //MARK: Scroll view
    private func refreshScrollView(){
        guard let scrollView = scrollView else{
            return
        }
        scrollView.delegate = self
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
    
    //MARK: Gesture
    @objc private func calculateOffsetGestureAction(_ panGesture : UIPanGestureRecognizer){
        calculateContentOffsetAndProgress()
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: Calculate content and progress
    private func calculateContentOffsetAndProgress(){
        if isScrollBlockedUntilProgressMax{
            calculateContentOffsetFromGesture()
        }else{
            calculateContentOffsetFromScroll()
        }
        calculateOffsetProgress()
    }
    
    private func calculateContentOffsetFromScroll(){
        guard let scrollView = scrollView else{
            contentOffset = 0
            return
        }
        
        var offset : CGFloat = 0
        
        //calculate offset
        switch mode{
        case .contentOffsetBased:
            offset = scrollView.contentOffset.y
            if scrollOffsetAxis == .horizontal{
                offset = scrollView.contentOffset.x
            }
            contentOffset = offset
            
        case .translationOffsetBased:
            if scrollOffsetAxis == .horizontal{
                //prevents from bouncing
                guard scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x <= (scrollView.contentSize.width - scrollView.bounds.width) else{
                    return
                }
                offset = scrollView.contentOffset.x
            }else{
                //prevents from bouncing
                guard scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y <= (scrollView.contentSize.height - scrollView.bounds.height) else{
                    return
                }
                offset = scrollView.contentOffset.y
            }
        
            offset = offset - lastContentOffset
            contentOffset += offset
            contentOffset = min(offsetRange, max(0, contentOffset))
            lastContentOffset = scrollView.contentOffset.y
            
        default:
            break
        }
    }

    private func calculateContentOffsetFromGesture(){
        guard let scrollView = scrollView, let calculateOffsetGesture = calculateOffsetGesture else{
            contentOffset = 0
            return
        }
        
        defer {
            calculateOffsetGesture.setTranslation(CGPoint.zero, in: scrollView)
        }
        
        var offset : CGFloat = contentOffset
        let translation = calculateOffsetGesture.translation(in: scrollView)
        if scrollOffsetAxis == .horizontal{
            //dosen't adds new values until scroll contentOffset is attaching to the view
            guard scrollView.contentOffset.y <= 0 else{
                return
            }
            offset -= translation.x
        }else{
            //dosen't adds new values until scroll contentOffset is attaching to the view
            guard scrollView.contentOffset.y <= 0 else{
                return
            }
            offset -= translation.y
        }
        offset = max(0, offset)
        contentOffset = offset
    }
    
    private func calculateOffsetProgress(){
        guard maxOffset > minOffset, maxOffset > 0 else{
            progress = 0
            return
        }
        
        //calculate progress
        var offset : CGFloat = contentOffset
        offset -= minOffset
        guard offset > 0 else{
            progress = 0
            return
        }
        offset /= offsetRange
        progress = min(max(offset, 0.0), 1.0)
    }
    
    //MARK: Public
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isScrollBlockedUntilProgressMax else{
            //prevent from scroll until progress is max
            if progress < 1{
                switch scrollOffsetAxis{
                case .horizontal:
                    if scrollView.contentOffset.x > 0{
                        scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y), animated: false)
                    }
                case .vertical:
                    if scrollView.contentOffset.y > 0{
                        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0), animated: false)
                    }
                }
            }
            return
        }
        calculateContentOffsetAndProgress()
    }
}
