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
        tintColor = UIColor.black
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray3.cgColor
        backgroundColor = .clear
        
    }
    
}
