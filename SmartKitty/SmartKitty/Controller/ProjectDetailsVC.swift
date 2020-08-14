//
//  ProjectDetailsVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 12.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ProjectDetailsVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    //MARK: - PROPERTIES
    var selectedProject: SkProject!
    var fetchedResultsController: NSFetchedResultsController<SkProject>!
    
    //MARK: - OUTLETS
    @IBOutlet weak var projectTitle: UILabel!
    @IBOutlet weak var documentsCount: UILabel!
    
    @IBOutlet weak var listOfDocuments: UILabel!
    
    
    //MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    //MARK: - VIEW WILL DISAPPEAR
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        guard let projects = fetchedResultsController.fetchedObjects else {
            return
        }
        let selectedProject = projects[0]
        let documents = selectedProject.documents
        let docs = documents as? Set<SkDocument> ?? []
        projectTitle.text = projects[0].name
        documentsCount.text = String(documents!.count)
        var docNames: [String] = []
        for doc in docs {
            if let name = doc.name {
                docNames.append(name)
            }
        }
        listOfDocuments.text = docNames.joined(separator: ", ")
    }
    
    //MARK: - SETUP FRC
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<SkProject> = SkProject.fetchRequest()
        fetchRequest.sortDescriptors = []
        guard let projectId = selectedProject.id else { return
        }
        let predicate = NSPredicate(format: "id == %@", projectId)
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            //setupSnapshot()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}
