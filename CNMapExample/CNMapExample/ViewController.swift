//
//  ViewController.swift
//  CNMapExample
//
//  Created by Igor Smirnov on 08/10/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit
import CNMap

enum MapProvider: Int {
    case apple//, yandex, google
}

class ViewController: UIViewController {
    
    @IBOutlet weak var mapProviderView: UIView!
    @IBOutlet weak var mapProviderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var baseMapView: UIView!
    
    var provider: MapProvider = .apple
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapProviderSegmentedControl.selectedSegmentIndex = provider.rawValue
        
        baseMapView.clipsToBounds = true
        CNMapCoordinator.coordinator.superView = baseMapView
        CNMapCoordinator.coordinator.delegate = self
        CNMapCoordinator.coordinator.reloadMap(sender: self)
        
    }

    @IBAction func mapProviderChanged(_ sender: AnyObject) {
        provider = MapProvider(rawValue: mapProviderSegmentedControl.selectedSegmentIndex)!
        CNMapCoordinator.coordinator.reloadMap(sender: self)
    }

}

extension ViewController: CNMapCoordinatorDelegate {
 
    func mapCoordinator(_ coordinator: CNMapCoordinator, needsMapViewInFrame frame: CGRect) -> CNMapView {
        switch provider {
        case .apple: return AppleMapView(frame: frame)
        /*case .yandex: return YandexMapView(frame: frame)
         case .google: return GoogleMapView(frame: frame)*/
        }
    }

    func mapCoordinator(_ coordinator: CNMapCoordinator, regionDidChangeAnimated animated: Bool) {
        
    }
    
    func mapCoordinator(_ coordinator: CNMapCoordinator, openInfoForAnnotation annotation: CNMapAnnotation) {
        
    }
    
}
