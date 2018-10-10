//
//  PickerViewController.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 03.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit
import KOControls

class PickerViewController: UIViewController, UITextFieldDelegate{
    //MARK: Variables
    @IBOutlet weak var scrollViewContainer: UIView!
    
    @IBOutlet weak var presentMode: UISegmentedControl!
    @IBOutlet weak var styleModePanel: UIView!
    @IBOutlet weak var styleMode: UISegmentedControl!
    
    fileprivate var popoverSettings : KOPopoverSettings? = nil
    
    fileprivate var isPresentPopover : Bool{
        return presentMode.selectedSegmentIndex == 1
    }
    
    fileprivate var isStyleCustomize : Bool{
        return styleMode.selectedSegmentIndex == 1
    }
    
    //birthday
    @IBOutlet weak var birthdayField: KOTextField!
    fileprivate var birthdayDate : Date = Date() {
        didSet{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-YYYY"
            birthdayField.text = dateFormatter.string(from: birthdayDate)
            birthdayField.isShowingError = (Calendar.current.dateComponents([.year], from: birthdayDate, to: Date()).year ?? 0) < 18
        }
    }
    
    //film type
    @IBOutlet weak var filmTypeField: KOTextField!
    fileprivate var filmTypes : [String] = [
            "Action",
            "Adventure",
            "Biographical",
            "Comedy",
            "Crime",
            "Drama",
            "Family",
            "Horror",
            "Musical",
            "Romance",
            "Spy",
            "Thriller",
            "War",
            "Incorrect type"
    ]
    fileprivate var favoriteFilmTypeIndex : Int = 0{
        didSet{
            filmTypeField.text = filmTypes[favoriteFilmTypeIndex]
            filmTypeField.isShowingError = favoriteFilmTypeIndex == (filmTypes.count - 1)
        }
    }
    
    //country
    @IBOutlet weak var countryField: KOTextField!
    @IBOutlet weak var countryPickerType: UISegmentedControl!
    @IBOutlet weak var customCountryField: KOTextField!
    
    fileprivate let customCountryCollectionsController : CountryCollectionsController = CountryCollectionsController()
    fileprivate let countryCollectionsController : CountryCollectionsController = CountryCollectionsController()
    
