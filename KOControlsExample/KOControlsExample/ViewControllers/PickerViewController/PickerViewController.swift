//
//  PickerViewController.swift
//  KOControlsExample
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
            dialogViewController.modalPresentationCapturesStatusBarAppearance = true
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
        guard isStyleCustomize && !isPresentPopover else{
            return
        }
        
        //override presenting animation
        let viewToAnimationDuration : TimeInterval = 0.5
        let viewToAnimation = KOScaleAnimation(toValue: CGPoint(x: 1, y: 1), fromValue: CGPoint.zero)
        viewToAnimation.timingParameters = UISpringTimingParameters(dampingRatio: 0.6)
        let animationControllerPresenting = KOAnimationController(duration: viewToAnimationDuration, viewToAnimation: viewToAnimation, viewFromAnimation: nil)
        
        //override dismissing animation
        let viewFromAnimationDuration : TimeInterval = 0.5
        let viewFromAnimation = KOAnimationGroup(animations: [
            KOFadeOutAnimation(),
            KOScaleAnimation(toValue: CGPoint(x: 0.5, y: 0.5))
            ], duration : viewFromAnimationDuration)
        let animationControllerDismissing = KOAnimationController(duration: viewFromAnimationDuration, viewToAnimation: nil, viewFromAnimation: viewFromAnimation)
        
        dialogViewController.customTransition = KOVisualEffectDimmingTransition(effect: UIBlurEffect(style: .dark), animationControllerPresenting: animationControllerPresenting, animationControllerDismissing: animationControllerDismissing)
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
        
        _ = presentDatePicker(viewLoadedAction: KODialogActionModel(title: "Select your birthday", action: {
            [weak self](dialogViewController) in
            guard let sSelf = self else{
                return
            }
            
            let datePickerViewController = dialogViewController as! KODatePickerViewController
            datePickerViewController.mainView.backgroundColor = UIColor.clear
            sSelf.initializeDatePicker(datePickerViewController)
        }), popoverSettings: popoverSettings!)
    }
    
    private func showDatePickerNormal(){
        _ = presentDatePicker(viewLoadedAction: KODialogActionModel(title: "Select your birthday", action: {
            [weak self](dialogViewController) in
            self?.initializeDatePicker(dialogViewController as! KODatePickerViewController)
        }), postInit: {
            [weak self] datePickerViewController in
            self?.customizeTransitionIfNeed(dialogViewController: datePickerViewController)
        })
    }
    
    private func initializeDatePicker(_ datePicker : KODatePickerViewController){
        datePicker.leftBarButtonAction = KODialogActionModel.cancelAction()
        datePicker.rightBarButtonAction = KODialogActionModel.doneAction(action:{
            [weak self](datePickerViewController : KODatePickerViewController) in
            self?.birthdayDate = datePickerViewController.datePicker.date
        })
        
        datePicker.datePicker.date = birthdayDate
        datePicker.datePicker.datePickerMode = .date
        datePicker.datePicker.maximumDate = Date()
        datePicker.datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -120, to: Date())
        customizeIfNeed(datePicker: datePicker)
    }
    
    //MARK: Customization
    private func customizeIfNeed(datePicker: KODatePickerViewController){
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
        
        _ = presentOptionsPicker(withOptions : [filmTypes], viewLoadedAction: KODialogActionModel(title: "Select your favorite film type", action: {
            [weak self](dialogViewController) in
            guard let sSelf = self else{
                return
            }
            let optionsPickerViewController = dialogViewController as! KOOptionsPickerViewController
            optionsPickerViewController.mainView.backgroundColor = UIColor.clear
            sSelf.initializeOptionsPicker(optionsPickerViewController)
        }), popoverSettings: popoverSettings!)
    }
    
    private func showOptionsPickerNormal(){
        _ = presentOptionsPicker(withOptions : [filmTypes], viewLoadedAction: KODialogActionModel(title: "Select your favorite film type", action: {
            [weak self](dialogViewController) in
            self?.initializeOptionsPicker(dialogViewController as! KOOptionsPickerViewController)
        }), postInit: {
            [weak self] optionsPickerViewController in
            self?.customizeTransitionIfNeed(dialogViewController: optionsPickerViewController)
        })
    }
    
    private func initializeOptionsPicker(_ optionsPicker : KOOptionsPickerViewController){
        optionsPicker.optionsPicker.selectRow(favoriteFilmTypeIndex, inComponent: 0, animated: false)
        optionsPicker.leftBarButtonAction = KODialogActionModel.cancelAction()
        optionsPicker.rightBarButtonAction = KODialogActionModel.doneAction(action:{
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
        (optionsPicker.optionsPickerDelegateInstance as! KOOptionsPickerSimpleDelegate).titleAttributesForRowInComponentsEvent =
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
        _ = presentItemsTablePicker(viewLoadedAction: KODialogActionModel(title: "Select your country", action: {
            [weak self](dialogViewController) in
            let itemsTablePickerViewController = dialogViewController as! KOItemsTablePickerViewController
            itemsTablePickerViewController.contentHeight = 300
            self?.initializeItemsTablePicker(itemsTablePickerViewController)
        }), postInit: {
            [weak self] itemsTablePickerViewController in
            self?.customizeTransitionIfNeed(dialogViewController: itemsTablePickerViewController)
        })
    }
    
    private func showItemsTablePickerPopover(){
        popoverSettings = KOPopoverSettings(sourceView: countryField, sourceRect: countryField.bounds)
        popoverSettings!.preferredContentSize = CGSize(width: 320, height: 320)
        customizeIfNeed(popoverSettings: popoverSettings!)
        
        _ = presentItemsTablePicker( viewLoadedAction: KODialogActionModel(title: "Select your country", action: {
            [weak self](dialogViewController) in
            guard let sSelf = self else{
                return
            }
            let itemsTablePickerViewController = dialogViewController as! KOItemsTablePickerViewController
            itemsTablePickerViewController.mainView.backgroundColor = UIColor.clear
            sSelf.initializeItemsTablePicker(itemsTablePickerViewController)
        }), popoverSettings: popoverSettings!)
    }
    
    private func initializeItemsTablePicker(_ itemsTablePicker : KOItemsTablePickerViewController){
        itemsTablePicker.leftBarButtonAction = KODialogActionModel.cancelAction()
        itemsTablePicker.rightBarButtonAction = KODialogActionModel.doneAction(action:{
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
        _ = presentItemsCollectionPicker(itemsCollectionLayout : UICollectionViewFlowLayout(), viewLoadedAction: KODialogActionModel(title: "Select your country", action: {
            [weak self](dialogViewController) in
            guard let sSelf = self else{
                return
            }
            
            let itemsCollectionPickerViewController = dialogViewController as! KOItemsCollectionPickerViewController
            itemsCollectionPickerViewController.contentHeight = 300
            sSelf.initializeItemsCollectionPicker(itemsCollectionPickerViewController, availableWidth: sSelf.view.bounds.width, itemMaxWidth: 120)
        }), postInit: {
            [weak self] itemsCollectionPickerViewController in
            self?.customizeTransitionIfNeed(dialogViewController: itemsCollectionPickerViewController)
        })
    }
    
    private func showItemsCollectionPickerPopover(){
        //creates popover's settings
        popoverSettings = KOPopoverSettings(sourceView: countryField, sourceRect: countryField.bounds)
        popoverSettings!.preferredContentSize = CGSize(width: 320, height: 320)
        customizeIfNeed(popoverSettings: popoverSettings!)
        
        _ = presentItemsCollectionPicker(itemsCollectionLayout : UICollectionViewFlowLayout(), viewLoadedAction: KODialogActionModel(title: "Select your country", action: {
            [weak self](dialogViewController) in
            guard let sSelf = self else{
                return
            }
            let itemsCollectionPickerViewController =  dialogViewController as! KOItemsCollectionPickerViewController
            itemsCollectionPickerViewController.mainView.backgroundColor = UIColor.clear
            sSelf.initializeItemsCollectionPicker(itemsCollectionPickerViewController, availableWidth: 320, itemMaxWidth: 80)
        }), popoverSettings: popoverSettings!)
    }
    
    private func initializeItemsCollectionPicker(_ itemsCollectionPicker : KOItemsCollectionPickerViewController, availableWidth : CGFloat, itemMaxWidth : Double){
        itemsCollectionPicker.leftBarButtonAction = KODialogActionModel.cancelAction()
        itemsCollectionPicker.rightBarButtonAction = KODialogActionModel.doneAction(action:{
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
        _ = presentDialog(searchItemsTablePicker, viewLoadedAction: KODialogActionModel(title: "Select your country", action: {
            [weak self](dialogViewController) in
            guard let sSelf = self else{
                return
            }
            let searchItemsTablePickerViewController = dialogViewController as! SearchItemsTablePickerViewController
            searchItemsTablePickerViewController.contentHeight = 300
            sSelf.initializeCustomItemsTablePicker(searchItemsTablePickerViewController)
        }))
    }
    
    private func showCustomItemsTablePickerPopover(){
        let searchItemsTablePicker = SearchItemsTablePickerViewController()
        
        popoverSettings = KOPopoverSettings(sourceView: customCountryField, sourceRect: customCountryField.bounds)
        popoverSettings!.preferredContentSize = CGSize(width: 320, height: 320)
        customizeIfNeed(popoverSettings: popoverSettings!)
        
        _ = presentDialog(searchItemsTablePicker, viewLoadedAction: KODialogActionModel(title: "Select your country", action: {
            [weak self](dialogViewController) in
            guard let sSelf = self else{
                return
            }
            
            let searchItemsTablePickerViewController = dialogViewController as! SearchItemsTablePickerViewController
            searchItemsTablePickerViewController.mainView.backgroundColor = UIColor.clear
            sSelf.initializeItemsTablePicker(searchItemsTablePickerViewController)
            sSelf.initializeCustomItemsTablePicker(searchItemsTablePickerViewController)
        }), popoverSettings: popoverSettings)
    }
    
    private func initializeCustomItemsTablePicker(_ itemsTablePicker : SearchItemsTablePickerViewController){
        itemsTablePicker.leftBarButtonAction = KODialogActionModel.cancelAction()
        itemsTablePicker.rightBarButtonAction = KODialogActionModel.doneAction(action:{
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
        let contentView = UIView()
        
        let itemsTable = super.createContentView()
        contentView.addSubview(itemsTable)
        itemsTable.translatesAutoresizingMaskIntoConstraints = false
        
        let searchField = KOTextField()
        searchField.borderStyle = .roundedRect
        searchField.borderSettings = AppSettings.fieldBorder
        searchField.placeholder = "Search country"
        contentView.addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        self.searchField = searchField
        
        contentView.addConstraints([
            searchField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            searchField.rightAnchor.constraint(equalTo: contentView.rightAnchor,  constant: -8),
            searchField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            itemsTable.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 4),
            itemsTable.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            itemsTable.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            itemsTable.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        
        return contentView
    }
}
