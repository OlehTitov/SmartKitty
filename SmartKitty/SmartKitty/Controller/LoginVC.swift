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
    
    @IBOutlet weak var rememberMe: ToggleButton!
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegates()
        setupFetchedResultsController()
        autofillCredentials()
    }
    
    //MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
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

    //MARK: - REMEMBER ME
    @IBAction func rememberMeTapped(_ sender: UIButton) {
        if sender.isSelected {
            print("Saving credentials is disabled")
            UserDefaults.standard.set(false, forKey: "CredentialsAvailable")
        } else {
            print("Setting true for CredentialsAvailable")
            UserDefaults.standard.set(true, forKey: "CredentialsAvailable")
        }
    }
    
    func saveCredentials() {
        guard let accountId = accountIDTextfield.text, let apiKey = apiKeyTextfield.text else {
            return
        }
        if rememberMe.isSelected {
            print("Saving credentials")
            UserDefaults.standard.set(accountId, forKey: "AccountId")
            UserDefaults.standard.set(apiKey, forKey: "ApiKey")
        }
    }
    
    func autofillCredentials() {
        if UserDefaults.standard.bool(forKey: "CredentialsAvailable") {
            print("Trying to autofill the fields")
            accountIDTextfield.text = (UserDefaults.standard.value(forKey: "AccountId") as! String)
            apiKeyTextfield.text = (UserDefaults.standard.value(forKey: "ApiKey") as! String)
            rememberMe.isSelected = true
        }
    }
    
    //MARK: - LOGIN
    @IBAction func loginTapped(_ sender: Any) {
        SCClient.Auth.accountId = accountIDTextfield.text!
        SCClient.Auth.apiKey = apiKeyTextfield.text!
        SCClient.getAccountInfo(completion: handleGetAccountInfo(companyName:statusCode:error:))
    }
    
    func handleGetAccountInfo(companyName: String, statusCode: Int, error: Error?) {
        print(statusCode)
        let httpStatusCode = HTTPStatusCodes(rawValue: statusCode)!
        switch httpStatusCode {
        case .OK:
            print(companyName)
            saveCredentials()
            SCClient.companyName = companyName
            SCClient.getProjectsList(completion: handleGetProjectsList(projects:error:))
        case .Unauthorized:
            showAlert(title: .authorizationFailed, message: .authorizationFailed)
        case .InternalServerError, .BadGateway, .ServiceUnavailable:
            showAlert(title: .serverError, message: .serverError)
        default:
            showAlert(title: .undefinedError, message: .undefinedError)
        }
        
    }
    
    func showAlert(title: AlertTitles, message: AlertMessages) {
        let alert = Alerts.errorAlert(title: title.rawValue, message: message.rawValue)
        present(alert, animated: true)
    }
    
    //MARK: - GET PROJECTS FROM SMARTCAT SERVER
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
        newProject.clientId = prj.clientId
        
        newProject.sourceLanguage = prj.sourceLanguage
        newProject.targetLanguages = prj.targetLanguages
        newProject.deadline = prj.deadline
        newProject.creationDate = prj.creationDate
        newProject.status = prj.status
        newProject.createdByUserEmail = prj.createdByUserEmail
        //Computed property for deadlineAsDate
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let deadline = prj.deadline {
            let date = RFC3339DateFormatter.date(from: deadline)!
            newProject.deadlineAsDate = date
            //Computed property for isToday
            let calendar = NSCalendar.current
            let isToday = calendar.isDateInToday(date)
            newProject.isToday = isToday
            //Computed property for isTomorrow
            let isTomorrow = calendar.isDateInTomorrow(date)
            newProject.isTomorrow = isTomorrow
        }
        //Create documents
        guard let SCdocuments = prj.documents else {
            return
        }
        for document in SCdocuments {
            let doc = SkDocument(context: DataController.shared.viewContext)
            doc.project = newProject
            doc.id = document.id
            doc.name = document.name
            doc.creationDate = document.creationDate
            doc.sourceLanguage = document.sourceLanguage
            doc.documentDisassemblingStatus = document.documentDisassemblingStatus
            doc.targetLanguage = document.targetLanguage
            doc.status = document.status
            if let count = document.wordsCount {
                doc.wordsCount = String(count)
            }
            doc.statusModificationDate = document.statusModificationDate
            if let pretranslateCompleted = document.pretranslateCompleted {
                doc.pretranslateCompleted = pretranslateCompleted
            }
            doc.externalId = document.externalId
            doc.metaInfo = document.metaInfo
            if let placeholdersAreEnabled = document.placeholdersAreEnabled {
                doc.placeholdersAreEnabled = placeholdersAreEnabled
            }
            
        }
        
        
        
        
        
        
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

