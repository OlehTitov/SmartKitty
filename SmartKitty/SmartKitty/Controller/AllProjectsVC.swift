//
//  AllProjectsVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 05.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AllProjectsVC: UITableViewController, NSFetchedResultsControllerDelegate {
    
    //MARK: - PROPERTIES
    var fetchedResultsController: NSFetchedResultsController<SkProject>!
    var dataSource: UITableViewDiffableDataSource<Int, SkProject>?
    var snapshot = NSDiffableDataSourceSnapshot<Int, SkProject>()
    var attributeNameForPredicate: String = ""
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
     //MARK: - OUTLETS
    @IBOutlet var allProjectsTableView: UITableView!
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        setupFetchedResultsController()
        setupTableView()
    }
    
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
    
    // MARK: - TABLE VIEW SETUP
    private func setupTableView() {
        dataSource = UITableViewDiffableDataSource<Int, SkProject>(tableView: allProjectsTableView) { (tableView, indexPath, project) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "projectsCell", for: indexPath)
            //Project status icon
            if let status = project.status {
                let projectStatus = ProjectStatuses(rawValue: status)
                switch projectStatus {
                case .created:
                    cell.imageView?.image = UIImage(systemName: "circle")
                case .inProgress:
                    cell.imageView?.image = UIImage(systemName: "ellipsis.circle")
                case .completed:
                    cell.imageView?.image = UIImage(systemName: "checkmark.circle")
                case .cancelled:
                    cell.imageView?.image = UIImage(systemName: "xmark.circle")
                case .none:
                    cell.imageView?.image = UIImage(systemName: "circle")
                }
            }
            //Project title
            let name = String(project.name ?? "")
            cell.textLabel?.text = name
            cell.textLabel?.lineBreakMode = .byTruncatingMiddle
            //Project deadline
            let deadlineAsDate = project.deadlineAsDate
            let RFC3339DateFormatter = DateFormatter()
            RFC3339DateFormatter.dateStyle = .full
            if deadlineAsDate != nil {
                cell.detailTextLabel?.text = RFC3339DateFormatter.string(from: deadlineAsDate!)
            }
            return cell
        }
        setupSnapshot()
    }
    
    private func setupSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot<Int, SkProject>()
        snapshot.appendSections([0])
        snapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        dataSource?.apply(self.snapshot, animatingDifferences: false)
    }
    
    //MARK: - SETUP FRC
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<SkProject> = SkProject.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if attributeNameForPredicate != "ShowAllProjects" {
            let predicate = NSPredicate(format: "\(attributeNameForPredicate) == YES")
            fetchRequest.predicate = predicate
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            setupSnapshot()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    //MARK: - FRC DELEGATE
    // Whenever the content changes it updates the snapshot
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        setupSnapshot()
    }
    
    //MARK: - DID SELECT PROJECT
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProject = fetchedResultsController.fetchedObjects![(indexPath as NSIndexPath).row]
        let projectDetailsVC = self.storyboard?.instantiateViewController(identifier: "ProjectDetailsVC") as! ProjectDetailsVC
        projectDetailsVC.selectedProject = selectedProject
        self.navigationController?.pushViewController(projectDetailsVC, animated: true)
    }
}
