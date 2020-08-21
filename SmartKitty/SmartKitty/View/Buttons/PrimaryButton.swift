//
//  PrimaryButton.swift
//  SmartKitty
//
//  Created by Oleh Titov on 20.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

class PrimaryButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tintColor = UIColor.white
        layer.cornerRadius = 15
        layer.shadowColor = UIColor.primary.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 15
        backgroundColor = UIColor.primary
        
    }
    
}
