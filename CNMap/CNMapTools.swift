//
//  CNMapTools.swift
//  CNMap
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import Foundation
import CoreLocation

public struct CNMapPoint {
    public var x: Int64
    public var y: Int64
    public init(x: Int64, y: Int64) {
        self.x = x
        self.y = y
    }
}

public struct CNMapCoordinateRect {
    
    public var topLeft: CLLocationCoordinate2D
    public var bottomRight: CLLocationCoordinate2D
    
    public func containsData(_ data: CNMapPinModel) -> Bool {
        if let coordinate = data.coordinate {
            let containsX = topLeft.latitude <= coordinate.latitude && coordinate.latitude <= bottomRight.latitude
            let containsY = topLeft.longitude <= coordinate.longitude && coordinate.longitude <= bottomRight.longitude
            
            return containsX && containsY
        }
        return false
    }
    
    public func intersectsBoundingBox(_ b2: CNMapCoordinateRect) -> Bool {
        return topLeft.latitude <= b2.bottomRight.latitude && bottomRight.latitude >= b2.topLeft.latitude &&
            topLeft.longitude <= b2.bottomRight.longitude && bottomRight.longitude >= b2.topLeft.longitude
    }
    
    public var center: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(
            (bottomRight.latitude + topLeft.latitude) / 2.0,
            (bottomRight.longitude + topLeft.longitude) / 2.0
        )
    }
    
    public var minX: Double { return min(topLeft.latitude, bottomRight.latitude) }
    public var maxX: Double { return max(topLeft.latitude, bottomRight.latitude) }
    public var minY: Double { return min(topLeft.longitude, bottomRight.longitude) }
    public var maxY: Double { return max(topLeft.longitude, bottomRight.longitude) }
    
    public init(x0: Double, y0: Double, xf: Double, yf: Double) {
        self.topLeft = CLLocationCoordinate2DMake(x0, y0)
        self.bottomRight = CLLocationCoordinate2DMake(xf, yf)
    }
    
    public init(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D) {
        self.topLeft = topLeft
        self.bottomRight = bottomRight
    }
    
}

extension CLLocationCoordinate2D: Hashable {

    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    
    public var hashValue: Int {
        return "\(longitude)/\(latitude)".hash
    }
    
}
