//
//  CNMapController.swift
//  CNMap
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit
import CoreLocation

typealias CNMapCallback = () -> Void

public protocol CNMapDataSource: class {
    func mapViewCoordinator(_ coordinator: CNMapCoordinator, needsPinsAtTopLeft topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D, completon: (_ list: [CNMapPinModel]) -> Void)
}

public protocol CNMapCoordinatorDelegate: class {
    func mapCoordinator(_ coordinator: CNMapCoordinator, needsMapViewInFrame frame: CGRect) -> CNMapView
}

open class CNMapCoordinator {
    
    static public let coordinator = CNMapCoordinator()
    
    open var superView: UIView!
    open var mapPinClass: CNMapPin.Type!
    
    fileprivate var _mapView: CNMapView!
    open var mapView: CNMapView {
        if _mapView == nil {
            _mapView = delegate?.mapCoordinator(self, needsMapViewInFrame: superView.bounds)
            _mapView.delegate = self
            
            _mapView.view.translatesAutoresizingMaskIntoConstraints = true
            superView.addSubview(_mapView.view)
            superView.sendSubview(toBack: _mapView.view)
        }
        return _mapView
    }
    
    let coordinateQuadTree = CNMapQuadTreeCoordinate()
    
    weak open var delegate: CNMapCoordinatorDelegate?
    weak open var dataSource: CNMapDataSource?
    
    open var startLocation: CLLocation?
    open var backCoordinate: CLLocationCoordinate2D?
    
    var lastViewLocationRect: CNMapCoordinateRect?
    var timer: Timer!
    
    func clearPins() {
        if _mapView != nil {
            let annotations = NSMutableSet(array: mapView.annotations)
            mapView.removeAnnotations(annotations.allObjects as! [CNMapAnnotation])
            coordinateQuadTree.clearTree()
        }
    }
    
    @objc open func reloadMap(sender: AnyObject) {
        clearPins()
        if _mapView != nil {
            _mapView.selectedAnnotation = nil
            _mapView.view.removeFromSuperview()
            _mapView = nil
        }
        coordinateQuadTree.mapView = mapView
        coordinateQuadTree.buildTree([])
        setInitialLocation()
    }
    
    func setInitialLocation() {
        let location = CNMapLocation.location.actualLocation(lastKnownLocation: startLocation)
        backCoordinate = location.coordinate
        if let lastRect = lastViewLocationRect {
            mapView.setRegion(lastRect)
        } else {
            mapView.setCenterCoordinate(location.coordinate, atZoomLevel: 16, animated: false)
        }
    }
    
    func updateMapViewAnnotationsWithAnnotations(annotations: [CNMapAnnotation]) {
        let before = NSMutableSet(array: mapView.annotations)
        let after = NSSet(array: annotations)
        
        let toKeep = NSMutableSet(set: before)
        toKeep.intersect(after as Set<NSObject>)
        
        let toAdd = NSMutableSet(set: after)
        toAdd.minus(toKeep as Set<NSObject>)
        
        let toRemove = NSMutableSet(set: before)
        toRemove.minus(after as Set<NSObject>)
        
        OperationQueue.main.addOperation() {
            self.mapView.addAnnotations(toAdd.allObjects as! [CNMapAnnotation])
            self.mapView.removeAnnotations(toRemove.allObjects as! [CNMapAnnotation])
        }
        
    }
    
    func mapViewVisibleRect() -> CNMapCoordinateRect {
        let bounds = mapView.view.bounds
        let bottomRight = mapView.convertMapViewPointToLL(CGPoint(x: bounds.width, y: 0.0))
        let topLeft = mapView.convertMapViewPointToLL(CGPoint(x: 0.0, y: bounds.height))
        return CNMapCoordinateRect(topLeft: topLeft, bottomRight: bottomRight)
    }
    
    @objc func updateContent(sender: Timer) {
        let mapViewRect = mapViewVisibleRect()
        
        dataSource?.mapViewCoordinator(self, needsPinsAtTopLeft: mapViewRect.topLeft, bottomRight: mapViewRect.bottomRight) { list in
            self.rebuildAnnotationsWithItems(items: list)
        }
    }
    
    open func stopTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    open func startTimer() {
        let mapViewRect = mapViewVisibleRect()
        lastViewLocationRect = mapViewRect
        rebuildAnnotationsWithItems(items: [])
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateContent(sender:)), userInfo: nil, repeats: false)
    }
    
    func rebuildAnnotationsWithItems(items: [CNMapPinModel]) {
        DispatchQueue.main.async {
            let bounds = self.mapView.view.bounds
            let bottomRight = self.mapView.convertMapViewPointToMapPoint(CGPoint.zero)
            let topLeft = self.mapView.convertMapViewPointToMapPoint(CGPoint(x: bounds.width, y: bounds.height))
            var visibleRect = CGRect.zero
            visibleRect.origin = CGPoint(x: CGFloat(topLeft.x), y: CGFloat(topLeft.y))
            visibleRect.size = CGSize(width: CGFloat(bottomRight.x - topLeft.x), height: CGFloat(bottomRight.y - topLeft.y))
            let scale = self.mapView.scaleFactor * Double(bounds.size.width) / Double(visibleRect.width)
            self.coordinateQuadTree.buildTree(items)
            let annotations = self.coordinateQuadTree.clusteredAnnotationsWithinMapRect(visibleRect, withZoomScale: scale)
            self.updateMapViewAnnotationsWithAnnotations(annotations: annotations)
        }
    }
    
    func zoomInButtonClick() {
        mapView.zoomIn()
    }
    
    func zoomOut() {
        mapView.zoomOut()
    }
    
    func locateMeButtonClick() {
        let cl = CNMapLocation.location.currentLocation
        if cl != nil {
            mapView.setCenterCoordinate(cl!.coordinate, atZoomLevel: 16, animated: true)
            mapView.selectedAnnotation = nil
        }
    }
    
    func back() {
        if let bc = backCoordinate {
            mapView.setCenterCoordinate(bc, atZoomLevel: 16, animated: true)
            mapView.selectedAnnotation = nil
        }
    }
    
}

extension CNMapCoordinator: CNMapViewDelegate {
    
    public func mapView(_ mapView: CNMapView, regionDidChangeAnimated animated: Bool) {
        stopTimer()
        startTimer()
    }

}