    fileprivate var countryIndex : Int = 0{
        didSet{
            countryField.text = countryCollectionsController.countries[countryIndex].name
        }
    }
    fileprivate var customCountryIndex : Int = 0{
        didSet{
            customCountryField.text = customCountryCollectionsController.currentVisibleCountries[customCountryIndex].name
        }
    }
    //customCountryIndex
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        intialize()
    }

    private func intialize(){
        initializeView()
        initializeFields()
        initializeCountryCollectionControllers()
    }
    
    private func initializeView(){
        navigationItem.title = "KOPickerView"
        definesPresentationContext = true
    }
    
    private func initializeFields(){
        birthdayField.borderSettings = AppSettings.fieldBorder
        birthdayField.showErrorInfoMode = .always
        birthdayField.errorInfoView.descriptionLabel.text = "You are under 18"
        birthdayField.showErrorInfoInView = scrollViewContainer
        
        filmTypeField.borderSettings = AppSettings.fieldBorder
        filmTypeField.showErrorInfoMode = .always
        filmTypeField.errorInfoView.descriptionLabel.text = "You have selected wrong option"
        filmTypeField.showErrorInfoInView = scrollViewContainer
        
        countryField.borderSettings = AppSettings.fieldBorder
        customCountryField.borderSettings = AppSettings.fieldBorder
    }
    
    private func initializeCountryCollectionControllers(){
        let setupTableCell : (CountryTableViewCell)->Void = {[weak self] (cell : CountryTableViewCell ) in self?.customizeIfNeed(countryTableViewCell: cell) }
        let setupCollectionCell : (CountryCollectionViewCell)->Void = {[weak self] (cell : CountryCollectionViewCell ) in self?.customizeIfNeed(countryCollectionViewCell: cell) }
        
        countryCollectionsController.collectionViewSetupCell = setupCollectionCell
        countryCollectionsController.tableViewSetupCell = setupTableCell
        customCountryCollectionsController.collectionViewSetupCell = setupCollectionCell
        customCountryCollectionsController.tableViewSetupCell = setupTableCell
    }
    
    //MARK: Show picker after field clicked
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return handleShouldBeginEditing(textField: textField)
    }
    
    private func handleShouldBeginEditing(textField: UITextField)->Bool{
        switch textField.tag {
        case 1:
            showDatePicker()
            return false
            
        case 2:
            showOptionsPicker()
            return false
            
        case 3:
            showItemsPicker()
            return false
            
        case 4:
            showCustomItemsTablePicker()
            return false
            
        default:
            return true
        }
    }
    
    private func showItemsPicker(){
        if countryPickerType.selectedSegmentIndex == 0{
            showItemsTablePicker()
        }else{
            showItemsCollectionPicker()
        }
    }
    
    //MARK: Additionals customizations
    private func customize(dialogViewController : KODialogViewController){
        if !isPresentPopover{
            dialogViewController.backgroundVisualEffect = UIBlurEffect(style: .dark)
            dialogViewController.mainViewHorizontalAlignment = .center
            dialogViewController.mainViewVerticalAlignment = .center
        }
        dialogViewController.mainView.layer.cornerRadius = 12
        dialogViewController.mainView.clipsToBounds = true
        dialogViewController.barMode = .bottom
        dialogViewController.barView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        dialogViewController.barView.titleLabel.textColor = UIColor.white
        (dialogViewController.barView.leftView as? UIButton)?.setTitleColor(UIColor.white, for: .normal)
        (dialogViewController.barView.rightView as? UIButton)?.setTitleColor(UIColor.white, for: .normal)
    }
    
    private func customizeIfNeed(popoverSettings : KOPopoverSettings){
        guard isStyleCustomize else{
            return
        }
        popoverSettings.setupPopoverPresentationControllerEvent = {
            popoverPresentationController in
            popoverPresentationController.backgroundColor = UIColor.black.withAlphaComponent(0.70)
        }
    }
    
    private func customizeTransitionIfNeed(dialogViewController : KODialogViewController){
        guard isStyleCustomize else{
            return
        }
        dialogViewController.dimmingTransition.setupPresentationControllerEvent = {
            presentationController in
            presentationController.dimmingView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        }
        
        guard !isPresentPopover else{
            return
        }
        
        //override presenting animation
        let viewToAnimationDuration : TimeInterval = 0.5
        let viewToAnimation = KOScaleAnimation(toValue: CGPoint(x: 1, y: 1), fromValue: CGPoint.zero)
        viewToAnimation.timingParameters = UISpringTimingParameters(dampingRatio: 0.6)
        dialogViewController.dimmingTransition.animationControllerPresenting = KOAnimationController(duration: viewToAnimationDuration, viewToAnimation: viewToAnimation, viewFromAnimation: nil)
        
        //override dismissing animation
        let viewFromAnimationDuration : TimeInterval = 0.5
        let viewFromAnimation = KOAnimationGroup(animations: [
            KOFadeOutAnimation(),
            KOScaleAnimation(toValue: CGPoint(x: 0.5, y: 0.5))
            ], duration : viewFromAnimationDuration)
        dialogViewController.dimmingTransition.animationControllerDismissing = KOAnimationController(duration: viewFromAnimationDuration, viewToAnimation: nil, viewFromAnimation: viewFromAnimation)
    }
}

//MARK: - Date picker
extension PickerViewController{
    
    fileprivate func showDatePicker(){
        isPresentPopover ? showDatePickerPopover() : showDatePickerNormal()
    }

