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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var offsetBasedContentView: UIView!
    @IBOutlet weak var userPointsLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var offsetBasedContentTopConst: NSLayoutConstraint!
    
    @IBOutlet weak var userImageHeightConst: NSLayoutConstraint!
    @IBOutlet weak var userImageWidthConst: NSLayoutConstraint!
    @IBOutlet weak var userImageLeftConst: NSLayoutConstraint!
    @IBOutlet weak var userImageTopConst: NSLayoutConstraint!
    
    @IBOutlet weak var userInformationLeftConst: NSLayoutConstraint!
    @IBOutlet weak var userInformationRightConst: NSLayoutConstraint!
    @IBOutlet weak var userInformationTopConst: NSLayoutConstraint!
    
    private var lastCollectionViewWidth: CGFloat = 0
    private var lastOffsetBasedContentViewWidth : CGFloat = 0
    private let countryCollectionsController : CountryCollectionsController = CountryCollectionsController()
    
    //MARK: Scroll offset progress
    private var scrollOffsetProgressController: KOScrollOffsetProgressController!
    private var popoverSettings : KOPopoverSettings?
    
    private let scrollOffsetProgressModes : [String] = [
        "contentOffsetBased",
        "translationOffsetBased",
        "scrollingBlockedUntilProgressMax" ]
    
    private let scrollOffsetProgressMaxOffsets : [String] = [
        "200",
        "300",
        "400",
        "500",
        "600",
        "700"
    ]
    
    private var selectedScrollOffsetProgressModeIndex : Int = 0{
        didSet{
            switch selectedScrollOffsetProgressModeIndex {
            case 0:
                scrollOffsetProgressController.mode = .contentOffsetBased
            case 1:
                scrollOffsetProgressController.mode = .translationOffsetBased
            case 2:
                scrollOffsetProgressController.mode = .scrollingBlockedUntilProgressMax
            default: break
            }
        }
    }
    
    private var selectedScrollOffsetProgressMaxOffsetIndex : Int = 1{
        didSet{
            let numberFormatter = NumberFormatter()
            scrollOffsetProgressController.maxOffset = CGFloat(numberFormatter.number(from: scrollOffsetProgressMaxOffsets[selectedScrollOffsetProgressMaxOffsetIndex])?.floatValue ?? 300)
        }
    }
    
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
        
        gradientView.gradientLayer.colors = [UIColor.black.cgColor, UIColor(red: 49/255, green: 49/255, blue: 49/255, alpha: 1.0).cgColor ]
        gradientView.gradientLayer.locations = [0, 0.5]
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
        userInformationRightConst.constant = entryProgress * userInformationMinLeftPadding + offsetProgress * backBttWidth
        
        userPointsLabel.font = UIFont.systemFont(ofSize: entryProgress * userPointsMaxFont + offsetProgress * userPointsMinFont, weight: .medium)
        
        view.layoutIfNeeded()
    }
    
    @IBAction func backBttClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
   
    @IBAction func settingsBttClick(_ sender: UIButton) {
        popoverSettings = KOPopoverSettings(sourceView: sender, sourceRect: sender.bounds)
        
        presentOptionsPicker(withOptions: [scrollOffsetProgressModes, scrollOffsetProgressMaxOffsets], viewLoadedAction: KOActionModel<KOOptionsPickerViewController>(title: "Choose mode and max offset of calculating scroll offset progress", action: {
            [weak self](optionsPickerViewController) in
            guard let sSelf = self else{
                return
            }
            
            optionsPickerViewController.optionsPicker.selectRow(sSelf.selectedScrollOffsetProgressModeIndex, inComponent: 0, animated: false)
            optionsPickerViewController.optionsPicker.selectRow(sSelf.selectedScrollOffsetProgressMaxOffsetIndex, inComponent: 1, animated: false)
            optionsPickerViewController.mainView.backgroundColor = UIColor.clear
            optionsPickerViewController.leftBarButtonAction = KODialogViewControllerActionModel.cancelAction(withTitle: "Cancel")
            optionsPickerViewController.rightBarButtonAction = KODialogViewControllerActionModel.doneAction(withTitle: "Done", action: {
                [weak self](optionsPickerViewController : KOOptionsPickerViewController) in
                guard let sSelf = self else{
                    return
                }
                sSelf.selectedScrollOffsetProgressModeIndex = optionsPickerViewController.optionsPicker.selectedRow(inComponent: 0)
                sSelf.selectedScrollOffsetProgressMaxOffsetIndex = optionsPickerViewController.optionsPicker.selectedRow(inComponent: 1)
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


class GradientView : UIView{
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer : CAGradientLayer{
        return layer as! CAGradientLayer
    }
}
