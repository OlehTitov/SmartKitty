//
//  ProjectInfoVC+ExtensionCollectionView.swift
//  SmartKitty
//
//  Created by Oleh Titov on 24.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension ProjectInfoVC: UICollectionViewDelegate {
    
    //MARK: - PROJECT STAGES DIFFABLE DATA SOURCE
    
    func configureStagesDataSource() {
        stageDataSource = UICollectionViewDiffableDataSource<Int, SkProjectWorkflowStage>(collectionView: projectStagesCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, stage: SkProjectWorkflowStage) -> UICollectionViewCell? in
            // Create cell
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ProjectStagesCell",
                for: indexPath) as? ProjectStagesCell else { fatalError("Cannot create new cell") }
            
            //Setup cell data
            cell.stageTitle.text = stage.stageType
            let roundedProgress = Int(floor(stage.progress))
            cell.progressLabel.text = String(roundedProgress) + "%"
            cell.stageProgressView.progress = Float(stage.progress)/100
            //Setup cell appearance
            //cell.layer.borderColor = UIColor.systemBlue.cgColor
            //cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 10
            //cell.layer.backgroundColor = UIColor.systemFill.cgColor
            return cell
        }
        setupStagesSnapshot()
    }
    
    func setupStagesSnapshot() {
        stagesSnapshot = NSDiffableDataSourceSnapshot<Int, SkProjectWorkflowStage>()
        stagesSnapshot.appendSections([0])
        stagesSnapshot.appendItems(stageFRC.fetchedObjects ?? [])
        stageDataSource?.apply(self.stagesSnapshot, animatingDifferences: true)
    }
    
    
    //MARK: - CONFIGURE STAGES LAYOUT
        func configureStagesLayout() {
            projectStagesCollectionView.collectionViewLayout = generateStagesLayout()
        }
        
        func generateStagesLayout() -> UICollectionViewLayout {
          
          let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            //heightDimension: .fractionalHeight(1/2))
            heightDimension: .estimated(120.0))
          let fullPhotoItem = NSCollectionLayoutItem(layoutSize: itemSize)
          
            fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 5,
                bottom: 0,
                trailing: 1)
            
          let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.93),
            //heightDimension: .fractionalWidth(3/4))
            heightDimension: .estimated(120.0))
          let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: fullPhotoItem,
            count: 1
          )
            group.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 5,
            bottom: 0,
            trailing: 0)
          
          let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
          let layout = UICollectionViewCompositionalLayout(section: section)
          return layout
        }

    
    //MARK: - PROJECT DOCUMENTS DIFFABLE DATA SOURCE
    
    func configureDocumentsDataSource() {
        documentsDataSource = UICollectionViewDiffableDataSource<Int, SkDocument>(collectionView: projectDocumentsCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, document: SkDocument) -> UICollectionViewCell? in
            // Create cell
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ProjectDocumentsCell",
                for: indexPath) as? ProjectDocumentsCell else { fatalError("Cannot create new cell") }
            
            //Setup cell data
            cell.documentTitle.text = document.name
            cell.documentWordCount.text = document.wordsCount
            cell.docStatus.text = document.status
            
            //Setup cell appearance
            cell.layer.cornerRadius = 10
            //cell.layer.borderColor = UIColor.systemBlue.cgColor
            //cell.layer.borderWidth = 1
            return cell
        }
        setupDocumentsSnapshot()
    }
    
    func setupDocumentsSnapshot() {
        documentsSnapshot = NSDiffableDataSourceSnapshot<Int, SkDocument>()
        documentsSnapshot.appendSections([0])
        documentsSnapshot.appendItems(documentFRC.fetchedObjects ?? [])
        documentsDataSource?.apply(self.documentsSnapshot, animatingDifferences: true)
    }
    
    
    //MARK: - CONFIGURE DOCUMENTS LAYOUT
    func configureDocumentsLayout() {
        projectDocumentsCollectionView.collectionViewLayout = generateDocumentsLayout()
    }
    
    func generateDocumentsLayout() -> UICollectionViewLayout {
      
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        //heightDimension: .fractionalHeight(1.0))
        heightDimension: .estimated(200.0))
      let fullPhotoItem = NSCollectionLayoutItem(layoutSize: itemSize)
      
        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 14,
            bottom: 0,
            trailing: 0)
        
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(0.93),
        //heightDimension: .fractionalWidth(3/4))
        heightDimension: .estimated(200.0))
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
