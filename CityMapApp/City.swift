//
//  City.swift
//  CityMapApp
//
//  Created by PAVIT KALRA on 2023-01-19.
//

import Foundation
import MapKit

class City : NSObject, MKAnnotation {
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        
    }
    
    
    
}
