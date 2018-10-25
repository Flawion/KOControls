//
//  PresentationQueueViewController.swift
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

class PresentationQueueViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var presentingView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var viewsCountInQueueLabel: UILabel!
    @IBOutlet weak var presentViewsCountField: UITextField!
    @IBOutlet weak var removeIndexField: UITextField!
    
    private weak var presentingContainerViewController : UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    
    private func initialize(){
        navigationItem.title = "KOPresentationQueueService"
        initializePresentingContainerViewController()
        initializeViewsCountInQueueLabel()
    }
    
    private func initializeViewsCountInQueueLabel(){
        KOPresentationQueuesService.shared.queueChangedEvent = {
            [weak self] queueIndex in
            guard let sSelf = self else{
                return
            }
            sSelf.viewsCountInQueueLabel.text = "Views count in queue: \(KOPresentationQueuesService.shared.itemsCountForQueue(withIndex: queueIndex) ?? 0)"
        }
    }
    
    private func initializePresentingContainerViewController(){
        let presentingContainerViewController = UIViewController()
        presentingContainerViewController.definesPresentationContext = true
        presentingContainerViewController.view.backgroundColor = UIColor.clear
        presentingContainerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(presentingContainerViewController)
        presentingView.addSubview(presentingContainerViewController.view)
        presentingView.addConstraints([
            presentingContainerViewController.view.leftAnchor.constraint(equalTo: presentingView.leftAnchor),
            presentingContainerViewController.view.rightAnchor.constraint(equalTo: presentingView.rightAnchor),
            presentingContainerViewController.view.bottomAnchor.constraint(equalTo: presentingView.bottomAnchor),
            presentingContainerViewController.view.topAnchor.constraint(equalTo: presentingView.topAnchor)
            ])
        presentingContainerViewController.didMove(toParent: self)
        self.presentingContainerViewController = presentingContainerViewController
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return handleShouldBeginEditing(textField: textField)
    }
    
    private func handleShouldBeginEditing(textField: UITextField)->Bool{
        switch textField.tag {
        case 1:
            showPresentViewsCountPicker()
            return false
            
        case 2:
            showRemoveIndexPicker()
            return false
            
        default:
            return true
        }
    }
    
    private func showPresentViewsCountPicker(){
        _ = presentOptionsPicker(withOptions: [["1","2","3","4","5"]], viewLoadedAction: KODialogActionModel(title: "Select present views count", action: {
            [weak self](dialogViewController) in
            guard let sSelf = self else{
                return
            }
            
            let optionsPickerViewController = dialogViewController as! KOOptionsPickerViewController
            optionsPickerViewController.optionsPicker.selectRow(((sSelf.convertTextToInt(sSelf.presentViewsCountField.text) ?? 0) - 1) , inComponent: 0, animated: false)
            optionsPickerViewController.rightBarButtonAction = KODialogActionModel.doneAction(action: {
                [weak self](optionsPickerViewController : KOOptionsPickerViewController) in
                guard let sSelf = self else{
                    return
                }
                sSelf.presentViewsCountField.text = "\(optionsPickerViewController.optionsPicker.selectedRow(inComponent: 0) + 1)"
            })
            optionsPickerViewController.leftBarButtonAction = KODialogActionModel.cancelAction()
        }))
    }
    
    private func showRemoveIndexPicker(){
        _ = presentOptionsPicker(withOptions: [["0","1","2","3","4"]], viewLoadedAction: KODialogActionModel(title: "Select index of view to remove", action: {
            [weak self](dialogViewController) in
            guard let sSelf = self else{
                return
            }
            
            let optionsPickerViewController = dialogViewController as! KOOptionsPickerViewController
            optionsPickerViewController.optionsPicker.selectRow(((sSelf.convertTextToInt(sSelf.removeIndexField.text) ?? 0)) , inComponent: 0, animated: false)
            optionsPickerViewController.rightBarButtonAction = KODialogActionModel.doneAction(action: {
                [weak self](optionsPickerViewController : KOOptionsPickerViewController) in
                guard let sSelf = self else{
                    return
                }
                sSelf.removeIndexField.text = "\(optionsPickerViewController.optionsPicker.selectedRow(inComponent: 0))"
            })
            optionsPickerViewController.leftBarButtonAction = KODialogActionModel.cancelAction()
        }))
    }
    
    private func convertTextToInt(_ text : String?)->Int?{
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        return numberFormatter.number(from: text ?? "")?.intValue
    }
    
    @IBAction func presentViewsBttClick(_ sender: Any) {
        view.endEditing(true)
        guard let count = convertTextToInt(presentViewsCountField.text) else{
            return
        }
        var itemsCount = 0
        if let queueCount = KOPresentationQueuesService.shared.itemsCountForQueue(withIndex: 0),  let customDialogViewController = KOPresentationQueuesService.shared.itemFromQueue(withIndex: 0, itemIndex: queueCount - 1)?.viewControllerToPresent as? CustomDialogViewController{
           itemsCount = customDialogViewController.index + 1
        }else if KOPresentationQueuesService.shared.itemPresentedForQueue(withIndex: 0) != nil{
            itemsCount += 1
        }

        for i in 0..<count{
            let customDialog = CustomDialogViewController(index: i + itemsCount)
            _ = KOPresentationQueuesService.shared.presentInQueue(customDialog, onViewController: presentingContainerViewController, queueIndex: 0, animated: true, animationCompletion: nil)
        }
    }
    
    @IBAction func removeViewBttClick(_ sender: Any) {
        view.endEditing(true)
        guard let index = convertTextToInt(removeIndexField.text) else{
            return
        }
        KOPresentationQueuesService.shared.removeFromQueue(withIndex: 0, itemWithIndex: index)
    }
    
    @IBAction func removeAllViewsBttClick(_ sender: Any) {
        KOPresentationQueuesService.shared.removeAllItemsFromQueue(withIndex: 0, forPresentingViewController: presentingContainerViewController)
    }
}

class CustomDialogViewController : KODialogViewController{
    let index : Int
    
    init(index : Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
        initializeTransition()
    }
    
    required init?(coder aDecoder: NSCoder) {
        index = 0
        super.init(coder: aDecoder)
        initializeTransition()
    }
    
    private func initializeTransition(){
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        mainViewHorizontalAlignment = .center
        mainViewVerticalAlignment = .center
        contentWidth = 300
        mainView.layer.cornerRadius = 5
        barView.titleLabel.text = "Dialog number \(index)"
        leftBarButtonAction = KODialogActionModel.cancelAction()
    }
    
    override func createContentView() -> UIView {
        let containerView = UIView()

        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        containerView.addConstraints([
            label.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12),
            label.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
            ])
        
        return containerView
    }
}
