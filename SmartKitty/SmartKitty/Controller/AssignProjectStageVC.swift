//
//  AssignProjectStageVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 11.10.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import CoreData

class CustomStageCell: UITableViewCell {
    static let identifier: String = "CustomStageCell"

    var label: UILabel!
    var switcher: UISwitch!
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configure()
    }

    func configure() {
        self.backgroundColor = .secondarySystemBackground
        label = UILabel(frame: .zero)
        switcher = UISwitch(frame: .zero)
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

class AssignProjectStage: UIViewController, NSFetchedResultsControllerDelegate {
    
    //MARK: - PROPERTIES
    let stagesTableView = UITableView()
    let subtitle = UILabel()
    let nextButton = NextButton()
    var dataSource: UITableViewDiffableDataSource<Int, SkProjectWorkflowStage>?
    var snapshot = NSDiffableDataSourceSnapshot<Int, SkProjectWorkflowStage>()
    var selectedProject: SkProject!
    var stageFRC: NSFetchedResultsController<SkProjectWorkflowStage>!
    var stageNumber: Int!
    var stageIsSelected = false
    
    //MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupStageFRC()
    }
    
    //MARK: - VIEW DID DISAPPEAR
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stageFRC = nil
    }
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStageFRC()
        addTableviewConstraints()
        setupTitle()
        setupSubtitle()
        addCancelButton()
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
        view.addSubview(stagesTableView)
        view.addSubview(nextButton)
        
        view.backgroundColor = .systemBackground
    }
    
    //MARK: - SETUP SUBTITLE
    func setupSubtitle() {
        subtitle.text = "SELECT THE STAGE"
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
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(-24)
            make.top.equalTo(self.stagesTableView.snp.bottom)
            make.height.equalTo(50)
        }
    }
    
    func addActionToNextButton() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    @objc func nextButtonTapped() {
        
        if stageIsSelected == true {
            //Access presenting VC and store selected stage
            let parentVC = self.presentingViewController as! TabBarVC
            let childOfTab = parentVC.children[0]
            let childrenOfNav = childOfTab.children
            let projectInfoVC = childrenOfNav[2] as! ProjectInfoVC
            projectInfoVC.selectedStage = self.stageNumber
            //Dismiss current VC and post Notification to present next VC
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: .didSelectedProjectStageForAssignment, object: nil)
            }
        } else {
            let alert = Alerts.errorAlert(title: "No stage is selected", message: "Please select a stage")
            present(alert, animated: true)
        }
        
        
    }
    
    //MARK SETUP TABLE VIEW
    func addTableviewConstraints() {
        
        stagesTableView.backgroundColor = .systemBackground
        stagesTableView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.subtitle.snp.bottom).offset(12)
            make.bottom.equalTo(nextButton.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        
        stagesTableView.register(CustomStageCell.self, forCellReuseIdentifier: "CustomStageCell")
        //Add footer to remove empty rows at the end
        stagesTableView.tableFooterView = UIView(frame: .zero)
        dataSource = UITableViewDiffableDataSource<Int, SkProjectWorkflowStage>(tableView: stagesTableView) { (tableView, indexPath, line) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomStageCell", for: indexPath) as! CustomStageCell
            
            let stage = ProjectStage(caseName: line.stageType ?? "Project has no stages")
            cell.label.text = stage?.description
            
            cell.switcher.setOn(false, animated: true)
            cell.switcher.tag = indexPath.row
            cell.switcher.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            
            cell.selectionStyle = .none
            return cell
        }
        setupSnapshot()
    }
    
    private func setupSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot<Int, SkProjectWorkflowStage>()
        snapshot.appendSections([0])
        snapshot.appendItems(stageFRC.fetchedObjects ?? [])
        dataSource?.apply(self.snapshot, animatingDifferences: false)
    }
    
    @objc func switchChanged(_ sender: UISwitch!) {
        print("switch changed to \(sender.tag)")
        stageNumber = 0
        if sender.isOn == true {
            stageIsSelected = true
            stageNumber = sender.tag + 1
        } else {
            stageIsSelected = false
        }
        let numberOfRows = stagesTableView.numberOfRows(inSection: 0)
        var arr = Array(0...(numberOfRows-1))
        arr.remove(at: sender.tag)
        //turn off the switch for other stages in the table
        for i in arr {
            let index = IndexPath(row: i, section: 0)
            let cell = stagesTableView.cellForRow(at: index) as! CustomStageCell
            cell.switcher.isOn = false
        }
    }
    
    //MARK: - SETUP STAGE FRC
    fileprivate func setupStageFRC() {
        let stageFetchRequest: NSFetchRequest<SkProjectWorkflowStage> = SkProjectWorkflowStage.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "stageNumber", ascending: true)
        stageFetchRequest.sortDescriptors = [sortDescriptor]
        let stagePredicate = NSPredicate(format: "project == %@", selectedProject)
        stageFetchRequest.predicate = stagePredicate
        stageFRC = NSFetchedResultsController(fetchRequest: stageFetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        stageFRC.delegate = self
        do {
            try stageFRC.performFetch()
            //setupSnapshot()
        } catch {
            fatalError("The fetch for project stages could not be performed: \(error.localizedDescription)")
        }
    }
    
    //MARK: - ADD CANCEL BUTTON
    func addCancelButton() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        self.navigationItem.rightBarButtonItem = cancelButton
    }
    
    @objc func cancelTapped() {
        print("cancel button tapped")
        
    }
}
