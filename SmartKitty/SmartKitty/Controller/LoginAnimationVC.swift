//
//  LoginAnimationVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 21.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation

import UIKit
import CoreData

class LoginAnimationVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    
    //MARK: - PROPERTIES
    var fetchedResultsController: NSFetchedResultsController<SkProject>!
    var userType: UserType!
    
    //MARK: - OUTLETS
    @IBOutlet weak var catImage: UIImageView!
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        SCClient.Auth.accountId = (UserDefaults.standard.value(forKey: "AccountId") as! String)
        SCClient.Auth.apiKey = (UserDefaults.standard.value(forKey: "ApiKey") as! String)
        SCClient.getProjectsList(completion: handleGetProjectsList(projects:error:))
    }
    
    //MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    //MARK: - VIEW DID DISAPPEAR
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func downloadProjects() {
        if UserDefaults.standard.bool(forKey: "SomeProjectsExist") {
            userType = .loggedIn
        }
    }
    
    //MARK: - ANIMATE TRANSITION TO NEXT VC
    func animateCatAndGoToNextVC() {
        UIView.animate(
            withDuration: 2,
            delay: 1,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0,
            options: .curveEaseIn,
            animations: {
            self.catImage.transform = CGAffineTransform(scaleX: 20, y: 20)
        }, completion: { (true) in
            let tabBarVC = self.storyboard?.instantiateViewController(identifier: "TabBarVC") as! TabBarVC
            tabBarVC.modalPresentationStyle = .fullScreen
            tabBarVC.modalTransitionStyle = .crossDissolve
            self.present(tabBarVC, animated: true, completion: nil)
            //self.navigationController?.pushViewController(tabBarVC, animated: true)
        })
    }
    
    //MARK: - HANDLE GET PROJECTS LIST
    func handleGetProjectsList(projects: [Project], error: Error?) {
        print(projects.count)
        for project in projects {
            if isExisting(project: project) {
                updateSkProject(prj: project)
                print("Updating project")
            } else {
                createSkProject(prj: project)
                UserDefaults.standard.set(true, forKey: "SomeProjectsExist")
                print("Creating project")
            }
        }
        animateCatAndGoToNextVC()
    }
    
    //MARK: - CHECK IF PROJECT IS EXISTING
    func isExisting(project: Project) -> Bool {
        var result = false
        if UserDefaults.standard.bool(forKey: "SomeProjectsExist") {
            if let existingProjects = fetchedResultsController.fetchedObjects {
               for existingProject in existingProjects where project.id == existingProject.id {
                    result = true
                }
            }
        } else {
            result = false
        }
        
        return result
    }
    
    //MARK: - UPDATE PROJECT IN CORE DATA
    func updateSkProject(prj: Project) {
        //First, find appropriate project to update
        var projectToUpdate: SkProject!
        guard let existingProjects = fetchedResultsController.fetchedObjects else { return }
        for existingProject in existingProjects where prj.id == existingProject.id {
            projectToUpdate = existingProject
        }
        //Set new values that were obtained from server
        if projectToUpdate.name != prj.name {
            for key in projectToUpdate.entity.attributesByName.keys {
                let value: Any? = projectToUpdate.value(forKey: key)
                print("\(key) = \(String(describing: value))")
            }
        }
    }
    
    
    //MARK: - CREATE NEW PROJECT IN CORE DATA
    func createSkProject(prj: Project) {
        ///Create new SkProject entity
        let newProject = SkProject(context: DataController.shared.viewContext)
        newProject.id = prj.id
        newProject.name = prj.name
        newProject.desc = prj.description
        newProject.clientId = prj.clientId
        newProject.sourceLanguage = prj.sourceLanguage
        newProject.targetLanguages = prj.targetLanguages
        newProject.deadline = prj.deadline
        newProject.creationDate = prj.creationDate
        newProject.status = prj.status
        newProject.createdByUserEmail = prj.createdByUserEmail
        //Computed property for deadlineAsDate
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let deadline = prj.deadline {
            let date = RFC3339DateFormatter.date(from: deadline)!
            newProject.deadlineAsDate = date
            //Computed property for isToday
            let calendar = NSCalendar.current
            let isToday = calendar.isDateInToday(date)
            newProject.isToday = isToday
            //Computed property for isTomorrow
            let isTomorrow = calendar.isDateInTomorrow(date)
            newProject.isTomorrow = isTomorrow
        }
        
        ///Create SkProjectWorkflowStage entities
        if let projectWorkflowStages = prj.workflowStages {
            for stage in projectWorkflowStages {
                let projectStage = SkProjectWorkflowStage(context: DataController.shared.viewContext)
                projectStage.stageType = stage.stageType
                projectStage.progress = stage.progress ?? 0.0
                projectStage.project = newProject
            }
        }
        
        ///Create SkDocument entities
        guard let SCdocuments = prj.documents else {
            return
        }
        for document in SCdocuments {
            let doc = SkDocument(context: DataController.shared.viewContext)
            doc.project = newProject
            doc.id = document.id
            doc.name = document.name
            doc.creationDate = document.creationDate
            doc.sourceLanguage = document.sourceLanguage
            doc.documentDisassemblingStatus = document.documentDisassemblingStatus
            doc.targetLanguage = document.targetLanguage
            doc.status = document.status
            if let count = document.wordsCount {
                doc.wordsCount = String(count)
            }
            doc.statusModificationDate = document.statusModificationDate
            if let pretranslateCompleted = document.pretranslateCompleted {
                doc.pretranslateCompleted = pretranslateCompleted
            }
            doc.externalId = document.externalId
            doc.metaInfo = document.metaInfo
            if let placeholdersAreEnabled = document.placeholdersAreEnabled {
                doc.placeholdersAreEnabled = placeholdersAreEnabled
            }
            ///Create SkDocumentWorkflowStage
            guard let docStages = document.workflowStages else {
                return
            }
            for stage in docStages {
                let docWorkflowStage = SkDocumentWorkflowStage(context: DataController.shared.viewContext)
                docWorkflowStage.document = doc
                if let stageProgress = stage.progress {
                    docWorkflowStage.progress = stageProgress
                }
                docWorkflowStage.status = stage.status
                if let wordsTranslated = stage.wordsTranslated {
                    docWorkflowStage.wordsTranslated = Int64(wordsTranslated)
                }
                if let unassignedwordsCount = stage.unassignedWordsCount {
                    docWorkflowStage.unassignedWordsCount = Int64(unassignedwordsCount)
                }
                ///Create SkAssignedExecutive
                guard let assignedExecutives = stage.executives else {
                    return
                }
                for executive in assignedExecutives {
                    let freelancer = SkAssignedExecutive(context: DataController.shared.viewContext)
                    freelancer.documentWorkflow = docWorkflowStage
                    freelancer.id = executive.id
                }
                
                 
            }
            
        }
        
        try? DataController.shared.viewContext.save()
        setupFetchedResultsController()
    }
    
    
    
    
    //MARK: - SETUP FRC
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<SkProject> = SkProject.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
}
