//
//  ProjectDetailsVC+ExtensionScrollView.swift
//  SmartKitty
//
//  Created by Oleh Titov on 15.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

extension ProjectDetailsVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Define the number by which the scroll view did changed
        let y: CGFloat = scrollView.contentOffset.y
        //Setup new height for top view
        let newTopViewHeight: CGFloat = topViewHeightConstraint.constant - y
        
        //Hide objects in top view
        deadlineInLabel.layer.opacity = Float(1 - y/10)
        
        if newTopViewHeight > topViewMaxHeight {
            topViewHeightConstraint.constant = topViewMaxHeight
        } else if newTopViewHeight < topViewMinHeight {
            topViewHeightConstraint.constant = topViewMinHeight
        } else {
            topViewHeightConstraint.constant = newTopViewHeight
            scrollView.contentOffset.y = 0
        }
    }
}
