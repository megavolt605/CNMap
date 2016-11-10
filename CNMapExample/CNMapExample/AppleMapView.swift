//
//  AppleMapView.swift
//  CNMapExample
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import CNMap

extension MKMapView {
    
    func setCenterCoordinate(_ centerCoordinate: CLLocationCoordinate2D, zoomLevel: UInt, animated: Bool) {
        let span = MKCoordinateSpanMake(0.0, 360.0 / pow(2.0, Double(zoomLevel)) * Double(frame.size.width) / 256.0)
        setRegion(MKCoordinateRegionMake(centerCoordinate, span), animated: animated)
    }
    
}

class AppleMapView: UIView {

    weak var delegate: CNMapViewDelegate?
    
    fileprivate var zoomLevel: UInt = 16 {
        didSet {
            if _mapView != nil {
                _mapView.setCenterCoordinate(_mapView.centerCoordinate, zoomLevel: zoomLevel, animated: true)
            }
        }
    }
    
    fileprivate var _mapView: MKMapView!

    var scaleFactor: Double = 0.5
    
    func createObjects() {
        _mapView = MKMapView(frame: frame)
        _mapView.isRotateEnabled = false
        _mapView.isPitchEnabled = false
        _mapView.showsUserLocation = true
        _mapView.userTrackingMode = .followWithHeading
        _mapView.delegate = self
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        createObjects()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

extension AppleMapView: CNMapView {

    var annotations: [CNMapAnnotation] {
        var res = _mapView.annotations
        if let index = (res.index() { ($0 as? MKUserLocation) == self._mapView.userLocation }) {
            res.remove(at: index)
        }
        return res as! [AppleMapAnnotation]
    }
    
    var selectedAnnotation: CNMapAnnotation? {
        get {
            return _mapView.selectedAnnotations.first as? CNMapAnnotation
        }
        set {
            if let a = newValue as? MKAnnotation {
                _mapView.selectedAnnotations = [a]
            } else {
                _mapView.selectedAnnotations = []
            }
        }
    }

    var view: UIView {
        return _mapView
    }
    
    func setRegion(_ region: CNMapCoordinateRect) {
        let mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2DMake(
                (region.topLeft.latitude + region.bottomRight.latitude) / 2.0,
                (region.topLeft.longitude + region.bottomRight.longitude) / 2.0
            ),
            span: MKCoordinateSpanMake(
                abs(region.topLeft.latitude - region.bottomRight.latitude) / 2.0,
                abs(region.topLeft.longitude - region.bottomRight.longitude) / 2.0
            )
        )
        _mapView.setRegion(mapRegion, animated: false)
    }
    
    func setCenterCoordinate(_ center: CLLocationCoordinate2D) {
        _mapView.setCenter(center, animated: false)
    }
    
    func setCenterCoordinate(_ center: CLLocationCoordinate2D, animated: Bool) {
        _mapView.setCenter(center, animated: animated)
    }
    
    func setCenterCoordinate(_ center: CLLocationCoordinate2D, atZoomLevel zoom: UInt, animated: Bool) {
        _mapView.setCenterCoordinate(center, zoomLevel: zoom, animated: false)
    }
    
    func addAnnotations(_ annotations: [CNMapAnnotation]) {
        _mapView.addAnnotations(annotations as! [AppleMapAnnotation])
    }
    
    func removeAnnotations(_ annotations: [CNMapAnnotation]) {
        _mapView.removeAnnotations(annotations as! [AppleMapAnnotation])
    }
    
    func convertMapViewPointToLL(_ point: CGPoint) -> CLLocationCoordinate2D {
        return _mapView.convert(point, toCoordinateFrom: nil)
    }
    
    func convertMapViewPointToMapPoint(_ point: CGPoint) -> CNMapPoint {
        let mapPoint = MKMapPointForCoordinate(convertMapViewPointToLL(point))
        return CNMapPoint(x: Int64(mapPoint.x), y: Int64(mapPoint.y))
    }
    
    func convertMapPointToMapView(_ point: CNMapPoint) -> CGPoint {
        let mapPoint = MKMapPointMake(Double(point.x), Double(point.y))
        return _mapView.convert(MKCoordinateForMapPoint(mapPoint), toPointTo: nil)
    }
    
    func mapRect(_ mapRect: CNMapCoordinateRect, containsMapCoordinate coordinate: CLLocationCoordinate2D) -> Bool {
        let mapPoint = MKMapPointForCoordinate(coordinate)
        let a = MKMapPointForCoordinate(mapRect.topLeft)
        let b = MKMapPointForCoordinate(mapRect.bottomRight)
        let mapRect = MKMapRectMake(min(a.x, b.x), min(a.y, b.y), max(a.x, b.x), max(a.y, b.y))
        return MKMapRectContainsPoint(mapRect, mapPoint)
    }
    
    func zoomIn() {
        zoomLevel += 1
    }
    
    func zoomOut() {
        if zoomLevel > 2 {
            zoomLevel -= 1
        }
        
    }
    
    func createPinForAnnotation(_ annotation: CNMapAnnotation) -> CNMapPin? {
        return CNMapPin(superView: self, annotation: annotation)
    }
    
    func createAnnotation(_ pins: [CNMapPinModel], coordinate: CLLocationCoordinate2D) -> CNMapAnnotation {
        return AppleMapAnnotation(pins: pins, coordinate: coordinate)
    }
    
    func createInfoViewForAnnotation(_ annotation: CNMapAnnotation) -> CNMapCalloutView? {
        return nil // TODO
    }
    
    func openInfoForAnnotation(_ annotation: CNMapAnnotation) {
        selectedAnnotation = annotation
        annotation.isUserInteractionEnabled = false
    }
    
}

extension AppleMapView: MKMapViewDelegate {
    
    // MKMapView delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "CNMapAnnotationViewReuseID"
        if let clusterAnnotation = annotation as? CNMapAnnotation {
            let annotationView = AppleMapPinView(annotation: annotation, reuseIdentifier: reuseID)
            
            annotationView.canShowCallout = false
            annotationView.pin.count = clusterAnnotation.count
            
            return annotationView
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let v = view as? AppleMapPinView, let a = v.annotation as? CNMapAnnotation {
            v.isSelected = true
            v.callout = CNMapCallout(mapView: self)
            v.callout?.showAtAnnotation(a, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let v = view as? AppleMapPinView {
            v.isSelected = false
            v.callout?.hide(true)
            v.callout = nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        views.forEach { _ in
            //CNUI.addBounceAnnimationToView($0)
        }
    }
    
    func mapViewShouldFollowUserLocation(_ map: MKMapView) -> Bool {
        return false
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        delegate?.mapView(self, regionDidChangeAnimated: animated)
    }
    
}
