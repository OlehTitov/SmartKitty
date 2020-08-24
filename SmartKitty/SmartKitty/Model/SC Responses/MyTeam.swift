//
//  MyTeam.swift
//  SmartKitty
//
//  Created by Oleh Titov on 22.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation

// MARK: - MyTeam
struct MyTeam: Codable {
    let id, email, firstName, lastName: String?
    let externalId: String?
    let services: [Service]?
    let clientIds: [String]?
}

// MARK: - Service
struct Service: Codable {
    let serviceType, sourceLanguage, targetLanguage: String?
    let pricePerUnit: Double?
    let currency: String?
    let specializations: [String]?
}
