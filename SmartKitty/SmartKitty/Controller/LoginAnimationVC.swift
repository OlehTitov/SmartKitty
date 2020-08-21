//
//  LoginAnimationVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 21.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation

import UIKit

class LoginAnimationVC: UIViewController {
    
    
    @IBOutlet weak var catImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(
            withDuration: 2,
            delay: 1,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0,
            options: .curveEaseIn,
            animations: {
            self.catImage.transform = CGAffineTransform(scaleX: 20, y: 20)
        }, completion: { (true) in
            let tabBarVC = self.storyboard?.instantiateViewController(identifier: "TabBarVC") as! TabBarVC
            self.navigationController?.pushViewController(tabBarVC, animated: true)
        })
    }
    
    
    
    
    
}