    private func showDatePickerPopover(){
        popoverSettings = KOPopoverSettings(sourceView: birthdayField, sourceRect: birthdayField.bounds)
        customizeIfNeed(popoverSettings: popoverSettings!)
        
        presentDatePicker(viewLoadedAction: KOActionModel<KODatePickerViewController>(title: "Select your birthday", action: {
            [weak self](datePicker) in
            guard let sSelf = self else{
                return
            }
            datePicker.mainView.backgroundColor = UIColor.clear
            sSelf.initializeDatePicker(datePicker)
        }), popoverSettings: popoverSettings!)
    }
    
    private func showDatePickerNormal(){
        presentDatePicker(viewLoadedAction: KOActionModel<KODatePickerViewController>(title: "Select your birthday", action: {
            [weak self](datePicker) in
            self?.initializeDatePicker(datePicker)
        }), postInit: {
            [weak self] datePicker in
            self?.customizeTransitionIfNeed(dialogViewController: datePicker)
        })
    }
    
    private func initializeDatePicker(_ datePicker : KODatePickerViewController){
        datePicker.leftBarButtonAction = KODialogViewControllerActionModel.cancelAction()
        datePicker.rightBarButtonAction = KODialogViewControllerActionModel.doneAction(action:{
            [weak self](datePickerViewController : KODatePickerViewController) in
            self?.birthdayDate =  datePickerViewController.datePicker.date
        })
        
        datePicker.datePicker.date = birthdayDate
        datePicker.datePicker.datePickerMode = .date
        datePicker.datePicker.maximumDate = Date()
        datePicker.datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -120, to: Date())
        customizeIfNeed(datePicker: datePicker)
    }
    
    //MARK: Customization
    private func customizeIfNeed(datePicker : KODatePickerViewController){
        guard isStyleCustomize else{
            return
        }
        datePicker.datePickerTextColor = UIColor.orange
        customize(dialogViewController: datePicker)
    }
}

//MARK: - Option picker
extension PickerViewController{
    
    fileprivate func showOptionsPicker(){
        isPresentPopover ? showOptionsPickerPopover() : showOptionsPickerNormal()
    }
    
    private func showOptionsPickerPopover(){
        popoverSettings = KOPopoverSettings(sourceView: filmTypeField, sourceRect: filmTypeField.bounds)
        customizeIfNeed(popoverSettings: popoverSettings!)
        
        presentOptionsPicker(withOptions : [filmTypes], viewLoadedAction: KOActionModel<KOOptionsPickerViewController>(title: "Select your favorite film type", action: {
            [weak self](optionsPicker) in
            guard let sSelf = self else{
                return
            }
            optionsPicker.mainView.backgroundColor = UIColor.clear
            sSelf.initializeOptionsPicker(optionsPicker)
        }), popoverSettings: popoverSettings!)
    }
    
    private func showOptionsPickerNormal(){
        presentOptionsPicker(withOptions : [filmTypes], viewLoadedAction: KOActionModel<KOOptionsPickerViewController>(title: "Select your favorite film type", action: {
            [weak self](optionsPicker) in
            self?.initializeOptionsPicker(optionsPicker)
        }), postInit: {
            [weak self] datePicker in
            self?.customizeTransitionIfNeed(dialogViewController: datePicker)
        })
    }
    
    private func initializeOptionsPicker(_ optionsPicker : KOOptionsPickerViewController){
        optionsPicker.optionsPicker.selectRow(favoriteFilmTypeIndex, inComponent: 0, animated: false)
        optionsPicker.leftBarButtonAction = KODialogViewControllerActionModel.cancelAction()
        optionsPicker.rightBarButtonAction = KODialogViewControllerActionModel.doneAction(action:{
            [weak self](optionsPickerViewController : KOOptionsPickerViewController) in
            guard let sSelf = self else{
                return
            }
            sSelf.favoriteFilmTypeIndex = optionsPickerViewController.optionsPicker.selectedRow(inComponent: 0)
        })
        customizeIfNeed(optionsPicker: optionsPicker)
    }
    
