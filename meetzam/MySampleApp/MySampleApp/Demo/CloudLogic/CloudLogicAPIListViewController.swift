//
//  CloudLogicAPIListViewController.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.10
//

import Foundation
import UIKit

class CloudLogicAPIListViewController: UITableViewController {
    
    fileprivate var cloudLogicAPIs: [CloudLogicAPI]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        cloudLogicAPIs = CloudLogicAPIFactory.supportedCloudLogicAPIs
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let cloudLogicAPIs = cloudLogicAPIs else {return 0}
        return cloudLogicAPIs.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CloudLogicAPITableCell", for: indexPath) as! CloudLogicAPITableCell
        let cloudLogicAPI = cloudLogicAPIs![indexPath.section]
        cell.cloudLogicAPIName.text = cloudLogicAPI.displayName
        cell.cloudLogicAPIDescription.text = ""
        if let apiDescription = cloudLogicAPI.apiDescription {
            cell.cloudLogicAPIDescription.text = apiDescription
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let showDetailsSegue = "CloudLogicAPIShowDetailsSegue"
        performSegue(withIdentifier: showDetailsSegue, sender: cloudLogicAPIs![indexPath.section])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? CloudLogicAPIOperationsViewController {
            destinationViewController.cloudLogicAPI = sender as? CloudLogicAPI
        }
    }
}

class CloudLogicAPITableCell: UITableViewCell {
    @IBOutlet weak var cloudLogicAPIName: UILabel!
    @IBOutlet weak var cloudLogicAPIDescription: UILabel!
    
}
