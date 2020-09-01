//
//  Flood.swift
//  FloodAlert
//
//  Created by Jaraad Hines on 8/31/20.
//  Copyright © 2020 Jaraad Hines. All rights reserved.
//

import Foundation

struct Flood {
    
    var documentId: String?
    let latitude: Double
    let longitude: Double
    var reportedDate: Date = Date()
}

extension Flood {
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
