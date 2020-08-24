//
//  ProjectDetailsVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 12.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MultiProgressView

class ProjectDetailsVC: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate {
    
    //MARK: - PROPERTIES
    //Layout properties
    var topViewMinHeight: CGFloat = 200
    var topViewMaxHeight: CGFloat = 400
    let titleMinConstraint: CGFloat = 80
    let titleMaxConstraint: CGFloat = 110
    
    //Project related properties
    var selectedProject: SkProject!
    var projectDocuments: [SkDocument] = []
    var projectStages: [SkProjectWorkflowStage] = []
    var assignedExecutives: [SkAssignedExecutive] = []
    var freelancersFullNames: [String] = []
    var allStagesProgressValues: Array<Float> = []
    var deadlineTimeString: String?
    var deadlineDateString: String?
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    let timeFormatter: DateFormatter = {
        let tf = DateFormatter()
        tf.dateFormat = "hh:mm a"
        return tf
    }()
    
    //Core Data
    var fetchedResultsController: NSFetchedResultsController<SkProject>!
    
    //Table view
    //var dataSource: UITableViewDiffableDataSource<Section, ProjectDetailRow>?
    var dataSource: ProjectDetailsDataSource?
    var snapshot = NSDiffableDataSourceSnapshot<Section, ProjectDetailRow>()
    var projectDetailRows: [ProjectDetailRow]!
    var rowsForNotes: [ProjectDetailRow]!
    var rowsForDeadline: [ProjectDetailRow]!
    var rowsForLanguages: [ProjectDetailRow]!
    var rowsForDocuments: [ProjectDetailRow]!
    var rowsForTeam: [ProjectDetailRow]!
    var rowsForMisc: [ProjectDetailRow]!
    var detailsList: DetailsList!
    
    //Collection view
    var buttonsDataSource: UICollectionViewDiffableDataSource<Int, ActionButton>?
    var buttonsSnapshot = NSDiffableDataSourceSnapshot<Int, ActionButton>()
    var actionButtonsArray: [ActionButton]!
    
    //MARK: - OUTLETS
    @IBOutlet weak var projectTitle: UILabel!
    
    
    @IBOutlet weak var stagesProgressView: MultiProgressView!
    
    @IBOutlet weak var projectDetailsTableView: UITableView!
    
