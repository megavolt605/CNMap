//
//  CNMapPinModel.swift
//  CNMap
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import Foundation
import CoreLocation

open class CNMapPinModel {
    
    open var coordinate: CLLocationCoordinate2D!
    open var count: Int = 1
    
    public init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    public convenience init(coordinate: CLLocationCoordinate2D, count: Int) {
        self.init(coordinate: coordinate)
        self.count = count
    }
    
}
