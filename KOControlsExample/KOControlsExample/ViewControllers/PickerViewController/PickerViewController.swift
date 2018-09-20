//
//  PickerViewController.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 03.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit
import KOControls

class PickerViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource {
    //MARK: Variables
    @IBOutlet weak var presentMode: UISegmentedControl!
    private var popoverSettings : KOPopoverSettings? = nil
    
    //birthday
    @IBOutlet weak var birthdayField: KOTextField!
    private var birthdayDate : Date = Date() {
        didSet{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-YYYY"
            birthdayField.text = dateFormatter.string(from: birthdayDate)
            birthdayField.isShowingError = (Calendar.current.dateComponents([.year], from: birthdayDate, to: Date()).year ?? 0) < 18
        }
    }
    
    //film type
    @IBOutlet weak var filmTypeField: KOTextField!
    private var filmTypes : [String] = [
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
    private var favoriteFilmTypeIndex : Int = 0{
        didSet{
            filmTypeField.text = filmTypes[favoriteFilmTypeIndex]
            filmTypeField.isShowingError = favoriteFilmTypeIndex == (filmTypes.count - 1)
        }
    }
    
    //country
    @IBOutlet weak var countryField: KOTextField!
    private var countries : [CountryModel] = []
    
    private let countryTableViewCellKey = "countryTableViewCell"
    private var countryTableIndex : Int = 0{
        didSet{
            countryField.text = countries[countryTableIndex].name
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
        
        filmTypeField.borderSettings = AppSettings.fieldBorder
        filmTypeField.showErrorInfoMode = .always
        filmTypeField.errorInfoView.descriptionLabel.text = "You have selected wrong option"
        
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

    //MARK: Date picker
    private func showDatePicker(){
        let presentPopover = presentMode.selectedSegmentIndex == 1
        if presentPopover{
            popoverSettings = KOPopoverSettings(sourceView: birthdayField, sourceRect: birthdayField.bounds)
            presentDatePicker(initializeAction: KOActionModel<KODatePickerViewController>(title: "Select your birthday", action: {
                [weak self](datePicker) in
                guard let sSelf = self else{
                    return
                }
                datePicker.mainView.backgroundColor = UIColor.clear
                sSelf.initializeDatePicker(datePicker)
            }), popoverSettings: popoverSettings!)
        }else{
            presentDatePicker(initializeAction: KOActionModel<KODatePickerViewController>(title: "Select your birthday", action: {
                [weak self](datePicker) in
                self?.initializeDatePicker(datePicker)
            }))
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
    }
    
    //MARK: Option picker
    private func showOptionsPicker(){
        let presentPopover = presentMode.selectedSegmentIndex == 1
        if presentPopover{
            popoverSettings = KOPopoverSettings(sourceView: filmTypeField, sourceRect: filmTypeField.bounds)
            presentOptionsPicker(withOptions : [filmTypes], initializeAction: KOActionModel<KOOptionsPickerViewController>(title: "Select your favorite film type", action: {
                [weak self](optionsPicker) in
                guard let sSelf = self else{
                    return
                }
                optionsPicker.mainView.backgroundColor = UIColor.clear
                sSelf.initializeOptionsPicker(optionsPicker)
            }), popoverSettings: popoverSettings!)
        }else{
            presentOptionsPicker(withOptions : [filmTypes], initializeAction: KOActionModel<KOOptionsPickerViewController>(title: "Select your favorite film type", action: {
                [weak self](optionsPicker) in
                self?.initializeOptionsPicker(optionsPicker)
            }))
        }
    }
    
    private func initializeOptionsPicker(_ optionPicker : KOOptionsPickerViewController){
        optionPicker.optionsPicker.selectRow(favoriteFilmTypeIndex, inComponent: 0, animated: false)
        optionPicker.leftBarButtonAction = KODialogViewControllerActionModel.cancelAction()
        optionPicker.rightBarButtonAction = KODialogViewControllerActionModel.doneAction(action:{
            [weak self](optionPickerViewController : KOOptionsPickerViewController) in
            guard let sSelf = self else{
                return
            }
            sSelf.favoriteFilmTypeIndex = optionPickerViewController.optionsPicker.selectedRow(inComponent: 0)
        })
    }
    
    //MARK: Items table picker
    private func showItemsPicker(){
        let presentPopover = presentMode.selectedSegmentIndex == 1
        if presentPopover{
            popoverSettings = KOPopoverSettings(sourceView: countryField, sourceRect: countryField.bounds)
            presentItemsTablePicker(initializeAction: KOActionModel<KOItemsTablePickerViewController>(title: "Select your country", action: {
                [weak self](itemsTablePicker) in
                guard let sSelf = self else{
                    return
                }
                itemsTablePicker.mainView.backgroundColor = UIColor.clear
                sSelf.initializeItemsTablePicker(itemsTablePicker)
            }), popoverSettings: popoverSettings!)
        }else{
            presentItemsTablePicker(initializeAction: KOActionModel<KOItemsTablePickerViewController>(title: "Select your country", action: {
                [weak self](itemsTablePicker) in
                self?.initializeItemsTablePicker(itemsTablePicker)
            }))
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
                sSelf.countryTableIndex = countryIndex
            }
        })
        itemsTablePicker.itemsTable.allowsSelection = true
        itemsTablePicker.itemsTable.register(UINib(nibName: "CountryTableViewCell", bundle: nil), forCellReuseIdentifier: countryTableViewCellKey)
        itemsTablePicker.itemsTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: countryTableViewCellKey, for: indexPath) as! CountryTableViewCell
        cell.countryModel = countries[indexPath.row]
        return cell
    }
}
