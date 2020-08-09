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
            let name = String(project.name ?? "")
            cell.textLabel?.text = name
            let deadlineAsDate = project.deadlineAsDate
            //let dateString = project.deadline!
            let RFC3339DateFormatter = DateFormatter()
            //RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
            //RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            //RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            //let date = RFC3339DateFormatter.date(from: dateString)!
            RFC3339DateFormatter.dateStyle = .full
            
            //let df = DateFormatter()
            //df.dateStyle = .long
            //let date = df.date(from: dateString)
            if deadlineAsDate != nil {
                cell.detailTextLabel?.text = RFC3339DateFormatter.string(from: deadlineAsDate!)
            }
            print(project.isToday)
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
}
