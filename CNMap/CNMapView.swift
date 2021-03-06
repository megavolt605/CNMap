//
//  CNMapView.swift
//  CNMap
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

public protocol CNMapViewDelegate: class  {
    func mapView(_ mapView: CNMapView, regionDidChangeAnimated animated: Bool)
}

public protocol CNMapView: NSObjectProtocol {

    var delegate: CNMapViewDelegate? { get set }
    
    var annotations: [CNMapAnnotation] { get }
    var selectedAnnotation: CNMapAnnotation? { get set }
    
    var view: UIView { get }
    
    var scaleFactor: Double { get }
    
    func setRegion(_ region: CNMapCoordinateRect)
    func setCenterCoordinate(_ center: CLLocationCoordinate2D)
    func setCenterCoordinate(_ center: CLLocationCoordinate2D, animated: Bool)
    func setCenterCoordinate(_ center: CLLocationCoordinate2D, atZoomLevel zoom: UInt, animated: Bool)
    
    func addAnnotations(_ annotations: [CNMapAnnotation])
    func removeAnnotations(_ annotations: [CNMapAnnotation])
    
    func convertMapViewPointToLL(_ point: CGPoint) -> CLLocationCoordinate2D
    func convertMapViewPointToMapPoint(_ point: CGPoint) -> CNMapPoint
    func convertMapPointToMapView(_ point: CNMapPoint) -> CGPoint
    
    func mapRect(_ mapRect: CNMapCoordinateRect, containsMapCoordinate coordinate: CLLocationCoordinate2D) -> Bool
    
    func createPinForAnnotation(_ annotation: CNMapAnnotation) -> CNMapPin?
    func createAnnotation(_ actionsInfo: [CNMapPinModel], coordinate: CLLocationCoordinate2D) -> CNMapAnnotation
    
    func createInfoViewForAnnotation(_ annotation: CNMapAnnotation) -> CNMapCalloutView?
    func openInfoForAnnotation(_ annotation: CNMapAnnotation)
    
    func zoomIn()
    func zoomOut()
    
    init(frame: CGRect)
    
    // UIView stuff
    func setNeedsDisplay()
    var frame: CGRect { get set }
    
    
}
