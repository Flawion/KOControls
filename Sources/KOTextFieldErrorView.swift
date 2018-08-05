//
//  KOTextFieldErrorView.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 04.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

public class KOTextFieldErrorView: UIView {
    //description variables
    public private(set) weak var descriptionLabel : UILabel!
    public private(set) weak var descriptionRightConst : NSLayoutConstraint!
    public private(set) weak var descriptionTopConst : NSLayoutConstraint!
    public private(set) weak var descriptionBottomConst : NSLayoutConstraint!
    
    //image variables
    public private(set) weak var imageView : UIImageView!
    public private(set) weak var imageLeftConst : NSLayoutConstraint!
    public private(set) weak var imageRightToDescriptionLeftConst : NSLayoutConstraint!
    public private(set) weak var imageTopConst : NSLayoutConstraint!
    public private(set) weak var imageBottomConst : NSLayoutConstraint!
    public private(set) weak var imageWidthConst : NSLayoutConstraint!
    
    //marker line variables
    private weak var markerLineView : UIView!
    public private(set) weak var markerLineHeightConst : NSLayoutConstraint!
    
    //marker variables
    private weak var markerView : UIView!
    private weak var markerShapeLayer : CAShapeLayer!
    private weak var markerWidthConst : NSLayoutConstraint!
    private weak var markerHeightConst : NSLayoutConstraint!
    
    var markerWidth : CGFloat = 12 {
        didSet{
            recreateMarkerShape()
        }
    }
    var markerHeight : CGFloat = 9 {
        didSet{
            recreateMarkerShape()
        }
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    
    private func initialize(){
        initializeViewAndConstraints()
        initializeAppearance()
    }

    private func initializeViewAndConstraints(){
        //create views
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        self.imageView = imageView
 
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(descriptionLabel)
        self.descriptionLabel = descriptionLabel
        
        let markerLineView = UIView()
        markerLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(markerLineView)
        self.markerLineView = markerLineView
        
        let markerView = UIView()
        markerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(markerView)
        self.markerView = markerView

        //create constraints
        //for marker
        let markerWidthConst = markerView.widthAnchor.constraint(equalToConstant: markerWidth)
        let markerHeightConst = markerView.heightAnchor.constraint(equalToConstant: markerHeight)
        markerView.addConstraints([
            markerWidthConst,
            markerHeightConst
            ])
        self.markerWidthConst = markerWidthConst
        self.markerHeightConst = markerHeightConst
        recreateMarkerShape()
        addConstraints([
            markerView.rightAnchor.constraint(equalTo: rightAnchor),
            markerView.bottomAnchor.constraint(equalTo: topAnchor),
            ])
        
        //for marker line
        let markerLineHeightConst = markerLineView.heightAnchor.constraint(equalToConstant: 2)
        addConstraints([
            markerLineView.leftAnchor.constraint(equalTo: leftAnchor),
            markerLineView.topAnchor.constraint(equalTo: markerView.bottomAnchor),
            markerLineView.rightAnchor.constraint(equalTo: rightAnchor),
            markerLineHeightConst
        ])
        self.markerLineView = markerLineView
        
        //for image view
        let imageLeftConst = imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        let imageRightToDescriptionLeftConst = imageView.rightAnchor.constraint(equalTo: descriptionLabel.leftAnchor, constant: -4)
        let imageTopConst = imageView.topAnchor.constraint(equalTo: topAnchor, constant: 4)
        let imageBottomConst = imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        let imageWidthConst = imageView.widthAnchor.constraint(equalToConstant: 0)
        addConstraints([
            imageLeftConst,
            imageRightToDescriptionLeftConst,
            imageTopConst,
            imageBottomConst,
            imageWidthConst
            ])
        self.imageLeftConst = imageLeftConst
        self.imageRightToDescriptionLeftConst = imageRightToDescriptionLeftConst
        self.imageTopConst = imageTopConst
        self.imageBottomConst = imageBottomConst

        //for description
        let descriptionRightConst = descriptionLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -4)
        let descriptionTopConst = descriptionLabel.topAnchor.constraint(equalTo: markerLineView.bottomAnchor, constant: 4)
        let descriptionBottomConst = descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        addConstraints([
            descriptionRightConst,
            descriptionTopConst,
            descriptionBottomConst
            ])
        self.descriptionRightConst = descriptionRightConst
        self.descriptionTopConst = descriptionTopConst
        self.descriptionBottomConst = descriptionBottomConst
    }
    
    private func initializeAppearance(){
        backgroundColor = UIColor.gray
        descriptionLabel.textColor = UIColor.white
        markerLineView.backgroundColor = UIColor.red
    }
    
    private func recreateMarkerShape(){
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x:0, y:markerHeight))
        bezierPath.addLine(to: CGPoint(x:markerWidth / 2, y:0))
        bezierPath.addLine(to: CGPoint(x:markerWidth, y:markerHeight))
        bezierPath.close()
        
        if let shape = self.markerShapeLayer{
            shape.removeFromSuperlayer()
        }
        let markerShapeLayer = CAShapeLayer()
        markerShapeLayer.path = bezierPath.cgPath
        markerShapeLayer.fillColor = UIColor.red.cgColor
        markerView.layer.addSublayer(markerShapeLayer)
        self.markerShapeLayer = markerShapeLayer
        
        markerHeightConst.constant = markerHeight
        markerWidthConst.constant = markerWidth
    }
}
