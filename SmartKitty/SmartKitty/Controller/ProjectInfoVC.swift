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
        df.timeStyle = .short
        return df
    }()
    
    //MARK: - OUTLETS
    @IBOutlet weak var projectTitle: UILabel!
    @IBOutlet weak var projectProgress: UILabel!
    @IBOutlet weak var projectStatus: UILabel!
    @IBOutlet weak var deadline: UILabel!
    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var target: UILabel!
    @IBOutlet weak var projectClient: UILabel!
    @IBOutlet weak var totalWordsCount: UILabel!
    @IBOutlet weak var notesContainer: Outlined!
    @IBOutlet weak var notes: UILabel!
    
    @IBOutlet weak var manager: UILabel!
    
    @IBOutlet weak var projectStagesCollectionView: UICollectionView!
    @IBOutlet weak var projectDocumentsCollectionView: UICollectionView!
    @IBOutlet weak var favButton: ToggleButton!
    @IBOutlet weak var copyToClipboardConfirmation: UIView!
    
    @IBOutlet weak var documentsTitle: UILabel!
    
    //MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupProjectFRC()
        setupStageFRC()
        setupDocumentFRC()
        displayNotesContainer()
    }
    
    //MARK: - VIEW DID APPEAR
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupProjectFRC()
        displayNotesContainer()
    }
    
    //MARK: - VIEW DID DISAPPEAR
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stageFRC = nil
        documentFRC = nil
        projectFRC = nil
    }
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        //Perform fetch requests
        setupProjectFRC()
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
        //Misc setup
        copyToClipboardConfirmation.isHidden = true
        displayNotesContainer()
        addAssignButton()
    }
    
    //MARK: - ADD A NOTE
    @IBAction func addANoteTapped(_ sender: Any) {
        let addNoteVC = self.storyboard?.instantiateViewController(identifier: "AddNote") as! AddNote
        addNoteVC.selectedProject = selectedProject
        addNoteVC.modalPresentationStyle = .overCurrentContext
        addNoteVC.modalTransitionStyle = .coverVertical
        present(addNoteVC, animated: true, completion: setupProjectFRC)
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
    
    //MARK: - ADD ASSIGN BUTTON
    func addAssignButton() {
        let assignButton = UIBarButtonItem(title: "Assign", style: .plain, target: self, action: #selector(assignTapped))
        self.navigationItem.rightBarButtonItem = assignButton
    }
    
    @objc func assignTapped() {
        print("assign button tapped")
        let nextVC = AssignProjectStage()
        nextVC.selectedProject = selectedProject
        //self.navigationController?.pushViewController(nextVC, animated: true)
        present(nextVC, animated: true, completion: nil)
    }
    
    //MARK: - SETUP PROJECT DETAILS
    //Get deadline
    func getStringFromDeadlineDate() -> String {
        guard let str = selectedProject.deadlineAsDate else {
            return "No deadline specified"
        }
        let dateAsString = dateFormatter.string(from: str)
        return dateAsString
    }
    
    //Display notes container
    func displayNotesContainer() {
        let text = notes.text
        let trimmedText = text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText == "" {
            notesContainer.isHidden = true
        } else {
            notesContainer.isHidden = false
        }
    }
    
    func displayNotesContainerAfterAddingANote() {
        
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
    
    //Get total words count
    func getTotalWordsCount() -> Int {
        guard let documents = documentFRC.fetchedObjects else {
            return 0
        }
        var wordsCountArray = [0]
        for doc in documents {
            if let wordsCount = doc.wordsCount {
                let wordsCountInt = Int(wordsCount)
                wordsCountArray.append(wordsCountInt!)
            }
        }
        let total = wordsCountArray.reduce(0,+)
        return total
    }
    
    //Display general project details
    func setupGeneralProjectDetails() {
        projectTitle.text = selectedProject.name
        let status = ProjectStatuses(rawValue: selectedProject.status!)
        projectStatus.text = status?.readableName.uppercased()
        let wc = getTotalWordsCount()
        totalWordsCount.text = String(wc)
        projectProgress.text = getTotalProgressString()
        deadline.text = getStringFromDeadlineDate()
        source.text = selectedProject.sourceLanguage ?? "No language specified"
        target.text = selectedProject.targetLanguages?.joined(separator: ", ") ?? "No language specified"
        let author = selectedProject.createdByUserEmail ?? ""
        manager.text = author
        let projectDesc = selectedProject.desc ?? ""
        let trimmedDesc = projectDesc.trimmingCharacters(in: .whitespacesAndNewlines)
        notes.text = trimmedDesc
        documentsTitle.text = "Documents: \(documentFRC.fetchedObjects?.count ?? 0)"
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
        self.projectClient.text = client
    }
    
    //MARK: - SETUP STAGE FRC
       fileprivate func setupStageFRC() {
           let stageFetchRequest: NSFetchRequest<SkProjectWorkflowStage> = SkProjectWorkflowStage.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "stageNumber", ascending: true)
        stageFetchRequest.sortDescriptors = [sortDescriptor]
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
    
    //MARK: - SETUP PROJECT FRC
    fileprivate func setupProjectFRC() {
        let projectFetchRequest: NSFetchRequest<SkProject> = SkProject.fetchRequest()
        projectFetchRequest.sortDescriptors = []
        let projectPredicate = NSPredicate(format: "id == %@", selectedProject.id!)
        projectFetchRequest.predicate = projectPredicate
        projectFRC = NSFetchedResultsController(fetchRequest: projectFetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        projectFRC.delegate = self
        do {
            try projectFRC.performFetch()
            
        } catch {
            fatalError("The fetch for project could not be performed: \(error.localizedDescription)")
        }
    }
    
    //MARK: - SETUP DOCUMENT FRC
    fileprivate func setupDocumentFRC() {
        let documentFetchRequest: NSFetchRequest<SkDocument> = SkDocument.fetchRequest()
        documentFetchRequest.sortDescriptors = []
        let docPredicate = NSPredicate(format: "project == %@", selectedProject)
        documentFetchRequest.predicate = docPredicate
        documentFRC = NSFetchedResultsController(fetchRequest: documentFetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        documentFRC.delegate = self
        
        do {
            try documentFRC.performFetch()
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
        displayNotesContainer()
    }
    
}
