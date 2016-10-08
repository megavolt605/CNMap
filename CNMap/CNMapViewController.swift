//
//  CNMapViewController.swift
//  CNMap
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit
import CoreLocation

typealias CNMapCallback = () -> Void

public protocol CNMapDataSource: class {
    func mapViewCoordinator(_ coordinator: CNMapViewCoordinator, needsPinsAtTopLeft topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D, completon: (_ list: [CNMapPinModel]) -> Void)
}

public protocol CNMapDelegate: class {
    func mapCoordinatorNeedsMapView(_ controller: CNMapViewCoordinator, rect: CGRect) -> CNMapView
    func createInfoViewForAnnotation(_ annotation: CNMapAnnotation) -> CNMapCalloutView?
}

open class CNMapViewCoordinator {
    
    open var superView: UIView!
    fileprivate var _mapView: CNMapView!

    var mapView: CNMapView {
        if _mapView == nil {
            _mapView = delegate?.mapCoordinatorNeedsMapView(self, rect: superView.bounds)
            // _mapView.delegate = self
            
            _mapView.view.translatesAutoresizingMaskIntoConstraints = true
            superView.addSubview(_mapView.view)
            superView.sendSubview(toBack: _mapView.view)
        }
        return _mapView
    }
    
    let coordinateQuadTree = CNMapQuadTreeCoordinate()
    
    weak var delegate: CNMapDelegate?
    weak var dataSource: CNMapDataSource?
    
    var startLocation: CLLocation?
    var backCoordinate: CLLocationCoordinate2D?
    
    var lastViewLocationRect: CNMapCoordinateRect?
    var timer: Timer!
    var skipTimer = false
    var refreshOnAppear = false
    
    // UIViewController methods
    open func didLoad() {
        reloadMap(sender: self)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMap(sender:)), name: NSNotification.Name(rawValue: "CNMapReload"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open func willAppear() {
        
        if let annotation = mapView.selectedAnnotation {
            annotation.enableUserInteractions()
        }
        
        if refreshOnAppear {
            refreshOnAppear = false
            startTimer()
        }
        
    }
    
    open func willDisappear(_ animated: Bool) {
        stopTimer()
    }
    
    func clearPlaces() {
        if _mapView != nil {
            let annotations = NSMutableSet(array: mapView.annotations)
            mapView.removeAnnotations(annotations.allObjects as! [CNMapAnnotation])
            coordinateQuadTree.clearTree()
            refreshOnAppear = true
        }
    }
    
    @objc func reloadMap(sender: AnyObject) {
        clearPlaces()
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
    
    func stopTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    func startTimer() {
        if (!skipTimer) && (!_mapView.skipTimer) {
            let mapViewRect = mapViewVisibleRect()
            lastViewLocationRect = mapViewRect
            rebuildAnnotationsWithItems(items: [])
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateContent(sender:)), userInfo: nil, repeats: false)
        }
        _mapView.skipTimer = false
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
/*
extension CNMapViewCoordinator: CNMapViewDelegate {
    
    func mapView(_ mapView: CNMapView, regionDidChangeAnimated animated: Bool) {
        stopTimer()
        startTimer()
    }
    
    func mapView(_ mapView: CNMapView, setCenterCoordinate coordinate: CLLocationCoordinate2D) {
        _mapView.skipTimer = true
        skipTimer = true
        mapView.setCenterCoordinate(coordinate, animated: true)
        skipTimer = false
    }
    
    func mapView(_ mapView: CNMapView, openInfoForAnnotation annotation: CNMapAnnotation) {
        let storyboard = CNStoryboard.main
        if annotation.actionCount == 1 {
            let viewController = storyboard.actionInfoViewController
            viewController.selectedAction = mapView.selectedAnnotation?.singleAction
            CNUI.mainVC.pushViewController(viewController: viewController)
        } else {
            let viewController = storyboard.actionTilesViewController
            viewController.mapAnnotation = mapView.selectedAnnotation
            CNUI.mainVC.pushViewController(viewController: viewController)
        }
    }
    
}
*/
