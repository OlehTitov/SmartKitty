//
//  projectStatuses.swift
//  SmartKitty
//
//  Created by Oleh Titov on 12.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

enum ProjectStatuses: String {
    case created = "created"
    case inProgress = "inProgress"
    case completed = "completed"
    case cancelled = "cancelled"
}

struct ProjectStatus: Equatable {
    let iconName: String
    let statusColor: UIColor
    
    init(iconName: String, statusColor: UIColor) {
        self.iconName = iconName
        self.statusColor = statusColor
    }
}
