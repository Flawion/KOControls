//
//  KOErrorInfoView.swift
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
public protocol KOErrorInfoProtocol {
    func markerCenterXEqualTo(_ constraint: NSLayoutXAxisAnchor) -> NSLayoutConstraint?
}

/// View that shows information about an error. The minimal effort is to change 'descriptionLabel.text' to match to the error.
open class KOErrorInfoView: UIView, KOErrorInfoProtocol {
    // MARK: - Variables
    public private(set) weak var contentView: UIView!
    
    // description variables
    public private(set) weak var descriptionLabel: UILabel!
    private var descriptionLabelConstsContainer: KOConstraintsContainer!
    public private(set) var descriptionLabelEdgesConstraintsInsets: KOEdgesConstraintsInsets!
    
    open var defaultDescriptionInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    }
    
    // image variables
    
    /// Additional image, it is positioned before 'descriptionLabel'
    public private(set) weak var imageView: UIImageView!
    private var imageViewConstsContainer: KOConstraintsContainer!
    public private(set) weak var imageWidthConst: NSLayoutConstraint!
    public private(set) var imageViewEdgesConstraintsInsets: KOEdgesConstraintsInsets!
    
    open var defaultImageInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    }
    
    // marker line variables
    
    /// Line that separates 'contentView' from the marker. It is inside the 'contentView'.
    private weak var markerLineView: UIView!
    public private(set) weak var markerLineHeightConst: NSLayoutConstraint!
    
    /// Default line thickness, can be overridden
    open var defaultMarkerLineHeight: CGFloat {
        return 2
    }
    
    // marker variables
    
    /// View that is pointing a field
    private weak var markerView: UIView!
    private weak var markerShapeLayer: CAShapeLayer!
    private weak var markerWidthConst: NSLayoutConstraint!
    private weak var markerHeightConst: NSLayoutConstraint!
    
    // public
    
    /// Minimum edges distances from the view border
    public private(set) var markerMinHorizontalConstraintsInsets: KOHorizontalConstraintsInsets!
    
    /// Shows or hides marker view, before used it you have to turn off 'KOTextField.manageErrorInfoMarkerVisibility'
    public var isMarkerViewHidden: Bool {
        get {
            return markerView.isHidden
        }
        set {
            markerView.isHidden = newValue
        }
    }
    
    public var markerWidth: CGFloat = 12 {
        didSet {
            recreateMarkerShape()
        }
    }
    
    public var markerHeight: CGFloat = 9 {
        didSet {
            recreateMarkerShape()
        }
    }
    
    public var markerColor: UIColor = UIColor.red {
        didSet {
            markerShapeLayer.fillColor = markerColor.cgColor
            markerLineView.backgroundColor = markerColor
        }
    }
    
    open var defaultMarkerMinHorizontalInsets: CGFloat {
        return 4
    }
    
    // MARK: - Functions
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

    // MARK: Initializations
    private func initialize() {
        initializeViews()
        recreateMarkerShape()
        initializeAppearance()
    }

    private func initializeAppearance() {
        backgroundColor = UIColor.clear
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 4
        contentView.backgroundColor = UIColor.gray
        descriptionLabel.textColor = UIColor.white
        markerLineView.backgroundColor = markerColor
    }

    private func initializeViews() {
        initializeContent()
        initializeMarkerView()
        initializeMarkerLineView()
        initializeDescriptionLabel()
        initializeImageView()
        initializeDescriptionLabelEdgesConstraintsInsets()
    }

    private func initializeContent() {
        let contentView = UIView()
        _ = addAutoLayoutSubview(contentView, toAddConstraints: [.left, .right, .bottom])
        self.contentView = contentView
    }

    private func initializeMarkerView() {
        let markerView = UIView()
        let markerConstraints = addAutoLayoutSubview(markerView, settings: createAddAutoLayoutSubviewSettings(forMarkerView: markerView))
        self.markerView = markerView

        let markerWidthConst = markerView.widthAnchor.constraint(equalToConstant: markerWidth)
        let markerHeightConst = markerView.heightAnchor.constraint(equalToConstant: markerHeight)
        markerView.addConstraints([
            markerWidthConst,
            markerHeightConst
            ])
        self.markerWidthConst = markerWidthConst
        self.markerHeightConst = markerHeightConst

        markerMinHorizontalConstraintsInsets = KOHorizontalConstraintsInsets(leftConst: markerConstraints.left!, rightConst: markerConstraints.right!)
    }

    private func createAddAutoLayoutSubviewSettings(forMarkerView markerView: UIView) -> KOAddAutoLayoutSubviewSettings {
        var addAutoLayoutSubviewSettings = KOAddAutoLayoutSubviewSettings()
        addAutoLayoutSubviewSettings.overrideAnchors = KOOAnchorsContainer(left: contentView.leftAnchor, right: contentView.rightAnchor, bottom: contentView.topAnchor)
        addAutoLayoutSubviewSettings.insets = UIEdgeInsets(top: 0, left: defaultMarkerMinHorizontalInsets, bottom: 0, right: defaultMarkerMinHorizontalInsets)
        addAutoLayoutSubviewSettings.operations = [KOConstraintsDirections.left: KOConstraintsOperations.equalOrGreater, KOConstraintsDirections.right: KOConstraintsOperations.equalOrLess]
        return addAutoLayoutSubviewSettings
    }

    private func initializeMarkerLineView() {
        let markerLineView = UIView()
        _ = contentView.addAutoLayoutSubview(markerLineView, toAddConstraints: [.left, .top, .right])
        self.markerLineView = markerLineView

        let markerLineHeightConst = markerLineView.heightAnchor.constraint(equalToConstant: defaultMarkerLineHeight)
        self.markerLineHeightConst = markerLineHeightConst
    }
    
    private func initializeDescriptionLabel() {
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabelConstsContainer = contentView.addAutoLayoutSubview(descriptionLabel, settings: createAddAutoLayoutSubviewSettings(forDescriptionLabel: descriptionLabel))
        self.descriptionLabel = descriptionLabel
    }

    private func createAddAutoLayoutSubviewSettings(forDescriptionLabel descriptionLabel: UILabel) -> KOAddAutoLayoutSubviewSettings {
        var addAutoLayoutSubviewSettings = KOAddAutoLayoutSubviewSettings()
        addAutoLayoutSubviewSettings.overrideAnchors = KOOAnchorsContainer(top: markerLineView.bottomAnchor)
        addAutoLayoutSubviewSettings.toAddConstraints = [.top, .right, .bottom]
        addAutoLayoutSubviewSettings.insets = UIEdgeInsets(top: defaultDescriptionInsets.top, left: 0, bottom: defaultDescriptionInsets.bottom, right: defaultDescriptionInsets.right)
        return addAutoLayoutSubviewSettings
    }
    
    private func initializeImageView() {
        let imageView = UIImageView()
        imageViewConstsContainer = contentView.addAutoLayoutSubview(imageView, settings: createAddAutoLayoutSubviewSettings(forImageView: imageView))
        self.imageView = imageView

        let imageWidthConst = imageView.widthAnchor.constraint(equalToConstant: 0)
        contentView.addConstraint(imageWidthConst)
        self.imageWidthConst = imageWidthConst
        imageViewEdgesConstraintsInsets = KOEdgesConstraintsInsets(horizontal: KOHorizontalConstraintsInsets(leftConst: imageViewConstsContainer.left!, rightConst: imageViewConstsContainer.right!), vertical: KOVerticalConstraintsInsets(topConst: imageViewConstsContainer.top!, bottomConst: imageViewConstsContainer.bottom!))
    }

    private func createAddAutoLayoutSubviewSettings(forImageView imageView: UIImageView) -> KOAddAutoLayoutSubviewSettings {
        var addAutoLayoutSubviewSettings = KOAddAutoLayoutSubviewSettings()
        addAutoLayoutSubviewSettings.overrideAnchors = KOOAnchorsContainer(right: descriptionLabel.leftAnchor)
        addAutoLayoutSubviewSettings.insets = UIEdgeInsets(top: defaultImageInsets.top, left: defaultImageInsets.left, bottom: defaultImageInsets.bottom, right: defaultImageInsets.right + defaultDescriptionInsets.left)
        return addAutoLayoutSubviewSettings
    }
    
    private func initializeDescriptionLabelEdgesConstraintsInsets() {
        descriptionLabelEdgesConstraintsInsets = KOEdgesConstraintsInsets(horizontal: KOHorizontalConstraintsInsets(leftConst: imageViewConstsContainer.right!,
                                                                                                                    rightConst: descriptionLabelConstsContainer.right!, leftMultipler: -1.0),
                                                                          vertical: KOVerticalConstraintsInsets(topConst: descriptionLabelConstsContainer.top!,
                                                                                                                bottomConst: descriptionLabelConstsContainer.bottom!))
    }

    // MARK: Marker
    private func recreateMarkerShape() {
        removeMarkerShapeLayer()
        let markerShapeLayer = CAShapeLayer()
        markerShapeLayer.path = createMarkerCGPath()
        markerShapeLayer.fillColor = markerColor.cgColor
        markerView.layer.addSublayer(markerShapeLayer)
        self.markerShapeLayer = markerShapeLayer
        
        markerHeightConst.constant = markerHeight
        markerWidthConst.constant = markerWidth
    }
    
    private func removeMarkerShapeLayer() {
        if let shape = self.markerShapeLayer {
            shape.removeFromSuperlayer()
        }
    }
    
    private func createMarkerCGPath() -> CGPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: markerHeight))
        bezierPath.addLine(to: CGPoint(x: markerWidth / 2, y: 0))
        bezierPath.addLine(to: CGPoint(x: markerWidth, y: markerHeight))
        bezierPath.close()
        return bezierPath.cgPath
    }
    
    open func markerCenterXEqualTo(_ constraint: NSLayoutXAxisAnchor) -> NSLayoutConstraint? {
        let const = markerView.centerXAnchor.constraint(equalTo: constraint).withPriority(900)
        return const
    }
}
