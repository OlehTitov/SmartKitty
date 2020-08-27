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
    
    
    
    @IBOutlet weak var saveButton: PrimaryButton!
    @IBOutlet weak var noteTextField: UITextField!
    
    @IBOutlet weak var textfieldHeight: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isTranslucent = true
         tabBarController?.tabBar.isHidden = true
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        noteTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        tabBarController?.tabBar.isTranslucent = false
         tabBarController?.tabBar.isHidden = false
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextField.delegate = dismissKeyboard
        
    }
    
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let textForNote = noteTextField.text else {
            // TO DO - Display alert
            return
        }
        print(textForNote)
        guard let projectId = selectedProject.id else {
            return
        }
        print(projectId)
        let note = ProjectNote(name: "", description: textForNote, deadline: "", clientId: "", domainId: 0, vendorAccountIds: [""], externalTag: "", specializations: [""], workflowStages: [""])
        
        //Check json
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(note)
        let jsonString = String(data: jsonData, encoding: .utf8)
        print("JSON String : " + jsonString!)
        
        
        SCClient.addProjectNote(projectId: projectId, method: "PUT", note: note, completion: handleAddNoteRequest(success:error:))
        
        
    }
    
    func handleAddNoteRequest(success: Bool, error: Error?) {
        //Check if successfull request
        if success {
            print("Yay, you've added a note")
            //Save note to Core Data
            selectedProject.desc = noteTextField.text
            try? DataController.shared.viewContext.save()
        } else {
            print(error as Any)
            //Display alert
        }
    
        //Dismiss the popup controller
        dismiss(animated: true, completion: nil)
    }
    
    
}

