//
//  NextButton.swift
//  SmartKitty
//
//  Created by Oleh Titov on 22.10.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import UIKit

class NextButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    func setupButton() {
        backgroundColor = .mediumSlateBlue
        //layer.cornerRadius = 10
        tintColor = UIColor.white
        
    }
    
}
