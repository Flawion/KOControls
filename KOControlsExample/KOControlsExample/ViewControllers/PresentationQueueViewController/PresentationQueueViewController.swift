//
//  PresentationQueueViewController.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 15.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit
import KOControls

class PresentationQueueViewController: UIViewController {
    @IBOutlet weak var presentingView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var presentViewsCountField: UITextField!
    @IBOutlet weak var removeIndexField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "KOPresentationQueueService"
    }

    @IBAction func presentViewsBttClick(_ sender: Any) {
        view.endEditing(true)
        guard let count = NumberFormatter().number(from: presentViewsCountField.text ?? "")?.intValue else{
            return
        }
        var itemsCount = KOPresentationQueuesService.shared.itemsCountForQueue(withIndex: 0) ?? 0
        if KOPresentationQueuesService.shared.isItemPresentedForQueue(withIndex: 0){
            itemsCount += 1
        }
        for i in 0..<count{
            let customDialog = CustomDialogViewController(index: i + itemsCount)
            customDialog.dimmingTransition.setupPresentationControllerEvent = {
                [weak self] presentation in
                guard let sSelf = self else{return}
                presentation.keepFrameOfView = sSelf.presentingView
                presentation.touchForwardingView.passthroughViews = [sSelf.bottomView]
            }
            _ = KOPresentationQueuesService.shared.presentInQueue(customDialog, onViewController: self, queueIndex: 0, animated: true, animationCompletion: nil)
        }
    }
    
    @IBAction func removeViewBttClick(_ sender: Any) {
        view.endEditing(true)
        guard let index = NumberFormatter().number(from: removeIndexField.text ?? "")?.intValue else{
            return
        }
        KOPresentationQueuesService.shared.removeFromQueue(withIndex: 0, itemWithIndex: index)
    }
}

class CustomDialogViewController : KODialogViewController{
    private let index : Int
    
    init(index : Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        index = 0
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainViewHorizontalAlignment = .center
        mainViewVerticalAlignment = .center
        contentWidth = 300
        mainView.layer.cornerRadius = 5
        barView.titleLabel.text = "Dialog number \(index)"
        leftBarButtonAction = KODialogViewControllerActionModel.cancelAction()
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
