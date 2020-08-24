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
    
    //Project stage
    var stageDataSource: UICollectionViewDiffableDataSource<Int, SkProjectWorkflowStage>?
    var stagesSnapshot = NSDiffableDataSourceSnapshot<Int, SkProjectWorkflowStage>()
    
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
        
        setupStageFRC()
        
        projectTitle.text = selectedProject.name
        projectStatus.text = selectedProject.status
        projectProgress.text = getTotalProgressString()
        projectDeadline.text = getStringFromDeadlineDate()
        projectNotes.text = selectedProject.desc
        
        configureStagesDataSource()
        configureStagesLayout()
        
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
    
    //Get total progress
    func getTotalProgressString() -> String {
        var totalProgress = 0
        var sumOfAllStagesProgresses = 0
        var stagesCount = 0
        let stages = stageFRC.fetchedObjects ?? []
        for stage in stages {
            print(stage.progress)
            sumOfAllStagesProgresses += Int(floor(stage.progress))
            stagesCount += 1
        }
        totalProgress = sumOfAllStagesProgresses/stagesCount
        let progressString = "\(totalProgress)%"
        return progressString
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
