//
//  SecondaryButton.swift
//  SmartKitty
//
//  Created by Oleh Titov on 31.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

class SecondaryButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tintColor = UIColor.label
        layer.cornerRadius = 15
        layer.borderWidth = 2
        layer.borderColor = UIColor.label.cgColor
        backgroundColor = .clear
        
    }
    
}
