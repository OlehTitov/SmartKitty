//
//  projectStages.swift
//  SmartKitty
//
//  Created by Oleh Titov on 19.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

enum ProjectStage: Int {
    case translation
    case editing
    case proofreading
    case postediting
    case finalPageProof
    case notarization
    case certifiedTranslation
    case transcreation
    case legalization
    case preliminaryPageProof
    
    var description: String {
        switch self {
        case .translation:
            return "Translation"
        case .editing:
            return "Editing"
        case .proofreading:
            return "Proofreading"
        case .postediting:
            return "Post-editing"
        case .finalPageProof:
            return "Final page proof"
        case .notarization:
            return "Notarization"
        case .certifiedTranslation:
            return "Certified translation"
        case.transcreation:
            return "Transcreation"
        case .legalization:
            return "Legalization"
        case .preliminaryPageProof:
            return "Preliminary page proof"
        }
    }
    
    var color: UIColor {
        switch self {
        case .translation:
            return UIColor.green
        case .editing:
            return UIColor.blue
        case .proofreading:
            return UIColor.orange
        case .postediting:
            return UIColor.brown
        case .finalPageProof:
            return UIColor.purple
        case .notarization:
            return UIColor.red
        case .certifiedTranslation:
            return UIColor.magenta
        case.transcreation:
            return UIColor.yellow
        case .legalization:
            return UIColor.black
        case .preliminaryPageProof:
            return UIColor.darkGray
        }
    }
}
