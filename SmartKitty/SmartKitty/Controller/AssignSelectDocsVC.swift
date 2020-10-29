//
//  AssignSelectDocsVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 23.10.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import CoreData

class CustomSelectDocsCell: UITableViewCell {
    static let identifier: String = "CustomSelectDocsCell"

    var label: UILabel!
    var switcher: SwitchForDocs!
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configure()
    }

    func configure() {
        self.backgroundColor = .secondarySystemBackground
        label = UILabel(frame: .zero)
        switcher = SwitchForDocs(frame: .zero)
        switcher.onTintColor = .mediumSlateBlue
        let stackView = UIStackView()
        stackView.insertArrangedSubview(label, at: 0)
        stackView.insertArrangedSubview(switcher, at: 1)
        self.contentView.addSubview(stackView)
       
        stackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
        }
         
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AssignSelectDocs: UIViewController, NSFetchedResultsControllerDelegate {
    
    //MARK: - PROPERTIES
    let docsTableView = UITableView()
    let subtitle = UILabel()
    let nextButton = NextButton()
    var dataSource: UITableViewDiffableDataSource<Int, SkDocument>?
    var snapshot = NSDiffableDataSourceSnapshot<Int, SkDocument>()
    var selectedProject: SkProject!
    var docsFRC: NSFetchedResultsController<SkDocument>!
    var stageNumber: Int!
    var selectedDocumentsIds = [String]()
    var documentIsSelected = false
    var selectAllLabel = UILabel()
    var selectAllSwitcher = UISwitch()
    let selectAllStackView = UIStackView()
    
    //MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDocsFRC()
    }
    
    //MARK: - VIEW DID DISAPPEAR
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        docsFRC = nil
    }
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupDocsFRC()
        setupSelectAllView()
        addTableviewConstraints()
        setupTitle()
        setupSubtitle()
        setupTableView()
        setupNextButton()
        addActionToNextButton()
        
        //self.edgesForExtendedLayout = []
        
        
    }
    
    //MARK: - SETUP TITLE
    
    func setupTitle() {
        navigationItem.title = "Assign"
    }
    
    //MARK: - SETUP VIEW
    
    func setupView() {
        view.addSubview(subtitle)
        view.addSubview(docsTableView)
        view.addSubview(nextButton)
        
        selectAllLabel.text = "Select all"
        selectAllSwitcher.onTintColor = .mediumSlateBlue
        selectAllSwitcher.addTarget(self, action: #selector(selectAllTapped(_:)), for: .valueChanged)
        selectAllStackView.insertArrangedSubview(selectAllLabel, at: 0)
        selectAllStackView.insertArrangedSubview(selectAllSwitcher, at: 1)
        view.addSubview(selectAllStackView)
        
        view.backgroundColor = .systemBackground
    }
    
    //MARK: - SETUP SELECT ALL VIEW
    func setupSelectAllView() {
        selectAllStackView.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(self.subtitle.snp.bottom).offset(24)
            //make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    @objc func selectAllTapped(_ sender: UISwitch!) {
        changeSelection(isOn: sender.isOn)
    }
    
    func changeSelection(isOn: Bool) {
        let numberOfRows = docsTableView.numberOfRows(inSection: 0)
        let arr = Array(0...(numberOfRows-1))
        for i in arr {
            let index = IndexPath(row: i, section: 0)
            let cell = docsTableView.cellForRow(at: index) as! CustomSelectDocsCell
            cell.switcher.isOn = isOn
            guard let docId = cell.switcher.documentId else {
                return
            }
            if cell.switcher.isOn == true {
                //Remove to avoid duplicates
                selectedDocumentsIds.removeAll(where: {$0 == docId})
                selectedDocumentsIds.append(docId)
            } else {
                selectedDocumentsIds.removeAll(where: {$0 == docId})
            }
        }
        if selectedDocumentsIds != [] {
            documentIsSelected = true
        } else {
            documentIsSelected = false
        }
        print(selectedDocumentsIds)
    }
    
    //MARK: - SETUP SUBTITLE
    func setupSubtitle() {
        subtitle.text = "SELECT DOCUMENT(S)"
        subtitle.font = .preferredFont(forTextStyle: .headline)
        //subtitle.font = .boldSystemFont(ofSize: 20)
        subtitle.adjustsFontForContentSizeCategory = true
        subtitle.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(24)
            //make.bottom.equalTo(self.stagesTableView.snp.top).offset(24)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(20)
        }
    }
    
    //MARK: - SETUP NEXT BUTTON
    
    func setupNextButton() {
        
        nextButton.setTitle("Next", for: .normal)
        //nextButton.backgroundColor = .mediumSlateBlue
        nextButton.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.top.equalTo(self.docsTableView.snp.bottom)
            make.height.equalTo(50)
        }
    }
    
    func addActionToNextButton() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    @objc func nextButtonTapped() {
        
        if documentIsSelected == true {
            //Access presenting VC and store selected stage
            let parentVC = self.presentingViewController as! TabBarVC
            let childOfTab = parentVC.children[0]
            let childrenOfNav = childOfTab.children
            let projectInfoVC = childrenOfNav[2] as! ProjectInfoVC
            projectInfoVC.selectedDocumentsIds = self.selectedDocumentsIds
            //Dismiss current VC and post Notification to present next VC
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: .didSelectedDocumentsForAssignment, object: nil)
            }
        } else {
            let alert = Alerts.errorAlert(title: "No document is selected", message: "Please select a document")
            present(alert, animated: true)
        }
        
        
    }
    
    //MARK SETUP TABLE VIEW
    func addTableviewConstraints() {
        
        docsTableView.backgroundColor = .systemBackground
        docsTableView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.selectAllStackView.snp.bottom).offset(12)
            make.bottom.equalTo(nextButton.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        
        docsTableView.register(CustomSelectDocsCell.self, forCellReuseIdentifier: "CustomSelectDocsCell")
        //Add footer to remove empty rows at the end
        docsTableView.tableFooterView = UIView(frame: .zero)
        dataSource = UITableViewDiffableDataSource<Int, SkDocument>(tableView: docsTableView) { (tableView, indexPath, doc) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomSelectDocsCell", for: indexPath) as! CustomSelectDocsCell
            
            //let stage = ProjectStage(caseName: line.stageType ?? "Project has no stages")
            cell.label.text = doc.name
            cell.switcher.documentId = doc.id
            cell.switcher.setOn(false, animated: true)
            cell.switcher.tag = indexPath.row
            cell.switcher.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            
            cell.selectionStyle = .none
            return cell
        }
        setupSnapshot()
    }
    
    private func setupSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot<Int, SkDocument>()
        snapshot.appendSections([0])
        snapshot.appendItems(docsFRC.fetchedObjects ?? [])
        dataSource?.apply(self.snapshot, animatingDifferences: false)
    }
    
    @objc func switchChanged(_ sender: SwitchForDocs!) {
        print("switch changed to \(sender.tag)")
        stageNumber = 0
        
        guard let docId = sender.documentId else {
            return
        }
        
        if sender.isOn == true {
            selectedDocumentsIds.append(docId)
        } else {
            selectedDocumentsIds.removeAll(where: {$0 == docId})
        }
        
        if selectedDocumentsIds != [] {
            documentIsSelected = true
        } else {
            documentIsSelected = false
        }
        
        print(selectedDocumentsIds)
        
    }
    
    //MARK: - SETUP DOCS FRC
    fileprivate func setupDocsFRC() {
        let docFetchRequest: NSFetchRequest<SkDocument> = SkDocument.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "wordsCount", ascending: false)
        docFetchRequest.sortDescriptors = [sortDescriptor]
        let stagePredicate = NSPredicate(format: "project == %@", selectedProject)
        docFetchRequest.predicate = stagePredicate
        docsFRC = NSFetchedResultsController(fetchRequest: docFetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        docsFRC.delegate = self
        do {
            try docsFRC.performFetch()
            //setupSnapshot()
        } catch {
            fatalError("The fetch for project stages could not be performed: \(error.localizedDescription)")
        }
    }
    
}
