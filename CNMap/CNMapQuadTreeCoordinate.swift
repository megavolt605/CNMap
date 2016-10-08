//
//  CNMapQuadTreeCoordinate.swift
//  CNMap
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import Foundation

import UIKit
import CoreLocation

final class CNMapQuadTreeCoordinate {
    
    var root: CNMapQuadTreeNode!
    weak var mapView: CNMapView?
    var dataArray: [CLLocationCoordinate2D:CNMapPinModel] = [:]
    
    func buildTree(_ places: [CNMapPinModel]) {
        for place in places {
            dataArray[place.coordinate] = place
        }
        root = CNMapQuadTreeNode(data: dataArray, boundingBox: CNMapCoordinateRect(x0: -200, y0: -200, xf: 200, yf: 200), capacity: 4)
    }
    
    func clearTree() {
        root = nil
        dataArray = [:]
    }
    
    func clusteredAnnotationsWithinMapRect(_ rect: CGRect, withZoomScale zoomScale: Double) -> [CNMapAnnotation] {
        let cellSize = cellSizeForZoomScale(zoomScale)
        let scaleFactor = zoomScale / cellSize
        
        // get some rects outside initial rect (for better UX)
        let minX = Int(floor(Double(rect.minX) * scaleFactor)) - 2
        let maxX = Int(floor(Double(rect.maxX) * scaleFactor)) + 2
        let minY = Int(floor(Double(rect.minY) * scaleFactor)) - 2
        let maxY = Int(floor(Double(rect.maxY) * scaleFactor)) + 2
        
        guard let mapView = mapView else { return [] }
        
        var clusteredAnnotations: [CNMapAnnotation] = []
        for x in minX..<maxX {
            for y in minY..<maxY {
                let x0 = Double(x) / scaleFactor
                let y0 = Double(y) / scaleFactor
                let xf = Double(x+1) / scaleFactor
                let yf = Double(y+1) / scaleFactor
                let mapPoint1 = mapView.convertMapPointToMapView(CNMapPoint(x: Int64(x0), y: Int64(yf)))
                let mapPoint2 = mapView.convertMapPointToMapView(CNMapPoint(x: Int64(xf), y: Int64(y0)))
                let c1 = mapView.convertMapViewPointToLL(mapPoint1)
                let c2 = mapView.convertMapViewPointToLL(mapPoint2)
                let mapRect = CNMapCoordinateRect(topLeft: c1, bottomRight: c2)
                
                var totalX = 0.0
                var totalY = 0.0
                var count = 0
                var info: [CNMapPinModel] = []
                root.gatherDataInRange(mapRect) { data in
                    totalX += data.coordinate.latitude
                    totalY += data.coordinate.longitude
                    count += 1
                    info.append(data)
                }
                
                if (count > 0) {
                    let coordinate = CLLocationCoordinate2DMake(totalX / Double(count), totalY / Double(count))
                    let annotation = mapView.createAnnotation(info, coordinate: coordinate)
                    clusteredAnnotations.append(annotation)
                }
            }
        }
        
        return clusteredAnnotations
    }
    
    func zoomScaleToZoomLevel(_ scale: Double) -> Int {
        let totalTilesAtMaxZoom: Double = 268435456.0 / CNMap.clusterDivider
        let zoomLevelAtMaxZoom: Double = log2(totalTilesAtMaxZoom)
        let logScale: Double = log2(scale)
        let floorLogScale: Double = floor(logScale + 0.5)
        let zoomLevel: Double = max(0.0, zoomLevelAtMaxZoom + floorLogScale)
        return Int(zoomLevel)
    }
    
    func cellSizeForZoomScale(_ zoomScale: Double) -> Double {
        switch zoomScaleToZoomLevel(zoomScale) {
        case 13, 14, 15: return 64
        case 16, 17, 18:  return 32
        case 19: return 16
        default: return 88
        }
    }
    
    init() {
        // dummy
    }
    
}

