//
//  ProjectDetailsDataSource.swift
//  SmartKitty
//
//  Created by Oleh Titov on 18.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

class ProjectDetailsDataSource: UITableViewDiffableDataSource<Section, ProjectDetailRow> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerName = ""
        let currentSection = Section(rawValue: section)!
        switch currentSection {
        case .notes:
            headerName = "Notes"
        case .deadline:
            headerName = "Deadline"
        case .languages:
            headerName = "Languages"
        case .documents:
            headerName = "Documents"
        case .team:
            headerName = "Assigned linguists"
        case .misc:
            headerName = "Additional information"
        }
        
        return headerName
    }
    
    
}
