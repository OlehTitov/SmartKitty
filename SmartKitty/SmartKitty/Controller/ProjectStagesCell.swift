//
//  ProjectStagesCell.swift
//  SmartKitty
//
//  Created by Oleh Titov on 24.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import UIKit

class ProjectStagesCell: UICollectionViewCell {
   
    @IBOutlet weak var stageTitle: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var stageProgressView: UIProgressView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //configure outlets
        progressLabel.textAlignment = .right
        //Rounded corners for ProgressView
        stageProgressView.layer.cornerRadius = 4
        stageProgressView.clipsToBounds = true
        stageProgressView.layer.sublayers![1].cornerRadius = 4
        stageProgressView.subviews[1].clipsToBounds = true
        
    }
    
}
