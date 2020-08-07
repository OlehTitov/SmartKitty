//
//  HomeVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 06.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class HomeVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    //MARK: - PROPERTIES
    var fetchedResultsController: NSFetchedResultsController<SkProject>!
    var numberOfProjectsForToday = 0
    var numberOfProjectsForTomorrow = 0
    var numberOfAllProjects = 0
    var numberOfStarredProjects = 0
    var headerTiles: [HomeHeaderTile]!
    
    
    @IBOutlet weak var companyName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        companyName.text = SCClient.companyName
        setupFetchedResultsController()
        calculateNumberOfProjects()
        setupHeaderTiles()
    }
    
    
    //MARK: - SETUP FRC
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<SkProject> = SkProject.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            //setupSnapshot()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    //MARK: - CALCULATE PROJECTS COUNT
    func calculateNumberOfProjects() {
        let projects = fetchedResultsController.fetchedObjects
        if let projects = projects {
            for project in projects {
                if project.isToday {
                    numberOfProjectsForToday += 1
                }
                if project.isTomorrow {
                    numberOfProjectsForTomorrow += 1
                }
                if project.isStarred {
                    numberOfStarredProjects += 1
                }
            }
            numberOfAllProjects = projects.count
        }
    }
    
    //MARK: - SETUP HEADER TILES
    func setupHeaderTiles() {
        headerTiles = [
        HomeHeaderTile(
            title: "Today",
            image: UIImage(systemName: "timer")!,
            color: .red,
            projectsCount: numberOfProjectsForToday,
            link: "TodayVC"
        ),
        HomeHeaderTile(
            title: "Tomorrow",
            image: UIImage(systemName: "calendar")!,
            color: .systemBlue,
            projectsCount: numberOfProjectsForTomorrow, link: "TomorrowVC"
        ),
        HomeHeaderTile(
            title: "Starred",
            image: UIImage(systemName: "star.fill")!,
            color: .yellow,
            projectsCount: numberOfStarredProjects,
            link: "StarredVC"
        ),
        HomeHeaderTile(
            title: "All",
            image: UIImage(systemName: "archivebox.fill")!,
            color: .gray, projectsCount: numberOfAllProjects,
            link: "AllProjectsVC"
        )
        ]
    }
    
}