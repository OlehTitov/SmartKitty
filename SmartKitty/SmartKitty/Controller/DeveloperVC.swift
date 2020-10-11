//
//  DeveloperVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 07.10.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

class DeveloperVC: UIViewController {
    
    let linkedinURL = "https://www.linkedin.com/in/oleg-titov/"
    let githubURL = "https://github.com/OlehTitov"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func linkedinTapped(_ sender: Any) {
        let url = URL(string: linkedinURL)
        UIApplication.shared.open(url!, options: [ : ], completionHandler: nil)
    }
    
    @IBAction func githubTapped(_ sender: Any) {
        let url = URL(string: githubURL)
        UIApplication.shared.open(url!, options: [ : ], completionHandler: nil)
    }
}
