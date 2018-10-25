//
//  KOTextFieldErrorView.swift
//  KOControls
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

/// This protocol must be implemented by 'errorInfoView'. It indicates a centerX anchor of marker that pointing a field.
public protocol KOTextFieldErrorInterface{
    func markerCenterXEqualTo(_ constraint : NSLayoutXAxisAnchor)->NSLayoutConstraint?
}

/// View that shows information about an error. The minimal effort is to change 'descriptionLabel.text' to match to the error.
open class KOTextFieldErrorInfoView: UIView, KOTextFieldErrorInterface {
    //MARK: - Variables
    public private(set) weak var contentView : UIView!
    
    //description variables
    public private(set) weak var descriptionLabel : UILabel!
    public private(set) var descriptionLabelEdgesConstraintsInsets : KOEdgesConstraintsInsets!
    
    open var defaultDescriptionInsets : UIEdgeInsets{
        return UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    }
    
    //image variables
    
    /// Additional image, it is positioned before 'descriptionLabel'
    public private(set) weak var imageView : UIImageView!
    public private(set) weak var imageWidthConst : NSLayoutConstraint!
    public private(set) var imageViewEdgesConstraintsInsets : KOEdgesConstraintsInsets!
    
    open var defaultImageInsets : UIEdgeInsets{
        return UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    }
    
    //marker line variables
    
    /// Line that separates 'contentView' from the marker. It is inside the 'contentView'.
    private weak var markerLineView : UIView!

    /// Line thickness
    public private(set) weak var markerLineHeightConst : NSLayoutConstraint!
    
    /// Default line thickness, can be overridden
    open var defaultMarkerLineHeight : CGFloat{
        return 2
    }
    
    //marker variables
    
    /// View that is pointing a field
    private weak var markerView : UIView!
    private weak var markerShapeLayer : CAShapeLayer!
    private weak var markerWidthConst : NSLayoutConstraint!
    private weak var markerHeightConst : NSLayoutConstraint!
    
    //public
    
    /// Minimum edges distances from the view border
    public private(set) var markerMinHorizontalConstraintsInsets : KOHorizontalConstraintsInsets!
    
    /// Shows or hides marker view, before used it you have to turn off 'KOTextField.manageErrorInfoMarkerVisibility'
    public var isMarkerViewHidden : Bool{
        get{
            return markerView.isHidden
        }
        set{
            markerView.isHidden = newValue
        }
    }
    
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
    
    open var defaultMarkerMinHorizontalInsets : CGFloat{
        return 4
    }
    
    //MARK: - Functions
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
        
        let markerLeftConst = markerView.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor, constant: defaultMarkerMinHorizontalInsets)
        let markerRightConst = markerView.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -defaultMarkerMinHorizontalInsets)
        addConstraints([
            markerRightConst,
            markerLeftConst,
            markerView.bottomAnchor.constraint(equalTo: contentView.topAnchor),
            markerView.topAnchor.constraint(equalTo: topAnchor)
            ])
        markerMinHorizontalConstraintsInsets = KOHorizontalConstraintsInsets(leftConst: markerLeftConst, rightConst: markerRightConst)
        
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
        imageViewEdgesConstraintsInsets = KOEdgesConstraintsInsets(horizontal: KOHorizontalConstraintsInsets(leftConst: imageLeftConst, rightConst: imageRightToDescriptionLeftConst), vertical: KOVerticalConstraintsInsets(topConst: imageTopConst, bottomConst: imageBottomConst))
        self.imageWidthConst = imageWidthConst

        //for description
        let descriptionRightConst = descriptionLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -defaultDescriptionInsets.right)
        let descriptionTopConst = descriptionLabel.topAnchor.constraint(equalTo: markerLineView.bottomAnchor, constant: defaultDescriptionInsets.top)
        let descriptionBottomConst = descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -defaultDescriptionInsets.bottom)
        contentView.addConstraints([
            descriptionRightConst,
            descriptionTopConst,
            descriptionBottomConst
            ])
        descriptionLabelEdgesConstraintsInsets = KOEdgesConstraintsInsets(horizontal: KOHorizontalConstraintsInsets(leftConst: imageRightToDescriptionLeftConst, rightConst: descriptionRightConst, leftMultipler: -1.0), vertical: KOVerticalConstraintsInsets(topConst: descriptionTopConst, bottomConst: descriptionBottomConst))
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
    
    open func markerCenterXEqualTo(_ constraint : NSLayoutXAxisAnchor)->NSLayoutConstraint?{
        let const = markerView.centerXAnchor.constraint(equalTo: constraint)
        const.priority = UILayoutPriority(rawValue: 900)
        return const
    }
}
