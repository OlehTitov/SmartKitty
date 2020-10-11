//
//  Rounded.swift
//  SmartKitty
//
//  Created by Oleh Titov on 30.09.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

class Rounded: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let height = self.frame.height
        layer.cornerRadius = height/2
    }
    
}
