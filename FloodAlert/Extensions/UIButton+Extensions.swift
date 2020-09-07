//
//  UIButton+Extensions.swift
//  FloodAlert
//
//  Created by Jaraad Hines on 9/6/20.
//  Copyright © 2020 Jaraad Hines. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    static func buttonForRightAccesoryView() -> UIButton {
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 10, height: 22)
        button.setImage(UIImage(named:"trash-icon"), for: .normal)
        return button
    }
}
