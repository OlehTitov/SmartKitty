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
    var projectFRC: NSFetchedResultsController<SkProject>!
    var documentFRC: NSFetchedResultsController<SkDocument>!
    var stageFRC: NSFetchedResultsController<SkProjectWorkflowStage>!
    
    //Project stage
    var stageDataSource: UICollectionViewDiffableDataSource<Int, SkProjectWorkflowStage>?
    var stagesSnapshot = NSDiffableDataSourceSnapshot<Int, SkProjectWorkflowStage>()
    
    //Project document
    var documentsDataSource: UICollectionViewDiffableDataSource<Int, SkDocument>?
    var documentsSnapshot = NSDiffableDataSourceSnapshot<Int, SkDocument>()
    
    //Date
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    let timeFormatter: DateFormatter = {
        let tf = DateFormatter()
        tf.dateFormat = "HH:mm"
        return tf
    }()
    
    
    //MARK: - OUTLETS
    
    @IBOutlet weak var projectTitle: UILabel!
    @IBOutlet weak var projectProgress: UILabel!
    @IBOutlet weak var projectStatus: UILabel!
    @IBOutlet weak var projectDeadline: UILabel!
    @IBOutlet weak var sourceLang: UILabel!
    @IBOutlet weak var targetLang: UILabel!
    @IBOutlet weak var createdBy: UILabel!
    @IBOutlet weak var client: UILabel!
    @IBOutlet weak var projectNotes: UILabel!
    @IBOutlet weak var projectStagesCollectionView: UICollectionView!
    @IBOutlet weak var projectDocumentsCollectionView: UICollectionView!
    @IBOutlet weak var favButton: ToggleButton!
    
    @IBOutlet weak var copyToClipboardConfirmation: UIView!
    
    @IBOutlet weak var deadlineContainer: UIView!
    
    //MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupStageFRC()
        setupDocumentFRC()
    }
    
    //MARK: - VIEW DID DISAPPEAR
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stageFRC = nil
        documentFRC = nil
    }
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        //Perform fetch requests
        setupStageFRC()
        setupDocumentFRC()
        //Setup general information
        setupGeneralProjectDetails()
        //Prepare data source and layout for collection views
        configureStagesDataSource()
        configureStagesLayout()
        configureDocumentsDataSource()
        configureDocumentsLayout()
        //Gesture recognizer to copy text into clipboard
        configureGestureRecognizer()
        //Favourite button
        configureFavButton()
        //Get client info
        getClientInformation()
        copyToClipboardConfirmation.isHidden = true
        deadlineContainer.layer.cornerRadius = 20
        
    }
    
    //MARK: - ADD A NOTE
    @IBAction func addANoteTapped(_ sender: Any) {
        let addNoteVC = self.storyboard?.instantiateViewController(identifier: "AddNote") as! AddNote
        addNoteVC.selectedProject = selectedProject
        addNoteVC.modalPresentationStyle = .overCurrentContext
        addNoteVC.modalTransitionStyle = .coverVertical
        
        present(addNoteVC, animated: true, completion: nil)
        
    }
    
    //MARK: - SHARE PROJECT LINK
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let id = selectedProject.id else {
            return
        }
        let projectURL = URL(string: "https://\(SCClient.selectedServer)/projects/\(id)")!
        let items = [projectURL]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityController, animated: true)
    }
    
    //MARK: - MAKE PROJECT FAVOURITE
    @IBAction func favouriteButtonTapped(_ sender: UIButton) {
        makeHapticFeedback()
        if sender.isSelected {
            selectedProject.isStarred = false
            try? DataController.shared.viewContext.save()
            print("Project is not favourite anymore")
        } else {
            selectedProject.isStarred = true
            try? DataController.shared.viewContext.save()
            print("Marked as favourite")
        }
    }
    
    func configureFavButton() {
        if selectedProject.isStarred {
            favButton.isSelected = true
        }
    }
    
    //MARK: - SETUP PROJECT DETAILS
    //Get deadline
    func getStringFromDeadlineDate() -> String {
        var fullDeadlineString = "No deadline specified"
        if let deadline = selectedProject.deadlineAsDate {
           let deadlineTimeString = timeFormatter.string(from: deadline)
           let deadlineDateString = dateFormatter.string(from: deadline)
           fullDeadlineString = "📦 \(deadlineTimeString), \(deadlineDateString)"
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
    
    //Display general project details
    func setupGeneralProjectDetails() {
        projectTitle.text = selectedProject.name
        projectStatus.text = selectedProject.status
        projectProgress.text = getTotalProgressString()
        projectDeadline.text = getStringFromDeadlineDate()
        let source = selectedProject.sourceLanguage ?? ""
        sourceLang.text = "Source: \(source)"
        let target = selectedProject.targetLanguages?.joined(separator: ", ") ?? ""
        targetLang.text = "Target: \(target)"
        let author = selectedProject.createdByUserEmail ?? ""
        createdBy.text = "Created by: \(author)"
        projectNotes.text = "Notes: \(selectedProject.desc ?? "")"
    }
    
    //Get client info
    func getClientInformation() {
        guard let id = selectedProject.clientId else {
            return
        }
        SCClient.getClientInfo(clientId: id, completion: handleGetClientInfo(client:error:))
    }
    
    func handleGetClientInfo(client: Client?, error: Error?) {
        guard let client = client?.name else {
            return
        }
        self.client.text = "Client: \(client)"
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
    
    //MARK: - SETUP DOCUMENT FRC
    fileprivate func setupDocumentFRC() {
        let projectFetchRequest: NSFetchRequest<SkProject> = SkProject.fetchRequest()
        projectFetchRequest.sortDescriptors = []
        let projectPredicate = NSPredicate(format: "id == %@", selectedProject.id!)
        projectFetchRequest.predicate = projectPredicate
        projectFRC = NSFetchedResultsController(fetchRequest: projectFetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        projectFRC.delegate = self
        
        
        let documentFetchRequest: NSFetchRequest<SkDocument> = SkDocument.fetchRequest()
        documentFetchRequest.sortDescriptors = []
        let docPredicate = NSPredicate(format: "project == %@", selectedProject)
        documentFetchRequest.predicate = docPredicate
        documentFRC = NSFetchedResultsController(fetchRequest: documentFetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        documentFRC.delegate = self
        
        do {
            try documentFRC.performFetch()
            try projectFRC.performFetch()
            
        } catch {
            fatalError("The fetch for project documents could not be performed: \(error.localizedDescription)")
        }
    }
    
    //MARK: - FRC DELEGATE
    // Whenever the content changes it updates the snapshot
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        setupStagesSnapshot()
        setupDocumentsSnapshot()
        setupGeneralProjectDetails()
    }
    
}
