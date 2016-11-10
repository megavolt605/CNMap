//
//  CNMapCallout.swift
//  CNMap
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import Foundation
import CoreLocation

open class CNMapCallout {
    
    var infoView: CNMapCalloutView?
    weak var mapView: CNMapView!

    var isUserInteractionEnabled: Bool {
        get { return infoView?.isUserInteractionEnabled ?? false }
        set { infoView?.isUserInteractionEnabled = newValue }
    }
    
    func disableUserInteraction() {
        infoView?.isUserInteractionEnabled = false
    }
    

    
    func createInfoViewForAnnotation(_ annotation: CNMapAnnotation) {
        infoView?.removeFromSuperview()
        infoView = nil
        infoView = mapView.createInfoViewForAnnotation(annotation)
    }
    
    /*
    func setupInfoViewForAnnotation(_ annotation: CNMapAnnotation) {
        if let view = infoView {
            view.frame = CGRect(x: 8.0, y: parentViewController.view.bounds.size.height - view.bounds.height, width: parentViewController.view.bounds.width - 16.0, height: view.bounds.height - 4.0)
            view.backgroundColor = UIColor.white
            view.alpha = 0.0
            parentViewController?.view.addSubview(view)
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    view.alpha = 1.0
                },
                completion: { done in
                }
            )
        }
    }
    */
    
    open func showAtAnnotation(_ annotation: CNMapAnnotation, animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.createInfoViewForAnnotation(annotation)
            self?.mapView.setCenterCoordinate(annotation.internalCoordinate)
            self?.isUserInteractionEnabled = true
        }
    }
    
    open func hide(_ animated: Bool = true) {
        if let view = infoView {
            infoView = nil
            UIView.setAnimationsEnabled(animated)
            UIView.animate(
                withDuration: 0.5,
                animations: { [view] in
                    view.alpha = 0.0
                },
                completion: {[view] done in
                    view.removeFromSuperview()
                    UIView.setAnimationsEnabled(true)
                    //self.infoView = nil
                }
            )
        }
    }
    
    public init(mapView: CNMapView) {
        self.mapView = mapView
    }
    
}
