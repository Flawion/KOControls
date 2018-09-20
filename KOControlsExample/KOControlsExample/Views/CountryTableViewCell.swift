//
//  CountryTableViewCell.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 20.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

class CountryTableViewCell: UITableViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var countryModel : CountryModel?{
        didSet{
            guard let countryModel = self.countryModel else{
                return
            }
            titleLabel.text = countryModel.name
            iconView.image = countryModel.image
        }
    }
}
