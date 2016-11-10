//
//  CNMapAnnotation.swift
//  CNMap
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit
import CoreLocation

open class CNMapAnnotation: NSObject {
    
    open var pins: [CNMapPinModel] = []
    
    weak var annotationView: UIView?
    weak var calloutView: UIView?
    
    open var internalCoordinate: CLLocationCoordinate2D
    
    fileprivate var _count = 0
    open var count: Int {
        if _count != 0 {
            return _count
        }
        _count = pins.reduce(0) { (sum, model) -> Int in
            return sum + model.count
        }
        return _count
    }
    
    open var isUserInteractionEnabled: Bool {
        get { return calloutView?.isUserInteractionEnabled ?? false }
        set { calloutView?.isUserInteractionEnabled = newValue }
    }
    
    // Obj-C stuff for Equitable & Hashable
    
    override open var hashValue: Int {
        let toHash = NSString(format: "%.5F%.5F", internalCoordinate.latitude, internalCoordinate.longitude)
        return toHash.hash
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        if let other = object as? CNMapAnnotation {
            return self == other
        }
        return false
    }
    
    override open var hash: Int {
        return hashValue
    }
    
    public init(pins: [CNMapPinModel], coordinate: CLLocationCoordinate2D) {
        internalCoordinate = coordinate
        self.pins = pins
        super.init()
    }
    
}

public func ==(lhs: CNMapAnnotation, rhs: CNMapAnnotation) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
