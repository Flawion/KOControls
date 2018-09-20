//
//  CountryModel.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 20.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

class CountryModel{
    let code : String
    let name : String
    let image : UIImage
    
    init(code : String, name: String, image : UIImage) {
        self.code = code
        self.name = name
        self.image = image
    }
}
