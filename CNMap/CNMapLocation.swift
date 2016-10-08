//
//  CNMapLocation.swift
//  CNMap
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import Foundation
import CoreLocation

let CNMapLocationUpdateNotification = "CNLocationUpdate"
let CNMapLocationLatitude = "latitude"
let CNMapLocationLongitude  = "longitude"

public typealias CNMapLocationDelegateCallback = (_ success: Bool) -> Void

public protocol CNMapLocationDelegate {
    func locationIsFirstTime(_ callback: @escaping CNMapLocationDelegateCallback)
    func locationIsDenied(_ callback: @escaping CNMapLocationDelegateCallback)
}

//public enum CNMapLocationMockup: Int {
//    case none, moscow, stPetersburg, voronezh, singapore
//    public var location: CLLocation? {
//        switch self {
//        case .moscow: return CLLocation(latitude: 55.755831, longitude: 37.617673)
//        case .stPetersburg: return CLLocation(latitude: 59.95000, longitude: 30.31667)
//        case .voronezh: return CLLocation(latitude: 51.67167, longitude: 39.21056)
//        case .singapore: return CLLocation(latitude: 1.3390412, longitude: 103.7064722)
//        default: return nil
//        }
//    }
//    public var localizedName: String {
//        switch self {
//        case .none: return "main.mockupLocation.none".localize
//        case .moscow: return "main.mockupLocation.moscow".localize
//        case .stPetersburg: return "main.mockupLocation.stpetersburg".localize
//        case .voronezh: return "main.mockupLocation.voronezh".localize
//        case .singapore: return "main.mockupLocation.singapore".localize
//        }
//    }
//    public static var allValues: [CNMapLocationMockup] = [none, moscow, stPetersburg, voronezh, singapore]
//    
//}
//

open class CNMapLocation: NSObject, CLLocationManagerDelegate {
    
    open static let location = CNMapLocation()
    
    fileprivate var manager: CLLocationManager!
    
    public var currentLocation: CLLocation?
    
    public var delegate: CNMapLocationDelegate!
    public var active: Bool { return manager != nil }
    public var firstRun = true
    
    public var lastLocation: CLLocation?
    public var lastLocationUpdate: Date?
    public var lastLocationAccuracy: CLLocationAccuracy?
    
