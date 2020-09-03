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
    
    //MARK: - PROPERTIES
    let signupURL = "https://smartcat.ai"
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()
    }
    
    //MARK: - SETUP VIEW
    func setGradientBackground() {
        let colorTop =  UIColor.antiqueFuchsia.cgColor
        let colorBottom = UIColor.cloudBurst.cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    //MARK: - SIGN IN TAPPED
    @IBAction func signInTapped(_ sender: Any) {
        goToNextVC()
    }
    
    func goToNextVC() {
        let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginVC") as! LoginVC
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.modalTransitionStyle = .crossDissolve
        present(loginVC, animated: true, completion: nil)
    }
    
    //MARK: - CREATE ACCOUNT TAPPED
    @IBAction func createAccountTapped(_ sender: Any) {
        let url = URL(string: signupURL)
        UIApplication.shared.open(url!, options: [ : ], completionHandler: nil)
    }
    
}
