//
//  ProjectDetailsVC+ExtensionCollectionView.swift
//  SmartKitty
//
//  Created by Oleh Titov on 17.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

extension ProjectDetailsVC: UICollectionViewDelegate {
 
    //MARK: - SETUP ACTION BUTTONS
    func setupActionButtons() {
        actionButtonsArray = [
            ActionButton(title: "Add a note", image: UIImage(systemName: "square.and.pencil")!, link: ""),
            ActionButton(title: "Assign", image: UIImage(systemName: "person")!, link: ""),
            ActionButton(title: "Post as job", image: UIImage(systemName: "briefcase")!, link: "")
        ]
    }
    
    //MARK: - CONFIGURE BUTTON
    
    func configureButtonAppearance() {
        
    }
    
    
    //MARK: - COLLECTION VIEW DIFFABLE DATA SOURCE
    
    func configureActionButtonsDataSource() {
        buttonsDataSource = UICollectionViewDiffableDataSource<Int, ActionButton>(collectionView: actionButtonsCollection) {
            (collectionView: UICollectionView, indexPath: IndexPath, button: ActionButton) -> UICollectionViewCell? in
            // Create cell
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ActionButtonCell",
                for: indexPath) as? ActionButtonCell else { fatalError("Cannot create new cell") }
            
            cell.buttonDescription.text = button.title
            cell.buttonWithImage.setImage(button.image, for: .normal)
            return cell
        }
        setupButtonsSnapshot()
    }
    
    private func setupButtonsSnapshot() {
        buttonsSnapshot = NSDiffableDataSourceSnapshot<Int, ActionButton>()
        buttonsSnapshot.appendSections([0])
        buttonsSnapshot.appendItems(actionButtonsArray)
        buttonsDataSource?.apply(self.buttonsSnapshot, animatingDifferences: true)
    }
    
    
    //MARK: - COLLECTION VIEW LAYOUT
    func configureLayout() {
        actionButtonsCollection.collectionViewLayout = generateLayout()
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1/3),
          heightDimension: .fractionalHeight(1.0))
        let tripleItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalWidth(1/3))
        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: groupSize,
          subitem: tripleItem,
          count: 3)
       
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}