    public var isLocationActual: Bool {
        if let time = lastLocationUpdate {
            return (-time.timeIntervalSinceNow) < 2.0 * 60.0 * 60.0
        } else {
            return false
        }
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        // test the age of the location measurement to determine if the measurement is cached
        // in most cases you will not want to rely on cached measurements
        for newLocation in locations {
            let locationAge = -newLocation.timestamp.timeIntervalSinceNow
            if locationAge > 5.0 * 60.0 {
                return
            }
            
            // test that the horizontal accuracy does not indicate an invalid measurement
            if newLocation.horizontalAccuracy < 0.0 {
                return
            }
            
            if currentLocation == nil {
                currentLocation = newLocation
            } else {
                if let actualLocation = currentLocation , actualLocation.coordinate.latitude != newLocation.coordinate.latitude || actualLocation.coordinate.longitude != newLocation.coordinate.longitude {
                    currentLocation = newLocation
                }
            }
            if currentLocation != nil {
                lastLocation = currentLocation
                lastLocationUpdate = Date() //currentLocation?.timestamp
                lastLocationAccuracy = currentLocation?.horizontalAccuracy
                synchronizeUserDefaults()
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: CNMapLocationUpdateNotification), object: self)
            if let currentLocation = currentLocation {
                print("CNMapLocation: moved to lat=\(currentLocation.coordinate.latitude) long=\(currentLocation.coordinate.longitude) alt=\(currentLocation.altitude)")
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("CNMapLocation ERROR: \(error.localizedDescription)")
    }
    
    public func setup() {
        currentLocation = lastLocation
        startUpdatingLocation()
    }
    
    public func startUpdatingLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            manager = CLLocationManager()
            manager.delegate = self
            manager.activityType = CLActivityType.fitness
            manager.pausesLocationUpdatesAutomatically = true
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.distanceFilter = 10.0
            
            let start: () -> Void = {
                self.manager.requestWhenInUseAuthorization()
                self.manager.startUpdatingLocation()
            }
            
            let status = CLLocationManager.authorizationStatus()
            if status == .denied {
                if firstRun {
                    firstRun = false
                    delegate.locationIsDenied { success in
                        /*if success {
                         start()
                         }*/
                    }
                }
            } else {
                start()
            }
        } else {
            if firstRun {
                firstRun = false
                delegate.locationIsDenied() { success in
                    /*if success {
                     start()
                     }*/
                }
            }
        }
    }
    
    public func stopUpdatingLocation() {
        manager?.stopUpdatingLocation()
        manager = nil
    }
    
    public static var defaultLocation: CLLocation = CLLocation(latitude: 55.755831, longitude: 37.617673)
    
    public func actualLocation(lastKnownLocation location: CLLocation?) -> CLLocation {
        return (location ?? currentLocation) ?? CNMapLocation.defaultLocation
    }
    
    public func synchronizeUserDefaults() {
        let ud = UserDefaults.standard
        
        var configInfo: Dictionary<String, Any> = ud.dictionary(forKey: "location") ?? [:]
        if let loc = lastLocation {
            configInfo["last_location"] = loc.stringValue as AnyObject?
            configInfo["last_location_update"] = lastLocationUpdate?.timeIntervalSince1970 as AnyObject?
            configInfo["last_location_accuracy"] = lastLocationAccuracy as AnyObject?
        }
        
        ud.setValue(configInfo, forKey: "location")
        ud.synchronize()
    }
    
    public func loadFromUserDefaults() {
        let ud = UserDefaults.standard
        
        var configInfo: Dictionary<String, Any> = ud.dictionary(forKey: "location") ?? [:]
        lastLocation = CLLocation.loadFromString(configInfo["last_location"] as? String)
        if let timeInterval = (configInfo["last_location_update"] as? TimeInterval) {
            lastLocationUpdate = Date(timeIntervalSince1970: timeInterval)
        }
        lastLocationAccuracy = configInfo["last_location_accuracy"] as? Double
    }
    
}

public extension CLLocationCoordinate2D {
    
    public var stringValue: String {
        return "\(latitude),\(longitude)"
    }
    
}

public extension CLLocation {
    
    public var stringValue: String {
        return coordinate.stringValue
    }
    
    public func textDistanceFromLocation(_ location: CLLocation?) -> String {
        if let loc = location {
            let dist = self.distance(from: loc)
            if dist < 1000.0 {
                return "~ \(Int(dist)) m"
            } else {
                if dist < 50_000 {
                    return "~ \(Double(Int(dist / 100.0)) / 10.0) km"
                } else {
                    return "~ \(Int(dist / 1000.0)) km"
                }
            }
        } else {
            return ""
        }
    }
    
    public class func loadFrom(_ dictionary: Dictionary<String, AnyObject>?) -> CLLocation? {
        if let lat = dictionary?[CNMapLocationLatitude] as? CLLocationDegrees, let long = dictionary?[CNMapLocationLongitude] as? CLLocationDegrees {
            return CLLocation(latitude: lat, longitude: long)
        } else {
            return nil
        }
    }
    
    public class func loadFromString(_ string: String?) -> CLLocation? {
        
        func toDouble(_ value: String) -> Double {
            let nf = NumberFormatter()
            nf.decimalSeparator = "."
            return nf.number(from: value)!.doubleValue
        }
        
        if let s = string {
            let v: [String] = s.components(separatedBy: ",")
            if v.count == 2 {
                return CLLocation.loadFrom([CNMapLocationLatitude: toDouble(v[0]) as AnyObject, CNMapLocationLongitude: toDouble(v[1]) as AnyObject])
            }
        }
        return nil
    }
    
    public func storeTo() -> Dictionary<String, AnyObject> {
        return [
            CNMapLocationLatitude: Double(coordinate.latitude) as AnyObject,
            CNMapLocationLongitude: Double(coordinate.longitude) as AnyObject
        ]
    }
    
}