    //MARK: Customization
    private func customizeIfNeed(optionsPicker : KOOptionsPickerViewController){
        guard isStyleCustomize else{
            return
        }
        (optionsPicker.optionsPickerDelegateInstance as! KOOptionsPickerSimpleDelegate).titleAttributesForRowInComponents =
            { (_, _) in
                return [NSAttributedString.Key.foregroundColor : UIColor.orange]
            }
        optionsPicker.optionsPicker.reloadAllComponents()
        customize(dialogViewController: optionsPicker)
    }
}

//MARK: - Items table picker
extension PickerViewController{
    
    fileprivate func showItemsTablePicker(){
        isPresentPopover ? showItemsTablePickerPopover() : showItemsTablePickerNormal()
    }
    
    private func showItemsTablePickerNormal(){
        presentItemsTablePicker(viewLoadedAction: KOActionModel<KOItemsTablePickerViewController>(title: "Select your country", action: {
            [weak self](itemsTablePicker) in
            itemsTablePicker.contentHeight = 300
            self?.initializeItemsTablePicker(itemsTablePicker)
        }), postInit: {
            [weak self] datePicker in
            self?.customizeTransitionIfNeed(dialogViewController: datePicker)
        })
    }
    
    private func showItemsTablePickerPopover(){
        popoverSettings = KOPopoverSettings(sourceView: countryField, sourceRect: countryField.bounds)
        popoverSettings!.overridePreferredContentSize = CGSize(width: 320, height: 320)
        customizeIfNeed(popoverSettings: popoverSettings!)
        
        presentItemsTablePicker( viewLoadedAction: KOActionModel<KOItemsTablePickerViewController>(title: "Select your country", action: {
            [weak self](itemsTablePicker) in
            guard let sSelf = self else{
                return
            }
            itemsTablePicker.mainView.backgroundColor = UIColor.clear
            sSelf.initializeItemsTablePicker(itemsTablePicker)
        }), popoverSettings: popoverSettings!)
    }
    
    private func initializeItemsTablePicker(_ itemsTablePicker : KOItemsTablePickerViewController){
        itemsTablePicker.leftBarButtonAction = KODialogViewControllerActionModel.cancelAction()
        itemsTablePicker.rightBarButtonAction = KODialogViewControllerActionModel.doneAction(action:{
            [weak self](itemsTablePickerViewController : KOItemsTablePickerViewController) in
            guard let sSelf = self else{
                return
            }
            if let countryIndex = itemsTablePickerViewController.itemsTable.indexPathForSelectedRow?.row{
                sSelf.countryIndex = countryIndex
            }
        })
        itemsTablePicker.itemsTable.allowsSelection = true
        countryCollectionsController.attach(tableView: itemsTablePicker.itemsTable)
 
        customizeIfNeed(itemsTablePicker: itemsTablePicker)
    }
    
    //MARK: Customization
    private func customizeIfNeed(itemsTablePicker : KOItemsTablePickerViewController){
        guard isStyleCustomize else{
            return
        }
        itemsTablePicker.itemsTable.separatorColor = UIColor.white
        itemsTablePicker.itemsTable.backgroundColor = UIColor.clear
        /* If custom style horizontal alignment isn't equal to fill,
        picker must has to set contentWidth, to properly calculate sizes of view.
         We only need to do it in normal presentation mode because in popover presentation mode
         we already override  prefered content size
         */
        if presentMode.selectedSegmentIndex == 0{
            itemsTablePicker.contentWidth = 320
        }
        customize(dialogViewController: itemsTablePicker)
    }
    
    private func customizeIfNeed(countryTableViewCell : CountryTableViewCell){
        guard isStyleCustomize else{
            return
        }
        countryTableViewCell.backgroundColor = UIColor.clear
        countryTableViewCell.titleLabel.textColor = UIColor.orange
    }
}

//MARK: - Items collection picker
extension PickerViewController{
    
    fileprivate func showItemsCollectionPicker(){
        isPresentPopover ? showItemsCollectionPickerPopover() : showItemsCollectionPickerNormal()
    }
    
