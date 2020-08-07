//
//  LoginVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 03.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//
import Foundation
import UIKit
import CoreData

class LoginVC: UIViewController, NSFetchedResultsControllerDelegate {

    //MARK: - PROPERTIES
    var fetchedResultsController: NSFetchedResultsController<SkProject>!
    let dismissKeyboard = DismissKeyboardDelegate()
    let pickerArray = [SCClient.Servers.europe.rawValue, SCClient.Servers.america.rawValue, SCClient.Servers.asia.rawValue]
    
    //MARK: - OUTLETS
    
    @IBOutlet weak var accountIDTextfield: UITextField!
    @IBOutlet weak var apiKeyTextfield: UITextField!
    @IBOutlet weak var serverPickerView: UIPickerView!
    
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        setupDelegates()
        setupFetchedResultsController()
    
    }
    
    //MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    //MARK: - VIEW DID DISAPPEAR
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    //MARK: - SETUP DELEGATES
    func setupDelegates() {
        serverPickerView.delegate = self
        apiKeyTextfield.delegate = dismissKeyboard
        accountIDTextfield.delegate = dismissKeyboard
    }

    //MARK: - LOGIN
    @IBAction func loginTapped(_ sender: Any) {
        SCClient.Auth.accountId = accountIDTextfield.text!
        SCClient.Auth.apiKey = apiKeyTextfield.text!
        SCClient.getAccountInfo(completion: handleGetAccountInfo(companyName:error:))
    }
    
    func handleGetAccountInfo(companyName: String, error: Error?) {
        //TO-DO: add error handling for wrong credentials, no internet connection etc.
        SCClient.companyName = companyName
        print(companyName)
        SCClient.getProjectsList(completion: handleGetProjectsList(projects:error:))
    }
    
    func handleGetProjectsList(projects: [Project], error: Error?) {
        print(projects.count)
        for project in projects {
            if isExisting(project: project) {
                updateSkProject(prj: project)
                print("Updating project")
            } else {
                createSkProject(prj: project)
                UserDefaults.standard.set(true, forKey: "SomeProjectsExist")
                print("Creating project")
            }
        }
        goToNextVC()
    }
    
    func isExisting(project: Project) -> Bool {
        var result = false
        if UserDefaults.standard.bool(forKey: "SomeProjectsExist") {
            if let existingProjects = fetchedResultsController.fetchedObjects {
               for existingProject in existingProjects where project.id == existingProject.id {
                    result = true
                }
            }
        } else {
            result = false
        }
        
        return result
    }
    
    func updateSkProject(prj: Project) {
        //First, find appropriate project to update
        var projectToUpdate: SkProject!
        guard let existingProjects = fetchedResultsController.fetchedObjects else { return }
        for existingProject in existingProjects where prj.id == existingProject.id {
            projectToUpdate = existingProject
        }
        //Set new values that were obtained from server
        if projectToUpdate.name != prj.name {
            for key in projectToUpdate.entity.attributesByName.keys {
                let value: Any? = projectToUpdate.value(forKey: key)
                print("\(key) = \(String(describing: value))")
            }
        }
    }
    
    func createSkProject(prj: Project) {
        let newProject = SkProject(context: DataController.shared.viewContext)
        newProject.id = prj.id
        newProject.name = prj.name
        newProject.deadline = prj.deadline
        newProject.creationDate = prj.creationDate
        try? DataController.shared.viewContext.save()
        setupFetchedResultsController()
    }
    
    func goToNextVC() {
        
        //let allProjectsVC = self.storyboard?.instantiateViewController(identifier: "AllProjectsVC") as! AllProjectsVC
        //self.navigationController?.pushViewController(allProjectsVC, animated: true)
        let homeVC = self.storyboard?.instantiateViewController(identifier: "HomeVC") as! HomeVC
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    //MARK: - SETUP FRC
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<SkProject> = SkProject.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
 
    
}

//MARK: - EXTENSION: PICKER VIEW DELEGATE
extension LoginVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        SCClient.selectedServer = pickerArray[row]
    }
}

