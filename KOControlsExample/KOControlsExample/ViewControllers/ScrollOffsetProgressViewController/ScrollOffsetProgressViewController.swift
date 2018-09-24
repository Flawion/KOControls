//
//  ScrollOffsetProgressViewController.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 16.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit
import KOControls

class ScrollOffsetProgressViewController: UIViewController, UICollectionViewDataSource, KOScrollOffsetProgressControllerDelegate{
    //MARK: - Variables
    private var scrollOffsetProgressController: KOScrollOffsetProgressController!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var offsetBasedContentTopConst: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userPointsLabel: UILabel!
    
    @IBOutlet weak var userImageHeightConst: NSLayoutConstraint!
    @IBOutlet weak var userImageWidthConst: NSLayoutConstraint!
    @IBOutlet weak var userImageLeftConst: NSLayoutConstraint!
    @IBOutlet weak var userImageTopConst: NSLayoutConstraint!
    
    @IBOutlet weak var userInformationLeftConst: NSLayoutConstraint!
    @IBOutlet weak var userInformationTopConst: NSLayoutConstraint!
    
    fileprivate var countries : [CountryModel] = []
    fileprivate let countryCollectionViewCellKey = "countryCollectionViewCell"
    
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
        scrollOffsetProgressController(scrollOffsetProgressController, offsetProgress: scrollOffsetProgressController.progress)
        calculateCollectionSize(collectionView, availableWidth: view.bounds.width, itemMaxWidth: 120)
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
        countries = AppSettings.countries
        collectionView.allowsSelection = false
        collectionView.register(UINib(nibName: "CountryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: countryCollectionViewCellKey)
    }
    
    private func initializeScrollOffsetBasedView(){
        scrollOffsetProgressController = KOScrollOffsetProgressController()
        scrollOffsetProgressController.delegate = self
        scrollOffsetProgressController.scrollView = collectionView
        scrollOffsetProgressController.maxOffset = 300
        scrollOffsetProgressController.mode = .contentOffsetBased
    }
    
    func scrollOffsetProgressController(_: KOScrollOffsetProgressController, offsetProgress: CGFloat) {
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
    
    private func calculateCollectionSize(_ collectionView : UICollectionView, availableWidth : CGFloat, itemMaxWidth : Double){
        let inset : CGFloat = 4
        let itemMargin = 2.0
        let parentWidth = Double(availableWidth - inset * 2)
        let divider = max(2.0,(Double(parentWidth)) / itemMaxWidth)
        let column = floor(divider)
        let allMargin = (itemMargin * (column - 1))
        let itemSize = (Double(parentWidth) / column) - allMargin
        let lineSpacing = max(4.0, ((Double(parentWidth) - allMargin) - (column * itemSize)) / column)
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumInteritemSpacing = CGFloat(itemMargin) * 2
        flowLayout.minimumLineSpacing = CGFloat(lineSpacing)
        flowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
        flowLayout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: countryCollectionViewCellKey, for: indexPath) as! CountryCollectionViewCell
        cell.countryModel = countries[indexPath.row]
        return cell
    }
    
    @IBAction func backBttClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
