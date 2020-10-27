//
//  SearchMyTeam.swift
//  SmartKitty
//
//  Created by Oleh Titov on 27.10.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation

struct SearchMyTeam: Codable {
    let skip, limit: Int?
    let serviceType, sourceLanguage, targetLanguage: String?
    let onlyNativeSpeakers, allDialects: Bool?
    let minRate, maxRate: Double?
    let rateRangeCurrency: String?
    let specializations, specializationKnowledgeLevel: [String]?
    let searchString: String?
    let daytime: Bool?
}
