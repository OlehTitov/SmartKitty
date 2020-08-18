//
//  ProjectDetailsSections.swift
//  SmartKitty
//
//  Created by Oleh Titov on 18.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

enum Section: Int, CaseIterable {
    case notes
    case deadline
    case languages
    case documents
    case team
    case misc
}

struct DetailsList {
    var notes: [ProjectDetailRow]
    var deadline: [ProjectDetailRow]
    var languages: [ProjectDetailRow]
    var documents: [ProjectDetailRow]
    var team: [ProjectDetailRow]
    var misc: [ProjectDetailRow]
}

