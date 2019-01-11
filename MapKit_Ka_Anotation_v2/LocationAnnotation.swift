//
//  File.swift
//  MapKit_Ka_Anotation_v2
//
//  Created by Viet Asc on 1/11/19.
//  Copyright © 2019 Viet Asc. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class LocationAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
}
