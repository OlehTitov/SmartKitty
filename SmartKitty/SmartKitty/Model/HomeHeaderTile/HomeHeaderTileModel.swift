//
//  HomeHeaderTileModel.swift
//  SmartKitty
//
//  Created by Oleh Titov on 07.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

class HomeHeaderTile: Hashable {
    var id = UUID()
    var title: String
    var image: UIImage
    var color: UIColor
    var projectsCount: Int
    var link: String
    
    init(title: String, image: UIImage, color: UIColor, projectsCount: Int, link: String) {
        self.title = title
        self.image = image
        self.color = color
        self.projectsCount = projectsCount
        self.link = link
    }
    
    //Conform to Hashable Protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: HomeHeaderTile, rhs: HomeHeaderTile) -> Bool {
        lhs.id == rhs.id
    }
}
