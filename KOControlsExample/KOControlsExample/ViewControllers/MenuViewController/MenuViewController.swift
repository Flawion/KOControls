//
//  MenuViewController.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 04.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var menuTableView: UITableView!
    
    private let menuItemReuseIdentifier : String = "menuItemReuseIdentifier"
    private let menuItemTypes : [MenuItemTypes] = [
        .presentationQueueService,
        .textFields,
        .scrollOffsetBasedView
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Menu"
        menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: menuItemReuseIdentifier)
        menuTableView.tableFooterView = UIView()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return menuItemTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = menuTableView.dequeueReusableCell(withIdentifier: menuItemReuseIdentifier, for: indexPath)
        cell.textLabel?.text = menuItemTypes[indexPath.row].rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItemType = menuItemTypes[indexPath.row]
        switch menuItemType {
        
        case .presentationQueueService:
            navigationController?.pushViewController(PresentationQueueViewController(), animated: true)
            
        case .textFields:
            navigationController?.pushViewController(TextFieldsViewController(), animated: true)
            
        case .scrollOffsetBasedView:
            navigationController?.pushViewController(ScrollOffsetBasedViewController(), animated: true)
        }
        menuTableView.deselectRow(at: indexPath, animated: true)
    }
}
