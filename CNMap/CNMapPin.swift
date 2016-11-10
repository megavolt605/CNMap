//
//  CNMapPin.swift
//  CNMap
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit

public
enum CNMapPinKind {
    case single, cluster
}

public protocol CNMapPinDelegate {
    func mapPinStateChanged(_ mapPin: CNMapPin)
}

open class CNMapPin {

    weak var superView: UIView?
    
    open var delegate: CNMapPinDelegate?
    
    open var count: Int = 0 {
        didSet {
            countWasChanged()
        }
    }
    
    open var kind: CNMapPinKind {
        return count > 1 ? .cluster : .single
    }
    
    open var selected: Bool = false {
        didSet {
            if selected != oldValue { pinDidSetSelected(selected) }
        }
    }
    
    var contentImage: UIImage?
    
    let scaleFactorAlpha = 0.5
    let scaleFactorBeta = 0.5
    let scaleFactorAlphaSingle = 1.0
    let scaleFactorBetaSingle = 0.1
    
    var countLabel: UILabel!
    var contentImageView: UIImageView!
    
    func pinDidSetSelected(_ selected: Bool) {
        superView?.setNeedsDisplay()
        delegate?.mapPinStateChanged(self)
    }
    
    func updatePinFrame() {
        countLabel.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 40.0, height: 40.0))
        superView?.frame = countLabel.frame
    }
    
    func countWasChanged() {
        updatePinFrame()
        if (kind == .cluster) && (contentImage == nil) {
            countLabel.text = "\(count)"
            countLabel.isHidden = false
            contentImageView.isHidden = true
        } else {
            countLabel.isHidden = true
            contentImageView.layer.cornerRadius = countLabel.bounds.width / 2.0
            contentImageView.isHidden = false
            selected = false
        }
        delegate?.mapPinStateChanged(self)
    }
    
    func scaledValueForValue(_ value: Double) -> Double {
        if count == 1 {
            let a = -scaleFactorAlphaSingle
            let b = pow(value, scaleFactorBetaSingle)
            let c = 1.0 + exp(a * b)
            return 1.0 / c
        } else {
            let a = -scaleFactorAlpha
            let b = pow(value, scaleFactorBeta)
            let c = 1.0 + exp(a * b)
            return 1.0 / c
        }
    }
    
    func setupSubviews() {
/*        if let sView = superView, countLabel == nil {
            countLabel = UILabel(frame: sView.frame)
            countLabel.backgroundColor = UIColor.clear
            countLabel.textAlignment = .center
            countLabel.adjustsFontSizeToFitWidth = true
            countLabel.numberOfLines = 1
            countLabel.applyUIConfig(CNUIConfig.config.map.pinText)
            countLabel.baselineAdjustment = .alignCenters
            sView.addSubview(countLabel)
            
            contentImageView = UIImageView(frame: sView.frame)
            contentImageView.backgroundColor = UIColor.clear
            contentImageView.contentMode = .scaleAspectFit
            sView.addSubview(contentImageView)
        }*/
    }
    
    func setupImages(_ annotation: CNMapAnnotation) {
        /*
        var categories: Set<Int> = []
        
        annotation.actionsInfo.forEach { info in
            info.mapBriefActions.forEach { action in
                action.categories.forEach { category in
                    categories.insert(category)
                }
            }
        }
        
        if annotation.actionCount == 1 || categories.count == 1 {
            let img: UIImage?
            if let cat = CNModel.model.categories.categoryById(categories.first) {
                img = cat.categoryImage ?? CNUI.placeholderSmallImage
            } else {
                img = CNUI.placeholderSmallImage
            }
            contentImage = img
            contentImageView.image = img
            countWasChanged()
        }*/
    }
    
    open func drawRect(_ rect: CGRect) { }
    
    public required init(superView: UIView, annotation: CNMapAnnotation) {
        self.superView = superView
        setupSubviews()
        setupImages(annotation)
        count = 1
    }
    
}
