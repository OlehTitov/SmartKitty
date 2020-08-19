//
//  ProjectDetailsVC+ExtensionMultiProgressView.swift
//  SmartKitty
//
//  Created by Oleh Titov on 19.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit
import MultiProgressView

extension ProjectDetailsVC: MultiProgressViewDataSource {
    func numberOfSections(in progressView: MultiProgressView) -> Int {
        return projectStages.count
    }
    
    func progressView(_ progressView: MultiProgressView, viewForSection section: Int) -> ProgressViewSection {
        let progressSection = ProgressViewSection()
        let stage = ProjectStage(rawValue: section)
        progressSection.backgroundColor = stage?.color
        //Do I need switch at all?
        /*
        switch stage {
        case .translation:
            progressSection.backgroundColor = stage?.color
        case 1:
            progressSection.backgroundColor = UIColor.red
        default:
            break
        }
 */
 
        return progressSection
    }
    
    
}
