//
//  PickerViewController.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 03.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit
import KOControls

class PickerViewController: UIViewController, UITextFieldDelegate {
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
    }
    
    private func initializeFields(){
        birthdayField.borderSettings = AppSettings.borderSettings
        birthdayField.showErrorInfoMode = .always
        birthdayField.errorInfoView.descriptionLabel.text = "You are under 18"
        
        filmTypeField.borderSettings = AppSettings.borderSettings
        filmTypeField.showErrorInfoMode = .always
        filmTypeField.errorInfoView.descriptionLabel.text = "You have selected wrong option"
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
    
    private func initializeOptionsPicker(_ optionPickers : KOOptionsPickerViewController){
        optionPickers.picker.selectRow(favoriteFilmTypeIndex, inComponent: 0, animated: false)
        optionPickers.leftBarButtonAction = KODialogViewControllerActionModel.cancelAction()
        optionPickers.rightBarButtonAction = KODialogViewControllerActionModel.doneAction(action:{
            [weak self](optionPickerViewController : KOOptionsPickerViewController) in
            guard let sSelf = self else{
                return
            }
            sSelf.favoriteFilmTypeIndex = optionPickerViewController.picker.selectedRow(inComponent: 0)
        })
    }
    
    

  
}
