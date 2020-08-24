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
            cell.progressLabel.text = String(stage.progress) + "%"
            cell.stageProgressView.progress = Float(stage.progress)
            //Setup cell appearance
            cell.layer.borderColor = UIColor.systemBlue.cgColor
            cell.layer.borderWidth = 1
            return cell
        }
        setupStagesSnapshot()
    }
    
    private func setupStagesSnapshot() {
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
                top: 1,
                leading: 14,
                bottom: 1,
                trailing: 0)
            
          let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.9),
            //heightDimension: .fractionalWidth(3/4))
            heightDimension: .estimated(120.0))
          let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: fullPhotoItem,
            count: 1
          )
          
          let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
          let layout = UICollectionViewCompositionalLayout(section: section)
          return layout
        }

    
}
