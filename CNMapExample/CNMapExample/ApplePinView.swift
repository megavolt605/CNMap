//
//  ApplePinView.swift
//  CNMapExample
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import MapKit
import CNMap

final class AppleMapPinView: MKAnnotationView {
    
    var pin: CNMapPin!
    var callout: CNMapCallout?
    
    override required init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        image = nil
        //selectedImage = nil
        pin = CNMapPin(superView: self, annotation: annotation as! CNMapAnnotation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        pin.selected = selected
    }
    
    override func draw(_ rect: CGRect) {
        pin.drawRect(rect)
    }
    
}

