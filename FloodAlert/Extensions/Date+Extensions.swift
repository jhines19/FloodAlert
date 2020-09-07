//
//  Date+Extensions.swift
//  FloodAlert
//
//  Created by Jaraad Hines on 9/1/20.
//  Copyright © 2020 Jaraad Hines. All rights reserved.
//

import Foundation

extension Date {
    
    func formatAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}
