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
    var topViewMinHeight: CGFloat = 220
    var topViewMaxHeight: CGFloat = 400
    //var alpha: CGFloat = 1
    var selectedProject: SkProject!
    var fetchedResultsController: NSFetchedResultsController<SkProject>!
    var dataSource: UITableViewDiffableDataSource<Int, ProjectDetailRow>?
    var snapshot = NSDiffableDataSourceSnapshot<Int, ProjectDetailRow>()
    var projectDetailRows: [ProjectDetailRow]!
    
    //MARK: - OUTLETS
    @IBOutlet weak var projectTitle: UILabel!
    @IBOutlet weak var projectProgressView: UIProgressView!
    @IBOutlet weak var deadlineInLabel: UILabel!
    
    @IBOutlet weak var projectProgressLabel: UILabel!
    
    @IBOutlet weak var projectDetailsTableView: UITableView!
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
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
        deadlineInLabel.alpha = 1
        self.projectDetailsTableView.delegate = self
        setupProjectDetails()
        setupTableView()
        projectTitle.text = selectedProject.name
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
        
        setupFetchedResultsController()
        
    }
    
    //MARK: - SETUP TOP VIEW
    func setupTopView() {
        //deadlineInLabel.textColor = UIColor.black.withAlphaComponent(alpha)
    }
    
    
    //MARK: - SETUP PROJECT DETAILS
    func setupProjectDetails() {
        projectDetailRows = [
            ProjectDetailRow(title: "Source", desc: selectedProject.sourceLanguage ?? ""),
            ProjectDetailRow(title: "Target", desc: "setup later"),
            ProjectDetailRow(title: "Created", desc: selectedProject.creationDate ?? ""),
            ProjectDetailRow(title: "Deadline", desc: selectedProject.deadline ?? ""),
            ProjectDetailRow(title: "Documents", desc: "setup later")
        ]
    }
    
    
    // MARK: - TABLE VIEW SETUP
    private func setupTableView() {
        dataSource = UITableViewDiffableDataSource<Int, ProjectDetailRow>(tableView: projectDetailsTableView) { (tableView, indexPath, detailRow) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectDetailsCell", for: indexPath)
            cell.textLabel?.text = detailRow.title
            cell.detailTextLabel?.text = detailRow.desc
            //cell.textLabel?.text = street
            //cell.detailTextLabel?.text = "\(city), \(country)"
            return cell
        }
        setupSnapshot()
    }
    
    private func setupSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot<Int, ProjectDetailRow>()
        snapshot.appendSections([0])
        snapshot.appendItems(projectDetailRows)
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
