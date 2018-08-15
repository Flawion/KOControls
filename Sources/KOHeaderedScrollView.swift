//
//  KOHeaderedScrollView.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 15.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

open class KOHeaderedTableView : KOHeaderedScrollView<UITableView>{
}

open class KOHeaderedCollectionView : KOHeaderedScrollView<UICollectionView>{
    override func initializeScrollViewType() -> UICollectionView {
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    }
}

open class KOHeaderedScrollView<ScrollType> : UIView where ScrollType : UIScrollView {
    //MARK: - Variables
    private weak var scrollViewLeftConst : NSLayoutConstraint!
    private weak var scrollViewTopConst : NSLayoutConstraint!
    private weak var scrollViewRightConst : NSLayoutConstraint!
    private weak var scrollViewBottomConst : NSLayoutConstraint!

    private weak var containerForHeaderView : UIView!
    
    //public
    public private(set) weak var scrollView : ScrollType!
    public var scrollViewInsets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0){
        didSet{
            refreshScrollViewInsets()
        }
    }
    
    public var header : UIView?{
        didSet{
            
        }
    }
    //if height is nil, it will be calculated by autolayout
    public var headerHeight : CGFloat?{
        didSet{
            
        }
    }
    
    public var minimizedHeader : UIView?{
        didSet{
            
        }
    }
    public var minimizedHeaderHeight : CGFloat = 0{
        didSet{
            
        }
    }
   
    
    //MARK: - Functions
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
        initializeHeaderView()
        initializeScrollView()
    }
    
    private func initializeHeaderView(){
        let containerForHeaderView = UIView()
        containerForHeaderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerForHeaderView)
        self.containerForHeaderView = containerForHeaderView
        addConstraints([
            containerForHeaderView.leftAnchor.constraint(equalTo: leftAnchor),
            containerForHeaderView.topAnchor.constraint(equalTo: topAnchor),
            containerForHeaderView.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        
    }
    
    fileprivate func initializeScrollViewType()->ScrollType{
        return ScrollType()
    }
    
    private func initializeScrollView(){
        let scrollView = initializeScrollViewType()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        self.scrollView = scrollView
        let scrollViewLeftConst = scrollView.leftAnchor.constraint(equalTo: leftAnchor, constant: scrollViewInsets.left)
        let scrollViewTopConst = scrollView.topAnchor.constraint(equalTo: containerForHeaderView.bottomAnchor, constant: scrollViewInsets.top)
        let scrollViewRightConst = scrollView.rightAnchor.constraint(equalTo: rightAnchor, constant: -scrollViewInsets.right)
        let scrollViewBottomConst = scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -scrollViewInsets.bottom)
        addConstraints([
            scrollViewLeftConst,
            scrollViewTopConst,
            scrollViewRightConst,
            scrollViewBottomConst
            ])
        self.scrollViewLeftConst = scrollViewLeftConst
        self.scrollViewTopConst = scrollViewTopConst
        self.scrollViewRightConst = scrollViewRightConst
        self.scrollViewBottomConst = scrollViewBottomConst
    }
    
    private func refreshScrollViewInsets(){
        scrollViewLeftConst.constant = scrollViewInsets.left
        scrollViewTopConst.constant = scrollViewInsets.top
        scrollViewRightConst.constant = -scrollViewInsets.right
        scrollViewBottomConst.constant = -scrollViewInsets.bottom
        layoutIfNeeded()
    }
}