    @IBOutlet weak var actionButtonsCollection: UICollectionView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var projectTitleTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var progressDescription: UILabel!
    
    
    //MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    //MARK: - VIEW WILL DISAPPEAR
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
        
    }
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        getProjectStages()
        configureProgressBar()
        setupProgressBar()
        setupProgressFooter()
        
        configureTableView()
        // Make the navigation bar background clear
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //navigationController?.navigationBar.shadowImage = UIImage()
        //navigationController?.navigationBar.isTranslucent = true
        
        //Setup action buttons
        setupActionButtons()
        configureActionButtonsDataSource()
        configureLayout()
        
        obtainValuesForProjectDetails()
        
        getFreelancerId()
        getFreelancersNames()
        
        setupProjectDetails()
        setupDetailsList()
        setupTableView()
        
        projectTitle.text = selectedProject.name
        
        setupFetchedResultsController()
        
        
        
        
    }
    //MARK: - GET FREELANCERS ID TO PASS INTO 'GetTeamMemberInfo'
    func getFreelancerId() {
        //Access SkDocument entity, loop over stages and loop over all executives
        for document in projectDocuments {
            guard let stages = document.workflows else {
                return
            }
            let stagesSet = stages as? Set<SkDocumentWorkflowStage> ?? []
            for stage in stagesSet {
                let executives = stage.executives
                guard let executivesSet = executives as? Set<SkAssignedExecutive> else {
                    return
                }
                for executive in executivesSet {
                    print("Executive ID is: \(executive.id ?? "")")
                    assignedExecutives.append(executive)
                }
            }
        }
    }
    
    //MARK: - GET FREELANCERS NAMES
    func getFreelancersNames() {
        for executive in assignedExecutives {
            if let id = executive.id {
               print("trying to get from SmartCat name of freelancer")
                SCClient.getTeamMemberInfo(userId: id, completion: handleGetTeamMemberInfo(freelancerName:error:))
            }
        }
        
    }
    
    //MARK: - HANDLE GET TEAM MEMBER INFO
    func handleGetTeamMemberInfo(freelancerName: String, error: Error?) {
        print(freelancerName)
        let dataForRow = ProjectDetailRow(title: freelancerName, desc: "", link: "freelancer")
        rowsForTeam.append(dataForRow)
        //setupSnapshot(with: detailsList)
    }
    
    
    //MARK: - CONFIGURE TABLE VIEW
    func configureTableView() {
        projectDetailsTableView.delegate = self
        self.projectDetailsTableView.layer.cornerRadius = 18
        self.projectDetailsTableView.showsVerticalScrollIndicator = false
        self.projectDetailsTableView.decelerationRate = .fast
    }
    
    //MARK: - SETUP PROGRESS BAR
    func configureProgressBar() {
        self.stagesProgressView.dataSource = self
        self.stagesProgressView.lineCap = .round
        //self.stagesProgressView.borderWidth = 2
        //self.stagesProgressView.borderColor = UIColor.darkGray
    }
    
    func setupProgressBar() {
        var sectionIndex: Int = 0
        for stage in projectStages {
            let progress = Float(stage.progress/100)
            //Progress values of all stages constitute the general progress
            let progressToTotal = progress/Float(projectStages.count)
            allStagesProgressValues.insert(progressToTotal, at: sectionIndex)
            //allStagesProgressValues.append(progressToTotal)
            UIView.animate(
                withDuration: 0.4,
                delay: 0.4,
                //usingSpringWithDamping: 0.8,
                //initialSpringVelocity: 0,
                options: .curveEaseOut,
                animations: {
                    self.stagesProgressView.setProgress(section: sectionIndex, to: progressToTotal)
            },
                completion: nil)
            print("Inserted \(progressToTotal) into section \(sectionIndex) named \(stage.stageType ?? "")")
            sectionIndex += 1
        }
        print("And the sectionIndex is: \(sectionIndex)")
    }
    
    func getProjectStages() {
        let rawStages = selectedProject.projectWorkflows as? Set<SkProjectWorkflowStage> ?? []
        
        //projectStages.append(contentsOf: rawStages)
        projectStages.insert(contentsOf: rawStages, at: 0)
        for stage in projectStages {
            print("Stage: \(stage.stageType ?? "empty"), progress: \(stage.progress)")
        }
        print("Array with project stages has \(projectStages.count) item(s)")
    }
    
    func setupProgressFooter() {
        //var subviews: [UIView] = []
        let fullString = NSMutableAttributedString(string: "")
        var stageIndex = 0
        for stage in projectStages {
            guard let stageName = stage.stageType else {
                return
            }
            let progress = Int(round(stage.progress))
            guard let stageAsEnum = ProjectStage(caseName: stageName) else {
                return
            }
            let imageAttachment = NSTextAttachment()
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10)
            imageAttachment.image = UIImage(systemName: "square.fill", withConfiguration: symbolConfig)?.withTintColor(stageAsEnum.color)
            fullString.insert(NSAttributedString(attachment: imageAttachment), at: stageIndex)
            stageIndex += 1
            fullString.insert(NSAttributedString(string: " \(stageName) \(progress)% "), at: stageIndex)
            stageIndex += 1
            //fullString.append(NSAttributedString(attachment: imageAttachment))
            //fullString.append(NSAttributedString(string: " \(stageName) \(progress)% "))
            //let range = NSMakeRange(0, fullString.length)
            //fullString.addAttribute(.foregroundColor, value: UIColor.white, range: range)
        }
        let range = NSMakeRange(0, fullString.length)
        fullString.addAttribute(.foregroundColor, value: UIColor.white, range: range)
        progressDescription.attributedText = fullString
    }
    
    
    //MARK: - SETUP PROJECT DETAILS
    func setupProjectDetails() {
        rowsForNotes = [
            ProjectDetailRow(title: "This is the text of the future note. It is a long note. Really.", desc: "", link: "note")
        ]
        rowsForDeadline = [
            ProjectDetailRow(title: "\(deadlineTimeString ?? "") \(deadlineDateString ?? "Not specified")", desc: "", link: "")
        ]
        rowsForLanguages = [
            ProjectDetailRow(title: "Source", desc: selectedProject.sourceLanguage?.capitalized ?? "", link: ""),
            ProjectDetailRow(title: "Target", desc: selectedProject.targetLanguages?.joined(separator: ", ").capitalized  ?? "", link: "")
        ]
        rowsForDocuments = setupDocumentsRows()
        rowsForTeam = [
            //Create a func to fill the array of team with assigned linguists
        ]
        rowsForMisc = [
            ProjectDetailRow(title: "Client", desc: "setup later", link: ""),
            ProjectDetailRow(title: "Created", desc: selectedProject.creationDate ?? "", link: "")
        ]
    }
    func setupDocumentsRows() -> [ProjectDetailRow] {
        var arrayOfDocuments: [ProjectDetailRow] = []
        let documents = selectedProject.documents
        let docs = documents as? Set<SkDocument> ?? []
        for doc in docs {
            let dataForRow = ProjectDetailRow(title: doc.name ?? "", desc: "", link: "docs")
            arrayOfDocuments.append(dataForRow)
        }
        return arrayOfDocuments
    }
    
    
    
    func obtainValuesForProjectDetails() {
        //Get array of documents
        let documents = selectedProject.documents
        let docs = documents as? Set<SkDocument> ?? []
        projectDocuments.append(contentsOf: docs)
        //Get deadline
        guard let deadline = selectedProject.deadlineAsDate else {
            return
        }
        deadlineTimeString = timeFormatter.string(from: deadline)
        deadlineDateString = dateFormatter.string(from: deadline)
        //Get time to deadline
        
    }
    
    //MARK: - SETUP SECTIONS LIST FROM ROWS
    func setupDetailsList() {
        detailsList = DetailsList(notes: rowsForNotes, deadline: rowsForDeadline, languages: rowsForLanguages, documents: rowsForDocuments, team: rowsForTeam, misc: rowsForMisc)
    }
    
    
    // MARK: - TABLE VIEW SETUP
    func setupTableView() {
        dataSource = ProjectDetailsDataSource(tableView: projectDetailsTableView) { (tableView, indexPath, detailRow) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectDetailsCell", for: indexPath)
            //Setup text labels
            cell.textLabel?.text = detailRow.title
            cell.detailTextLabel?.text = detailRow.desc
            //Dispay cells specially for different sections
            if detailRow.link == "docs" {
                cell.textLabel?.lineBreakMode = .byTruncatingMiddle
            }
            if detailRow.link == "note" {
                cell.textLabel?.numberOfLines = 0
                cell.accessoryType = .none
            }
            
            return cell
        }
        setupSnapshot(with: detailsList)
    }
    
    
    func setupSnapshot(with list: DetailsList) {
        snapshot = NSDiffableDataSourceSnapshot<Section, ProjectDetailRow>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(list.notes, toSection: .notes)
        snapshot.appendItems(list.deadline, toSection: .deadline)
        snapshot.appendItems(list.languages, toSection: .languages)
        snapshot.appendItems(list.documents, toSection: .documents)
        snapshot.appendItems(list.team, toSection: .team)
        snapshot.appendItems(list.misc, toSection: .misc)
        //snapshot.appendItems(projectDetailRows)
        dataSource?.apply(self.snapshot, animatingDifferences: true)
    }
    
    //Configure the color of the section header title
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .lightPrimary
        }
    }
    
    
    //MARK: - SETUP FRC
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<SkProject> = SkProject.fetchRequest()
        fetchRequest.sortDescriptors = []
        guard let projectId = selectedProject.id else { return
        }
        let predicate = NSPredicate(format: "id == %@", projectId)
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            //setupSnapshot()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}
