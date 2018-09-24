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
    
    fileprivate var countries : [CountryModel] = []
    
    fileprivate let countryTableViewCellKey = "countryTableViewCell"
    fileprivate let countryCollectionViewCellKey = "countryCollectionViewCell"
    
    fileprivate var countryIndex : Int = 0{
        didSet{
            countryField.text = countries[countryIndex].name
        }
    }
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        intialize()
    }

    private func intialize(){
        initializeView()
        initializeFields()
    }
    
    private func initializeView(){
        navigationItem.title = "KOPickerView"
        definesPresentationContext = true
        countries = AppSettings.countries
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
    }
    
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
        if presentMode.selectedSegmentIndex == 0{
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
        guard styleMode.selectedSegmentIndex == 1 else{
            return
        }
        popoverSettings.setupPopoverPresentationControllerEvent = {
            popoverPresentationController in
            popoverPresentationController.backgroundColor = UIColor.black.withAlphaComponent(0.70)
        }
    }
    
    private func customizeTransitionIfNeed(dialogViewController : KODialogViewController){
        guard styleMode.selectedSegmentIndex == 1 else{
            return
        }
        dialogViewController.dimmingTransition.setupPresentationControllerEvent = {
            presentationController in
            presentationController.dimmingView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        }
    }
}

//MARK: - Date picker
extension PickerViewController{
    
    private func showDatePicker(){
        let presentPopover = presentMode.selectedSegmentIndex == 1
        if presentPopover{
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
        }else{
            presentDatePicker(viewLoadedAction: KOActionModel<KODatePickerViewController>(title: "Select your birthday", action: {
                [weak self](datePicker) in
                self?.initializeDatePicker(datePicker)
            }), postInit: {
                [weak self] datePicker in
                self?.customizeTransitionIfNeed(dialogViewController: datePicker)
            })
        }
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
        guard styleMode.selectedSegmentIndex == 1 else{
            return
        }
        datePicker.datePickerTextColor = UIColor.orange
        customize(dialogViewController: datePicker)
    }
}

//MARK: - Option picker
extension PickerViewController{
    
    private func showOptionsPicker(){
        let presentPopover = presentMode.selectedSegmentIndex == 1
        if presentPopover{
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
        }else{
            presentOptionsPicker(withOptions : [filmTypes], viewLoadedAction: KOActionModel<KOOptionsPickerViewController>(title: "Select your favorite film type", action: {
                [weak self](optionsPicker) in
                self?.initializeOptionsPicker(optionsPicker)
            }), postInit: {
                [weak self] datePicker in
                self?.customizeTransitionIfNeed(dialogViewController: datePicker)
            })
        }
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
        guard styleMode.selectedSegmentIndex == 1 else{
            return
        }
        optionsPicker.optionsPickerTitleAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .medium), NSAttributedString.Key.foregroundColor : UIColor.orange]
        optionsPicker.optionsPicker.reloadAllComponents()
        customize(dialogViewController: optionsPicker)
    }
}

//MARK: - Items table picker
extension PickerViewController : UITableViewDataSource{
    
    private func showItemsTablePicker(){
        let presentPopover = presentMode.selectedSegmentIndex == 1
        if presentPopover{
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
        }else{
            presentItemsTablePicker(viewLoadedAction: KOActionModel<KOItemsTablePickerViewController>(title: "Select your country", action: {
                [weak self](itemsTablePicker) in
                itemsTablePicker.contentHeight = 300
                self?.initializeItemsTablePicker(itemsTablePicker)
            }), postInit: {
                [weak self] datePicker in
                self?.customizeTransitionIfNeed(dialogViewController: datePicker)
            })
        }
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
        itemsTablePicker.itemsTable.register(UINib(nibName: "CountryTableViewCell", bundle: nil), forCellReuseIdentifier: countryTableViewCellKey)
        itemsTablePicker.itemsTable.dataSource = self
        customizeIfNeed(itemsTablePicker: itemsTablePicker)
    }
    
    //MARK: Customization
    private func customizeIfNeed(itemsTablePicker : KOItemsTablePickerViewController){
        guard styleMode.selectedSegmentIndex == 1 else{
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
        guard styleMode.selectedSegmentIndex == 1 else{
            return
        }
        countryTableViewCell.backgroundColor = UIColor.clear
        countryTableViewCell.titleLabel.textColor = UIColor.orange
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: countryTableViewCellKey, for: indexPath) as! CountryTableViewCell
        cell.countryModel = countries[indexPath.row]
        customizeIfNeed(countryTableViewCell: cell)
        return cell
    }
}

//MARK: - Items collection picker
extension PickerViewController : UICollectionViewDataSource{
    
    private func showItemsCollectionPicker(){
        let presentPopover = presentMode.selectedSegmentIndex == 1
        //show as a popover or not
        if presentPopover{
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
        }else{
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
        itemsCollectionPicker.itemsCollection.dataSource = self
        itemsCollectionPicker.itemsCollection.register(UINib(nibName: "CountryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: countryCollectionViewCellKey)
        
        customizeIfNeed(itemsCollectionPickerViewController: itemsCollectionPicker)
        calculateCollectionSize(itemsCollectionPicker, availableWidth: availableWidth, itemMaxWidth: itemMaxWidth)
    }
    
    private func calculateCollectionSize(_ itemsCollectionPicker : KOItemsCollectionPickerViewController, availableWidth : CGFloat, itemMaxWidth : Double){
        let inset : CGFloat = 4
        let itemMargin = 2.0
        let parentWidth = Double( (itemsCollectionPicker.contentWidth ?? availableWidth) - inset * 2)
        let divider = max(2.0,(Double(parentWidth)) / itemMaxWidth)
        let column = floor(divider)
        let allMargin = (itemMargin * (column - 1))
        let itemSize = (Double(parentWidth) / column) - allMargin
        let lineSpacing = max(4.0, ((Double(parentWidth) - allMargin) - (column * itemSize)) / column)
        
        let flowLayout = itemsCollectionPicker.itemsCollection.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumInteritemSpacing = CGFloat(itemMargin) * 2
        flowLayout.minimumLineSpacing = CGFloat(lineSpacing)
        flowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
        flowLayout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    //MARK: Customization
    private func customizeIfNeed(itemsCollectionPickerViewController : KOItemsCollectionPickerViewController){
        guard styleMode.selectedSegmentIndex == 1 else{
            return
        }
        itemsCollectionPickerViewController.itemsCollection.backgroundColor = UIColor.clear
        
        /* If custom style horizontal alignment isn't equal to fill,
         picker must has to set contentWidth, to properly calculate sizes of view.
         We only need to do it in normal presentation mode because in popover presentation mode
         we already override  prefered content size
         */
        if presentMode.selectedSegmentIndex == 0{
            itemsCollectionPickerViewController.contentWidth = 320
        }
        customize(dialogViewController: itemsCollectionPickerViewController)
    }
    
    private func customizeIfNeed(countryCollectionViewCell : CountryCollectionViewCell){
        guard styleMode.selectedSegmentIndex == 1 else{
            return
        }
        countryCollectionViewCell.backgroundColor = UIColor.clear
        countryCollectionViewCell.titleLabel.textColor = UIColor.orange
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: countryCollectionViewCellKey, for: indexPath) as! CountryCollectionViewCell
        cell.countryModel = countries[indexPath.row]
        customizeIfNeed(countryCollectionViewCell: cell)
        return cell
    }
}
