//
//  ClientResponse.swift
//  SmartKitty
//
//  Created by Oleh Titov on 02.09.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation

// MARK: - Client
struct Client: Codable {
    let id, name: String?
    let netRate: NetRate?
    let mainContact: Contact?
    let additionalContacts: [Contact]?
    let vat, countryCode, comment, website: String?
    let industryId, legalName, address: String?
    let languageId: Int?
    let vendorManager: String?
}

// MARK: - Contact
struct Contact: Codable {
    let email, fullName, phoneNumber, position: String?
    let comment: String?
}

// MARK: - NetRate
struct NetRate: Codable {
    let id, name: String?
    let newWordsRate, repetitionsRate: Double?
    let tmMatchRates: [TmMatchRate]?
}

// MARK: - TmMatchRate
struct TmMatchRate: Codable {
    let fromQuality, toQuality: Int?
    let value: Double?
}
