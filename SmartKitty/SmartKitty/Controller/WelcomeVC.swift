//
//  WelcomeVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 31.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

class WelcomeVC: UIViewController {
    
    let signupURL = "https://smartcat.ai"
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var signInButton: PrimaryButton!
    
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImageHeight()
        
        setGradientBackground()
    }
   
    func setImageHeight() {
        let viewHeigh = view.frame.size.height
        imageHeight.constant = viewHeigh * 0.3
    }
    
    func setGradientBackground() {
        let colorTop =  UIColor.coldPurple.cgColor
        let colorBottom = UIColor.cloudBurst.cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        //gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        //gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
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
