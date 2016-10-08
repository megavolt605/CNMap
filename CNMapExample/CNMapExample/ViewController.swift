//
//  ViewController.swift
//  CNMapExample
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit
import CNMap

enum CNMapProvider {
    case apple, yandex, google
}

class ViewController: UIViewController {
    
    static func createViewWithProvider(_ provider: CNMapProvider, frame: CGRect, ownerViewController: UIViewController) -> CNMapView {
        switch provider {
        case .yandex: return RPMapViewYandex(frame: frame, ownerViewController: ownerViewController)
        case .google: return RPMapViewGoogle(frame: frame, ownerViewController: ownerViewController)
        case .apple: return RPMapViewApple(frame: frame, ownerViewController: ownerViewController)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