    private func showItemsCollectionPickerNormal(){
        presentItemsCollectionPicker(itemsCollectionLayout : UICollectionViewFlowLayout(), viewLoadedAction: KOActionModel<KOItemsCollectionPickerViewController>(title: "Select your country", action: {
            [weak self](itemsCollectionPicker) in
            guard let sSelf = self else{
                return
            }
            itemsCollectionPicker.contentHeight = 300
            sSelf.initializeItemsCollectionPicker(itemsCollectionPicker, availableWidth: sSelf.view.bounds.width, itemMaxWidth: 120)
        }), postInit: {
            [weak self] datePicker in
            self?.customizeTransitionIfNeed(dialogViewController: datePicker)
        })
    }
    
    private func showItemsCollectionPickerPopover(){
        //creates popover's settings
        popoverSettings = KOPopoverSettings(sourceView: countryField, sourceRect: countryField.bounds)
        popoverSettings!.overridePreferredContentSize = CGSize(width: 320, height: 320)
        customizeIfNeed(popoverSettings: popoverSettings!)
        
        presentItemsCollectionPicker(itemsCollectionLayout : UICollectionViewFlowLayout(), viewLoadedAction: KOActionModel<KOItemsCollectionPickerViewController>(title: "Select your country", action: {
            [weak self](itemsCollectionPicker) in
            guard let sSelf = self else{
                return
            }
            itemsCollectionPicker.mainView.backgroundColor = UIColor.clear
            sSelf.initializeItemsCollectionPicker(itemsCollectionPicker, availableWidth: 320, itemMaxWidth: 80)
        }), popoverSettings: popoverSettings!)
    }
    
    private func initializeItemsCollectionPicker(_ itemsCollectionPicker : KOItemsCollectionPickerViewController, availableWidth : CGFloat, itemMaxWidth : Double){
        itemsCollectionPicker.leftBarButtonAction = KODialogViewControllerActionModel.cancelAction()
        itemsCollectionPicker.rightBarButtonAction = KODialogViewControllerActionModel.doneAction(action:{
            [weak self](itemsCollectionPicker : KOItemsCollectionPickerViewController) in
            guard let sSelf = self else{
                return
            }
            if let countryIndex = itemsCollectionPicker.itemsCollection.indexPathsForSelectedItems?.first?.row{
                sSelf.countryIndex = countryIndex
            }
        })

        itemsCollectionPicker.itemsCollection.allowsSelection = true
        itemsCollectionPicker.itemsCollection.backgroundColor = UIColor.lightGray
        countryCollectionsController.attach(collectionView: itemsCollectionPicker.itemsCollection)

        customizeIfNeed(itemsCollectionPickerViewController: itemsCollectionPicker)
        countryCollectionsController.calculateCollectionSize(itemsCollectionPicker.itemsCollection, availableWidth: itemsCollectionPicker.contentWidth ?? availableWidth, itemMaxWidth: itemMaxWidth)
    }
    
    //MARK: Customization
    private func customizeIfNeed(itemsCollectionPickerViewController : KOItemsCollectionPickerViewController){
        guard isStyleCustomize else{
            return
        }
        itemsCollectionPickerViewController.itemsCollection.backgroundColor = UIColor.clear
        
        /* If custom style horizontal alignment isn't equal to fill,
         picker must has to set contentWidth, to properly calculate sizes of view.
         We only need to do it in normal presentation mode because in popover presentation mode
         we already override  prefered content size
         */
        if !isPresentPopover{
            itemsCollectionPickerViewController.contentWidth = 320
        }
        customize(dialogViewController: itemsCollectionPickerViewController)
    }
    
    private func customizeIfNeed(countryCollectionViewCell : CountryCollectionViewCell){
        guard isStyleCustomize else{
            return
        }
        countryCollectionViewCell.backgroundColor = UIColor.clear
        countryCollectionViewCell.titleLabel.textColor = UIColor.orange
    }
}


