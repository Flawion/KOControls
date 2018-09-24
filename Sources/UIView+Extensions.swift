//
//  UIView+Extensions.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 04.09.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

//MARK: Internal extensions
extension UIView{
    internal func fill(withView filingView: UIView?){
        guard subviews.first != filingView else{
            //nothing changed
            return
        }
        
        //delete old ones
        removeConstraints(constraints)
        for subview in subviews{
            subview.removeFromSuperview()
        }
        
        //add new one if need
        if let filingView = filingView{
            filingView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(filingView)
            addConstraints([
                filingView.leftAnchor.constraint(equalTo: leftAnchor),
                filingView.topAnchor.constraint(equalTo: topAnchor),
                filingView.rightAnchor.constraint(equalTo: rightAnchor),
                filingView.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
        }
    }
}
