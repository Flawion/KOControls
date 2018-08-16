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

@objc public protocol KOScrollOffsetBasedViewDelegate : NSObjectProtocol{
    func scrollOffsetBasedView(_ : KOScrollOffsetBasedView, offsetProgress : CGFloat)
}

open class KOScrollOffsetBasedView : UIView, UIScrollViewDelegate{
    //MARK: - Variables
    @IBOutlet public weak var scrollView : UIScrollView?{
        didSet{
            refreshScrollView()
        }
    }
    public var scrollOffsetAxis : KOScrollOffsetAxis = .vertical{
        didSet{
            refreshOffsetProgress(scrollView: scrollView)
        }
    }
    
    public var minOffset : CGFloat = 0{
        didSet{
            refreshOffsetProgress(scrollView: scrollView)
        }
    }
    
    public var maxOffset: CGFloat = 0{
        didSet{
            refreshOffsetProgress(scrollView: scrollView)
        }
    }
    
    @IBOutlet public weak var koDelegate : KOScrollOffsetBasedViewDelegate?{
        didSet{
           refreshOffsetProgress(scrollView: scrollView)
        }
    }
    
    public private(set) var offsetProgress : CGFloat = 0
    
    
    //MARK: - Functions
    private func refreshScrollView(){
        guard let scrollView = scrollView else{
            return
        }
        scrollView.delegate = self
        refreshOffsetProgress(scrollView : scrollView)
    }
    
    private func refreshOffsetProgress(scrollView : UIScrollView?){
        guard let scrollView = scrollView, maxOffset > 0 else{
            offsetProgress = 0
            return
        }
        var contentOffset : CGFloat = scrollView.contentOffset.y
        if scrollOffsetAxis == .horizontal{
            contentOffset = scrollView.contentOffset.x
        }
        contentOffset -= minOffset
        guard contentOffset > 0 else{
            offsetProgress = 0
            return
        }
        contentOffset /= maxOffset
        offsetProgress = min(max(contentOffset, 0.0), 1.0)
        koDelegate?.scrollOffsetBasedView(self, offsetProgress: offsetProgress)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        refreshOffsetProgress(scrollView : scrollView)
    }
}
