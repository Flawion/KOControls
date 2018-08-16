//
//  ScrollOffsetBasedViewController.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 16.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit
import KOControls

class ScrollOffsetBasedViewController: UIViewController, KOScrollOffsetBasedViewDelegate{
    //MARK: - Variables
    @IBOutlet weak var offsetBasedContentTopConst: NSLayoutConstraint!
    @IBOutlet weak var scrollOffsetBasedView: KOScrollOffsetBasedView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userPointsLabel: UILabel!
    
    @IBOutlet weak var userImageHeightConst: NSLayoutConstraint!
    @IBOutlet weak var userImageWidthConst: NSLayoutConstraint!
    @IBOutlet weak var userImageLeftConst: NSLayoutConstraint!
    @IBOutlet weak var userImageTopConst: NSLayoutConstraint!
    
    @IBOutlet weak var userInformationLeftConst: NSLayoutConstraint!
    @IBOutlet weak var userInformationTopConst: NSLayoutConstraint!
    
    //MARK: Settable parameters
    private let backBttWidth : CGFloat = 40
    
    private let userInformationMinLeftPadding : CGFloat = 8
    private let userInformationMinTopPadding : CGFloat = 5
    private let userInformationMaxTopPadding : CGFloat = 158
    
    private let userImageMaxTopPadding : CGFloat = 50
    private let userImageMinTopPadding : CGFloat = 5
    private let userImageMinLeftPadding : CGFloat = 8
    private let userImageMaxSize : CGSize = CGSize(width: 100, height: 100)
    private let userImageMinSize : CGSize = CGSize(width: 30, height: 30)
    
    private let userPointsMaxFont : CGFloat = 28
    private let userPointsMinFont : CGFloat = 17
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //MARK: - Functions
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollOffsetBasedView(scrollOffsetBasedView, offsetProgress: scrollOffsetBasedView.offsetProgress)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "KOScrollOffsetBasedView"
        initialize()
    }
    
    private func initialize(){
        initializeView()
        initializeScrollOffsetBasedView()
    }
    
    private func initializeView(){
        if #available(iOS 11.0, *) {} else{
            offsetBasedContentTopConst.constant = 20
        }
        
        automaticallyAdjustsScrollViewInsets = false
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor.white.cgColor
    }
    
    private func initializeScrollOffsetBasedView(){
        scrollOffsetBasedView.maxOffset = 150
    }
    
    func scrollOffsetBasedView(_: KOScrollOffsetBasedView, offsetProgress: CGFloat) {
        let defaultValueProgress = (1.0 - offsetProgress)
        
        let userImageMaxLeft : CGFloat = ((view.bounds.width / 2.0) - backBttWidth) - (userImageMaxSize.width / 2.0)
        let userInformationMaxLeft : CGFloat = -(view.bounds.width - ((view.bounds.width - backBttWidth) - userImageMaxLeft))
        let userImageNewHeight = defaultValueProgress * userImageMaxSize.height + offsetProgress * userImageMinSize.height
        let userImageNewLeft = defaultValueProgress * userImageMaxLeft + offsetProgress * userImageMinLeftPadding
        
        userImageHeightConst.constant = userImageNewHeight
        userImageWidthConst.constant = defaultValueProgress * userImageMaxSize.width + offsetProgress * userImageMinSize.width
        userImageTopConst.constant = defaultValueProgress * userImageMaxTopPadding + offsetProgress * userImageMinTopPadding
        userImageLeftConst.constant = userImageNewLeft
        userImageView.layer.cornerRadius = userImageNewHeight / 2
    
        userInformationLeftConst.constant = defaultValueProgress * userInformationMaxLeft + offsetProgress * userInformationMinLeftPadding
        userInformationTopConst.constant = defaultValueProgress * userInformationMaxTopPadding + offsetProgress * userInformationMinTopPadding
        
        userPointsLabel.font = UIFont.systemFont(ofSize: defaultValueProgress * userPointsMaxFont + offsetProgress * userPointsMinFont, weight: .medium)
        
        view.layoutIfNeeded()
    }
    
    @IBAction func backBttClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
