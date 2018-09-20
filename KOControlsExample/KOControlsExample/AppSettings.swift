//
//  AppSettings.swift
//  KOControlsExample
//
//  Created by Kuba Ostrowski on 18.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit
import KOControls

class AppSettings{
    static let fieldBorder = KOTextFieldBorderSettings(color: UIColor.lightGray.cgColor, errorColor: UIColor.red.cgColor, focusedColor: UIColor.blue.cgColor, errorFocusedColor : UIColor.red.cgColor,  width: 1, focusedWidth: 2)
    

    static var countries : [CountryModel]{
        var countries : [CountryModel] = []
        guard let fileUrl =  Bundle.main.url(forResource: "CountriesList", withExtension: "txt"), let countriesStr = try? String.init(contentsOf: fileUrl) else{
            return countries
        }
        countriesStr.enumerateLines {
            (line, _) in
            let lineSplited = line.split(separator: ":")
            if lineSplited.count >= 2{
                let code = String(lineSplited[0]).lowercased()
                let name = String(lineSplited[1])
                if let image = UIImage(named: code){
                    countries.append(CountryModel(code: code, name: name, image: image))
                }
            }
        }
        return countries
    }
    
}
