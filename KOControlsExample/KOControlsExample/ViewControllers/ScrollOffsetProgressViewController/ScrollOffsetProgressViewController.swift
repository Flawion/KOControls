//
//  ScrollOffsetProgressViewController.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 16.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit
import KOControls

class ScrollOffsetProgressViewController: UIViewController, KOScrollOffsetProgressControllerDelegate{
    //MARK: - Variables
    private var scrollOffsetProgressController: KOScrollOffsetProgressController!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var offsetBasedContentView: UIView!
    @IBOutlet weak var offsetBasedContentTopConst: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userPointsLabel: UILabel!
    
    @IBOutlet weak var userImageHeightConst: NSLayoutConstraint!
    @IBOutlet weak var userImageWidthConst: NSLayoutConstraint!
    @IBOutlet weak var userImageLeftConst: NSLayoutConstraint!
    @IBOutlet weak var userImageTopConst: NSLayoutConstraint!
    
    @IBOutlet weak var userInformationLeftConst: NSLayoutConstraint!
    @IBOutlet weak var userInformationTopConst: NSLayoutConstraint!
    
    private var lastCollectionViewWidth: CGFloat = 0
    private var lastOffsetBasedContentViewWidth : CGFloat = 0
    private let countryCollectionsController : CountryCollectionsController = CountryCollectionsController()
    
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
        DispatchQueue.main.async {
            [weak self] in
            self?.recalculateSizeIfNeed()
        }
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
        initialize()
    }
    
    private func initialize(){
        initializeView()
        initializeCollectionView()
        initializeScrollOffsetBasedView()
    }
    
    private func initializeView(){
         navigationItem.title = "KOScrollOffsetBasedView"
        
        if #available(iOS 11.0, *) {} else{
            offsetBasedContentTopConst.constant = 20
        }
        
        automaticallyAdjustsScrollViewInsets = false
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor.white.cgColor
    }
    
    private func initializeCollectionView(){
        countryCollectionsController.attach(collectionView: collectionView)
        collectionView.allowsSelection = false
    }
    
    private func initializeScrollOffsetBasedView(){
        scrollOffsetProgressController = KOScrollOffsetProgressController()
        scrollOffsetProgressController.delegate = self
        scrollOffsetProgressController.scrollView = collectionView
        scrollOffsetProgressController.maxOffset = 300
        scrollOffsetProgressController.mode = .contentOffsetBased
    }
    
    private func recalculateSizeIfNeed(){
        if offsetBasedContentView.bounds.width != lastOffsetBasedContentViewWidth{
            scrollOffsetProgressController(scrollOffsetProgressController, offsetProgress: scrollOffsetProgressController.progress)
            lastOffsetBasedContentViewWidth = offsetBasedContentView.bounds.width
        }
        
        if collectionView.bounds.width != lastCollectionViewWidth{
            countryCollectionsController.calculateCollectionSize(collectionView, availableWidth: collectionView.bounds.width, itemMaxWidth: 120)
            lastCollectionViewWidth = collectionView.bounds.width
        }
    }
    
    func scrollOffsetProgressController(_: KOScrollOffsetProgressController, offsetProgress: CGFloat) {
        let entryProgress = (1.0 - offsetProgress)
        
        let availableWidth : CGFloat = offsetBasedContentView.bounds.width
        let userImageMaxLeft : CGFloat = ((availableWidth / 2.0) - backBttWidth) - (userImageMaxSize.width / 2.0)
        let userInformationMaxLeft : CGFloat = -(availableWidth - ((availableWidth - backBttWidth) - userImageMaxLeft))
        let userImageNewHeight = entryProgress * userImageMaxSize.height + offsetProgress * userImageMinSize.height
        let userImageNewLeft = entryProgress * userImageMaxLeft + offsetProgress * userImageMinLeftPadding
        
        userImageHeightConst.constant = userImageNewHeight
        userImageWidthConst.constant = entryProgress * userImageMaxSize.width + offsetProgress * userImageMinSize.width
        userImageTopConst.constant = entryProgress * userImageMaxTopPadding + offsetProgress * userImageMinTopPadding
        userImageLeftConst.constant = userImageNewLeft
        userImageView.layer.cornerRadius = userImageNewHeight / 2
    
        userInformationLeftConst.constant = entryProgress * userInformationMaxLeft + offsetProgress * userInformationMinLeftPadding
        userInformationTopConst.constant = entryProgress * userInformationMaxTopPadding + offsetProgress * userInformationMinTopPadding
        
        userPointsLabel.font = UIFont.systemFont(ofSize: entryProgress * userPointsMaxFont + offsetProgress * userPointsMinFont, weight: .medium)
        
        view.layoutIfNeeded()
    }
    
    @IBAction func backBttClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private let scrollOffsetProgressControllerModes : [String] = [
        "contentOffsetBased",
        "translationOffsetBased",
        "scrollingBlockedUntilProgressMax" ]
    
    private let scrollOffsetProgressControllerMaxOffsets : [String] = [
        "200",
        "300",
        "400",
        "500",
        "600",
        "700"
    ]
    var popoverSettings : KOPopoverSettings?
    @IBAction func settingsBttClick(_ sender: UIButton) {
        popoverSettings = KOPopoverSettings(sourceView: sender, sourceRect: sender.bounds)
        
        presentOptionsPicker(withOptions: [scrollOffsetProgressControllerModes, scrollOffsetProgressControllerMaxOffsets], viewLoadedAction: KOActionModel<KOOptionsPickerViewController>(title: "Choose mode and max offset of calculating scroll offset progress", action: {
            (optionsPickerViewController) in
            optionsPickerViewController.mainView.backgroundColor = UIColor.clear
            optionsPickerViewController.leftBarButtonAction = KODialogViewControllerActionModel.cancelAction(withTitle: "Cancel")
            optionsPickerViewController.rightBarButtonAction = KODialogViewControllerActionModel.doneAction(withTitle: "Done", action: {
                (optionsPickerViewController : KOOptionsPickerViewController) in
                
            })
            
        }), postInit: {
            (optionsPickerViewController) in
            optionsPickerViewController.optionsPickerDelegateInstance = KOOptionsPickerCustomViewDelegate(optionsPickerViewController: optionsPickerViewController, widthForComponent: { (component) -> CGFloat in
                return component == 0 ? 240 : 60
            }, heightForComponent: { _ -> CGFloat in
                return 44
            }, viewForRowInComponent: {
                (_, component, title, reusableView : UIView?) in
                guard let reusableLabel = reusableView as? UILabel else{
                    let label = UILabel()
                    label.textColor = UIColor.black
                    label.font = UIFont.systemFont(ofSize: component == 0 ? 14 : 17)
                    label.text = title
                    return label
                }
                reusableLabel.text = title
                return reusableLabel
            })
            
        }, popoverSettings: popoverSettings!)
    }
}
