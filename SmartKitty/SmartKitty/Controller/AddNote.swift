//
//  AddNote.swift
//  SmartKitty
//
//  Created by Oleh Titov on 25.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddNote: UIViewController {
    
    var selectedProject: SkProject!
    let dismissKeyboard = DismissKeyboardDelegate()
    
    
    
    @IBOutlet weak var saveBottomContstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: PrimaryButton!
    @IBOutlet weak var noteTextField: UITextField!
    
    //MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isTranslucent = true
         tabBarController?.tabBar.isHidden = true
        subscribeToKeyboardNotifications()
    }
    
    //MARK: - VIEW DID APPEAR
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        noteTextField.becomeFirstResponder()
    }
    
    //MARK: - VIEW WILL DISAPPEAR
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        tabBarController?.tabBar.isTranslucent = false
         tabBarController?.tabBar.isHidden = false
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextField.delegate = dismissKeyboard
        
    }
    
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        //Save note text
        selectedProject.desc = noteTextField.text
        try? DataController.shared.viewContext.save()
        
        //Dismiss the popup controller
        dismiss(animated: true, completion: nil)
        
    }
    
    
}

