//
//  InstructionsVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 02.09.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

class InstructionVC: UIViewController {
    
    let signupURL = "https://smartcat.ai"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()
    }
    
    func setGradientBackground() {
        let colorTop =  UIColor.antiqueFuchsia.cgColor
        let colorBottom = UIColor.cloudBurst.cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        goToNextVC()
    }
    
    
    @IBAction func createAccountTapped(_ sender: Any) {
        let url = URL(string: signupURL)
        UIApplication.shared.open(url!, options: [ : ], completionHandler: nil)
    }
    
    func goToNextVC() {
        let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginVC") as! LoginVC
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.modalTransitionStyle = .crossDissolve
        present(loginVC, animated: true, completion: nil)
    }
    
}
