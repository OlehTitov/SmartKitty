//
//  WalkthroughCards.swift
//  SmartKitty
//
//  Created by Oleh Titov on 24.09.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

class WalkthroughCard: Hashable {
    var id = UUID()
    var title: String
    var image: String
    var description: String
    
    
    init(title: String, image: String, description: String) {
        self.title = title
        self.image = image
        self.description = description
    }
    
    //Conform to Hashable Protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: WalkthroughCard, rhs: WalkthroughCard) -> Bool {
        lhs.id == rhs.id
    }
}
