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
        
        if newTopViewHeight > topViewMaxHeight {
            topViewHeightConstraint.constant = topViewMaxHeight
        } else if newTopViewHeight < topViewMinHeight {
            topViewHeightConstraint.constant = topViewMinHeight
        } else {
            topViewHeightConstraint.constant = newTopViewHeight
            scrollView.contentOffset.y = 0
        }
        
        //Change opacity of elements in top view
        let step = topViewMaxHeight - newTopViewHeight
        print("This is step: \(step)")
        var alpha: CGFloat = 1
        if step > 0 {
            alpha = 1 - step/100
        }
        print("This is alpha: \(alpha)")
        
        if alpha > 0 {
            deadlineInLabel.layer.opacity = Float(alpha)
            projectProgressView.alpha = alpha
            projectProgressLabel.alpha = alpha
        } else if alpha < 0 {
            deadlineInLabel.layer.opacity = 0
            projectProgressView.alpha = 0
            projectProgressLabel.alpha = 0
        }
       
        
    }
}
