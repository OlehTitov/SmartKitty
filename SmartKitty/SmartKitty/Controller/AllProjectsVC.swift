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

class AllProjectsVC: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    
    //MARK: - PROPERTIES
    var fetchedResultsController: NSFetchedResultsController<SkProject>!
    var dataSource: UITableViewDiffableDataSource<Int, SkProject>?
    var snapshot = NSDiffableDataSourceSnapshot<Int, SkProject>()
    var attributeNameForPredicate: String = ""
    var searchText: String = ""
    var projectTypesPredicate: NSPredicate!
    var searchPredicate: NSPredicate!
    var allPredicates: [NSPredicate] = []
    var includeSearchPredicate: Bool = false
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
        self.navigationController?.navigationBar.tintColor = .mediumSlateBlue
        self.navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.mediumSlateBlue]
        setupFetchedResultsController()
        setupTableView()
        setupSearchController()
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
        allPredicates = []
    }
    
    // MARK: - TABLE VIEW SETUP
    private func setupTableView() {
        dataSource = UITableViewDiffableDataSource<Int, SkProject>(tableView: allProjectsTableView) { (tableView, indexPath, project) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "projectsCell", for: indexPath)
            //Project status icon
            if let status = project.status {
                self.configureStatusIcon(status: status, cell: cell)
            }
            //Project title
            let name = String(project.name ?? "")
            cell.textLabel?.text = name
            cell.textLabel?.lineBreakMode = .byTruncatingMiddle
            //Project deadline
            let deadlineAsDate = project.deadlineAsDate
            if deadlineAsDate != nil {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .full
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "hh:mm a"
                let timeSting = timeFormatter.string(from: deadlineAsDate!)
                let dateString = dateFormatter.string(from: deadlineAsDate!)
                let imageAttachment = NSTextAttachment()
                let lightConfig = UIImage.SymbolConfiguration(weight: .thin)
                imageAttachment.image = UIImage(systemName: "calendar", withConfiguration: lightConfig)?.withTintColor(.secondaryLabel)
                let imageString = NSAttributedString(attachment: imageAttachment)
                let fullString = NSMutableAttributedString(string: "")
                fullString.append(imageString)
                fullString.append(NSAttributedString(string: " \(timeSting) on \(dateString)"))
                let range = NSMakeRange(0, fullString.length)
                fullString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: range)
                //cell.detailTextLabel?.text = "\(timeSting), \(dateString)"
                cell.detailTextLabel?.attributedText = fullString
            } else {
                cell.detailTextLabel?.text = "No deadline specified"
            }
            return cell
        }
        setupSnapshot()
    }
    
    ///Configure project status icon
    private func configureStatusIcon(status: String, cell: UITableViewCell) {
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
            projectTypesPredicate = NSPredicate(format: "\(attributeNameForPredicate) == YES")
            allPredicates.append(projectTypesPredicate)
        }
        if !searchText.isEmpty {
            searchPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
            allPredicates.append(searchPredicate)
        }
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: allPredicates)
        if searchText.isEmpty {
            fetchRequest.predicate = projectTypesPredicate
        } else {
            fetchRequest.predicate = andPredicate
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
        let projectInfoVC = self.storyboard?.instantiateViewController(identifier: "ProjectInfoVC") as! ProjectInfoVC
        projectInfoVC.selectedProject = selectedProject
        self.navigationController?.pushViewController(projectInfoVC, animated: true)
        
    }
    
    //MARK: - SEARCH
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search projects"
        searchController.searchBar.searchBarStyle = .minimal
        navigationItem.searchController = searchController
        //navigationItem.titleView = searchController.searchBar
        searchController.definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        includeSearchPredicate = true
        guard let text = searchController.searchBar.text else {
            return
        }
        searchText = text
        setupFetchedResultsController()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //resignFirstResponder()
        print("Clear the search")
        searchText = ""
        allPredicates.removeAll()
        setupFetchedResultsController()
    }
}
