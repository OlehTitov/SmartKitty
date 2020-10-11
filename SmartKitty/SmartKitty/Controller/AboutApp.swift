//
//  AboutApp.swift
//  SmartKitty
//
//  Created by Oleh Titov on 06.10.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class AboutApp: UIViewController, UITableViewDelegate {
    
    //MARK: - PROPERTIES
    var dataSource: UITableViewDiffableDataSource<Int, AboutRow>?
    var snapshot = NSDiffableDataSourceSnapshot<Int, AboutRow>()
    var rows = [
        AboutRow(title: "Privacy Policy", tag: "PrivacyPolicyVC"),
        AboutRow(title: "Send feedback", tag: "SendFeddback"),
        //AboutRow(title: "Share", tag: "Share"),
        AboutRow(title: "Developer", tag: "DeveloperVC")
    ]
    
    
    //MARK: _ OUTLETS
    
    @IBOutlet weak var aboutTable: UITableView!
    
    //MARK:- VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        self.aboutTable.delegate = self
        setupTableView()
        //Add footer to remove empty rows at the end
        aboutTable.tableFooterView = UIView(frame: .zero)
    }
    
    //MARK: - SETUP VIEW
    func setupNavbar() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    func hideNavBar(_ hidden: Bool) {
        tabBarController?.tabBar.isTranslucent = hidden
        tabBarController?.tabBar.isHidden = hidden
    }
    
    // MARK: - TABLE VIEW SETUP
    private func setupTableView() {
        dataSource = UITableViewDiffableDataSource<Int, AboutRow>(tableView: aboutTable) { (tableView, indexPath, line) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath)
            cell.textLabel?.text = line.title
            
            return cell
        }
        setupSnapshot()
    }
    
    private func setupSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot<Int, AboutRow>()
        snapshot.appendSections([0])
        snapshot.appendItems(rows)
        dataSource?.apply(self.snapshot, animatingDifferences: false)
    }
    
    //MARK: - DID SELECT PROJECT
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedRow = dataSource?.itemIdentifier(for: indexPath) {
            let aboutRowTitle = AboutRowTitle(rawValue: selectedRow.title)!
            switch aboutRowTitle {
            case .privacyPolicy:
                let nextVC = self.storyboard?.instantiateViewController(identifier: selectedRow.tag)
                self.navigationController?.pushViewController(nextVC!, animated: true)
            case .feedback:
                showMailComposer()
            case .share:
                print(selectedRow)
            case .developer:
                let nextVC = self.storyboard?.instantiateViewController(identifier: selectedRow.tag)
                self.navigationController?.pushViewController(nextVC!, animated: true)
            }
            
        }
    }
    
    func showMailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            //Show alert to user
            let alert = Alerts.errorAlert(title: AlertTitles.undefinedError.rawValue, message: AlertMessages.unableToSendEmail.rawValue)
            present(alert, animated: true)
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["oleg.titov81@gmail.com"])
        composer.setSubject("SmartKitty feedback")
        composer.setMessageBody("I like your app, but ...", isHTML: false)
        present(composer, animated: true)
        
    }
}

extension AboutApp: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            let alert = Alerts.errorAlert(title: AlertTitles.undefinedError.rawValue, message: AlertMessages.errorSendingEmail.rawValue)
            present(alert, animated: true)
            controller.dismiss(animated: true)
            return
        }
        
        switch result {
        case .cancelled:
            print("Feedback email canceled")
        case .failed:
            print("Feedback email failed")
        case .saved:
            print("Feedback email saved")
        case .sent:
            print("Feedback email sent")
            let alertSent = Alerts.errorAlert(title: AlertTitles.thankYou.rawValue, message: AlertMessages.feedback.rawValue)
            present(alertSent, animated: true)
        @unknown default:
            print("Unknown case of sending feedback message")
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
