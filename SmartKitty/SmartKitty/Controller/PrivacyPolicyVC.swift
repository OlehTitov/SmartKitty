//
//  PrivacyPolicyVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 06.10.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

class PrivacyPolicyVC: UIViewController {
    let smartcatPrivacyURL = "https://www.smartcat.com/privacy-policy/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func privacyTapped(_ sender: Any) {
        let url = URL(string: smartcatPrivacyURL)
        UIApplication.shared.open(url!, options: [ : ], completionHandler: nil)
    }
    
}
