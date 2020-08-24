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

class HomeVC: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate {
    
    //MARK: - PROPERTIES
    var tilesDataSource: UICollectionViewDiffableDataSource<Int, HomeHeaderTile>! = nil
    var tilesSnapshot = NSDiffableDataSourceSnapshot<Int, HomeHeaderTile>()
    var fetchedResultsController: NSFetchedResultsController<SkProject>!
    var numberOfProjectsForToday = 0
    var numberOfProjectsForTomorrow = 0
    var numberOfAllProjects = 0
    var numberOfStarredProjects = 0
    var headerTiles: [HomeHeaderTile]!
    
    //MARK: - OUTLETS
    @IBOutlet weak var companyName: UILabel!
    
    @IBOutlet weak var tilesCollectionView: UICollectionView!
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        tilesCollectionView.delegate = self
        companyName.text = SCClient.companyName
        setupFetchedResultsController()
        calculateNumberOfProjects()
        setupHeaderTiles()
        configureTilesDataSource()
        configureTilesLayout()
    }
    
    //MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBars()
        setupFetchedResultsController()
    }
    
    //MARK: - VIEW DID DISAPPEAR
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    //MARK: - SETUP NAVIGATION BARS
    func setupNavBars() {
        self.tabBarController?.tabBar.tintColor = .primary
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.backgroundColor = .white
        self.navigationController?.isNavigationBarHidden = true
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
            title: "Deadline Today",
            image: UIImage(systemName: "timer")!,
            color: .secondary,
            projectsCount: numberOfProjectsForToday,
            link: "isToday"
        ),
        HomeHeaderTile(
            title: "Deadline Tomorrow",
            image: UIImage(systemName: "calendar")!,
            color: .primary,
            projectsCount: numberOfProjectsForTomorrow,
            link: "isTomorrow"
        ),
        HomeHeaderTile(
            title: "Starred",
            image: UIImage(systemName: "star.fill")!,
            color: .darkPrimary,
            projectsCount: numberOfStarredProjects,
            link: "isStarred"
        ),
        HomeHeaderTile(
            title: "All",
            image: UIImage(systemName: "archivebox.fill")!,
            color: .gray,
            projectsCount: numberOfAllProjects,
            link: "ShowAllProjects"
        )
        ]
    }
    
    //MARK: - COLLECTION VIEW DIFFABLE DATA SOURCE
    
    private func configureTilesDataSource() {
        tilesDataSource = UICollectionViewDiffableDataSource<Int, HomeHeaderTile>(collectionView: tilesCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, tile: HomeHeaderTile) -> UICollectionViewCell? in
            // Create cell
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TilesCellIdentifier",
                for: indexPath) as? TilesCell else { fatalError("Cannot create new cell") }
            cell.layer.cornerRadius = 15
            cell.layer.shadowRadius = 7
            cell.layer.shadowColor = tile.color.cgColor
            cell.layer.shadowOpacity = 0.5
            cell.layer.shadowOffset = CGSize(width: 0, height: 8)
            cell.layer.masksToBounds = false
            cell.backgroundColor = tile.color
            cell.tileTitle.text = tile.title
            cell.iconContainer.backgroundColor = tile.color
            cell.iconContainer.layer.cornerRadius = 17.5
            cell.tileImageView.image = tile.image
            cell.tileImageView.tintColor = UIColor.white
            cell.projectsCount.text = String(tile.projectsCount)
            return cell
        }
        setupTilesSnapshot()
    }
    
    private func setupTilesSnapshot() {
        tilesSnapshot = NSDiffableDataSourceSnapshot<Int, HomeHeaderTile>()
        tilesSnapshot.appendSections([0])
        tilesSnapshot.appendItems(headerTiles)
        tilesDataSource.apply(self.tilesSnapshot, animatingDifferences: true)
    }
    
    //MARK: - COLLECTION VIEW DELEGATE
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTile = headerTiles[(indexPath as NSIndexPath).row]
        let allProjectsVC = self.storyboard?.instantiateViewController(identifier: "AllProjectsVC") as! AllProjectsVC
        allProjectsVC.attributeNameForPredicate = selectedTile.link
        self.navigationController?.pushViewController(allProjectsVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let selectedTile = headerTiles[(indexPath as NSIndexPath).row]
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = selectedTile.color
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = nil
        }
    }
    
    //MARK: - CONFIGURE COLLECTION VIEW LAYOUT
    func configureTilesLayout() {
        tilesCollectionView.collectionViewLayout = generateTilesLayout()
        //photoCollection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func generateTilesLayout() -> UICollectionViewLayout {
      
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(7/8))
      let fullPhotoItem = NSCollectionLayoutItem(layoutSize: itemSize)
      
        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(
            top: 6,
            leading: 14,
            bottom: 6,
            trailing: 0)
        
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(0.9),
        heightDimension: .fractionalWidth(2/3))
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: groupSize,
        subitem: fullPhotoItem,
        count: 2
      )
      
      let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
      let layout = UICollectionViewCompositionalLayout(section: section)
      return layout
    }
}
