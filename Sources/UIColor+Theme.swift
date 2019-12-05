//
//  UIColor+Theme.swift
//  KOControls
//
//  Copyright (c) 2019 Kuba Ostrowski
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

extension UIColor {
    struct Theme {
        static var dialogMainViewBackground: UIColor {
            if #available(iOS 13.0, *) {
                return UIColor.systemBackground
            } else {
                return UIColor.white
            }
        }
        
        static var dimmingViewBackground: UIColor {
            if #available(iOS 13.0, *) {
                return (UITraitCollection.current.userInterfaceStyle == .dark ? UIColor.white : UIColor.black).withAlphaComponent(0.5)
            } else {
                return UIColor.black.withAlphaComponent(0.5)
            }
        }
        
        static var errorInfoViewMarker: UIColor {
            return UIColor.red
        }
        
        static var errorInfoViewContentBackground: UIColor {
             return UIColor.gray
        }
        
        static var errorInfoViewDescription: UIColor {
            return UIColor.white
        }
    }
}
