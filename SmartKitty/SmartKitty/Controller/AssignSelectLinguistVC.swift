//
//  AssignSelectLinguistVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 27.10.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SnapKit

class CustomSelectLinguistCell: UITableViewCell {
    static let identifier: String = "CustomSelectLinguistCell"

    var name: UILabel!
    var rate: UILabel!
    var switcher: SwitchForLinguists!
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configure()
    }

    func configure() {
        self.backgroundColor = .secondarySystemBackground
        name = UILabel(frame: .zero)
        rate = UILabel(frame: .zero)
        switcher = SwitchForLinguists(frame: .zero)
        switcher.onTintColor = .mediumSlateBlue
        let stackView = UIStackView()
        stackView.insertArrangedSubview(name, at: 0)
        stackView.insertArrangedSubview(rate, at: 1)
        stackView.insertArrangedSubview(switcher, at: 2)
        stackView.setCustomSpacing(12.0, after: rate)
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


class AssignSelectLinguistVC: UIViewController {
    
    //MARK: - PROPERTIES
    var sourceLang = ""
    var targetLang = ""
    var serviceType = ""
    var listOfLinguists = [MyTeam]()
    let subtitle = UILabel()
    let linguistsTableView = UITableView()
    var dataSource: UITableViewDiffableDataSource<Int, MyTeam>?
    var snapshot = NSDiffableDataSourceSnapshot<Int, MyTeam>()
    let indicator = UIActivityIndicatorView()
    let nextButton = NextButton()
    var selectedLinguistsIds = [String]()
    var linguistsAreSelected = false
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNetworkActivityIndicator()
        setupSubtitle()
        getListOfLinguists()
        addTableviewConstraints()
        setupTableView()
        setupNextButton()
        print("Number of linguists: \(listOfLinguists.count)")
    }
    
    //MARK: - SETUP VIEW
    
    func setupView() {
        view.addSubview(subtitle)
        view.addSubview(linguistsTableView)
        view.addSubview(indicator)
        view.addSubview(nextButton)
        view.backgroundColor = .systemBackground
    }
    
    //MARK: - SETUP SUBTITLE
    func setupSubtitle() {
        subtitle.text = "SELECT LINGUIST(S)"
        subtitle.font = .preferredFont(forTextStyle: .headline)
        subtitle.adjustsFontForContentSizeCategory = true
        subtitle.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(24)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(20)
        }
    }
    
    //MARK: - SETUP INDICATOR
    func setupNetworkActivityIndicator() {
        indicator.snp.makeConstraints { (make) -> Void in
            make.center.equalToSuperview()
        }
        indicator.hidesWhenStopped = true
        indicator.tintColor = .label
        indicator.style = .medium
        indicator.startAnimating()
    }
    
    //MARK: - GET LIST OF LINGUISTS
    
    func getListOfLinguists() {
        print("Making network request")
        let request = SearchMyTeam(skip: 0, limit: 50, serviceType: serviceType, sourceLanguage: sourceLang, targetLanguage: targetLang, onlyNativeSpeakers: false, allDialects: true, minRate: 0.0, maxRate: 1000.0, rateRangeCurrency: "usd", specializations: [], specializationKnowledgeLevel: [], searchString: "", daytime: nil)
        SCClient.searchMyTeam(method: "POST", searchRequest: request, completion: handleGetListOfLinguists(response:error:))
    }
    
    func handleGetListOfLinguists(response: [MyTeam]?, error: Error?) {
        print("Handling network request")
        guard let response = response else {
            return
        }
        print(response)
        listOfLinguists.append(contentsOf: response)
        setupSnapshot()
        indicator.stopAnimating()
    }
    
    //MARK: - SETUP TABLE VIEW
    func addTableviewConstraints() {
        
        linguistsTableView.backgroundColor = .systemBackground
        linguistsTableView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.subtitle.snp.bottom).offset(12)
            //make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        
        linguistsTableView.register(CustomSelectLinguistCell.self, forCellReuseIdentifier: "CustomSelectLinguistCell")
        //Add footer to remove empty rows at the end
        linguistsTableView.tableFooterView = UIView(frame: .zero)
        dataSource = UITableViewDiffableDataSource<Int, MyTeam>(tableView: linguistsTableView) { (tableView, indexPath, linguist) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomSelectLinguistCell", for: indexPath) as! CustomSelectLinguistCell
            
            cell.name.text = "\(linguist.lastName ?? "") \(linguist.firstName ?? "")"
            print("Linguist last name is: \(linguist.lastName ?? "")")
            let services = linguist.services
            if let service = services?.first(where: {$0.serviceType == self.serviceType}) {
                let price = service.pricePerUnit ?? 0.0
                let priceAsString = String(price)
                let currency = service.currency ?? "N/A"
                cell.rate.text = "\(priceAsString) \(currency.uppercased())"
            }
            
            cell.switcher.linguistsId = linguist.id
            cell.switcher.setOn(false, animated: true)
            cell.switcher.tag = indexPath.row
            cell.switcher.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            
            cell.selectionStyle = .none
            return cell
        }
        setupSnapshot()
    }
    
    func setupSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot<Int, MyTeam>()
        snapshot.appendSections([0])
        snapshot.appendItems(listOfLinguists)
        dataSource?.apply(self.snapshot, animatingDifferences: false)
    }
    
    @objc func switchChanged(_ sender: SwitchForLinguists!) {
        guard let linguistId = sender.linguistsId else {
            return
        }
        
        if sender.isOn == true {
            selectedLinguistsIds.append(linguistId)
        } else {
            selectedLinguistsIds.removeAll(where: {$0 == linguistId})
        }
        
        if selectedLinguistsIds != [] {
            linguistsAreSelected = true
        } else {
            linguistsAreSelected = false
        }
        
        print(selectedLinguistsIds)
        
    }
    
       //MARK: - SETUP NEXT BUTTON
       
       func setupNextButton() {
           
           nextButton.setTitle("Next", for: .normal)
           //nextButton.backgroundColor = .mediumSlateBlue
           nextButton.snp.makeConstraints { (make) -> Void in
               make.left.equalToSuperview()
               make.right.equalToSuperview()
               make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
               make.top.equalTo(self.linguistsTableView.snp.bottom)
               make.height.equalTo(50)
           }
       }
       
       func addActionToNextButton() {
           nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
       }
       
       @objc func nextButtonTapped() {
        
           if linguistsAreSelected == true {
               //Access presenting VC and store selected linguists
               let parentVC = self.presentingViewController as! TabBarVC
               let childOfTab = parentVC.children[0]
               let childrenOfNav = childOfTab.children
               let projectInfoVC = childrenOfNav[2] as! ProjectInfoVC
            projectInfoVC.selectedLinguistsIds = self.selectedLinguistsIds
               //Dismiss current VC and post Notification to present next VC
               self.dismiss(animated: true) {
                NotificationCenter.default.post(name: .didSelectedLinguistsForAssignment, object: nil)
               }
           } else {
               let alert = Alerts.errorAlert(title: "No linguist is selected", message: "Please select a linguist")
               present(alert, animated: true)
           }
        
       }
 
 
}
