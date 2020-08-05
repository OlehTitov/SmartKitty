//
//  AccountResponse.swift
//  SmartKitty
//
//  Created by Oleh Titov on 04.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation

struct AccountResponse: Codable {
    let id: String
    let name: String
    let isPersonal: Bool
    let type: String
}
