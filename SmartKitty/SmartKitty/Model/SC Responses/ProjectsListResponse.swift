//
//  ProjectsListResponse.swift
//  SmartKitty
//
//  Created by Oleh Titov on 05.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation

// MARK: - PROJECT
struct Project: Codable {
    let id, name, description, deadline: String?
    let creationDate, createdByUserId, createdByUserEmail, modificationDate: String?
    let sourceLanguage: String?
    let targetLanguages: [String]?
    let status, statusModificationDate: String?
    let domainId: Int?
    let clientId: String?
    let vendors: [Vendor]?
    let workflowStages: [ProjectWorkflowStage]?
    let documents: [Document]?
    let externalTag: String?
    let specializations, managers: [String]?
    let number: String?
    
}

// MARK: - Document
struct Document: Codable {
    let id, name, creationDate, deadline: String?
    let sourceLanguage, documentDisassemblingStatus, targetLanguage, status: String?
    let wordsCount: Int?
    let statusModificationDate: String?
    let pretranslateCompleted: Bool?
    let workflowStages: [DocumentWorkflowStage]?
    let externalId, metaInfo: String?
    let placeholdersAreEnabled: Bool?
}

// MARK: - DocumentWorkflowStage
struct DocumentWorkflowStage: Codable {
    let progress: Double?
    let wordsTranslated, unassignedWordsCount: Int?
    let status: String?
    let executives: [Executive]?
}

// MARK: - Executive
struct Executive: Codable {
    let assignedWordsCount: Int?
    let progress: Double?
    let id, supplierType: String?
}

// MARK: - Vendor
struct Vendor: Codable {
    let vendorAccountId: String?
    let removedFromProject: Bool?
}

// MARK: - ProjectWorkflowStage
struct ProjectWorkflowStage: Codable {
    let progress: Double?
    let stageType: String?
}

