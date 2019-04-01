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

// MARK: Main class
final class PickerViewController: UIViewController {
    // MARK: Variables
    @IBOutlet weak var scrollViewContainer: UIView!
    
    @IBOutlet weak var presentMode: UISegmentedControl!
    @IBOutlet weak var styleModePanel: UIView!
    @IBOutlet weak var styleMode: UISegmentedControl!
    
    var popoverSettings: KOPopoverSettings?
    
    var isPresentPopover: Bool {
        return presentMode.selectedSegmentIndex == 1
    }
    
    var isStyleCustomize: Bool {
        return styleMode.selectedSegmentIndex == 1
    }
    
    //birthday
    @IBOutlet weak var birthdayField: KOTextField!
    var birthdayDate: Date = Date() {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-YYYY"
            birthdayField.text = dateFormatter.string(from: birthdayDate)
            birthdayField.isShowingError = (Calendar.current.dateComponents([.year], from: birthdayDate, to: Date()).year ?? 0) < 18
        }
    }
    
    //film type
    @IBOutlet weak var filmTypeField: KOTextField!
    private(set) var filmTypes: [String] = [
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
    var favoriteFilmTypeIndex: Int = 0 {
        didSet {
            filmTypeField.text = filmTypes[favoriteFilmTypeIndex]
            filmTypeField.isShowingError = favoriteFilmTypeIndex == (filmTypes.count - 1)
        }
    }
    
    //country
    @IBOutlet weak var countryField: KOTextField!
    @IBOutlet weak var countryPickerType: UISegmentedControl!
    @IBOutlet weak var customCountryField: KOTextField!
    
    let customCountryCollectionsController: CountryCollectionsController = CountryCollectionsController()
    let countryCollectionsController: CountryCollectionsController = CountryCollectionsController()
    
    var countryIndex: Int = 0 {
        didSet {
            countryField.text = countryCollectionsController.countries[countryIndex].name
        }
    }
    var customCountryIndex: Int = 0 {
        didSet {
            customCountryField.text = customCountryCollectionsController.currentVisibleCountries[customCountryIndex].name
        }
    }

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        intialize()
    }

    private func intialize() {
        initializeView()
        initializeFields()
        initializeCountryCollectionControllers()
    }
    
    private func initializeView() {
        navigationItem.title = "KOPickerView"
        definesPresentationContext = true
    }
    
    private func initializeFields() {
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
    
    private func initializeCountryCollectionControllers() {
        let setupTableCell: (CountryTableViewCell) -> Void = { [weak self] (cell: CountryTableViewCell ) in self?.customizeIfNeed(countryTableViewCell: cell) }
        let setupCollectionCell: (CountryCollectionViewCell) -> Void = { [weak self] (cell: CountryCollectionViewCell ) in self?.customizeIfNeed(countryCollectionViewCell: cell) }
        
        countryCollectionsController.collectionViewSetupCell = setupCollectionCell
        countryCollectionsController.tableViewSetupCell = setupTableCell
        customCountryCollectionsController.collectionViewSetupCell = setupCollectionCell
        customCountryCollectionsController.tableViewSetupCell = setupTableCell
    }
    
    // MARK: Show picker after field clicked
    private func handleShouldBeginEditing(textField: UITextField) -> Bool {
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
    
    private func showItemsPicker() {
        if countryPickerType.selectedSegmentIndex == 0 {
            showItemsTablePicker()
        } else {
            showItemsCollectionPicker()
        }
    }
    
    // MARK: Additionals customizations
    func customize(dialogViewController: KODialogViewController) {
        if !isPresentPopover {
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
    
    func customizeIfNeed(popoverSettings: KOPopoverSettings) {
        guard isStyleCustomize else {
            return
        }
        popoverSettings.setupPopoverPresentationControllerEvent = {
            popoverPresentationController in
            popoverPresentationController.backgroundColor = UIColor.black.withAlphaComponent(0.70)
        }
    }
    
    func customizeTransitionIfNeed(dialogViewController: KODialogViewController) {
        guard isStyleCustomize && !isPresentPopover else {
            return
        }
        
        //override presenting animation
        let viewToAnimationDuration: TimeInterval = 0.5
        let viewToAnimation = KOScaleAnimation(toValue: CGPoint(x: 1, y: 1), fromValue: CGPoint.zero)
        viewToAnimation.timingParameters = UISpringTimingParameters(dampingRatio: 0.6)
        let animationControllerPresenting = KOAnimationController(duration: viewToAnimationDuration, viewToAnimation: viewToAnimation, viewFromAnimation: nil)
        
        //override dismissing animation
        let viewFromAnimationDuration: TimeInterval = 0.5
        let viewFromAnimation = KOAnimationGroup(animations: [
            KOFadeOutAnimation(),
            KOScaleAnimation(toValue: CGPoint(x: 0.5, y: 0.5))
            ], duration: viewFromAnimationDuration)
        let animationControllerDismissing = KOAnimationController(duration: viewFromAnimationDuration, viewToAnimation: nil, viewFromAnimation: viewFromAnimation)
        
        dialogViewController.customTransition = KOVisualEffectDimmingTransition(effect: UIBlurEffect(style: .dark), animationControllerPresenting: animationControllerPresenting, animationControllerDismissing: animationControllerDismissing)
    }
}

// MARK: - UITextFieldDelegate
extension PickerViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return handleShouldBeginEditing(textField: textField)
    }
}
