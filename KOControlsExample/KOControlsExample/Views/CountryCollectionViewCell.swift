//
//  CollectionViewCell.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 21.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit
import KOControls

class CountryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override var isSelected: Bool{
        get{
            return super.isSelected
        }
        set{
            super.isSelected = newValue
            layer.borderWidth = newValue ? 4 : 0
        }
    }
    
    weak var countryModel : CountryModel?{
        didSet{
            guard let countryModel = self.countryModel else{
                return
            }
            titleLabel.text = countryModel.name
            iconView.image = countryModel.image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.orange.cgColor
        layer.cornerRadius = 5
    }
}
