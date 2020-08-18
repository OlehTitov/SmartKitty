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

class ProjectDetailsVC: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate {
    
    //MARK: - PROPERTIES
    //Layout properties
    var topViewMinHeight: CGFloat = 200
    var topViewMaxHeight: CGFloat = 400
    let titleMinConstraint: CGFloat = 80
    let titleMaxConstraint: CGFloat = 110
    
    //Project related properties
    var selectedProject: SkProject!
    var projectDocuments: [SkDocument] = []
    var deadlineTimeString: String?
    var deadlineDateString: String?
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
    
    //Core Data
    var fetchedResultsController: NSFetchedResultsController<SkProject>!
    
    //Table view
    //var dataSource: UITableViewDiffableDataSource<Section, ProjectDetailRow>?
    var dataSource: ProjectDetailsDataSource?
    var snapshot = NSDiffableDataSourceSnapshot<Section, ProjectDetailRow>()
    var projectDetailRows: [ProjectDetailRow]!
    var rowsForNotes: [ProjectDetailRow]!
    var rowsForDeadline: [ProjectDetailRow]!
    var rowsForLanguages: [ProjectDetailRow]!
    var rowsForDocuments: [ProjectDetailRow]!
    var rowsForTeam: [ProjectDetailRow]!
    var rowsForMisc: [ProjectDetailRow]!
    var detailsList: DetailsList!
    
    //Collection view
    var buttonsDataSource: UICollectionViewDiffableDataSource<Int, ActionButton>?
    var buttonsSnapshot = NSDiffableDataSourceSnapshot<Int, ActionButton>()
    var actionButtonsArray: [ActionButton]!
    
    //MARK: - OUTLETS
    @IBOutlet weak var projectTitle: UILabel!
    @IBOutlet weak var projectProgressView: UIProgressView!
    @IBOutlet weak var deadlineInLabel: UILabel!
    @IBOutlet weak var projectProgressLabel: UILabel!
    @IBOutlet weak var projectDetailsTableView: UITableView!
    
    @IBOutlet weak var actionButtonsCollection: UICollectionView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var projectTitleTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var buttonsBlockTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressBlockTopConstraint: NSLayoutConstraint!
    
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
        configureTableView()
        // Make the navigation bar background clear
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //navigationController?.navigationBar.shadowImage = UIImage()
        //navigationController?.navigationBar.isTranslucent = true
        
        //Setup action buttons
        setupActionButtons()
        configureActionButtonsDataSource()
        configureLayout()
        
        obtainValuesForProjectDetails()
        
        setupProjectDetails()
        setupDetailsList()
        setupTableView()
        
        projectTitle.text = selectedProject.name
        
        //Old code to get documentsCount and documents names
        /*
        let documents = selectedProject.documents
        let docs = documents as? Set<SkDocument> ?? []
        documentsCount.text = String(documents!.count)
        var docNames: [String] = []
        for doc in docs {
            if let name = doc.name {
                docNames.append(name)
            }
        }
        listOfDocuments.text = docNames.joined(separator: ", ")
 */
        
        setupFetchedResultsController()
        
    }
    
    //MARK: - CONFIGURE TABLE VIEW
    func configureTableView() {
        projectDetailsTableView.delegate = self
        self.projectDetailsTableView.layer.cornerRadius = 18
        self.projectDetailsTableView.showsVerticalScrollIndicator = false
        self.projectDetailsTableView.decelerationRate = .fast
    }
    
    //MARK: - SETUP TOP VIEW
    func setupTopView() {
        //deadlineInLabel.textColor = UIColor.black.withAlphaComponent(alpha)
    }
    
    
    //MARK: - SETUP PROJECT DETAILS
    func setupProjectDetails() {
        rowsForNotes = [
            ProjectDetailRow(title: "This is the text of the future note. It is a long note. Really.", desc: "", link: "note")
        ]
        
        rowsForDeadline = [
            ProjectDetailRow(title: "\(deadlineTimeString ?? "") \(deadlineDateString ?? "Not specified")", desc: "", link: "")
        ]
        
        rowsForLanguages = [
            ProjectDetailRow(title: "Source", desc: selectedProject.sourceLanguage?.capitalized ?? "", link: ""),
            ProjectDetailRow(title: "Target", desc: selectedProject.targetLanguages?.joined(separator: ", ").capitalized  ?? "", link: "")
        ]
        
        rowsForDocuments = setupDocumentsRows()
        
        rowsForTeam = [
            //Create a func to fill the array of team with assigned linguists
        ]
        
        rowsForMisc = [
            ProjectDetailRow(title: "Client", desc: "setup later", link: ""),
            ProjectDetailRow(title: "Created", desc: selectedProject.creationDate ?? "", link: "")
        ]
    }
    func setupDocumentsRows() -> [ProjectDetailRow] {
        var arrayOfDocuments: [ProjectDetailRow] = []
        let documents = selectedProject.documents
        let docs = documents as? Set<SkDocument> ?? []
        for doc in docs {
            let dataForRow = ProjectDetailRow(title: doc.name ?? "", desc: "", link: "docs")
            arrayOfDocuments.append(dataForRow)
        }
        return arrayOfDocuments
    }
    
    func obtainValuesForProjectDetails() {
        //Get array of documents
        let documents = selectedProject.documents
        let docs = documents as? Set<SkDocument> ?? []
        projectDocuments.append(contentsOf: docs)
        //Get deadline
        guard let deadline = selectedProject.deadlineAsDate else {
            return
        }
        deadlineTimeString = timeFormatter.string(from: deadline)
        deadlineDateString = dateFormatter.string(from: deadline)
    }
    
    //MARK: - SETUP SECTIONS LIST FROM ROWS
    func setupDetailsList() {
        detailsList = DetailsList(notes: rowsForNotes, deadline: rowsForDeadline, languages: rowsForLanguages, documents: rowsForDocuments, team: rowsForTeam, misc: rowsForMisc)
    }
    
    
    // MARK: - TABLE VIEW SETUP
    private func setupTableView() {
        dataSource = ProjectDetailsDataSource(tableView: projectDetailsTableView) { (tableView, indexPath, detailRow) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectDetailsCell", for: indexPath)
            //Setup text labels
            cell.textLabel?.text = detailRow.title
            cell.detailTextLabel?.text = detailRow.desc
            //Dispay cells specially for different sections
            if detailRow.link == "docs" {
                cell.textLabel?.lineBreakMode = .byTruncatingMiddle
            }
            if detailRow.link == "note" {
                cell.textLabel?.numberOfLines = 0
                cell.accessoryType = .none
            }
            
            return cell
        }
        setupSnapshot(with: detailsList)
    }
    
    
    private func setupSnapshot(with list: DetailsList) {
        snapshot = NSDiffableDataSourceSnapshot<Section, ProjectDetailRow>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(list.notes, toSection: .notes)
        snapshot.appendItems(list.deadline, toSection: .deadline)
        snapshot.appendItems(list.languages, toSection: .languages)
        snapshot.appendItems(list.documents, toSection: .documents)
        snapshot.appendItems(list.team, toSection: .team)
        snapshot.appendItems(list.misc, toSection: .misc)
        //snapshot.appendItems(projectDetailRows)
        dataSource?.apply(self.snapshot, animatingDifferences: true)
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
