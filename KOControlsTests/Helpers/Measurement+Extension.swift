//
//  Measurement+Extension.swift
//  KOControlsTests
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

extension CGFloat {
    func almostEqual(to: CGFloat, maxDifference: CGFloat = 0.001) -> Bool {
        return self + maxDifference > to && self - maxDifference < to
    }
    
    func almostEqualUI(to: CGFloat) -> Bool {
        return almostEqual(to: to, maxDifference: 0.999)
    }
}

extension CGRect {
    func almostEqualUI(to: CGRect) -> Bool {
        let intersectionRect = to.intersection(to)
        return minX.almostEqualUI(to: intersectionRect.minX) && minY.almostEqualUI(to: intersectionRect.minY)
        && maxX.almostEqualUI(to: intersectionRect.maxX) && maxY.almostEqualUI(to: intersectionRect.maxY)
    }
}
