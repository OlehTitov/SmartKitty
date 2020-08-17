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
    
    ///Animate transition when user lift the finger from scroll view
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
                if self.topViewHeightConstraint.constant != self.topViewMaxHeight || self.topViewHeightConstraint.constant != self.topViewMinHeight {
                    if self.topViewHeightConstraint.constant >= 300 {
                        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                            self.topViewHeightConstraint.constant = self.topViewMaxHeight
                            self.deadlineInLabel.alpha = 1
                            self.projectProgressView.alpha = 1
                            self.projectProgressLabel.alpha = 1
                            //Animations on constraints do not work without layoutIfNeeded()
                            self.view.layoutIfNeeded()
                        }, completion: nil)
                        
                    } else {
                        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                            self.topViewHeightConstraint.constant = self.topViewMinHeight
                            self.deadlineInLabel.alpha = 0
                            self.projectProgressView.alpha = 0
                            self.projectProgressLabel.alpha = 0
                            //Animations on constraints do not work without layoutIfNeeded()
                            self.view.layoutIfNeeded()
                        }, completion: nil)
                    }
                }
        }
    }
    
    ///Transition logic
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Define the number by which the scroll view did changed
        let y: CGFloat = scrollView.contentOffset.y
        
        //Setup new height for top view
        var newTopViewHeight: CGFloat = topViewHeightConstraint.constant - y
        let newProjectTitleTopConstraint = projectTitleTopConstraint.constant - y/2
        
        //Calculate the step
        let step = topViewMaxHeight - newTopViewHeight
        
        //Increase speed
        if step >= 40 {
            newTopViewHeight = topViewHeightConstraint.constant - y * 2
        }
        
        //Transition for top view
        if newTopViewHeight > topViewMaxHeight {
            topViewHeightConstraint.constant = topViewMaxHeight
        } else if newTopViewHeight < topViewMinHeight {
            topViewHeightConstraint.constant = topViewMinHeight
        } else {
            topViewHeightConstraint.constant = newTopViewHeight
            scrollView.contentOffset.y = 0
        }
 
        //Transition for title top constraint
        if newProjectTitleTopConstraint > titleMaxConstraint {
            projectTitleTopConstraint.constant = titleMaxConstraint
        } else if newProjectTitleTopConstraint < titleMinConstraint {
            projectTitleTopConstraint.constant = titleMinConstraint
        } else {
            projectTitleTopConstraint.constant = newProjectTitleTopConstraint
            scrollView.contentOffset.y = 0
        }
        
        
        //Transition for progress block which depends on the change of the top view constraint
        progressBlockTopConstraint.constant = topViewHeightConstraint.constant / 9
        
        //Change opacity of elements in top view
        var alpha: CGFloat = 1
        if step > 0 {
            alpha = 1 - step/100
        }
        
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
