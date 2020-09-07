//
//  FloodAnnotation.swift
//  FloodAlert
//
//  Created by Jaraad Hines on 9/6/20.
//  Copyright © 2020 Jaraad Hines. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class FloodAnnotation: MKPointAnnotation {
    
    let flood: Flood
    
    init(_ flood: Flood) {
        self.flood = flood
    }
}
