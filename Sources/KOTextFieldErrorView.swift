//
//  KOTextFieldErrorView.swift
//  KOControls
//
//  Created by Kuba Ostrowski on 04.08.2018.
//  Copyright © 2018 Kuba Ostrowski. All rights reserved.
//

import UIKit

public protocol KOTextFieldErrorInterface{
    func markerCenterXEqualTo(_ constraint : NSLayoutXAxisAnchor)->NSLayoutConstraint?
}

public class KOTextFieldErrorView: UIView, KOTextFieldErrorInterface {
    //MARK: Variables
    public private(set) weak var contentView : UIView!
    
    //description variables
    public private(set) weak var descriptionLabel : UILabel!
    public private(set) weak var descriptionRightConst : NSLayoutConstraint!
    public private(set) weak var descriptionTopConst : NSLayoutConstraint!
    public private(set) weak var descriptionBottomConst : NSLayoutConstraint!
    
    public var defaultDescriptionInsets : UIEdgeInsets{
        return UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    }
    
    //image variables
    public private(set) weak var imageView : UIImageView!
    public private(set) weak var imageLeftConst : NSLayoutConstraint!
    public private(set) weak var imageRightToDescriptionLeftConst : NSLayoutConstraint!
    public private(set) weak var imageTopConst : NSLayoutConstraint!
    public private(set) weak var imageBottomConst : NSLayoutConstraint!
    public private(set) weak var imageWidthConst : NSLayoutConstraint!
    
    public var defaultImageInsets : UIEdgeInsets{
        return UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    }
    
    //marker line variables
    private weak var markerLineView : UIView!
    
    public private(set) weak var markerLineHeightConst : NSLayoutConstraint!
    public var defaultMarkerLineHeight : CGFloat{
        return 2
    }
    
    //marker variables
    private weak var markerView : UIView!
    private weak var markerShapeLayer : CAShapeLayer!
    private weak var markerWidthConst : NSLayoutConstraint!
    private weak var markerHeightConst : NSLayoutConstraint!
    private weak var markerLeftConst : NSLayoutConstraint!
    private weak var markerRightConst : NSLayoutConstraint!
    
    public var markerWidth : CGFloat = 12 {
        didSet{
            recreateMarkerShape()
        }
    }
    public var markerHeight : CGFloat = 9 {
        didSet{
            recreateMarkerShape()
        }
    }
    
    public var markerColor : UIColor = UIColor.red{
        didSet{
            markerShapeLayer.fillColor = markerColor.cgColor
            markerLineView.backgroundColor = markerColor
        }
    }
    
    public var markerMinLeftMargin : CGFloat = 4{
        didSet{
            markerLeftConst.constant = markerMinLeftMargin
            layoutIfNeeded()
        }
    }
    
    public var markerMinRightMargin : CGFloat = 4{
        didSet{
            markerRightConst.constant = -markerMinRightMargin
            layoutIfNeeded()
        }
    }
    
    //MARK: Functions
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
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        self.contentView = contentView
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        self.imageView = imageView
 
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        self.descriptionLabel = descriptionLabel
        
        let markerLineView = UIView()
        markerLineView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(markerLineView)
        self.markerLineView = markerLineView
        
        let markerView = UIView()
        markerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(markerView)
        self.markerView = markerView

        //create constraints
        //for content
        addConstraints([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
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
        
        let markerLeftConst = markerView.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor, constant: markerMinLeftMargin)
        let markerRightConst = markerView.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -markerMinRightMargin)
        addConstraints([
            markerRightConst,
            markerLeftConst,
            markerView.bottomAnchor.constraint(equalTo: contentView.topAnchor),
            markerView.topAnchor.constraint(equalTo: topAnchor)
            ])
        self.markerLeftConst = markerLeftConst
        self.markerRightConst = markerRightConst
        
        //for marker line
        let markerLineHeightConst = markerLineView.heightAnchor.constraint(equalToConstant: defaultMarkerLineHeight)
        contentView.addConstraints([
            markerLineView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            markerLineView.topAnchor.constraint(equalTo: contentView.topAnchor),
            markerLineView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            markerLineHeightConst
        ])
        self.markerLineView = markerLineView
        
        //for image view
        let imageLeftConst = imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: defaultImageInsets.left)
        let imageRightToDescriptionLeftConst = imageView.rightAnchor.constraint(equalTo: descriptionLabel.leftAnchor, constant:  (-defaultImageInsets.right) + (-defaultDescriptionInsets.left))
        let imageTopConst = imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: defaultImageInsets.top)
        let imageBottomConst = imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -defaultImageInsets.bottom)
        let imageWidthConst = imageView.widthAnchor.constraint(equalToConstant: 0)
        contentView.addConstraints([
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
        let descriptionRightConst = descriptionLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -defaultDescriptionInsets.right)
        let descriptionTopConst = descriptionLabel.topAnchor.constraint(equalTo: markerLineView.bottomAnchor, constant: defaultDescriptionInsets.top)
        let descriptionBottomConst = descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -defaultDescriptionInsets.bottom)
        contentView.addConstraints([
            descriptionRightConst,
            descriptionTopConst,
            descriptionBottomConst
            ])
        self.descriptionRightConst = descriptionRightConst
        self.descriptionTopConst = descriptionTopConst
        self.descriptionBottomConst = descriptionBottomConst
    }
    
    private func initializeAppearance(){
        backgroundColor = UIColor.clear
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 4
        contentView.backgroundColor = UIColor.gray
        descriptionLabel.textColor = UIColor.white
        markerLineView.backgroundColor = markerColor
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
        markerShapeLayer.fillColor = markerColor.cgColor
        markerView.layer.addSublayer(markerShapeLayer)
        self.markerShapeLayer = markerShapeLayer
        
        markerHeightConst.constant = markerHeight
        markerWidthConst.constant = markerWidth
    }
    
    public func markerCenterXEqualTo(_ constraint : NSLayoutXAxisAnchor)->NSLayoutConstraint?{
        let const = markerView.centerXAnchor.constraint(equalTo: constraint)
        const.priority = UILayoutPriority(rawValue: 900)
        return const
    }
}
