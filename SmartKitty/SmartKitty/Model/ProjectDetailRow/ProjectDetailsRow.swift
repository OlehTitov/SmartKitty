//
//  ProjectDetailsRow.swift
//  SmartKitty
//
//  Created by Oleh Titov on 15.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

class ProjectDetailRow: Hashable {
    var id = UUID()
    var title: String
    var desc: String
    
    init(title: String, desc: String) {
        self.title = title
        self.desc = desc
    }
    
    //Conform to Hashable Protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ProjectDetailRow, rhs: ProjectDetailRow) -> Bool {
        lhs.id == rhs.id
    }
}
