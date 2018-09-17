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
    @IBOutlet weak var birthdayField: KOTextField!
    
    private var birthdayDate : Date = Date() {
        didSet{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-YYYY"
            birthdayField.text = dateFormatter.string(from: birthdayDate)
            birthdayField.isShowingError = (Calendar.current.dateComponents([.year], from: birthdayDate, to: Date()).year ?? 0) < 18
        }
    }
    
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
        birthdayField.showErrorInfoMode = .always
        birthdayField.errorInfoView.descriptionLabel.text = "You are under 18"
    }
    
    private func handleShouldBeginEditing(textField: UITextField)->Bool{
        switch textField.tag {
        case 1:
            showDatePicker()
            return false
            
        default:
            return true
        }
    }
    
    private func showDatePicker(){
        let datePickerViewController = KODatePickerViewController()
        datePickerViewController.barView.titleLabel.text = "Select your birthday"
        datePickerViewController.leftBarButtonAction = KODialogViewControllerActionModel.cancelAction()
        datePickerViewController.rightBarButtonAction = KODialogViewControllerActionModel.doneAction(action:{
            [weak self](datePickerViewController : KODatePickerViewController) in
            self?.birthdayDate =  datePickerViewController.datePicker.date
        })

        datePickerViewController.datePicker.date = birthdayDate
        datePickerViewController.datePicker.datePickerMode = .date
        datePickerViewController.datePicker.maximumDate = Date()
        datePickerViewController.datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -120, to: Date())
        
        present(datePickerViewController, animated: true, completion: nil)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
       return handleShouldBeginEditing(textField: textField)
    }
}
