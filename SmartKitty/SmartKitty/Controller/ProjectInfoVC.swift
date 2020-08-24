//
//  ProjectInfoVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 24.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ProjectInfoVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    //MARK: - PROPERTIES
    //Project
    var selectedProject: SkProject!
    
    //Core Data
    var documentFRC: NSFetchedResultsController<SkDocument>!
    var stageFRC: NSFetchedResultsController<SkProjectWorkflowStage>!
    
    //Date
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    let timeFormatter: DateFormatter = {
        let tf = DateFormatter()
        tf.dateFormat = "hh:mm a"
        return tf
    }()
    
    
    //MARK: - OUTLETS
    
    @IBOutlet weak var projectTitle: UILabel!
    @IBOutlet weak var projectProgress: UILabel!
    @IBOutlet weak var projectStatus: UILabel!
    @IBOutlet weak var projectDeadline: UILabel!
    @IBOutlet weak var projectNotes: UILabel!
    @IBOutlet weak var projectStagesCollectionView: UICollectionView!
    @IBOutlet weak var projectDocumentsCollectionView: UICollectionView!
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        projectTitle.text = selectedProject.name
        projectStatus.text = selectedProject.status
        projectDeadline.text = getStringFromDeadlineDate()
        projectNotes.text = selectedProject.desc
        
        
    }
    
    //Get deadline
    func getStringFromDeadlineDate() -> String {
        var fullDeadlineString = "No deadline specified"
        if let deadline = selectedProject.deadlineAsDate {
           let deadlineTimeString = timeFormatter.string(from: deadline)
           let deadlineDateString = dateFormatter.string(from: deadline)
           fullDeadlineString = deadlineTimeString + deadlineDateString
        }
         return fullDeadlineString
    }
    
    //MARK: - SETUP STAGE FRC
       fileprivate func setupStageFRC() {
           let stageFetchRequest: NSFetchRequest<SkProjectWorkflowStage> = SkProjectWorkflowStage.fetchRequest()
           stageFetchRequest.sortDescriptors = []
           let stagePredicate = NSPredicate(format: "project == %@", selectedProject)
           stageFetchRequest.predicate = stagePredicate
           stageFRC = NSFetchedResultsController(fetchRequest: stageFetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
           stageFRC.delegate = self
           do {
               try stageFRC.performFetch()
               //setupSnapshot()
           } catch {
               fatalError("The fetch for project stages could not be performed: \(error.localizedDescription)")
           }
       }
    
    
    
}
