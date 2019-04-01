//
//  AppSettings.swift
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

final class AppSettings {
    static let fieldBorder = KOTextFieldBorderSettings(color: UIColor.lightGray.cgColor, errorColor: UIColor.red.cgColor, focusedColor: UIColor.blue.cgColor, errorFocusedColor: UIColor.red.cgColor, width: 1, focusedWidth: 2)
    
    static var countries: [CountryModel] {
        var countries: [CountryModel] = []
        guard let fileUrl =  Bundle.main.url(forResource: "CountriesList", withExtension: "txt"), let countriesStr = try? String.init(contentsOf: fileUrl) else {
            return countries
        }
        countriesStr.enumerateLines { (line, _) in
            let lineSplited = line.split(separator: ":")
            if lineSplited.count >= 2 {
                let code = String(lineSplited[0]).lowercased()
                let name = String(lineSplited[1])
                if let image = UIImage(named: code) {
                    countries.append(CountryModel(code: code, name: name, image: image))
                }
            }
        }
        return countries
    }
}
