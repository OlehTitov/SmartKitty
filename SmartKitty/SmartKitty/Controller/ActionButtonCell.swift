//
//  ActionButtonCell.swift
//  SmartKitty
//
//  Created by Oleh Titov on 17.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import UIKit

class ActionButtonCell: UICollectionViewCell {
    
    @IBOutlet weak var buttonWithImage: UIButton!
    @IBOutlet weak var buttonDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonWithImage.layer.cornerRadius = 25
    }
}