//MARK: - Custom items table picker
extension PickerViewController{
    
    fileprivate func showCustomItemsTablePicker(){
        isPresentPopover ? showCustomItemsTablePickerPopover() : showCustomItemsTablePickerNormal()
    }
    
    private func showCustomItemsTablePickerNormal(){
        let searchItemsTablePicker = SearchItemsTablePickerViewController()
        customizeTransitionIfNeed(dialogViewController: searchItemsTablePicker)
        presentDialog(searchItemsTablePicker, viewLoadedAction: KOActionModel<SearchItemsTablePickerViewController>(title: "Select your country", action: {
            [weak self](itemsTablePicker) in
            guard let sSelf = self else{
                return
            }
            itemsTablePicker.contentHeight = 300
            sSelf.initializeCustomItemsTablePicker(itemsTablePicker)
        }))
    }
    
    private func showCustomItemsTablePickerPopover(){
        let searchItemsTablePicker = SearchItemsTablePickerViewController()
        
        popoverSettings = KOPopoverSettings(sourceView: customCountryField, sourceRect: customCountryField.bounds)
        popoverSettings!.overridePreferredContentSize = CGSize(width: 320, height: 320)
        customizeIfNeed(popoverSettings: popoverSettings!)
        
        presentDialog(searchItemsTablePicker, viewLoadedAction: KOActionModel<SearchItemsTablePickerViewController>(title: "Select your country", action: {
            [weak self](itemsTablePicker) in
            guard let sSelf = self else{
                return
            }
            itemsTablePicker.mainView.backgroundColor = UIColor.clear
            sSelf.initializeItemsTablePicker(itemsTablePicker)
            sSelf.initializeCustomItemsTablePicker(itemsTablePicker)
            
        }), popoverSettings: popoverSettings)
    }
    
    private func initializeCustomItemsTablePicker(_ itemsTablePicker : SearchItemsTablePickerViewController){
        itemsTablePicker.leftBarButtonAction = KODialogViewControllerActionModel.cancelAction()
        itemsTablePicker.rightBarButtonAction = KODialogViewControllerActionModel.doneAction(action:{
            [weak self](itemsTablePickerViewController : KOItemsTablePickerViewController) in
            guard let sSelf = self else{
                return
            }
            if let countryIndex = itemsTablePickerViewController.itemsTable.indexPathForSelectedRow?.row{
                sSelf.customCountryIndex = countryIndex
            }
        })
        itemsTablePicker.itemsTable.allowsSelection = true
        customizeIfNeed(itemsTablePicker: itemsTablePicker)
        
        itemsTablePicker.searchField.addTarget(self, action: #selector(customItemsTablePickerSearchFieldChanged(_:)) , for: .editingChanged)
        customCountryCollectionsController.searchForCountries(byName: "")
        customCountryCollectionsController.attach(tableView: itemsTablePicker.itemsTable)
    }
    
    @objc private func customItemsTablePickerSearchFieldChanged(_ sender : UITextField){
        customCountryCollectionsController.searchForCountries(byName: sender.text ?? "")
    }
}

class SearchItemsTablePickerViewController : KOItemsTablePickerViewController{
    private(set) weak var searchField : KOTextField!
    
    
    override func createContentView() -> UIView {
        let containerView = UIView()
        
        let itemsTable = super.createContentView()
        containerView.addSubview(itemsTable)
        itemsTable.translatesAutoresizingMaskIntoConstraints = false
        
        let searchField = KOTextField()
        searchField.borderStyle = .roundedRect
        searchField.borderSettings = AppSettings.fieldBorder
        searchField.placeholder = "Search country"
        containerView.addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        self.searchField = searchField
        
        containerView.addConstraints([
            searchField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8),
            searchField.rightAnchor.constraint(equalTo: containerView.rightAnchor,  constant: -8),
            searchField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            itemsTable.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 4),
            itemsTable.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            itemsTable.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            itemsTable.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        
        return containerView
    }
}
