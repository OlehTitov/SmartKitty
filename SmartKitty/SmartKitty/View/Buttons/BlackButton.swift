//
//  BlackButton.swift
//  SmartKitty
//
//  Created by Oleh Titov on 02.09.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

class BlackButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tintColor = UIColor.white
        layer.cornerRadius = 10
        //layer.shadowColor = UIColor.primary.cgColor
        //layer.shadowOpacity = 0.5
        //layer.shadowOffset = CGSize(width: 0, height: 5)
        //layer.shadowRadius = 15
        layer.borderColor = UIColor.systemGray3.cgColor
        
    }
    
}
