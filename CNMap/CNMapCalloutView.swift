//
//  CNMapCalloutView.swift
//  CNMap
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit

open class CNMapCalloutView: UIView {
    
    weak public var annotation: CNMapAnnotation!
    weak public var owner: CNMapView!
    
    func openInfoTap(_ recognizer: UIGestureRecognizer) {
        startActivity()
        owner.openInfoForAnnotation(annotation)
        self.stopActivity()
    }
    
    func startActivity() { }
    
    func stopActivity() { }
    
    func enableUserInteraction() { }
    
    func disableUserInteraction() { }
    
}
