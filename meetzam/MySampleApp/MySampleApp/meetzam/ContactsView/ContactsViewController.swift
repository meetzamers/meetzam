//
//  ContactsViewController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/21/17.
//  Monika Qi Meng
//

import UIKit
import AWSMobileHubHelper

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    var contacts = [contact]()
    
    @IBOutlet weak var contactTable: UITableView!
    
    
    var resultsController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
    
        loadContact()

        //set search bar
        self.resultsController = UISearchController(searchResultsController: nil)
        self.resultsController.searchResultsUpdater = self
        
        self.resultsController.dimsBackgroundDuringPresentation = false
        self.resultsController.searchBar.sizeToFit()
        
        self.contactTable.tableHeaderView = self.resultsController.searchBar
        contactTable.reloadData()
        
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        contactTable.reloadData()
    }
    
    //what happen when seach happens
    var filteredNames = [contact]()
    func updateSearchResults(for searchController: UISearchController) {
        //filter throught the names
        filteredNames.removeAll(keepingCapacity: false)
        
        //let searchPredicate = NSPredicate(format:"SELF CONTAINS[c] %@", searchController.searchBar.text!)
        
        filteredNames = contacts.filter{ person in
            return person.displayName.lowercased().contains(searchController.searchBar.text!.lowercased())
        }
        
        
        self.contactTable.reloadData()
        

    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {

        if self.resultsController.isActive {
            return self.filteredNames.count
        } else {
            return contacts.count
        }
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactCell
        cell.displayName.font = UIFont(name: "HelveticaNeue-Light", size: 22)
        
        if (!self.resultsController.isActive) {
            cell.profilePicture.image = contacts[indexPath.row].profilePic
            cell.displayName.text = contacts[indexPath.row].displayName
        } else {
            cell.profilePicture.image = filteredNames[indexPath.row].profilePic
            cell.displayName.text = filteredNames[indexPath.row].displayName
        }
        return cell
    }
    
    func loadContact() {

        let matchedUserIDs = UserProfileToDB().getPotentialUserIDs(key: AWSIdentityManager.default().identityId!)
        let matchedUsers = UserProfileToDB().getUserProfileByIds(userIDs: matchedUserIDs)
        
        for matchedUser in matchedUsers
        {
            let newContact = contact()
            
            
            //add names to the new contact
            newContact.displayName = matchedUser.displayName!
            //add profile pic to new contact
            newContact.profilePic = getProfilePic(userId: matchedUser.userId!)
            
            //add new contact to contacs
            contacts.append(newContact)
            
        }
        
    }
    
    func getProfilePic(userId: String)->UIImage {
        let URLString = UserProfileToDB().downloadUserIcon(userID: userId).path
        
        if FileManager.default.fileExists(atPath: URLString) {
            print("The file exists!! \(userId)")
            let profileURL = URL(fileURLWithPath: URLString)
            return UIImage(contentsOfFile: profileURL.path)!
        } else {
            return #imageLiteral(resourceName: "emptyMovie")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "showProfile" {
            return
        }
    
        let indexPaths = self.contactTable!.indexPathForSelectedRow!
        let indexPath = indexPaths[1]
        print("the index Paths is \(indexPaths)")
        let vc = segue.destination as! ContactProfile
        
        // load everything in profile page!
        vc.displayName.text = contacts[indexPath].displayName
        vc.userPicField.image = contacts[indexPath].profilePic
        //vc.userBioField.text =
        //vc.moviePic1.image = #imageLiteral(resourceName: "split")
        //vc.moviePic2.image = #imageLiteral(resourceName: "split")
        //vc.moviePic3.image = #imageLiteral(resourceName: "split")
        //vc.moviePic4.image = #imageLiteral(resourceName: "split")
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            self.contacts.remove(at:indexPath.row)
            
            //call DB function to delete the contact
            // XXXXXX
            
            contactTable.reloadData()
        }
    }
    
    
}

class contact {
    var displayName = String()
    var profilePic = UIImage()
}
