//
//  CNMapCalloutView.swift
//  CNMap
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit

open class CNMapCalloutView: UIView {
    
    open weak var annotation: CNMapAnnotation!
    open weak var owner: CNMapView!
    
    func openInfoTap(_ recognizer: UIGestureRecognizer) {
        startActivity()
        owner.openInfoForAnnotation(annotation)
        self.stopActivity()
    }
    
    open func startActivity() { }
    
    open func stopActivity() { }
    
}
