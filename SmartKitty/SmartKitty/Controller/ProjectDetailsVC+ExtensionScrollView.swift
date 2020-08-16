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
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            
                if self.topViewHeightConstraint.constant != self.topViewMaxHeight || self.topViewHeightConstraint.constant != self.topViewMinHeight {
                    if self.topViewHeightConstraint.constant >= 300 {
                        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveLinear, animations: {
                            self.topViewHeightConstraint.constant = self.topViewMaxHeight
                            self.deadlineInLabel.alpha = 1
                            self.projectProgressView.alpha = 1
                            self.projectProgressLabel.alpha = 1
                        }, completion: nil)
                        
                    } else {
                        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveLinear, animations: {
                            self.topViewHeightConstraint.constant = self.topViewMinHeight
                            self.deadlineInLabel.alpha = 0
                            self.projectProgressView.alpha = 0
                            self.projectProgressLabel.alpha = 0
                        }, completion: nil)
                    }
                }
            
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Define the number by which the scroll view did changed
        let y: CGFloat = scrollView.contentOffset.y
        
        //Setup new height for top view
        var newTopViewHeight: CGFloat = topViewHeightConstraint.constant - y
        let newProjectTitleTopConstraint = projectTitleTopConstraint.constant - y/2
        //Calculate the step
        let step = topViewMaxHeight - newTopViewHeight
        print("This is step: \(step)")
        print("Height constraint is \(topViewHeightConstraint.constant)")
        
        
        //Increase speed
        if step >= 40 {
            newTopViewHeight = topViewHeightConstraint.constant - y * 2
        }
        
        //Old simple working transition for top view
        if newTopViewHeight > topViewMaxHeight {
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                self.topViewHeightConstraint.constant = self.topViewMaxHeight
            }, completion: nil)
            
        } else if newTopViewHeight < topViewMinHeight {
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                self.topViewHeightConstraint.constant = self.topViewMinHeight
            }, completion: nil)
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
        
        
        //Transition for progress block
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
