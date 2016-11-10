//
//  AppleMapAnnotation.swift
//  CNMapExample
//
//  Created by Igor Smirnov on 13/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import Foundation
import MapKit
import CNMap

class AppleMapAnnotation: CNMapAnnotation, MKAnnotation {
    
    var title: String? = "!"
    @objc(subTitle) var subTitle: String = ""
    var coordinate: CLLocationCoordinate2D {
        get {
            return internalCoordinate
        }
        set {
            internalCoordinate = newValue
        }
    }
}
