//
//  ProjectNote.swift
//  SmartKitty
//
//  Created by Oleh Titov on 25.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation

struct ProjectNote: Codable {
    let name: String?
    let description: String
    let deadline: String?
    let clientId: String?
    let domainId: Int?
    let vendorAccountIds: [String]?
    let externalTag: String?
    let specializations: [String]?
    let workflowStages: [String]?
}
