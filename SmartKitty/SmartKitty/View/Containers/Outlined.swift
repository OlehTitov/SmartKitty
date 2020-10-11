//
//  Outlined.swift
//  SmartKitty
//
//  Created by Oleh Titov on 29.09.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

class Outlined: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.borderWidth = 1
        
    }
    
}
