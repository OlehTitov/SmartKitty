//
//  ActionButton.swift
//  SmartKitty
//
//  Created by Oleh Titov on 17.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

class ActionButton: Hashable {
    var id = UUID()
    var title: String
    var image: UIImage
    var link: String
    
    init(title: String, image: UIImage, link: String) {
        self.title = title
        self.image = image
        self.link = link
        
    }
    
    //Conform to Hashable Protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ActionButton, rhs: ActionButton) -> Bool {
        lhs.id == rhs.id
    }
}
