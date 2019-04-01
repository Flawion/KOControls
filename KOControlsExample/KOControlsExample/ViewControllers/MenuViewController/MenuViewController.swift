//
//  MenuViewController.swift
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

final class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var menuTableView: UITableView!
    
    private let menuItemReuseIdentifier: String = "menuItemReuseIdentifier"
    private let menuItemTypes: [MenuItemTypes] = [
        .presentationQueueService,
        .textFields,
        .scrollOffsetProgressController,
        .pickerView
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Menu"
        menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: menuItemReuseIdentifier)
        menuTableView.tableFooterView = UIView()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            
        case .scrollOffsetProgressController:
            navigationController?.pushViewController(ScrollOffsetProgressViewController(), animated: true)
            
        case .pickerView:
            navigationController?.pushViewController(PickerViewController(), animated: true)
        }
        menuTableView.deselectRow(at: indexPath, animated: true)
    }
}
