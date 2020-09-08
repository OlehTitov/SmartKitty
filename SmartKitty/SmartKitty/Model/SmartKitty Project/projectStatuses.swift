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
    
    var icon: UIImage {
        switch self {
        case .created: return UIImage(systemName: "circle")!
        case .inProgress: return UIImage(systemName: "ellipsis.circle")!
        case .completed: return UIImage(systemName: "checkmark.circle")!
        case .cancelled: return UIImage(systemName: "xmark.circle")!
        }
    }
    
    var readableName: String {
        switch self {
        case .created: return "Created"
        case .inProgress: return "In progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: UIColor {
        switch self {
        case .created: return UIColor.gray
        case .inProgress: return UIColor.systemBlue
        case .completed: return UIColor.green
        case .cancelled: return UIColor.red
        }
    }
}

struct ProjectStatus: Equatable {
    let iconName: String
    let statusColor: UIColor
    
    init(iconName: String, statusColor: UIColor) {
        self.iconName = iconName
        self.statusColor = statusColor
    }
}
