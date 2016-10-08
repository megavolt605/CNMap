//
//  CNMapQuadTreeNode.swift
//  CNMap
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import Foundation
import CoreLocation

typealias CNMapDataReturnBlock = (_ data: CNMapPinModel) -> Void

enum CNMapQuadTreeNodeKind {
    case northWest, northEast, southWest, southEast
    static var allValues: [CNMapQuadTreeNodeKind] = [.northWest, .northEast, .southWest, .southEast]
}

final class CNMapQuadTreeNode {
    
    var nodes: [CNMapQuadTreeNodeKind: CNMapQuadTreeNode] = [:]
    
    var boundingBox: CNMapCoordinateRect
    var bucketCapacity: Int
    
    var points: [CNMapPinModel] = []
    
    func gatherDataInRange(_ range: CNMapCoordinateRect, block: CNMapDataReturnBlock) {
        if !boundingBox.intersectsBoundingBox(range) {
            return
        }
        
        for point in points {
            if range.containsData(point) {
                block(point)
            }
        }
        
        if nodes.count == 0 {
            return
        }
        
        for (_, node) in nodes {
            node.gatherDataInRange(range, block: block)
        }
    }
    
    @discardableResult
    func insertData(_ data: CNMapPinModel) -> Bool {
        if !boundingBox.containsData(data) {
            return false
        }
        
        if (points.count < bucketCapacity) {
            points.append(data)
            return true
        }
        
        if nodes.count == 0 {
            subdivide()
        }
        
        for (_, node) in nodes {
            if node.insertData(data) { return true }
        }
        
        return false
    }
    
    func subdivide() {
        let center = boundingBox.center
        
        nodes[.northWest] = CNMapQuadTreeNode(
            boundary: CNMapCoordinateRect(
                x0: boundingBox.topLeft.latitude,
                y0: boundingBox.topLeft.longitude,
                xf: center.latitude,
                yf: center.longitude),
            capacity: bucketCapacity
        )
        nodes[.northEast] = CNMapQuadTreeNode(
            boundary: CNMapCoordinateRect(
                x0: center.latitude,
                y0: boundingBox.topLeft.longitude,
                xf: boundingBox.bottomRight.latitude,
                yf: center.longitude),
            capacity: bucketCapacity
        )
        nodes[.southWest] = CNMapQuadTreeNode(
            boundary: CNMapCoordinateRect(
                x0: boundingBox.topLeft.latitude,
                y0: center.longitude,
                xf: center.latitude,
                yf: boundingBox.bottomRight.longitude),
            capacity: bucketCapacity
        )
        nodes[.southEast] = CNMapQuadTreeNode(
            boundary: CNMapCoordinateRect(
                x0: center.latitude,
                y0: center.longitude,
                xf: boundingBox.bottomRight.latitude,
                yf: boundingBox.bottomRight.longitude),
            capacity: bucketCapacity
        )
    }
    
    convenience init(data: [CLLocationCoordinate2D: CNMapPinModel], boundingBox: CNMapCoordinateRect, capacity: Int) {
        self.init(boundary: boundingBox, capacity: capacity)
        for (_, point) in data {
            insertData(point)
        }
        
    }
    
    init(boundary: CNMapCoordinateRect, capacity: Int) {
        self.boundingBox = boundary
        self.bucketCapacity = capacity
    }
    
}
